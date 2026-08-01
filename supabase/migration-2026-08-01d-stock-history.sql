-- History of stock changes: who changed what, when, and from what to what.
-- Written both by stocktakes (Stock screen) and by purchases that add to
-- a site's stock. Run once in the Supabase SQL editor.

create table public.stock_changes (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid,                 -- groups one save together
  ingredient_id uuid not null references public.ingredients (id) on delete cascade,
  site text not null check (site in ('ari', 'yindee', 'sayhi')),
  qty_from numeric,              -- null when there was no stock record yet
  qty_to numeric not null,
  source text not null default 'stocktake'
    check (source in ('stocktake', 'purchase')),
  changed_at timestamptz not null default now(),
  changed_by text
);

create index stock_changes_at_idx on public.stock_changes (changed_at desc);
create index stock_changes_batch_idx on public.stock_changes (batch_id);

alter table public.stock_changes enable row level security;

create policy "team read" on public.stock_changes
  for select to authenticated using (true);
create policy "team write" on public.stock_changes
  for insert to authenticated with check (true);
create policy "admin delete" on public.stock_changes
  for delete to authenticated using (public.is_admin());
