-- Remembered invoice wordings.
-- When a scanned line can't be matched automatically and the user picks
-- the right ingredient, that supplier wording is stored here. The next
-- invoice with the same wording matches instantly, for everyone.
-- Run once in the Supabase SQL editor.

create table public.ingredient_aliases (
  id uuid primary key default gen_random_uuid(),
  alias_key text not null unique,   -- normalised wording used for lookup
  alias_text text not null,         -- wording as printed on the invoice
  ingredient_id uuid not null references public.ingredients (id) on delete cascade,
  created_at timestamptz not null default now(),
  created_by text
);

create index ingredient_aliases_ing_idx on public.ingredient_aliases (ingredient_id);

alter table public.ingredient_aliases enable row level security;

-- Anyone logged in can read and teach the app (including shoppers, who
-- are the ones scanning receipts); only admins can delete.
create policy "team read" on public.ingredient_aliases
  for select to authenticated using (true);
create policy "team teach" on public.ingredient_aliases
  for insert to authenticated with check (true);
create policy "team update" on public.ingredient_aliases
  for update to authenticated using (true) with check (true);
create policy "admin delete" on public.ingredient_aliases
  for delete to authenticated using (public.is_admin());
