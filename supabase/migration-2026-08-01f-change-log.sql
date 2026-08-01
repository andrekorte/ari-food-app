-- Records every add, edit and delete of an ingredient, sauce or dish, so the
-- Change history at the bottom of the Home screen shows what happened, when
-- and who did it. Written by database triggers, so a change made from any
-- device — or by a future version of the app — cannot slip through unlogged.
-- Run once in the Supabase SQL editor.

create table if not exists public.change_log (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,          -- ingredient | sauce | dish
  entity_id uuid,
  entity_name text,                   -- kept as text so deletes stay readable
  action text not null,               -- created | updated | deleted
  details jsonb,                      -- {fields: [...]} for edits
  changed_by text,
  changed_at timestamptz not null default now()
);

-- The history is always read newest-first, one page at a time.
create index if not exists change_log_changed_at_idx
  on public.change_log (changed_at desc);

alter table public.change_log enable row level security;

drop policy if exists change_log_read on public.change_log;
create policy change_log_read on public.change_log
  for select to authenticated using (true);

-- Rows are only ever written by the triggers below (which run as the table
-- owner), never by the client, so no insert/update/delete policy is granted.

-- Who is making the change: the app's display name if the row carries one,
-- otherwise the signed-in user's email.
create or replace function public.change_actor(p_row jsonb)
returns text
language sql
stable
set search_path = public
as $$
  select coalesce(
    nullif(p_row ->> 'updated_by', ''),
    nullif(current_setting('request.jwt.claims', true)::jsonb ->> 'email', ''),
    'unknown'
  );
$$;

create or replace function public.log_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  entity text := tg_argv[0];
  before jsonb;
  after jsonb;
  changed text[];
  k text;
begin
  if tg_op = 'DELETE' then
    before := to_jsonb(old);
    insert into public.change_log (entity_type, entity_id, entity_name, action, changed_by)
    values (entity, old.id, before ->> 'name', 'deleted',
            coalesce(nullif(current_setting('request.jwt.claims', true)::jsonb ->> 'email', ''), 'unknown'));
    return old;
  end if;

  after := to_jsonb(new);

  if tg_op = 'INSERT' then
    insert into public.change_log (entity_type, entity_id, entity_name, action, changed_by)
    values (entity, new.id, after ->> 'name', 'created', public.change_actor(after));
    return new;
  end if;

  -- UPDATE: record only the fields that actually changed, and skip the
  -- bookkeeping columns the app touches on every save.
  before := to_jsonb(old);
  changed := array[]::text[];
  for k in select jsonb_object_keys(after) loop
    if k in ('updated_at', 'updated_by', 'unit_price', 'usable_qty', 'last_purchase_at') then
      continue;
    end if;
    if (before -> k) is distinct from (after -> k) then
      changed := changed || k;
    end if;
  end loop;

  if array_length(changed, 1) is null then
    return new;   -- nothing meaningful changed, don't clutter the history
  end if;

  insert into public.change_log (entity_type, entity_id, entity_name, action, details, changed_by)
  values (entity, new.id, after ->> 'name', 'updated',
          jsonb_build_object('fields', to_jsonb(changed)),
          public.change_actor(after));
  return new;
end;
$$;

drop trigger if exists ingredients_change_log on public.ingredients;
create trigger ingredients_change_log
after insert or update or delete on public.ingredients
for each row execute function public.log_change('ingredient');

drop trigger if exists sauces_change_log on public.sauces;
create trigger sauces_change_log
after insert or update or delete on public.sauces
for each row execute function public.log_change('sauce');

drop trigger if exists dishes_change_log on public.dishes;
create trigger dishes_change_log
after insert or update or delete on public.dishes
for each row execute function public.log_change('dish');
