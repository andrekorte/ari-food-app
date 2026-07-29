-- Arifood database schema.
-- Run this once in the Supabase SQL editor (see SETUP.md, step 3).

-- unit: 'kg' for weight-based ingredients, 'l' for volume-based (e.g. oil).
-- Purchase quantities/wastage are in this unit; dish amounts are g or mL.
create table public.ingredients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_th text,
  unit text not null default 'kg' check (unit in ('kg', 'l')),
  category text not null default 'other'
    check (category in ('meat', 'veg', 'sauce', 'other')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by text
);

-- Every purchase is kept, so prices can be tracked over time.
-- The app treats the most recent purchase as the current price.
-- purchased_kg / wastage_kg hold the amount in the ingredient's unit
-- (kg or L); the column names predate volume support.
create table public.purchases (
  id uuid primary key default gen_random_uuid(),
  ingredient_id uuid not null references public.ingredients (id) on delete cascade,
  purchased_kg numeric not null check (purchased_kg > 0),
  price_paid numeric not null check (price_paid >= 0),
  wastage_kg numeric not null default 0 check (wastage_kg >= 0),
  purchased_at timestamptz not null default now(),
  entered_by text,
  check (wastage_kg < purchased_kg)
);

-- category values mirror the menu sections on ari-thaistreetfood.com.
create table public.dishes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_th text,
  category text not null default 'other'
    check (category in (
      'ala_carte', 'noodle_soup', 'entree', 'vegan', 'gluten_free',
      'drinks', 'dessert', 'snacks', 'special', 'other'
    )),
  selling_price numeric check (selling_price >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by text
);

-- A sauce is a recipe of ingredients (grams each); its cost per gram is
-- derived from those and used when a dish contains the sauce.
create table public.sauces (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_th text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by text
);

create table public.sauce_ingredients (
  id uuid primary key default gen_random_uuid(),
  sauce_id uuid not null references public.sauces (id) on delete cascade,
  ingredient_id uuid not null references public.ingredients (id) on delete restrict,
  grams numeric not null check (grams > 0)
);

-- Each dish row references EITHER an ingredient OR a sauce.
-- "restrict" stops an ingredient/sauce being deleted while still in use;
-- the app shows a friendly message when that happens.
create table public.dish_ingredients (
  id uuid primary key default gen_random_uuid(),
  dish_id uuid not null references public.dishes (id) on delete cascade,
  ingredient_id uuid references public.ingredients (id) on delete restrict,
  sauce_id uuid references public.sauces (id) on delete restrict,
  grams numeric not null check (grams > 0),
  check ((ingredient_id is null) <> (sauce_id is null))
);

create index purchases_ingredient_idx on public.purchases (ingredient_id, purchased_at desc);
create index dish_ingredients_dish_idx on public.dish_ingredients (dish_id);
create index dish_ingredients_ingredient_idx on public.dish_ingredients (ingredient_id);
create index dish_ingredients_sauce_idx on public.dish_ingredients (sauce_id);
create index sauce_ingredients_sauce_idx on public.sauce_ingredients (sauce_id);

-- User roles: 'admin' (full access) and 'shopper' (may only record
-- purchases and read the ingredient list). A user without a profiles row
-- counts as admin. Roles are managed in the SQL editor (see the examples
-- in migration-2026-07-28-roles.sql).
create table public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  role text not null default 'admin' check (role in ('admin', 'shopper'))
);

create or replace function public.is_admin()
returns boolean
language sql stable
as $$
  select coalesce(
    (select role from public.profiles where user_id = auth.uid()),
    'admin'
  ) = 'admin';
$$;

-- Row level security: only logged-in team members can read or write,
-- every team member shares the same data, and writes are gated by role.
alter table public.ingredients enable row level security;
alter table public.purchases enable row level security;
alter table public.dishes enable row level security;
alter table public.dish_ingredients enable row level security;
alter table public.sauces enable row level security;
alter table public.sauce_ingredients enable row level security;
alter table public.profiles enable row level security;

create policy "team read" on public.profiles
  for select to authenticated using (true);
create policy "team read" on public.ingredients
  for select to authenticated using (true);
create policy "team read" on public.purchases
  for select to authenticated using (true);
create policy "team read" on public.dishes
  for select to authenticated using (true);
create policy "team read" on public.dish_ingredients
  for select to authenticated using (true);
create policy "team read" on public.sauces
  for select to authenticated using (true);
create policy "team read" on public.sauce_ingredients
  for select to authenticated using (true);

-- Every logged-in user, including shoppers, can record purchases.
create policy "any user records purchases" on public.purchases
  for insert to authenticated with check (true);

-- Everything else is admin-only.
create policy "admin write" on public.ingredients
  for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin delete purchases" on public.purchases
  for delete to authenticated using (public.is_admin());
create policy "admin write" on public.dishes
  for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin write" on public.dish_ingredients
  for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin write" on public.sauces
  for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin write" on public.sauce_ingredients
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Stock levels per ingredient per site (Ari, Yindee, Sayhi). Any
-- logged-in team member (including shoppers) can read and update stock.
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
