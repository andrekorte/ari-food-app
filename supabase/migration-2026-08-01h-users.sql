-- Support for the Users tab.
--
-- Two things matter here. First, every account must have a profiles row, so
-- an invited person gets the role they were invited with instead of falling
-- through to the "no profile = admin" default. Second, existing accounts
-- (yours and anyone already signed in) are backfilled as admin so nobody
-- loses access.
-- Run once in the Supabase SQL editor.

-- New signups get a profile row automatically, using the role passed with
-- the invite. Anyone who somehow arrives without one is a shopper, not an
-- admin — the safe default.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, display_name, role)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'display_name', ''),
      split_part(coalesce(new.email, ''), '@', 1)
    ),
    case when new.raw_user_meta_data ->> 'role' = 'admin' then 'admin' else 'shopper' end
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Everyone who already has an account keeps full access.
insert into public.profiles (user_id, display_name, role)
select
  u.id,
  coalesce(
    nullif(u.raw_user_meta_data ->> 'display_name', ''),
    split_part(coalesce(u.email, ''), '@', 1)
  ),
  'admin'
from auth.users u
on conflict (user_id) do nothing;

-- The Users tab reads the whole team; the existing "team read" policy on
-- profiles already allows that for signed-in users. Adding, deleting and
-- role changes go through the manage-users Edge Function, which holds the
-- service_role key — so still no write policy is granted to the app.
