-- GeoJustiça - Permitir escrita via anon key
-- O painel admin faz auth local (senha no cliente), não usa Supabase Auth.
-- Enquanto o Auth não for integrado, liberamos writes para anon.
-- TODO: quando migrar para Supabase Auth, restringir de volta.

drop policy if exists "Escrita autenticada" on public.institutions;

create policy "Escrita anon (admin local)" on public.institutions
  for all
  using (true)
  with check (true);
