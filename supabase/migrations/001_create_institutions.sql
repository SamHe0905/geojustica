-- GeoJustiça - Schema inicial
create extension if not exists "uuid-ossp";

create table if not exists public.institutions (
  id            uuid primary key default uuid_generate_v4(),
  name          text not null,
  address       text not null default '',
  neighborhood  text not null default '',
  phone         text,
  whatsapp      text,
  category      text not null default 'outros',
  services      text default '',
  schedule      text,
  observations  text,
  sphere        text not null default 'municipal',
  latitude      double precision not null default 0,
  longitude     double precision not null default 0,
  accepts_indigent boolean not null default true,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Row-level security: leitura pública, escrita apenas autenticada
alter table public.institutions enable row level security;

create policy "Leitura pública" on public.institutions
  for select using (true);

create policy "Escrita autenticada" on public.institutions
  for all using (auth.role() = 'authenticated');

-- Índices
create index institutions_category_idx on public.institutions (category);
create index institutions_is_active_idx on public.institutions (is_active);

-- Dados de exemplo para Campo Grande/MS
insert into public.institutions (name, address, neighborhood, phone, category, services, schedule, sphere, latitude, longitude, accepts_indigent) values
('Defensoria Pública do Estado de MS', 'Rua Dom Aquino, 640', 'Centro', '(67) 3316-1800', 'outros', 'Assistência jurídica gratuita;Todas as áreas do direito', 'Seg-Sex 7h-19h', 'estadual', -20.4621, -54.6174, true),
('PROCON Campo Grande', 'Rua Barão do Rio Branco, 1808', 'Centro', '(67) 3316-3700', 'consumidor', 'Defesa do consumidor;Mediação de conflitos;Orientação jurídica', 'Seg-Sex 8h-17h', 'municipal', -20.4668, -54.6198, true),
('CRAS Centro', 'Rua Barão do Rio Branco, 1930', 'Centro', '(67) 3314-3500', 'familia', 'Assistência social;Orientação familiar;Benefícios sociais', 'Seg-Sex 8h-17h', 'municipal', -20.4681, -54.6211, true),
('CREAS Campo Grande', 'Rua Marechal Cândido Mariano, 500', 'Jardim dos Estados', '(67) 3314-3600', 'violencia_domestica', 'Acolhimento de vítimas;Medidas protetivas;Apoio psicossocial', 'Seg-Sex 8h-17h', 'municipal', -20.4732, -54.6148, true),
('Núcleo de Prática Jurídica UFMS', 'Av. Costa e Silva, s/n', 'Universitário', '(67) 3345-7000', 'outros', 'Assistência jurídica gratuita;Direito civil;Direito trabalhista', 'Seg-Sex 8h-12h 13h-17h', 'federal', -20.5065, -54.6159, true),
('Delegacia da Mulher', 'Rua Ceará, 200', 'Centro', '(67) 3321-1500', 'direitos_mulher', 'Registro de B.O.;Medidas protetivas;Apoio às vítimas', '24 horas', 'estadual', -20.4655, -54.6182, true),
('Junta do Trabalho - Vara 1', 'Rua Dom Aquino, 2416', 'Carandá Bosque', '(67) 3043-9700', 'trabalho', 'Reclamações trabalhistas;Audiências;Mediação', 'Seg-Sex 8h-18h', 'federal', -20.4893, -54.5970, true),
('INSS Campo Grande', 'Rua Dr. Zerbini, 34', 'Centro', '135', 'aposentadoria', 'Aposentadoria;BPC/LOAS;Auxílio-doença;Pensão por morte', 'Seg-Sex 7h-17h', 'federal', -20.4693, -54.6211, true);
