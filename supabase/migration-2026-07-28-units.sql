-- Adds a unit to each ingredient: 'kg' (weight) or 'l' (volume, e.g. oil).
-- Purchase quantities and wastage are interpreted in this unit; dish
-- amounts are then grams or millilitres to match.
-- Run once in the Supabase SQL editor. Existing ingredients stay in kg.

alter table public.ingredients
  add column if not exists unit text not null default 'kg'
  check (unit in ('kg', 'l'));
