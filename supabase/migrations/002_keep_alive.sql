-- GeoJustiça - Keep-alive para evitar pausa por inatividade no Supabase Free
-- O Supabase pausa projetos Free após ~7 dias sem atividade no banco.
-- Aqui usamos pg_cron para gravar um registro a cada 3 dias, mantendo o projeto ativo.

create extension if not exists pg_cron with schema extensions;

create table if not exists public.keep_alive (
  id         bigserial primary key,
  pinged_at  timestamptz not null default now(),
  note       text
);

-- RLS: bloqueia acesso via API pública (a tabela só é usada internamente pelo cron).
alter table public.keep_alive enable row level security;

-- Sem policies = ninguém acessa via anon/authenticated. O cron roda como superuser e ignora RLS.

create or replace function public.ping_keep_alive()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.keep_alive (note) values ('cron ping');
  -- mantém só os últimos 30 registros para não crescer indefinidamente
  delete from public.keep_alive
   where id in (
     select id from public.keep_alive
      order by pinged_at desc
      offset 30
   );
end;
$$;

-- Remove agendamento anterior, se existir (idempotente)
do $$
begin
  perform cron.unschedule('geojustica_keep_alive');
exception when others then null;
end $$;

-- Agenda a cada 3 dias às 03:00 UTC (00:00 em Campo Grande)
select cron.schedule(
  'geojustica_keep_alive',
  '0 3 */3 * *',
  $$select public.ping_keep_alive();$$
);

-- Registra um ping imediato para você conferir que funcionou
select public.ping_keep_alive();
