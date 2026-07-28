-- Dish categories matching the menu sections on ari-thaistreetfood.com.
-- Run once in the Supabase SQL editor (after the earlier migrations).

alter table public.dishes
  add column if not exists category text not null default 'other'
  check (category in (
    'ala_carte', 'noodle_soup', 'entree', 'vegan', 'gluten_free',
    'drinks', 'dessert', 'snacks', 'special', 'other'
  ));

-- Categorise the seeded menu (safe if some names are missing).
update public.dishes set category = 'vegan' where name like '%(Vegan)';
update public.dishes set category = 'gluten_free' where name like '%(GF)';

update public.dishes set category = 'ala_carte' where name in (
  'Pad Kra Pow on Rice','Thai Fried Rice','Spicy Basil Fried Rice',
  'Tom Yum Fried Rice','Chili Jam Stir Fry on Rice',
  'Garlic & Pepper Stir Fry on Rice','Red Curry Paste Stir Fried',
  'Gai-Lan (Kana) Oyster Sauce over Rice','Chilli Salt Stir-Fry on Rice',
  'Pad See Eiw','Pad Thai','Pad Kee Mao with Rice Noodles',
  'Sen Kaeaw Salad – Kelp Noodle','Dry Sukiyaki Kelp Noodles',
  'Tum Sen Lek – Thin Rice Noodle Salad'
);

update public.dishes set category = 'noodle_soup' where name in (
  'Clear Noodle Soup','Creamy Tom Yum Noodles','Spicy and Sour Soup',
  'Boat Noodles','Pink Noodle Sauce','Dry Noodles with Black Soy Sauce'
);

update public.dishes set category = 'entree' where name in (
  'Moo Ping – Pork Skewers','Set Moo Ping (Pork Skewers)',
  'Thai Fish Cake (1 pc)','Spring Roll (1 pc)','Sour Pork (1 pc)',
  'Sour Pork (3 pcs)','Chicken Dim Sim (4 pcs)','Chicken Dim Sim (1 pc)',
  'Chicken Wing Zap','Curry Puff','Thai Sausage'
);

update public.dishes set category = 'drinks' where name in (
  'Thai Milk Tea','Thai Black Tea','Thai Lemon Tea','Chrysanthemum Tea',
  'Longan Juice','Pinky Milky','O-Liang Black Coffee','Thai Red Soda'
);

update public.dishes set category = 'dessert' where name in (
  'Mango Sticky Rice','Durian'
);

update public.dishes set category = 'snacks' where name in (
  'Beef Jerky','Chilli Oil','Crispy Pork Crackers','Jaew Bong',
  'Mango Sweet & Sour','Nam Prik Namyoi','Pork Jerky',
  'Spicy Crispy Pork Cracker (Small)','Thai Dip Seafood (Small)',
  'Nam Prik Ari Mackerel Fish','Nam Prik Ari Pla Salid',
  'Nam Prik Ari Seasonal Clam','Nam Prik Ari Dried Shrimp'
);

update public.dishes set category = 'special' where name in (
  'Hainanese Chicken','Spicy Bamboo Salad','Pork Blood Soup',
  'Jasmine Rice','Sticky Rice'
);
