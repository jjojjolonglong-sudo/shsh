-- shsh(초단편 작품 컨셉 정리) 테이블 — 2026-11-24 커넥터로 실행
-- 작품(shsh_work) · 태그(shsh_tag) · 작품↔태그 연결(shsh_work_tag, 행 id 없음)

create table if not exists public.shsh_work (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  title text not null default '',
  pub_date date,                       -- 출간일
  length integer,                      -- 분량(글자 수)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.shsh_tag (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, name)
);

create table if not exists public.shsh_work_tag (
  work_id uuid not null references public.shsh_work(id) on delete cascade,
  tag_id  uuid not null references public.shsh_tag(id)  on delete cascade,
  user_id uuid not null default auth.uid(),
  created_at timestamptz not null default now(),
  primary key (work_id, tag_id)
);
create index if not exists shsh_work_tag_tag on public.shsh_work_tag(tag_id);
create index if not exists shsh_work_user on public.shsh_work(user_id);
create index if not exists shsh_tag_user on public.shsh_tag(user_id);
create index if not exists shsh_work_tag_user on public.shsh_work_tag(user_id);

alter table public.shsh_work enable row level security;
alter table public.shsh_tag enable row level security;
alter table public.shsh_work_tag enable row level security;

create policy "own rows" on public.shsh_work for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own rows" on public.shsh_tag for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own rows" on public.shsh_work_tag for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
