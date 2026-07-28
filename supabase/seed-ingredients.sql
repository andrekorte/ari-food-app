-- Seeds a typical ingredient list for the Ari Thai Street Food menu:
-- proteins, rice & noodles, vegetables & aromatics, sauces & liquids,
-- pastes & dry goods, drinks ingredients.
-- No prices are seeded on purpose — record each ingredient's first real
-- purchase in the app (amount bought, price paid, wastage) and the true
-- unit cost is calculated from that. Until then it shows "no price yet".
-- unit: 'kg' = bought by weight, 'l' = bought by volume (oil, sauces).
-- Safe to run more than once: existing names are skipped.

insert into public.ingredients (name, unit, category, updated_by)
select v.name, v.unit, v.category, 'menu import'
from (values
  -- Proteins
  ('Chicken thigh', 'kg', 'meat'),
  ('Chicken breast', 'kg', 'meat'),
  ('Whole chicken', 'kg', 'meat'),
  ('Chicken wings', 'kg', 'meat'),
  ('Pork mince', 'kg', 'meat'),
  ('Pork shoulder', 'kg', 'meat'),
  ('Pork belly', 'kg', 'meat'),
  ('Pork bones (stock)', 'kg', 'meat'),
  ('Beef (rump)', 'kg', 'meat'),
  ('Prawns', 'kg', 'meat'),
  ('Squid', 'kg', 'meat'),
  ('White fish fillet', 'kg', 'meat'),
  ('Fish balls', 'kg', 'meat'),
  ('Pork balls', 'kg', 'meat'),
  ('Eggs', 'kg', 'meat'),
  ('Firm tofu', 'kg', 'meat'),
  -- Rice & noodles
  ('Jasmine rice', 'kg', 'other'),
  ('Sticky rice (glutinous)', 'kg', 'other'),
  ('Thin rice noodles (sen lek)', 'kg', 'other'),
  ('Wide rice noodles (sen yai)', 'kg', 'other'),
  ('Kelp noodles', 'kg', 'other'),
  ('Glass noodles', 'kg', 'other'),
  ('Egg noodles', 'kg', 'other'),
  -- Vegetables & aromatics
  ('Garlic', 'kg', 'veg'),
  ('Red chilli', 'kg', 'veg'),
  ('Bird''s eye chilli', 'kg', 'veg'),
  ('Dried chilli', 'kg', 'veg'),
  ('Brown onion', 'kg', 'veg'),
  ('Shallots', 'kg', 'veg'),
  ('Spring onion', 'kg', 'veg'),
  ('Coriander', 'kg', 'veg'),
  ('Holy basil', 'kg', 'veg'),
  ('Thai basil', 'kg', 'veg'),
  ('Gai lan (Chinese broccoli)', 'kg', 'veg'),
  ('Carrot', 'kg', 'veg'),
  ('Cabbage', 'kg', 'veg'),
  ('Bean sprouts', 'kg', 'veg'),
  ('Tomato', 'kg', 'veg'),
  ('Mushrooms', 'kg', 'veg'),
  ('Baby corn', 'kg', 'veg'),
  ('Snake beans', 'kg', 'veg'),
  ('Bamboo shoots', 'kg', 'veg'),
  ('Lemongrass', 'kg', 'veg'),
  ('Galangal', 'kg', 'veg'),
  ('Kaffir lime leaves', 'kg', 'veg'),
  ('Lime', 'kg', 'veg'),
  ('Ginger', 'kg', 'veg'),
  ('Cucumber', 'kg', 'veg'),
  ('Pickled mustard greens', 'kg', 'veg'),
  ('Pickled radish', 'kg', 'veg'),
  ('Mango', 'kg', 'veg'),
  ('Durian (frozen)', 'kg', 'veg'),
  ('Longan', 'kg', 'veg'),
  ('Chrysanthemum flowers', 'kg', 'veg'),
  -- Sauces & liquids (bought by volume)
  ('Vegetable oil', 'l', 'sauce'),
  ('Sesame oil', 'l', 'sauce'),
  ('Fish sauce', 'l', 'sauce'),
  ('Light soy sauce', 'l', 'sauce'),
  ('Dark soy sauce', 'l', 'sauce'),
  ('Sweet soy sauce', 'l', 'sauce'),
  ('Black soy sauce', 'l', 'sauce'),
  ('Oyster sauce', 'l', 'sauce'),
  ('Sriracha chilli sauce', 'l', 'sauce'),
  ('White vinegar', 'l', 'sauce'),
  ('Evaporated milk', 'l', 'sauce'),
  ('Coconut milk', 'l', 'sauce'),
  ('Coconut cream', 'l', 'sauce'),
  ('Sukiyaki sauce', 'l', 'sauce'),
  ('Red soda syrup (sala)', 'l', 'sauce'),
  ('Full cream milk', 'l', 'sauce'),
  -- Pastes & dry goods
  ('Red curry paste', 'kg', 'sauce'),
  ('Tom yum paste', 'kg', 'sauce'),
  ('Chilli jam (nam prik pao)', 'kg', 'sauce'),
  ('Tamarind paste', 'kg', 'sauce'),
  ('Shrimp paste', 'kg', 'sauce'),
  ('Condensed milk', 'kg', 'sauce'),
  ('Palm sugar', 'kg', 'sauce'),
  ('White sugar', 'kg', 'sauce'),
  ('Salt', 'kg', 'sauce'),
  ('White pepper', 'kg', 'sauce'),
  ('Black pepper', 'kg', 'sauce'),
  ('Chicken stock powder', 'kg', 'sauce'),
  ('Rice flour', 'kg', 'other'),
  ('Tapioca flour', 'kg', 'other'),
  ('Puff pastry (curry puff)', 'kg', 'other'),
  ('Spring roll wrappers', 'kg', 'other'),
  ('Crushed peanuts', 'kg', 'other'),
  ('Dried shrimp', 'kg', 'other'),
  ('Ice', 'kg', 'other'),
  -- Drinks ingredients
  ('Thai tea leaves', 'kg', 'other'),
  ('Black tea leaves', 'kg', 'other'),
  ('O-liang coffee powder', 'kg', 'other')
) as v(name, unit, category)
where not exists (
  select 1 from public.ingredients i where i.name = v.name
);
