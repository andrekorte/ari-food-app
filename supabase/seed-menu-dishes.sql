-- Seeds the dish list from ari-thaistreetfood.com/menu (July 2026),
-- with current selling prices. Ingredients/recipes are added later in
-- the app; until then a dish shows no cost.
-- Safe to run more than once: dishes that already exist (same name)
-- are skipped. Run in the Supabase SQL editor.

insert into public.dishes (name, selling_price, updated_by)
select v.name, v.price, 'menu import'
from (values
  -- Ala Carte
  ('Pad Kra Pow on Rice', 16.99),
  ('Thai Fried Rice', 16.99),
  ('Spicy Basil Fried Rice', 16.99),
  ('Tom Yum Fried Rice', 16.99),
  ('Chili Jam Stir Fry on Rice', 16.99),
  ('Garlic & Pepper Stir Fry on Rice', 16.99),
  ('Red Curry Paste Stir Fried', 16.99),
  ('Gai-Lan (Kana) Oyster Sauce over Rice', 16.99),
  ('Chilli Salt Stir-Fry on Rice', 16.99),
  ('Pad See Eiw', 16.99),
  ('Pad Thai', 16.99),
  ('Pad Kee Mao with Rice Noodles', 16.99),
  ('Sen Kaeaw Salad – Kelp Noodle', 16.99),
  ('Dry Sukiyaki Kelp Noodles', 16.99),
  ('Tum Sen Lek – Thin Rice Noodle Salad', 16.99),
  -- Noodle Soup
  ('Clear Noodle Soup', 16.99),
  ('Creamy Tom Yum Noodles', 16.99),
  ('Spicy and Sour Soup', 16.99),
  ('Boat Noodles', 16.99),
  ('Pink Noodle Sauce', 16.99),
  ('Dry Noodles with Black Soy Sauce', 16.99),
  -- Entree
  ('Moo Ping – Pork Skewers', 3.50),
  ('Set Moo Ping (Pork Skewers)', 12.99),
  ('Thai Fish Cake (1 pc)', 1.50),
  ('Spring Roll (1 pc)', 2.00),
  ('Sour Pork (1 pc)', 3.50),
  ('Sour Pork (3 pcs)', 10.00),
  ('Chicken Dim Sim (4 pcs)', 9.00),
  ('Chicken Dim Sim (1 pc)', 2.30),
  ('Chicken Wing Zap', 3.00),
  ('Curry Puff', 3.00),
  ('Thai Sausage', 4.00),
  -- Vegan
  ('Thai Fried Rice (Vegan)', 16.99),
  ('Garlic and Pepper (Vegan)', 16.99),
  ('Pad Ka Praw (Vegan)', 16.99),
  ('Spicy Basil Fried Rice (Vegan)', 16.99),
  ('Thai Salt and Chili (Vegan)', 16.99),
  ('Chili Jam Stir Fried (Vegan)', 16.99),
  ('Pad Kee Mao (Vegan)', 16.99),
  ('Red Curry Stir Fried (Vegan)', 16.99),
  ('Gai-Lan (Kana) Oyster Sauce (Vegan)', 16.99),
  ('Sen Keaw Salad (Vegan)', 16.99),
  -- Gluten Free
  ('Thai Fried Rice (GF)', 16.99),
  ('Garlic and Pepper (GF)', 16.99),
  ('Pad Ka Praw (GF)', 16.99),
  ('Spicy Basil Fried Rice (GF)', 16.99),
  ('Thai Salt and Chili (GF)', 16.99),
  ('Chili Jam Stir Fried (GF)', 16.99),
  ('Red Curry Paste Stir Fried (GF)', 16.99),
  ('Gai-Lan (Kana) Oyster Sauce (GF)', 16.99),
  ('Pad Kee Mao (GF)', 16.99),
  ('Sen Keaw Salad (GF)', 16.99),
  ('Dry Sukiyaki (GF)', 16.99),
  ('Tum Sen Lek Salad (GF)', 16.99),
  -- Ari's Drinks
  ('Thai Milk Tea', 7.00),
  ('Thai Black Tea', 7.00),
  ('Thai Lemon Tea', 7.00),
  ('Chrysanthemum Tea', 7.00),
  ('Longan Juice', 7.00),
  ('Pinky Milky', 7.00),
  ('O-Liang Black Coffee', 7.00),
  ('Thai Red Soda', 7.00),
  -- Dessert
  ('Mango Sticky Rice', 14.99),
  ('Durian', 41.00),
  -- Thai Snacks
  ('Beef Jerky', 12.00),
  ('Chilli Oil', 7.00),
  ('Crispy Pork Crackers', 12.00),
  ('Jaew Bong', 12.00),
  ('Mango Sweet & Sour', 3.20),
  ('Nam Prik Namyoi', 7.00),
  ('Pork Jerky', 12.00),
  ('Spicy Crispy Pork Cracker (Small)', 7.00),
  ('Thai Dip Seafood (Small)', 7.00),
  ('Nam Prik Ari Mackerel Fish', 7.00),
  ('Nam Prik Ari Pla Salid', 7.00),
  ('Nam Prik Ari Seasonal Clam', 7.00),
  ('Nam Prik Ari Dried Shrimp', 7.00),
  -- Special
  ('Hainanese Chicken', 15.99),
  ('Spicy Bamboo Salad', 15.99),
  ('Pork Blood Soup', 15.99),
  ('Jasmine Rice', 3.00),
  ('Sticky Rice', 3.00)
) as v(name, price)
where not exists (
  select 1 from public.dishes d where d.name = v.name
);
