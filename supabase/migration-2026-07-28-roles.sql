-- User roles: 'admin' (full access) and 'shopper' (may only record
-- purchases / shopping baskets, and read the ingredient list).
-- A user WITHOUT a profiles row counts as admin, so existing users keep
-- working unchanged. To restrict someone, add a profile row with role
-- 'shopper' (example at the bottom).
-- Run once in the Supabase SQL editor.

create table public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  role text not null default 'admin' check (role in ('admin', 'shopper'))
);

alter table public.profiles enable row level security;

create policy "team read" on public.profiles
  for select to authenticated using (true);
-- No insert/update/delete policies on profiles: roles are managed here
-- in the SQL editor, not from the app.

create or replace function public.is_admin()
returns boolean
language sql stable
as $$
  select coalesce(
    (select role from public.profiles where user_id = auth.uid()),
    'admin'
  ) = 'admin';
$$;

-- Replace the all-in-one policies with role-aware ones.
drop policy "team access" on public.ingredients;
drop policy "team access" on public.purchases;
drop policy "team access" on public.dishes;
drop policy "team access" on public.dish_ingredients;

-- Everyone logged in can read everything.
create policy "team read" on public.ingredients
  for select to authenticated using (true);
create policy "team read" on public.purchases
  for select to authenticated using (true);
create policy "team read" on public.dishes
  for select to authenticated using (true);
create policy "team read" on public.dish_ingredients
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

-- ---------------------------------------------------------------
-- To make a user a shopper, run this with their email filled in:
--
-- insert into public.profiles (user_id, role)
-- select id, 'shopper' from auth.users where email = 'person@example.com'
-- on conflict (user_id) do update set role = 'shopper';
--
-- To give them full access again:
--
-- update public.profiles set role = 'admin'
-- where user_id = (select id from auth.users where email = 'person@example.com');
-- ---------------------------------------------------------------
