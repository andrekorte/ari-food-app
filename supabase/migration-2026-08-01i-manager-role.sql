-- Adds a third access level, Manager: full use of the app — ingredients,
-- sauces, dishes, purchases, stock — but no ability to add, remove or
-- change users. Only Admins manage the team.
--
--   Admin    everything, including users
--   Manager  everything except users
--   Shopper  purchases and stock only
--
-- Run once in the Supabase SQL editor.

alter table public.profiles
  drop constraint if exists profiles_role_check;

alter table public.profiles
  add constraint profiles_role_check
  check (role in ('admin', 'manager', 'shopper'));

-- Who may edit the recipe book: ingredients, sauces, dishes and prices.
create or replace function public.can_edit()
returns boolean
language sql stable
set search_path = public
as $$
  select coalesce(
    (select role from public.profiles where user_id = auth.uid()),
    'admin'          -- the very first account, before any profile exists
  ) in ('admin', 'manager');
$$;

-- Every row level security policy in this database gates data editing, not
-- user management — accounts are handled by the manage-users Edge Function,
-- which checks for 'admin' separately. So this now means "may edit data",
-- and Managers pass it. Kept as a wrapper so the existing policies that
-- call it keep working unchanged.
create or replace function public.is_admin()
returns boolean
language sql stable
set search_path = public
as $$
  select public.can_edit();
$$;
