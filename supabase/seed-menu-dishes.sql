-- Seeds the dish list from ari-thaistreetfood.com/menu (July 2026),
-- with current selling prices. Ingredients/recipes are added later in
-- the app; until then a dish shows no cost.
-- Safe to run more than once: dishes that already exist (same name)
-- are skipped. Run in the Supabase SQL editor.

insert into public.dishes (name, selling_price, category, updated_by)
select v.name, v.price, v.category, 'menu import'
from (values
  -- Ala Carte
  ('Pad Kra Pow on Rice', 16.99, 'ala_carte'),
  ('Thai Fried Rice', 16.99, 'ala_carte'),
  ('Spicy Basil Fried Rice', 16.99, 'ala_carte'),
  ('Tom Yum Fried Rice', 16.99, 'ala_carte'),
  ('Chili Jam Stir Fry on Rice', 16.99, 'ala_carte'),
  ('Garlic & Pepper Stir Fry on Rice', 16.99, 'ala_carte'),
  ('Red Curry Paste Stir Fried', 16.99, 'ala_carte'),
  ('Gai-Lan (Kana) Oyster Sauce over Rice', 16.99, 'ala_carte'),
  ('Chilli Salt Stir-Fry on Rice', 16.99, 'ala_carte'),
  ('Pad See Eiw', 16.99, 'ala_carte'),
  ('Pad Thai', 16.99, 'ala_carte'),
  ('Pad Kee Mao with Rice Noodles', 16.99, 'ala_carte'),
  ('Sen Kaeaw Salad – Kelp Noodle', 16.99, 'ala_carte'),
  ('Dry Sukiyaki Kelp Noodles', 16.99, 'ala_carte'),
  ('Tum Sen Lek – Thin Rice Noodle Salad', 16.99, 'ala_carte'),
  -- Noodle Soup
  ('Clear Noodle Soup', 16.99, 'noodle_soup'),
  ('Creamy Tom Yum Noodles', 16.99, 'noodle_soup'),
  ('Spicy and Sour Soup', 16.99, 'noodle_soup'),
  ('Boat Noodles', 16.99, 'noodle_soup'),
  ('Pink Noodle Sauce', 16.99, 'noodle_soup'),
  ('Dry Noodles with Black Soy Sauce', 16.99, 'noodle_soup'),
  -- Entree
  ('Moo Ping – Pork Skewers', 3.50, 'entree'),
  ('Set Moo Ping (Pork Skewers)', 12.99, 'entree'),
  ('Thai Fish Cake (1 pc)', 1.50, 'entree'),
  ('Spring Roll (1 pc)', 2.00, 'entree'),
  ('Sour Pork (1 pc)', 3.50, 'entree'),
  ('Sour Pork (3 pcs)', 10.00, 'entree'),
  ('Chicken Dim Sim (4 pcs)', 9.00, 'entree'),
  ('Chicken Dim Sim (1 pc)', 2.30, 'entree'),
  ('Chicken Wing Zap', 3.00, 'entree'),
  ('Curry Puff', 3.00, 'entree'),
  ('Thai Sausage', 4.00, 'entree'),
  -- Vegan
  ('Thai Fried Rice (Vegan)', 16.99, 'vegan'),
  ('Garlic and Pepper (Vegan)', 16.99, 'vegan'),
  ('Pad Ka Praw (Vegan)', 16.99, 'vegan'),
  ('Spicy Basil Fried Rice (Vegan)', 16.99, 'vegan'),
  ('Thai Salt and Chili (Vegan)', 16.99, 'vegan'),
  ('Chili Jam Stir Fried (Vegan)', 16.99, 'vegan'),
  ('Pad Kee Mao (Vegan)', 16.99, 'vegan'),
  ('Red Curry Stir Fried (Vegan)', 16.99, 'vegan'),
  ('Gai-Lan (Kana) Oyster Sauce (Vegan)', 16.99, 'vegan'),
  ('Sen Keaw Salad (Vegan)', 16.99, 'vegan'),
  -- Gluten Free
  ('Thai Fried Rice (GF)', 16.99, 'gluten_free'),
  ('Garlic and Pepper (GF)', 16.99, 'gluten_free'),
  ('Pad Ka Praw (GF)', 16.99, 'gluten_free'),
  ('Spicy Basil Fried Rice (GF)', 16.99, 'gluten_free'),
  ('Thai Salt and Chili (GF)', 16.99, 'gluten_free'),
  ('Chili Jam Stir Fried (GF)', 16.99, 'gluten_free'),
  ('Red Curry Paste Stir Fried (GF)', 16.99, 'gluten_free'),
  ('Gai-Lan (Kana) Oyster Sauce (GF)', 16.99, 'gluten_free'),
  ('Pad Kee Mao (GF)', 16.99, 'gluten_free'),
  ('Sen Keaw Salad (GF)', 16.99, 'gluten_free'),
  ('Dry Sukiyaki (GF)', 16.99, 'gluten_free'),
  ('Tum Sen Lek Salad (GF)', 16.99, 'gluten_free'),
  -- Ari's Drinks
  ('Thai Milk Tea', 7.00, 'drinks'),
  ('Thai Black Tea', 7.00, 'drinks'),
  ('Thai Lemon Tea', 7.00, 'drinks'),
  ('Chrysanthemum Tea', 7.00, 'drinks'),
  ('Longan Juice', 7.00, 'drinks'),
  ('Pinky Milky', 7.00, 'drinks'),
  ('O-Liang Black Coffee', 7.00, 'drinks'),
  ('Thai Red Soda', 7.00, 'drinks'),
  -- Dessert
  ('Mango Sticky Rice', 14.99, 'dessert'),
  ('Durian', 41.00, 'dessert'),
  -- Thai Snacks
  ('Beef Jerky', 12.00, 'snacks'),
  ('Chilli Oil', 7.00, 'snacks'),
  ('Crispy Pork Crackers', 12.00, 'snacks'),
  ('Jaew Bong', 12.00, 'snacks'),
  ('Mango Sweet & Sour', 3.20, 'snacks'),
  ('Nam Prik Namyoi', 7.00, 'snacks'),
  ('Pork Jerky', 12.00, 'snacks'),
  ('Spicy Crispy Pork Cracker (Small)', 7.00, 'snacks'),
  ('Thai Dip Seafood (Small)', 7.00, 'snacks'),
  ('Nam Prik Ari Mackerel Fish', 7.00, 'snacks'),
  ('Nam Prik Ari Pla Salid', 7.00, 'snacks'),
  ('Nam Prik Ari Seasonal Clam', 7.00, 'snacks'),
  ('Nam Prik Ari Dried Shrimp', 7.00, 'snacks'),
  -- Special
  ('Hainanese Chicken', 15.99, 'special'),
  ('Spicy Bamboo Salad', 15.99, 'special'),
  ('Pork Blood Soup', 15.99, 'special'),
  ('Jasmine Rice', 3.00, 'special'),
  ('Sticky Rice', 3.00, 'special')
) as v(name, price, category)
where not exists (
  select 1 from public.dishes d where d.name = v.name
);
