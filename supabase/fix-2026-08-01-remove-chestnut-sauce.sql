-- "Chestnut sauce" was read from the Hot bar SOP line "ซอส Chestnuts",
-- but no such product exists. Remove it and the recipe line that used it.
-- Run once in the Supabase SQL editor.

begin;

delete from public.dish_ingredients
where sauce_id = (select id from public.sauces where name = 'Chestnut sauce');

delete from public.sauce_ingredients
where sub_sauce_id = (select id from public.sauces where name = 'Chestnut sauce');

delete from public.sauces where name = 'Chestnut sauce';

commit;
