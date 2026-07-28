-- Arifood database schema.
-- Run this once in the Supabase SQL editor (see SETUP.md, step 3).

create table public.ingredients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by text
);

-- Every purchase is kept, so prices can be tracked over time.
-- The app treats the most recent purchase as the current price.
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

create table public.dishes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  selling_price numeric check (selling_price >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by text
);

-- "restrict" stops an ingredient being deleted while a dish still uses it;
-- the app shows a friendly message when that happens.
create table public.dish_ingredients (
  id uuid primary key default gen_random_uuid(),
  dish_id uuid not null references public.dishes (id) on delete cascade,
  ingredient_id uuid not null references public.ingredients (id) on delete restrict,
  grams numeric not null check (grams > 0)
);

create index purchases_ingredient_idx on public.purchases (ingredient_id, purchased_at desc);
create index dish_ingredients_dish_idx on public.dish_ingredients (dish_id);
create index dish_ingredients_ingredient_idx on public.dish_ingredients (ingredient_id);

-- Row level security: only logged-in team members can read or write,
-- and every team member shares the same data.
alter table public.ingredients enable row level security;
alter table public.purchases enable row level security;
alter table public.dishes enable row level security;
alter table public.dish_ingredients enable row level security;

create policy "team access" on public.ingredients
  for all to authenticated using (true) with check (true);
create policy "team access" on public.purchases
  for all to authenticated using (true) with check (true);
create policy "team access" on public.dishes
  for all to authenticated using (true) with check (true);
create policy "team access" on public.dish_ingredients
  for all to authenticated using (true) with check (true);
