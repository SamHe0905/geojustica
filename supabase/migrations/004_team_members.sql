-- GeoJustiça - Equipe do painel administrativo
--
-- Substitui a senha única hardcoded no cliente (AdminAuth._password) por contas
-- reais de usuário. Regras:
--   * "dono"   -> gerencia a equipe (criar, editar, trocar senha, remover)
--   * "membro" -> entra no painel e edita órgãos/denúncias, mas não vê a equipe
--
-- As tabelas ficam FECHADAS para anon/authenticated (RLS ligada, sem policies).
-- Todo acesso passa pelas funções security definer abaixo, então o hash da senha
-- nunca sai do banco.

create extension if not exists pgcrypto with schema extensions;

-- ============================================================
-- TABELAS
-- ============================================================

create table if not exists public.team_members (
  id            uuid primary key default gen_random_uuid(),
  username      text not null unique,
  name          text not null,
  password_hash text not null,
  role          text not null default 'membro' check (role in ('dono', 'membro')),
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  last_login_at timestamptz
);

create table if not exists public.team_sessions (
  token      uuid primary key default gen_random_uuid(),
  member_id  uuid not null references public.team_members (id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '30 days'
);

create index if not exists team_sessions_member_idx on public.team_sessions (member_id);
create index if not exists team_sessions_expires_idx on public.team_sessions (expires_at);

alter table public.team_members  enable row level security;
alter table public.team_sessions enable row level security;
-- Sem policies de propósito: ninguém lê/escreve direto via API.

-- ============================================================
-- HELPER INTERNO (não exposto ao cliente)
-- ============================================================

-- Resolve o membro dono de um token válido. Devolve linha NULL se o token
-- não existir, estiver expirado ou o membro estiver desativado.
create or replace function public.team_session_member(p_token uuid)
returns public.team_members
language sql
stable
security definer
set search_path = public, extensions
as $$
  select m.*
    from public.team_sessions s
    join public.team_members  m on m.id = s.member_id
   where s.token = p_token
     and s.expires_at > now()
     and m.is_active;
$$;

-- Essa função devolve o password_hash: só as outras funções podem chamá-la.
revoke all on function public.team_session_member(uuid) from public, anon, authenticated;

-- ============================================================
-- SESSÃO
-- ============================================================

create or replace function public.team_login(p_username text, p_password text)
returns json
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_member public.team_members;
  v_token  uuid;
begin
  select * into v_member
    from public.team_members
   where username = lower(trim(coalesce(p_username, '')))
     and is_active;

  if v_member.id is null then
    return null;
  end if;

  if v_member.password_hash <> crypt(coalesce(p_password, ''), v_member.password_hash) then
    return null;
  end if;

  delete from public.team_sessions where expires_at < now();

  insert into public.team_sessions (member_id)
  values (v_member.id)
  returning token into v_token;

  update public.team_members set last_login_at = now() where id = v_member.id;

  return json_build_object(
    'token',    v_token,
    'id',       v_member.id,
    'username', v_member.username,
    'name',     v_member.name,
    'role',     v_member.role
  );
end;
$$;

-- Revalida um token guardado no navegador (usado ao abrir o painel).
create or replace function public.team_me(p_token uuid)
returns json
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_member public.team_members;
begin
  select * into v_member from public.team_session_member(p_token);
  if v_member.id is null then
    return null;
  end if;

  return json_build_object(
    'token',    p_token,
    'id',       v_member.id,
    'username', v_member.username,
    'name',     v_member.name,
    'role',     v_member.role
  );
end;
$$;

create or replace function public.team_logout(p_token uuid)
returns void
language sql
security definer
set search_path = public, extensions
as $$
  delete from public.team_sessions where token = p_token;
$$;

-- ============================================================
-- GESTÃO DA EQUIPE (apenas o dono)
-- ============================================================

create or replace function public.team_list(p_token uuid)
returns json
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_actor  public.team_members;
  v_result json;
begin
  select * into v_actor from public.team_session_member(p_token);
  if v_actor.id is null then
    raise exception 'Sessão inválida ou expirada. Entre novamente.';
  end if;
  if v_actor.role <> 'dono' then
    raise exception 'Apenas o dono pode ver a equipe.';
  end if;

  select coalesce(json_agg(x order by x.created_at), '[]'::json)
    into v_result
    from (
      select id, username, name, role, is_active, created_at, last_login_at
        from public.team_members
    ) x;

  return v_result;
end;
$$;

create or replace function public.team_create(
  p_token    uuid,
  p_username text,
  p_name     text,
  p_password text,
  p_role     text default 'membro'
)
returns json
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_actor public.team_members;
  v_user  text := lower(trim(coalesce(p_username, '')));
  v_name  text := trim(coalesce(p_name, ''));
  v_id    uuid;
begin
  select * into v_actor from public.team_session_member(p_token);
  if v_actor.id is null then
    raise exception 'Sessão inválida ou expirada. Entre novamente.';
  end if;
  if v_actor.role <> 'dono' then
    raise exception 'Apenas o dono pode criar membros.';
  end if;

  if v_user !~ '^[a-z0-9._-]{3,32}$' then
    raise exception 'Usuário deve ter de 3 a 32 caracteres, usando apenas letras minúsculas, números, ponto, hífen ou underline.';
  end if;
  if v_name = '' then
    raise exception 'Informe o nome do membro.';
  end if;
  if length(coalesce(p_password, '')) < 6 then
    raise exception 'A senha precisa ter pelo menos 6 caracteres.';
  end if;
  if p_role not in ('dono', 'membro') then
    raise exception 'Papel inválido.';
  end if;
  if exists (select 1 from public.team_members where username = v_user) then
    raise exception 'Já existe um membro com o usuário "%".', v_user;
  end if;

  insert into public.team_members (username, name, password_hash, role)
  values (v_user, v_name, crypt(p_password, gen_salt('bf', 10)), p_role)
  returning id into v_id;

  return json_build_object(
    'id', v_id, 'username', v_user, 'name', v_name,
    'role', p_role, 'is_active', true
  );
end;
$$;

create or replace function public.team_update(
  p_token     uuid,
  p_id        uuid,
  p_name      text,
  p_role      text,
  p_is_active boolean
)
returns json
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_actor  public.team_members;
  v_target public.team_members;
  v_name   text := trim(coalesce(p_name, ''));
begin
  select * into v_actor from public.team_session_member(p_token);
  if v_actor.id is null then
    raise exception 'Sessão inválida ou expirada. Entre novamente.';
  end if;
  if v_actor.role <> 'dono' then
    raise exception 'Apenas o dono pode editar membros.';
  end if;

  select * into v_target from public.team_members where id = p_id;
  if v_target.id is null then
    raise exception 'Membro não encontrado.';
  end if;
  if v_name = '' then
    raise exception 'Informe o nome do membro.';
  end if;
  if p_role not in ('dono', 'membro') then
    raise exception 'Papel inválido.';
  end if;

  if v_target.id = v_actor.id and (p_role <> 'dono' or p_is_active is false) then
    raise exception 'Você não pode rebaixar nem desativar a própria conta.';
  end if;

  -- Nunca deixar o sistema sem nenhum dono ativo.
  if v_target.role = 'dono' and v_target.is_active
     and (p_role <> 'dono' or p_is_active is false)
     and (select count(*) from public.team_members where role = 'dono' and is_active) <= 1 then
    raise exception 'Precisa existir pelo menos um dono ativo.';
  end if;

  update public.team_members
     set name       = v_name,
         role       = p_role,
         is_active  = coalesce(p_is_active, true),
         updated_at = now()
   where id = p_id;

  -- Membro desativado perde as sessões abertas na hora.
  if p_is_active is false then
    delete from public.team_sessions where member_id = p_id;
  end if;

  return json_build_object(
    'id', p_id, 'username', v_target.username, 'name', v_name,
    'role', p_role, 'is_active', coalesce(p_is_active, true)
  );
end;
$$;

-- O dono troca a senha de qualquer um; o membro só troca a própria.
create or replace function public.team_set_password(
  p_token    uuid,
  p_id       uuid,
  p_password text
)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_actor public.team_members;
begin
  select * into v_actor from public.team_session_member(p_token);
  if v_actor.id is null then
    raise exception 'Sessão inválida ou expirada. Entre novamente.';
  end if;
  if v_actor.role <> 'dono' and v_actor.id <> p_id then
    raise exception 'Você só pode trocar a própria senha.';
  end if;
  if length(coalesce(p_password, '')) < 6 then
    raise exception 'A senha precisa ter pelo menos 6 caracteres.';
  end if;
  if not exists (select 1 from public.team_members where id = p_id) then
    raise exception 'Membro não encontrado.';
  end if;

  update public.team_members
     set password_hash = crypt(p_password, gen_salt('bf', 10)),
         updated_at    = now()
   where id = p_id;

  -- Derruba as outras sessões desse membro (a atual continua válida).
  delete from public.team_sessions where member_id = p_id and token <> p_token;
end;
$$;

create or replace function public.team_delete(p_token uuid, p_id uuid)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_actor  public.team_members;
  v_target public.team_members;
begin
  select * into v_actor from public.team_session_member(p_token);
  if v_actor.id is null then
    raise exception 'Sessão inválida ou expirada. Entre novamente.';
  end if;
  if v_actor.role <> 'dono' then
    raise exception 'Apenas o dono pode remover membros.';
  end if;
  if v_actor.id = p_id then
    raise exception 'Você não pode remover a própria conta.';
  end if;

  select * into v_target from public.team_members where id = p_id;
  if v_target.id is null then
    raise exception 'Membro não encontrado.';
  end if;

  if v_target.role = 'dono' and v_target.is_active
     and (select count(*) from public.team_members where role = 'dono' and is_active) <= 1 then
    raise exception 'Precisa existir pelo menos um dono ativo.';
  end if;

  delete from public.team_members where id = p_id;
end;
$$;

-- ============================================================
-- PERMISSÕES
-- ============================================================

grant execute on function public.team_login(text, text)                      to anon, authenticated;
grant execute on function public.team_me(uuid)                               to anon, authenticated;
grant execute on function public.team_logout(uuid)                           to anon, authenticated;
grant execute on function public.team_list(uuid)                             to anon, authenticated;
grant execute on function public.team_create(uuid, text, text, text, text)   to anon, authenticated;
grant execute on function public.team_update(uuid, uuid, text, text, boolean) to anon, authenticated;
grant execute on function public.team_set_password(uuid, uuid, text)         to anon, authenticated;
grant execute on function public.team_delete(uuid, uuid)                     to anon, authenticated;

-- ============================================================
-- CONTA INICIAL DO DONO
-- ============================================================
-- Reaproveita a senha que já era usada no painel. TROQUE depois do primeiro
-- login, pela própria aba "Equipe".
insert into public.team_members (username, name, password_hash, role)
values (
  'admin',
  'Administrador',
  crypt('geojustica2026', gen_salt('bf', 10)),
  'dono'
)
on conflict (username) do nothing;
