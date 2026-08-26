-- GeoJustiça - Setup inicial do dono + limpeza do seed comprometido
--
-- Substitui a conta semeada 'admin' / 'geojustica2026' (que ficava com senha
-- fixa no SQL versionado) por um fluxo de PRIMEIRO ACESSO: enquanto não existe
-- nenhum dono ativo, o app mostra uma tela de setup que cria o primeiro dono.
-- Depois disso, o acesso é sempre por login normal.
--
-- Tudo passa por funções security definer (as tabelas team_* seguem fechadas
-- para anon/authenticated), então o hash da senha nunca sai do banco.

-- ============================================================
-- 1) team_needs_setup(): há dono ativo?
-- ============================================================
create or replace function public.team_needs_setup()
returns boolean
language sql
stable
security definer
set search_path = public, extensions
as $$
  select not exists (
    select 1 from public.team_members where role = 'dono' and is_active
  );
$$;

-- ============================================================
-- 2) team_bootstrap(): cria o primeiro dono (só se não houver nenhum)
-- ============================================================
create or replace function public.team_bootstrap(
  p_username text,
  p_name     text,
  p_password text
)
returns json
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_user  text := lower(trim(coalesce(p_username, '')));
  v_name  text := trim(coalesce(p_name, ''));
  v_id    uuid;
  v_token uuid;
begin
  -- Trava principal: se já existe dono ativo, o cadastro inicial está encerrado.
  if exists (select 1 from public.team_members where role = 'dono' and is_active) then
    raise exception 'O painel já tem um responsável. Entre com seu usuário e senha.';
  end if;

  if v_user !~ '^[a-z0-9._-]{3,32}$' then
    raise exception 'Usuário deve ter de 3 a 32 caracteres, usando apenas letras minúsculas, números, ponto, hífen ou underline.';
  end if;
  if v_name = '' then
    raise exception 'Informe o nome do responsável.';
  end if;
  if length(coalesce(p_password, '')) < 6 then
    raise exception 'A senha precisa ter pelo menos 6 caracteres.';
  end if;
  if exists (select 1 from public.team_members where username = v_user) then
    raise exception 'Já existe um membro com o usuário "%".', v_user;
  end if;

  insert into public.team_members (username, name, password_hash, role)
  values (v_user, v_name, crypt(p_password, gen_salt('bf', 10)), 'dono')
  returning id into v_id;

  insert into public.team_sessions (member_id)
  values (v_id)
  returning token into v_token;

  update public.team_members set last_login_at = now() where id = v_id;

  return json_build_object(
    'token',    v_token,
    'id',       v_id,
    'username', v_user,
    'name',     v_name,
    'role',     'dono'
  );
end;
$$;

grant execute on function public.team_needs_setup()                 to anon, authenticated;
grant execute on function public.team_bootstrap(text, text, text)   to anon, authenticated;

-- ============================================================
-- 3) Remove o seed comprometido
-- ============================================================
-- Só apaga se a senha ainda for a original 'geojustica2026' — assim, se você já
-- tiver trocado a senha da conta 'admin' por conta própria, ela é preservada.
-- Com a conta removida, o app cai no fluxo de setup e você cria o dono real.
delete from public.team_members
 where username = 'admin'
   and role = 'dono'
   and password_hash = crypt('geojustica2026', password_hash);
