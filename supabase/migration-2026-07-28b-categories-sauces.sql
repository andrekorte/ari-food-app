-- 1) Ingredient categories: meat / veg / sauce / other.
-- 2) Sauces: a sauce is a recipe of sauce ingredients (grams each); its
--    cost per gram is derived from those. Dishes can then contain either
--    an ingredient or a sauce per row.
-- Run once in the Supabase SQL editor.

alter table public.ingredients
  add column if not exists category text not null default 'other'
  check (category in ('meat', 'veg', 'sauce', 'other'));

create table public.sauces (
  id uuid primary key default gen_random_uuid(),
  name text not null,
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

-- A dish row now references EITHER an ingredient OR a sauce.
alter table public.dish_ingredients
  alter column ingredient_id drop not null;
alter table public.dish_ingredients
  add column if not exists sauce_id uuid references public.sauces (id) on delete restrict;
alter table public.dish_ingredients
  add constraint dish_row_one_ref
  check ((ingredient_id is null) <> (sauce_id is null));

create index sauce_ingredients_sauce_idx on public.sauce_ingredients (sauce_id);
create index dish_ingredients_sauce_idx on public.dish_ingredients (sauce_id);

alter table public.sauces enable row level security;
alter table public.sauce_ingredients enable row level security;

create policy "team read" on public.sauces
  for select to authenticated using (true);
create policy "team read" on public.sauce_ingredients
  for select to authenticated using (true);
create policy "admin write" on public.sauces
  for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin write" on public.sauce_ingredients
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Categorise the seeded ingredient list (safe if some names are missing).
update public.ingredients set category = 'meat' where name in (
  'Chicken thigh','Chicken breast','Whole chicken','Chicken wings',
  'Pork mince','Pork shoulder','Pork belly','Pork bones (stock)',
  'Beef (rump)','Prawns','Squid','White fish fillet','Fish balls',
  'Pork balls','Eggs','Firm tofu'
);

update public.ingredients set category = 'veg' where name in (
  'Garlic','Red chilli','Bird''s eye chilli','Dried chilli','Brown onion',
  'Shallots','Spring onion','Coriander','Holy basil','Thai basil',
  'Gai lan (Chinese broccoli)','Carrot','Cabbage','Bean sprouts','Tomato',
  'Mushrooms','Baby corn','Snake beans','Bamboo shoots','Lemongrass',
  'Galangal','Kaffir lime leaves','Lime','Ginger','Cucumber',
  'Pickled mustard greens','Pickled radish','Mango','Durian (frozen)',
  'Longan','Chrysanthemum flowers'
);

update public.ingredients set category = 'sauce' where name in (
  'Vegetable oil','Sesame oil','Fish sauce','Light soy sauce',
  'Dark soy sauce','Sweet soy sauce','Black soy sauce','Oyster sauce',
  'Sriracha chilli sauce','White vinegar','Evaporated milk','Coconut milk',
  'Coconut cream','Sukiyaki sauce','Red soda syrup (sala)','Full cream milk',
  'Red curry paste','Tom yum paste','Chilli jam (nam prik pao)',
  'Tamarind paste','Shrimp paste','Condensed milk','Palm sugar',
  'White sugar','Salt','White pepper','Black pepper','Chicken stock powder'
);
-- Everything else (rice, noodles, flours, wrappers, tea …) stays 'other'.
