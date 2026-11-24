-- shsh 2차(2026-11-24, 커넥터로 실행)
-- 1) 분량: 글자 수(정수) → 만자 단위(소수 가능). 기존 값은 ÷10000으로 옮김
alter table public.shsh_work alter column length type numeric using (length / 10000.0);

-- 2) 작가·출판사 목록: 한 테이블에 type으로 구분 ('author' 작가 / 'publisher' 출판사) — bkbk_tags와 같은 방식
create table if not exists public.shsh_ref (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  type text not null check (type in ('author','publisher')),
  name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, type, name)
);
create index if not exists shsh_ref_user on public.shsh_ref(user_id);
alter table public.shsh_ref enable row level security;
create policy "own rows" on public.shsh_ref for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- 3) 작품에 작가·출판사 칸 (목록에서 지우면 작품 쪽은 빈 칸이 됨)
alter table public.shsh_work add column if not exists author_id uuid references public.shsh_ref(id) on delete set null;
alter table public.shsh_work add column if not exists publisher_id uuid references public.shsh_ref(id) on delete set null;
create index if not exists shsh_work_author on public.shsh_work(author_id);
create index if not exists shsh_work_publisher on public.shsh_work(publisher_id);
