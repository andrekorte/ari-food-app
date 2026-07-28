-- Seeds a typical ingredient list for the Ari Thai Street Food menu:
-- proteins, rice & noodles, vegetables & aromatics, sauces & liquids,
-- pastes & dry goods, drinks ingredients.
-- No prices are seeded on purpose — record each ingredient's first real
-- purchase in the app (amount bought, price paid, wastage) and the true
-- unit cost is calculated from that. Until then it shows "no price yet".
-- unit: 'kg' = bought by weight, 'l' = bought by volume (oil, sauces).
-- Safe to run more than once: existing names are skipped.

insert into public.ingredients (name, unit, updated_by)
select v.name, v.unit, 'menu import'
from (values
  -- Proteins
  ('Chicken thigh', 'kg'),
  ('Chicken breast', 'kg'),
  ('Whole chicken', 'kg'),
  ('Chicken wings', 'kg'),
  ('Pork mince', 'kg'),
  ('Pork shoulder', 'kg'),
  ('Pork belly', 'kg'),
  ('Pork bones (stock)', 'kg'),
  ('Beef (rump)', 'kg'),
  ('Prawns', 'kg'),
  ('Squid', 'kg'),
  ('White fish fillet', 'kg'),
  ('Fish balls', 'kg'),
  ('Pork balls', 'kg'),
  ('Eggs', 'kg'),
  ('Firm tofu', 'kg'),
  -- Rice & noodles
  ('Jasmine rice', 'kg'),
  ('Sticky rice (glutinous)', 'kg'),
  ('Thin rice noodles (sen lek)', 'kg'),
  ('Wide rice noodles (sen yai)', 'kg'),
  ('Kelp noodles', 'kg'),
  ('Glass noodles', 'kg'),
  ('Egg noodles', 'kg'),
  -- Vegetables & aromatics
  ('Garlic', 'kg'),
  ('Red chilli', 'kg'),
  ('Bird''s eye chilli', 'kg'),
  ('Dried chilli', 'kg'),
  ('Brown onion', 'kg'),
  ('Shallots', 'kg'),
  ('Spring onion', 'kg'),
  ('Coriander', 'kg'),
  ('Holy basil', 'kg'),
  ('Thai basil', 'kg'),
  ('Gai lan (Chinese broccoli)', 'kg'),
  ('Carrot', 'kg'),
  ('Cabbage', 'kg'),
  ('Bean sprouts', 'kg'),
  ('Tomato', 'kg'),
  ('Mushrooms', 'kg'),
  ('Baby corn', 'kg'),
  ('Snake beans', 'kg'),
  ('Bamboo shoots', 'kg'),
  ('Lemongrass', 'kg'),
  ('Galangal', 'kg'),
  ('Kaffir lime leaves', 'kg'),
  ('Lime', 'kg'),
  ('Ginger', 'kg'),
  ('Cucumber', 'kg'),
  ('Pickled mustard greens', 'kg'),
  ('Pickled radish', 'kg'),
  ('Mango', 'kg'),
  ('Durian (frozen)', 'kg'),
  ('Longan', 'kg'),
  ('Chrysanthemum flowers', 'kg'),
  -- Sauces & liquids (bought by volume)
  ('Vegetable oil', 'l'),
  ('Sesame oil', 'l'),
  ('Fish sauce', 'l'),
  ('Light soy sauce', 'l'),
  ('Dark soy sauce', 'l'),
  ('Sweet soy sauce', 'l'),
  ('Black soy sauce', 'l'),
  ('Oyster sauce', 'l'),
  ('Sriracha chilli sauce', 'l'),
  ('White vinegar', 'l'),
  ('Evaporated milk', 'l'),
  ('Coconut milk', 'l'),
  ('Coconut cream', 'l'),
  ('Sukiyaki sauce', 'l'),
  ('Red soda syrup (sala)', 'l'),
  ('Full cream milk', 'l'),
  -- Pastes & dry goods
  ('Red curry paste', 'kg'),
  ('Tom yum paste', 'kg'),
  ('Chilli jam (nam prik pao)', 'kg'),
  ('Tamarind paste', 'kg'),
  ('Shrimp paste', 'kg'),
  ('Condensed milk', 'kg'),
  ('Palm sugar', 'kg'),
  ('White sugar', 'kg'),
  ('Salt', 'kg'),
  ('White pepper', 'kg'),
  ('Black pepper', 'kg'),
  ('Chicken stock powder', 'kg'),
  ('Rice flour', 'kg'),
  ('Tapioca flour', 'kg'),
  ('Puff pastry (curry puff)', 'kg'),
  ('Spring roll wrappers', 'kg'),
  ('Crushed peanuts', 'kg'),
  ('Dried shrimp', 'kg'),
  ('Ice', 'kg'),
  -- Drinks ingredients
  ('Thai tea leaves', 'kg'),
  ('Black tea leaves', 'kg'),
  ('O-liang coffee powder', 'kg')
) as v(name, unit)
where not exists (
  select 1 from public.ingredients i where i.name = v.name
);
