-- ============================================================
-- SCHEMA - Sistema Operacional Logístico
-- Rode este arquivo primeiro no SQL Editor do Supabase.
-- Depois rode o seed_data.sql para carregar os dados da planilha.
-- ============================================================

-- Extensão para gen_random_uuid (normalmente já ativa no Supabase)
create extension if not exists pgcrypto;

-- ============================================================
-- 1. CLIENTES (unifica as abas "Granel" e "Cilindro")
-- ============================================================
create table if not exists clientes (
  id              bigserial primary key,
  codigo          bigint unique not null,
  nome            text not null,
  tipo_atendimento text not null check (tipo_atendimento in ('Granel', 'Cilindro')),
  num_tqs         text,
  tq              text,
  cidade          text,
  bairro          text,
  endereco        text,
  observacao      text,
  ativo           boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index if not exists idx_clientes_nome on clientes using gin (to_tsvector('portuguese', coalesce(nome,'')));
create index if not exists idx_clientes_cidade on clientes (cidade);
create index if not exists idx_clientes_tipo on clientes (tipo_atendimento);

-- ============================================================
-- 2. OCORRÊNCIAS
-- ============================================================
create table if not exists ocorrencias (
  id          bigserial primary key,
  codigo      bigint,
  cliente     text not null,
  num_tqs     text,
  tq          text,
  cidade      text,
  bairro      text,
  endereco    text,
  placa       text,
  observacao  text,
  status      text not null default 'Aberta' check (status in ('Aberta', 'Em andamento', 'Resolvida')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ============================================================
-- 3. EQUIPE (motoristas e ajudantes)
-- ============================================================
create table if not exists equipe (
  id            bigserial primary key,
  id_externo    integer,
  nome          text not null,
  tipo          text not null check (tipo in ('Motorista Granel','Motorista Cilindro','Motorista Carreteiro','Ajudante Granel','Ajudante Cilindro')),
  cpf           text,
  rg            text,
  cnh_categoria text,
  falta         boolean not null default false,
  folga         boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ============================================================
-- 4. VEÍCULOS
-- ============================================================
create table if not exists veiculos (
  id                bigserial primary key,
  placa             text unique not null,
  pda               text,
  serie             text,
  motorista_padrao  text,
  ajudante_padrao   text,
  numero_pda        text,
  imei              text,
  tara_kg           numeric,
  pbt_65_kg         numeric,
  pbt_70_kg         numeric,
  pbt_85_kg         numeric,
  tara_caminhao_kg  numeric,
  lotacao_kg        numeric,
  peso_bruto_kg     numeric,
  caracteristica    text,
  status            text not null default 'Ativo' check (status in ('Ativo','Em manutenção','Inativo')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- ============================================================
-- 5. ESCALA DIÁRIA (rotina de segunda a sexta)
-- ============================================================
create table if not exists escala_diaria (
  id              bigserial primary key,
  data            date not null default current_date,
  turno_tipo      text not null check (turno_tipo in ('Granel','Cilindro','Carreteiro')),
  motorista       text not null,
  ajudante        text,
  placa           text,
  placa_carreta   text,
  capacidade      text,
  rota            text,
  horario_entrada text,
  rodando         boolean not null default false,
  status          text not null default 'Planejado' check (status in ('Planejado','Em Rota','Concluído')),
  observacao      text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index if not exists idx_escala_diaria_data on escala_diaria (data);

-- Planejamento fixo semanal de viagens longas (aba "Viagem")
create table if not exists escala_viagens (
  id          bigserial primary key,
  dia_semana  text not null,
  motorista   text not null,
  ajudante    text,
  rota        text,
  created_at  timestamptz not null default now()
);

-- ============================================================
-- 6. ESCALA DE SÁBADO (semana corrente)
-- ============================================================
create table if not exists escala_sabado (
  id              bigserial primary key,
  data            date,
  turno_tipo      text not null check (turno_tipo in ('Granel','Cilindro','Carreteiro')),
  motorista       text not null,
  ajudante        text,
  placa           text,
  capacidade      text,
  rota            text,
  horario_entrada text,
  adm_do_dia      text,
  status          text not null default 'Planejado' check (status in ('Planejado','Em Rota','Concluído')),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- Grade mensal (Jan a Ago) — histórico/planejamento de escalas de sábado
create table if not exists escala_sabado_mensal (
  id          bigserial primary key,
  mes_ano     text not null,
  data        date,
  data_texto  text,
  motorista   text not null,
  ajudante    text,
  adm_do_dia  text,
  created_at  timestamptz not null default now()
);

-- ============================================================
-- 7. PASSAGEM DE TURNO (checklist diário)
-- ============================================================
create table if not exists passagem_turno (
  id                    bigserial primary key,
  data_turno            date not null default current_date,
  horario_passagem      time,
  assistente_saindo     text,
  assistente_assumindo  text,
  ocorrencias_pendentes boolean default false,
  ocorrencias_qtd       integer default 0,
  veiculos_problema     boolean default false,
  veiculos_qtd          integer default 0,
  folga_colaboradores   boolean default false,
  folga_qtd             integer default 0,
  clientes_0402         boolean default false,
  clientes_0402_qtd     integer default 0,
  mapa_nota_imprimir    boolean default false,
  mapa_nota_qtd         integer default 0,
  roterizado            boolean default false,
  caminhoes_retornados  boolean default false,
  caminhoes_qtd         integer default 0,
  observacao            text,
  created_at            timestamptz not null default now()
);

create table if not exists passagem_turno_ocorrencias (
  id                bigserial primary key,
  passagem_turno_id bigint references passagem_turno(id) on delete cascade,
  cliente_nome      text,
  codigo            bigint,
  observacao        text
);

-- ============================================================
-- 8. ROTAS SEMANAIS (referência de regiões por dia)
-- ============================================================
create table if not exists rotas_semanais (
  id          bigserial primary key,
  dia_semana  text not null,
  ordem       integer,
  regiao      text,
  descricao   text not null,
  created_at  timestamptz not null default now()
);

-- ============================================================
-- 9. TABELAS DE APOIO (motivos de recusa/reprogramação, contatos frota)
-- ============================================================
create table if not exists motivos_recusa (
  id          bigserial primary key,
  codigo      integer,
  descricao   text not null
);

create table if not exists motivos_reprogramacao (
  id          bigserial primary key,
  codigo      integer,
  descricao   text not null
);

create table if not exists contatos_frota (
  id              bigserial primary key,
  pda             text,
  serie           text,
  placa           text,
  numero_contato  text
);

-- ============================================================
-- 10. HISTÓRICO DE PEDIDOS (aba "Planilha1")
-- ============================================================
create table if not exists pedidos_historico (
  id                bigserial primary key,
  data              date,
  cod_cliente       bigint,
  nome              text,
  canal_venda       text,
  endereco          text,
  bairro            text,
  cidade            text,
  desc_frequencia   text,
  num_pedido        bigint,
  med_consumo       numeric,
  tancagem_pedido   text,
  observacao        text,
  created_at        timestamptz not null default now()
);
create index if not exists idx_pedidos_cod_cliente on pedidos_historico (cod_cliente);
create index if not exists idx_pedidos_data on pedidos_historico (data);

-- ============================================================
-- 11. NOTAS DE ACESSO (aba "apenas numeros" — portaria/zeladoria/chaves)
-- ============================================================
create table if not exists notas_acesso (
  id           bigserial primary key,
  data         date,
  cod_cliente  bigint,
  nome         text,
  bairro       text,
  cidade       text,
  num_pedido   bigint,
  observacao   text,
  created_at   timestamptz not null default now()
);
create index if not exists idx_notas_acesso_cod on notas_acesso (cod_cliente);

-- ============================================================
-- TRIGGER genérico de updated_at
-- ============================================================
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

do $$
declare
  t text;
begin
  for t in select unnest(array[
    'clientes','ocorrencias','equipe','veiculos','escala_diaria','escala_sabado'
  ])
  loop
    execute format('drop trigger if exists trg_updated_at on %I;', t);
    execute format('create trigger trg_updated_at before update on %I for each row execute function set_updated_at();', t);
  end loop;
end $$;

-- ============================================================
-- ROW LEVEL SECURITY
-- Este é um sistema interno de uso via chave anon exposta no front-end
-- (hospedagem estática no GitHub Pages). Liberamos leitura e escrita
-- para a role "anon"/"authenticated". Se quiser restringir depois,
-- troque estas policies por regras com autenticação (Supabase Auth).
-- ============================================================
do $$
declare
  t text;
begin
  for t in select unnest(array[
    'clientes','ocorrencias','equipe','veiculos','escala_diaria','escala_viagens',
    'escala_sabado','escala_sabado_mensal','passagem_turno','passagem_turno_ocorrencias',
    'rotas_semanais','motivos_recusa','motivos_reprogramacao','contatos_frota',
    'pedidos_historico','notas_acesso'
  ])
  loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists "allow_all" on %I;', t);
    execute format('create policy "allow_all" on %I for all using (true) with check (true);', t);
  end loop;
end $$;
