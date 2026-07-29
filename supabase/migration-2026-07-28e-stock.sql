-- Stock levels per ingredient per site (Ari, Yindee, Sayhi).
-- Any logged-in team member (including shoppers) can read and update
-- stock — it's a stocktake task.
-- Run once in the Supabase SQL editor.

create table public.stock_levels (
  id uuid primary key default gen_random_uuid(),
  ingredient_id uuid not null references public.ingredients (id) on delete cascade,
  site text not null check (site in ('ari', 'yindee', 'sayhi')),
  qty numeric not null default 0 check (qty >= 0),
  updated_at timestamptz not null default now(),
  updated_by text,
  unique (ingredient_id, site)
);

alter table public.stock_levels enable row level security;

create policy "team read" on public.stock_levels
  for select to authenticated using (true);
create policy "team write" on public.stock_levels
  for all to authenticated using (true) with check (true);
