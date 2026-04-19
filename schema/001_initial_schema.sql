-- AI Roadmap Tracker — Initial Schema
-- Supabase project: tenone (formerly "tenone pipeline", ref iraisbyzblybxcexiova)
-- Namespace: all tracker tables live in the `tracker` schema to avoid collisions
--            with pipeline tables (pipeline_ideas, experiment_lac_ledger, tasks, etc.)
-- Migration: 001_initial_schema
-- Apply via: mcp__3d5ec979-cb0c-4709-b311-a6f56828fc62__apply_migration
--
-- Post-migration manual step (one-time):
--   Supabase Dashboard → Settings → API → Exposed schemas → add "tracker"
--   This lets PostgREST serve /rest/v1/ queries against tracker.* tables.

-- =============================================================================
-- NAMESPACE
-- =============================================================================

create schema if not exists tracker;

-- Let the Data API roles read tracker.* objects. RLS policies below gate which rows.
grant usage on schema tracker to anon, authenticated, service_role;
grant select on all tables in schema tracker to anon, authenticated;
alter default privileges in schema tracker grant select on tables to anon, authenticated;

-- =============================================================================
-- ENUMS (in tracker schema)
-- =============================================================================

create type tracker.jurisdiction_type as enum (
  'us_federal',
  'us_state',
  'eu',
  'un',
  'other_international'
);

create type tracker.chamber_type as enum (
  'senate',
  'house',
  'assembly',
  'council',
  'parliament',
  'na'
);

create type tracker.bill_status as enum (
  'introduced',
  'committee_hearing',
  'committee_passed',
  'chamber_passed',
  'both_chambers_passed',
  'signed',
  'failed',
  'withdrawn',
  'vetoed',
  'in_force'               -- for non-legislative instruments (EU regs, UN resolutions)
);

create type tracker.mapping_source as enum ('human', 'llm', 'seed');

-- =============================================================================
-- REFERENCE TABLES
-- =============================================================================

create table tracker.principles (
  id            smallint primary key,
  short_name    text not null,
  full_name     text not null,
  color_hex     text,
  description   text,
  icon_slug     text,
  display_order smallint not null
);

insert into tracker.principles (id, short_name, full_name, display_order) values
  (1, 'Safe & Transparent',    'AI should be built safely and transparently',                       1),
  (2, 'Duty of Care',          'AI companies owe a duty of care to the public',                     2),
  (3, 'Human Well-being',      'AI design should center human well-being',                          3),
  (4, 'Meaningful Work',       'AI should not automate away meaningful work and human dignity',     4),
  (5, 'Rights & Freedom',      'AI innovation should not come at the expense of our rights and freedom', 5),
  (6, 'International Limits',  'AI should have internationally agreed-upon limits',                 6),
  (7, 'Balanced Power',        'AI power should be balanced in society',                            7);

create table tracker.data_sources (
  id         serial primary key,
  slug       text unique not null,
  name       text not null,
  base_url   text,
  notes      text
);

insert into tracker.data_sources (slug, name, base_url) values
  ('congress_gov',   'Congress.gov',      'https://api.congress.gov/v3'),
  ('legiscan',       'LegiScan',          'https://api.legiscan.com'),
  ('court_listener', 'CourtListener',     'https://www.courtlistener.com/api/rest/v4'),
  ('eur_lex',        'EUR-Lex',           'https://eur-lex.europa.eu'),
  ('un_docs',        'UN Official Docs',  'https://documents.un.org'),
  ('seed',           'Seed corpus (manual)', null);

-- =============================================================================
-- CORE TABLES
-- =============================================================================

create table tracker.bills (
  id                uuid primary key default gen_random_uuid(),
  slug              text unique not null,
  jurisdiction      tracker.jurisdiction_type not null,
  state_code        text,
  chamber           tracker.chamber_type,
  bill_number       text not null,
  congress_session  text,
  short_name        text not null,
  official_title    text,
  summary           text,
  sponsor           text,
  cosponsors        text[],
  introduced_date   date,
  weight            numeric(3,2) not null check (weight >= 0.0 and weight <= 1.0),
  source_id         int references tracker.data_sources(id),
  source_bill_id    text,
  source_url        text,
  is_active         boolean not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index bills_jurisdiction_idx on tracker.bills (jurisdiction, state_code);
create index bills_active_idx on tracker.bills (is_active) where is_active = true;

create table tracker.bill_status_history (
  id             uuid primary key default gen_random_uuid(),
  bill_id        uuid not null references tracker.bills(id) on delete cascade,
  status         tracker.bill_status not null,
  status_date    date not null,
  detected_at    timestamptz not null default now(),
  source_id      int references tracker.data_sources(id),
  source_payload jsonb,
  notes          text
);

create index bill_status_history_bill_idx on tracker.bill_status_history (bill_id, status_date desc);
create index bill_status_history_detected_idx on tracker.bill_status_history (detected_at desc);

create materialized view tracker.bill_latest_status as
select distinct on (bill_id)
  bill_id,
  status,
  status_date,
  detected_at,
  source_id
from tracker.bill_status_history
order by bill_id, status_date desc, detected_at desc;

create unique index bill_latest_status_bill_idx on tracker.bill_latest_status (bill_id);

create table tracker.bill_principle_map (
  bill_id       uuid not null references tracker.bills(id) on delete cascade,
  principle_id  smallint not null references tracker.principles(id),
  confidence    numeric(3,2) not null default 1.0 check (confidence >= 0.0 and confidence <= 1.0),
  mapped_by     tracker.mapping_source not null default 'human',
  mapped_at     timestamptz not null default now(),
  notes         text,
  primary key (bill_id, principle_id)
);

create index bill_principle_map_principle_idx on tracker.bill_principle_map (principle_id);

create table tracker.classification_queue (
  id                  uuid primary key default gen_random_uuid(),
  bill_id             uuid not null references tracker.bills(id) on delete cascade,
  proposed_principles smallint[] not null,
  llm_confidence      numeric(3,2),
  llm_reasoning       text,
  status              text not null default 'pending' check (status in ('pending','approved','rejected','edited')),
  reviewed_by         text,
  reviewed_at         timestamptz,
  created_at          timestamptz not null default now()
);

create index classification_queue_pending_idx on tracker.classification_queue (status) where status = 'pending';

-- =============================================================================
-- NORMS LAYER (stubbed for v1 week 3)
-- =============================================================================

create table tracker.norm_signals (
  id           uuid primary key default gen_random_uuid(),
  principle_id smallint not null references tracker.principles(id),
  signal_date  date not null,
  source       text not null,
  volume       numeric,
  stance_score numeric,
  metadata     jsonb,
  created_at   timestamptz not null default now()
);

create index norm_signals_principle_date_idx on tracker.norm_signals (principle_id, signal_date desc);

-- =============================================================================
-- COMPUTED SCORES (daily snapshots)
-- =============================================================================

create table tracker.principle_scores (
  principle_id  smallint not null references tracker.principles(id),
  score_date    date not null,
  laws_score    numeric(5,2),
  norms_score   numeric(5,2),
  composite     numeric(5,2),
  bill_count    int not null default 0,
  movers_count  int not null default 0,
  top_movers    jsonb,
  computed_at   timestamptz not null default now(),
  primary key (principle_id, score_date)
);

create index principle_scores_date_idx on tracker.principle_scores (score_date desc);

create table tracker.index_snapshots (
  snapshot_date timestamptz primary key,
  index_value   numeric(5,2) not null,
  delta_1d      numeric(5,2),
  delta_7d      numeric(5,2),
  delta_30d     numeric(5,2),
  top_movers    jsonb,
  narrative     text,
  computed_at   timestamptz not null default now()
);

-- =============================================================================
-- WATCHLIST
-- =============================================================================

create table tracker.watchlist_items (
  id             uuid primary key default gen_random_uuid(),
  bill_id        uuid references tracker.bills(id) on delete cascade,
  principle_id   smallint references tracker.principles(id),
  event_type     text not null,
  expected_date  date,
  importance     smallint not null default 3 check (importance between 1 and 5),
  notes          text,
  is_active      boolean not null default true,
  created_at     timestamptz not null default now()
);

create index watchlist_active_idx on tracker.watchlist_items (expected_date) where is_active = true;

-- =============================================================================
-- OPERATIONS
-- =============================================================================

create table tracker.ingestion_runs (
  id             uuid primary key default gen_random_uuid(),
  source_id      int not null references tracker.data_sources(id),
  started_at     timestamptz not null default now(),
  completed_at   timestamptz,
  status         text not null default 'running' check (status in ('running','success','partial','failed')),
  bills_seen     int default 0,
  bills_new      int default 0,
  status_changes int default 0,
  error_message  text,
  metadata       jsonb
);

create index ingestion_runs_source_idx on tracker.ingestion_runs (source_id, started_at desc);

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

create or replace function tracker.refresh_bill_latest_status() returns void as $$
begin
  refresh materialized view concurrently tracker.bill_latest_status;
end;
$$ language plpgsql security definer;

grant execute on function tracker.refresh_bill_latest_status() to service_role;

create or replace function tracker.status_multiplier(s tracker.bill_status) returns numeric as $$
begin
  return case s
    when 'introduced'            then 0.10
    when 'committee_hearing'     then 0.20
    when 'committee_passed'      then 0.40
    when 'chamber_passed'        then 0.60
    when 'both_chambers_passed'  then 0.80
    when 'signed'                then 1.00
    when 'in_force'              then 1.00
    when 'vetoed'                then 0.00
    when 'failed'                then 0.00
    when 'withdrawn'             then 0.00
    else 0.00
  end;
end;
$$ language plpgsql immutable;

-- RPC used by the scoring job to join bills × bill_principle_map × bill_latest_status
create or replace function tracker.bills_for_principle(p_id smallint)
returns table (bill_id uuid, weight numeric, status tracker.bill_status, confidence numeric)
language sql stable as $$
  select b.id, b.weight, coalesce(ls.status, 'introduced'::tracker.bill_status), m.confidence
  from tracker.bills b
  join tracker.bill_principle_map m on m.bill_id = b.id
  left join tracker.bill_latest_status ls on ls.bill_id = b.id
  where m.principle_id = p_id
    and b.is_active = true
$$;

grant execute on function tracker.bills_for_principle(smallint) to anon, authenticated, service_role;

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================

-- Public read for everything that backs the dashboard; writes require service role.
alter table tracker.principles             enable row level security;
alter table tracker.data_sources           enable row level security;
alter table tracker.bills                  enable row level security;
alter table tracker.bill_status_history    enable row level security;
alter table tracker.bill_principle_map     enable row level security;
alter table tracker.principle_scores       enable row level security;
alter table tracker.index_snapshots        enable row level security;
alter table tracker.watchlist_items        enable row level security;
alter table tracker.norm_signals           enable row level security;

create policy "public read principles"     on tracker.principles          for select using (true);
create policy "public read data_sources"   on tracker.data_sources        for select using (true);
create policy "public read bills"          on tracker.bills               for select using (is_active = true);
create policy "public read status_history" on tracker.bill_status_history for select using (true);
create policy "public read principle_map"  on tracker.bill_principle_map  for select using (true);
create policy "public read scores"         on tracker.principle_scores    for select using (true);
create policy "public read index"          on tracker.index_snapshots     for select using (true);
create policy "public read watchlist"      on tracker.watchlist_items     for select using (is_active = true);
create policy "public read norms"          on tracker.norm_signals        for select using (true);

-- Internal-only tables: RLS on with no select policies = nobody reads via anon/authenticated roles.
alter table tracker.classification_queue enable row level security;
alter table tracker.ingestion_runs       enable row level security;
