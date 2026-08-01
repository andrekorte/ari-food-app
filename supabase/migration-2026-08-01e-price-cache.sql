-- Keep each ingredient's current unit price on the ingredient row itself,
-- maintained by the database whenever a purchase is added, changed or
-- removed. The app can then load prices without pulling every purchase
-- ever recorded, so launch stays fast no matter how much history builds up.
-- Run once in the Supabase SQL editor.

alter table public.ingredients
  add column if not exists unit_price numeric,        -- $ per kg or per L
  add column if not exists usable_qty numeric,        -- latest purchase, after prep loss
  add column if not exists last_purchase_at timestamptz;

-- security definer: a shopper may record a purchase, which must be able to
-- update the ingredient row even though shoppers cannot edit ingredients.
create or replace function public.refresh_ingredient_price(p_ingredient uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
  usable numeric;
begin
  select purchased_kg, price_paid, wastage_kg, purchased_at
    into r
  from public.purchases
  where ingredient_id = p_ingredient
  order by purchased_at desc, id desc
  limit 1;

  if not found then
    update public.ingredients
       set unit_price = null, usable_qty = null, last_purchase_at = null
     where id = p_ingredient;
    return;
  end if;

  usable := r.purchased_kg - coalesce(r.wastage_kg, 0);

  update public.ingredients
     set usable_qty = usable,
         unit_price = case when usable > 0 then r.price_paid / usable else null end,
         last_purchase_at = r.purchased_at
   where id = p_ingredient;
end;
$$;

create or replace function public.purchases_sync_price()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.refresh_ingredient_price(old.ingredient_id);
    return old;
  end if;

  perform public.refresh_ingredient_price(new.ingredient_id);
  if tg_op = 'UPDATE' and new.ingredient_id is distinct from old.ingredient_id then
    perform public.refresh_ingredient_price(old.ingredient_id);
  end if;
  return new;
end;
$$;

drop trigger if exists purchases_price_sync on public.purchases;
create trigger purchases_price_sync
after insert or update or delete on public.purchases
for each row execute function public.purchases_sync_price();

-- Fill in the prices for everything already recorded.
do $$
declare i record;
begin
  for i in select id from public.ingredients loop
    perform public.refresh_ingredient_price(i.id);
  end loop;
end;
$$;
