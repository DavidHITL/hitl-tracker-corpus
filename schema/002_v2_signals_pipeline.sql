-- V2 signals pipeline — LLM-in-the-loop tagging against CHT indicator rubric
-- Published: 2026-04-18
-- Runs additively alongside existing v1 bills schema. No v1 tables dropped.

set search_path to tracker, public;

-- =====================================================================
-- Codebook versions
-- =====================================================================
create table if not exists tracker.codebook_versions (
  version text primary key,                -- "v1.0.0"
  published_at timestamptz not null default now(),
  notes text,
  indicator_count int not null,
  is_current boolean not null default false
);

-- Only one version can be current at a time
create unique index if not exists codebook_current_uniq
  on tracker.codebook_versions (is_current) where is_current;

-- =====================================================================
-- Indicators
-- =====================================================================
create table if not exists tracker.indicators (
  id text primary key,                     -- "1.L.d"
  principle_id smallint not null references tracker.principles(id),
  domain text not null check (domain in ('norms', 'laws', 'design')),
  letter text not null check (letter ~ '^[a-z]$'),
  name text not null,                      -- "Red-team disclosure rules"
  positive_direction_rule text not null,   -- What counts as +1
  negative_direction_rule text not null,   -- What counts as -1
  major_threshold text,                    -- Optional notes on Major/Minor
  codebook_version text not null references tracker.codebook_versions(version),
  active boolean not null default true,
  display_order smallint not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists indicators_principle_domain_idx
  on tracker.indicators (principle_id, domain);
create index if not exists indicators_active_idx
  on tracker.indicators (active) where active;

-- =====================================================================
-- Source feeds (distinct from existing tracker.data_sources)
-- =====================================================================
create table if not exists tracker.source_feeds (
  id uuid primary key default gen_random_uuid(),
  outlet text not null,                    -- "Reuters", "Congress.gov"
  source_type text not null check (source_type in
    ('official','media','research','industry','advocacy','capital')),
  geography text not null check (geography in
    ('us','eu','uk','international','global')),
  url text not null,
  rss_url text,
  tier smallint not null default 2 check (tier between 1 and 3),
  active boolean not null default true,
  ingestion_method text not null check (ingestion_method in
    ('rss','api','firecrawl','manual')),
  last_ingested_at timestamptz,
  triangulation_weight numeric(3,2) not null default 0.5,
  created_at timestamptz not null default now()
);

create index if not exists source_feeds_type_geo_idx
  on tracker.source_feeds (source_type, geography);
create index if not exists source_feeds_active_idx
  on tracker.source_feeds (active) where active;

-- =====================================================================
-- Raw signals (ingestion queue, pre-tagging)
-- =====================================================================
create table if not exists tracker.raw_signals (
  id uuid primary key default gen_random_uuid(),
  source_feed_id uuid references tracker.source_feeds(id),
  external_id text,                        -- Outlet's own ID if any (dedup key)
  url text not null,
  title text not null,
  summary text,
  full_text text,                          -- Body if we have it
  published_at timestamptz,
  ingested_at timestamptz not null default now(),
  processing_status text not null default 'pending'
    check (processing_status in ('pending','tagging','tagged','skipped','error')),
  skip_reason text,
  error_message text,
  tag_attempted_at timestamptz
);

create unique index if not exists raw_signals_dedup_idx
  on tracker.raw_signals (source_feed_id, coalesce(external_id, url));
create index if not exists raw_signals_pending_idx
  on tracker.raw_signals (processing_status, ingested_at)
  where processing_status = 'pending';

-- =====================================================================
-- Signals (tagged)
-- =====================================================================
create table if not exists tracker.signals (
  id uuid primary key default gen_random_uuid(),
  raw_signal_id uuid unique references tracker.raw_signals(id) on delete set null,
  title text not null,
  summary text,
  primary_url text not null,
  indicator_id text not null references tracker.indicators(id),
  direction smallint not null check (direction in (-1, 0, 1)),
  magnitude text not null check (magnitude in ('major','minor')),
  direction_of_power text not null check (direction_of_power in
    ('regulators','industry','public','unclear')),
  rationale text not null check (length(rationale) <= 140),
  confidence numeric(3,2) not null check (confidence between 0 and 1),
  geography text not null check (geography in
    ('us','eu','uk','international','global')),
  occurred_at timestamptz not null,        -- When the event happened
  triangulation_count smallint not null default 1,
  is_preliminary boolean not null default false,  -- True if single-source
  review_status text not null default 'pending_review'
    check (review_status in
      ('auto_approved','pending_review','approved','rejected','overridden')),
  human_override_reason text,
  tagged_by text not null default 'gemini-3.1-pro-preview',
  codebook_version text not null references tracker.codebook_versions(version),
  flagship boolean not null default false,
  tagged_at timestamptz not null default now(),
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists signals_indicator_idx on tracker.signals (indicator_id);
create index if not exists signals_occurred_idx on tracker.signals (occurred_at desc);
create index if not exists signals_review_idx
  on tracker.signals (review_status) where review_status in ('pending_review','auto_approved');
create index if not exists signals_published_idx
  on tracker.signals (occurred_at desc)
  where review_status in ('auto_approved','approved');
create index if not exists signals_flagship_idx on tracker.signals (flagship) where flagship;

-- Trigger: auto-update updated_at
create or replace function tracker.update_signals_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end; $$;

drop trigger if exists signals_updated_at_trg on tracker.signals;
create trigger signals_updated_at_trg
  before update on tracker.signals
  for each row execute procedure tracker.update_signals_updated_at();

-- =====================================================================
-- Signal sources (triangulation join)
-- =====================================================================
create table if not exists tracker.signal_sources (
  signal_id uuid not null references tracker.signals(id) on delete cascade,
  source_feed_id uuid not null references tracker.source_feeds(id),
  source_url text not null,
  retrieved_at timestamptz not null default now(),
  primary key (signal_id, source_feed_id)
);

create index if not exists signal_sources_feed_idx on tracker.signal_sources (source_feed_id);

-- =====================================================================
-- Flagship analyses (deep process tracing, 1-2 per cycle)
-- =====================================================================
create table if not exists tracker.flagship_analyses (
  id uuid primary key default gen_random_uuid(),
  signal_id uuid not null references tracker.signals(id),
  cycle_start date not null,
  headline text not null,
  causal_chain text not null,
  historical_analog text,
  predicted_second_order text,
  author text not null default 'David Felsmann',
  published_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists flagship_cycle_idx on tracker.flagship_analyses (cycle_start desc);

-- =====================================================================
-- Tagging audit log (sample-based QC)
-- =====================================================================
create table if not exists tracker.tag_audits (
  id uuid primary key default gen_random_uuid(),
  signal_id uuid not null references tracker.signals(id),
  auditor text not null default 'david',
  agreed boolean not null,
  notes text,
  audited_at timestamptz not null default now()
);

create index if not exists tag_audits_signal_idx on tracker.tag_audits (signal_id);
create index if not exists tag_audits_time_idx on tracker.tag_audits (audited_at desc);

-- =====================================================================
-- Matrix aggregation view (what the homepage reads)
-- Configurable time windows via parameterized function
-- =====================================================================
create or replace function tracker.matrix_cell(
  p_principle smallint,
  p_domain text,
  p_geography text default 'global',
  p_window_days int default 180
)
returns table (
  principle_id smallint,
  domain text,
  geography text,
  window_days int,
  signal_count int,
  direction_state text,
  weighted_score numeric,
  last_signal_at timestamptz
) language sql stable as $$
  with relevant_signals as (
    select
      s.direction,
      case s.magnitude when 'major' then 2 else 1 end as weight,
      s.occurred_at
    from tracker.signals s
    join tracker.indicators i on i.id = s.indicator_id
    where i.principle_id = p_principle
      and i.domain = p_domain
      and (p_geography = 'global' or s.geography = p_geography or s.geography = 'global')
      and s.occurred_at >= now() - (p_window_days || ' days')::interval
      and s.review_status in ('auto_approved','approved','overridden')
      and not s.is_preliminary
  ),
  agg as (
    select
      count(*) as n,
      sum(direction * weight)::numeric as score,
      max(occurred_at) as last_at
    from relevant_signals
  )
  select
    p_principle,
    p_domain,
    p_geography,
    p_window_days,
    coalesce(n, 0)::int as signal_count,
    case
      when coalesce(n, 0) < 5 then 'insufficient_data'
      when abs(score) < 3 and n >= 5 and score <> 0 then 'mixed'
      when score = 0 then 'stalled'
      when score >= 3 then 'advancing'
      when score <= -3 then 'regressing'
      else 'mixed'
    end as direction_state,
    score as weighted_score,
    last_at
  from agg;
$$;

-- =====================================================================
-- Helper: full matrix (21 cells) for a given geography + window
-- =====================================================================
create or replace function tracker.full_matrix(
  p_geography text default 'global',
  p_window_days int default 180
)
returns table (
  principle_id smallint,
  domain text,
  geography text,
  window_days int,
  signal_count int,
  direction_state text,
  weighted_score numeric,
  last_signal_at timestamptz
) language sql stable as $$
  select m.*
  from (
    select p.id as pid, d.d_name
    from tracker.principles p
    cross join (values ('norms'), ('laws'), ('design')) as d(d_name)
  ) grid
  cross join lateral tracker.matrix_cell(grid.pid, grid.d_name, p_geography, p_window_days) m;
$$;

-- =====================================================================
-- RLS: public reads on everything, writes via service role only
-- =====================================================================
alter table tracker.codebook_versions enable row level security;
alter table tracker.indicators enable row level security;
alter table tracker.source_feeds enable row level security;
alter table tracker.raw_signals enable row level security;
alter table tracker.signals enable row level security;
alter table tracker.signal_sources enable row level security;
alter table tracker.flagship_analyses enable row level security;
alter table tracker.tag_audits enable row level security;

-- Public read on approved content only
do $$ begin
  create policy "public read codebook" on tracker.codebook_versions
    for select using (true);
exception when duplicate_object then null; end $$;

do $$ begin
  create policy "public read indicators" on tracker.indicators
    for select using (active);
exception when duplicate_object then null; end $$;

do $$ begin
  create policy "public read sources" on tracker.source_feeds
    for select using (active);
exception when duplicate_object then null; end $$;

do $$ begin
  create policy "public read approved signals" on tracker.signals
    for select using (review_status in ('auto_approved','approved','overridden'));
exception when duplicate_object then null; end $$;

do $$ begin
  create policy "public read signal sources" on tracker.signal_sources
    for select using (
      exists (select 1 from tracker.signals s
              where s.id = signal_id
                and s.review_status in ('auto_approved','approved','overridden'))
    );
exception when duplicate_object then null; end $$;

do $$ begin
  create policy "public read published flagships" on tracker.flagship_analyses
    for select using (published_at is not null);
exception when duplicate_object then null; end $$;

-- raw_signals and tag_audits are internal only (no public policy = no reads)
