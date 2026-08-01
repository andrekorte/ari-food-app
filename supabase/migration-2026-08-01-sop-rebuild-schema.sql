-- Schema changes needed for the SOP rebuild:
--  1. A sauce can contain another sauce (e.g. tom yum stir-fry sauce
--     contains stir-fry sauce), so price changes cascade correctly.
--  2. Protein options: most dishes are cooked with the customer's choice
--     of protein. Instead of duplicating every dish per protein, a dish
--     is flagged "uses_protein" and the app shows cost/margin for each
--     protein side by side.
--  3. A "hot_bar" dish category.
-- Run once in the Supabase SQL editor, BEFORE the data rebuild script.

-- 1. Nested sauces -----------------------------------------------------
alter table public.sauce_ingredients
  alter column ingredient_id drop not null;
alter table public.sauce_ingredients
  add column if not exists sub_sauce_id uuid references public.sauces (id) on delete restrict;
alter table public.sauce_ingredients
  add constraint sauce_row_one_ref
  check ((ingredient_id is null) <> (sub_sauce_id is null));
create index if not exists sauce_ingredients_sub_idx on public.sauce_ingredients (sub_sauce_id);

-- 2. Protein options ---------------------------------------------------
create table public.protein_options (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_th text,
  ingredient_id uuid references public.ingredients (id) on delete set null,
  grams numeric not null default 0 check (grams >= 0),
  selling_price numeric check (selling_price >= 0),
  sort_order integer not null default 0
);

alter table public.protein_options enable row level security;
create policy "team read" on public.protein_options
  for select to authenticated using (true);
create policy "admin write" on public.protein_options
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

alter table public.dishes
  add column if not exists uses_protein boolean not null default false;

-- 3. Hot bar category --------------------------------------------------
alter table public.dishes drop constraint if exists dishes_category_check;
alter table public.dishes add constraint dishes_category_check
  check (category in (
    'ala_carte', 'noodle_soup', 'entree', 'vegan', 'gluten_free',
    'drinks', 'dessert', 'snacks', 'special', 'hot_bar', 'other'
  ));
