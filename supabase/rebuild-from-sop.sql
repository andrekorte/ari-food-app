-- Food tracker: rebuild ingredients, sauces and dish recipes from the
-- Ari / Yindee SOPs (A la carte, Noodle menu, Hot bar, YINDEE SOP xlsx).
-- Run AFTER migration-2026-08-01-sop-rebuild-schema.sql.
-- WARNING: this deletes all existing ingredients, sauces, recipes,
-- purchases and stock levels (all dummy data) and replaces them.

begin;

-- 1. Clear the old artificial data --------------------------------
delete from public.dish_ingredients;
delete from public.sauce_ingredients;
delete from public.sauces;
delete from public.protein_options;
delete from public.stock_levels;
delete from public.purchases;
delete from public.ingredients;

-- Remove bought-in dishes that are not cooked in-house
delete from public.dishes where category in ('snacks','dessert','entree','special');

-- 2. Ingredients --------------------------------------------------
insert into public.ingredients (name, name_th, unit, category, updated_by) values
  ('Chicken slice', 'เนื้อไก่สไลด์', 'kg', 'meat', 'SOP import'),
  ('Chicken curry cut', 'ไก่สำหรับแกง', 'kg', 'meat', 'SOP import'),
  ('Chicken carcass', 'โครงไก่', 'kg', 'meat', 'SOP import'),
  ('Pork slice', 'เนื้อหมูสไลด์', 'kg', 'meat', 'SOP import'),
  ('Pork mince', 'หมูสับ', 'kg', 'meat', 'SOP import'),
  ('Beef slice', 'เนื้อวัวสไลด์', 'kg', 'meat', 'SOP import'),
  ('Prawns', 'กุ้ง', 'kg', 'meat', 'SOP import'),
  ('Squid', 'ปลาหมึก', 'kg', 'meat', 'SOP import'),
  ('Crispy pork', 'หมูกรอบ', 'kg', 'meat', 'SOP import'),
  ('Firm tofu', 'เต้าหู้แข็ง', 'kg', 'meat', 'SOP import'),
  ('Meatballs', 'ลูกชิ้น', 'kg', 'meat', 'SOP import'),
  ('Fish balls', 'ลูกชิ้นปลา', 'kg', 'meat', 'SOP import'),
  ('Eggs', 'ไข่ไก่', 'kg', 'meat', 'SOP import'),
  ('Duck blood', 'เลือดเป็ด', 'kg', 'meat', 'SOP import'),
  ('Pork blood', 'เลือดหมู', 'kg', 'meat', 'SOP import'),
  ('Fish strips', 'ปลาเส้น', 'kg', 'meat', 'SOP import'),
  ('Pork crackling', 'กากหมู', 'kg', 'meat', 'SOP import'),
  ('Brown onion', 'หอมหัวใหญ่', 'kg', 'veg', 'SOP import'),
  ('Shallots', 'หอมแดง', 'kg', 'veg', 'SOP import'),
  ('Spring onion', 'ต้นหอม', 'kg', 'veg', 'SOP import'),
  ('Tomato', 'มะเขือเทศ', 'kg', 'veg', 'SOP import'),
  ('Gai lan (Chinese broccoli)', 'ผักคะน้า', 'kg', 'veg', 'SOP import'),
  ('Chinese cabbage', 'ผักกาดขาว', 'kg', 'veg', 'SOP import'),
  ('Cabbage', 'กะหล่ำปลี', 'kg', 'veg', 'SOP import'),
  ('Choy sum', 'ผักกวางตุ้ง', 'kg', 'veg', 'SOP import'),
  ('Morning glory', 'ผักบุ้ง', 'kg', 'veg', 'SOP import'),
  ('Bean sprouts', 'ถั่วงอก', 'kg', 'veg', 'SOP import'),
  ('Garlic chives', 'กุยช่าย', 'kg', 'veg', 'SOP import'),
  ('Snake beans', 'ถั่วฝักยาว', 'kg', 'veg', 'SOP import'),
  ('Carrot', 'แครอท', 'kg', 'veg', 'SOP import'),
  ('Capsicum', 'พริกหวาน', 'kg', 'veg', 'SOP import'),
  ('Zucchini', 'ซูกินี', 'kg', 'veg', 'SOP import'),
  ('Broccoli', 'บรอกโคลี', 'kg', 'veg', 'SOP import'),
  ('Baby corn', 'ข้าวโพดอ่อน', 'kg', 'veg', 'SOP import'),
  ('Eggplant', 'มะเขือ', 'kg', 'veg', 'SOP import'),
  ('Potato', 'มันฝรั่ง', 'kg', 'veg', 'SOP import'),
  ('Water chestnuts', 'แห้ว', 'kg', 'veg', 'SOP import'),
  ('Mushrooms', 'เห็ด', 'kg', 'veg', 'SOP import'),
  ('Enoki mushrooms', 'เห็ดเข็มทอง', 'kg', 'veg', 'SOP import'),
  ('Mixed stir-fry vegetables', 'ชุดผัดรวม', 'kg', 'veg', 'SOP import'),
  ('Garlic', 'กระเทียมสด', 'kg', 'veg', 'SOP import'),
  ('Red chilli', 'พริกแดง', 'kg', 'veg', 'SOP import'),
  ('Green chilli', 'พริกเขียว', 'kg', 'veg', 'SOP import'),
  ('Bird''s eye chilli', 'พริกขี้หนู', 'kg', 'veg', 'SOP import'),
  ('Dried chilli', 'พริกแห้ง', 'kg', 'veg', 'SOP import'),
  ('Holy basil', 'ใบกระเพรา', 'kg', 'veg', 'SOP import'),
  ('Thai basil', 'ใบโหระพา', 'kg', 'veg', 'SOP import'),
  ('Coriander', 'ผักชี', 'kg', 'veg', 'SOP import'),
  ('Coriander root', 'รากผักชี', 'kg', 'veg', 'SOP import'),
  ('Lemongrass', 'ตะไคร้', 'kg', 'veg', 'SOP import'),
  ('Galangal', 'ข่า', 'kg', 'veg', 'SOP import'),
  ('Fingerroot', 'กระชาย', 'kg', 'veg', 'SOP import'),
  ('Young green peppercorns', 'พริกไทยอ่อน', 'kg', 'veg', 'SOP import'),
  ('Kaffir lime leaves', 'ใบมะกรูด', 'kg', 'veg', 'SOP import'),
  ('Pandan leaves', 'ใบเตย', 'kg', 'veg', 'SOP import'),
  ('Daikon radish', 'หัวไชเท้า', 'kg', 'veg', 'SOP import'),
  ('Lime', 'มะนาว', 'kg', 'veg', 'SOP import'),
  ('Oyster sauce', 'น้ำมันหอย', 'l', 'sauce', 'SOP import'),
  ('Light soy sauce', 'ซีอิ๊วขาว', 'l', 'sauce', 'SOP import'),
  ('Seasoning sauce (green cap)', 'ซอสปรุงรสฝาเขียว', 'l', 'sauce', 'SOP import'),
  ('Seasoning sauce (white cap)', 'ซอสปรุงรสฝาขาว', 'l', 'sauce', 'SOP import'),
  ('ABC sweet soy sauce', 'ซอส ABC', 'l', 'sauce', 'SOP import'),
  ('Shiitake mushroom sauce', 'ซอสเห็ดหอม', 'l', 'sauce', 'SOP import'),
  ('Fish sauce', 'น้ำปลา', 'l', 'sauce', 'SOP import'),
  ('Fermented fish sauce (pla ra)', 'น้ำปลาร้า', 'l', 'sauce', 'SOP import'),
  ('White vinegar', 'น้ำส้มสายชู', 'l', 'sauce', 'SOP import'),
  ('Sriracha sauce', 'ซอสศรีราชา', 'l', 'sauce', 'SOP import'),
  ('Tomato sauce', 'ซอสมะเขือเทศ', 'l', 'sauce', 'SOP import'),
  ('Sesame oil', 'น้ำมันงา', 'l', 'sauce', 'SOP import'),
  ('Vegetable oil', 'น้ำมันพืช', 'l', 'sauce', 'SOP import'),
  ('Fried garlic oil', 'น้ำมันกระเทียมเจียว', 'l', 'sauce', 'SOP import'),
  ('Coconut milk', 'กะทิ', 'l', 'sauce', 'SOP import'),
  ('Evaporated milk', 'นมข้นจืด', 'l', 'sauce', 'SOP import'),
  ('Tamarind juice', 'น้ำมะขาม', 'l', 'sauce', 'SOP import'),
  ('Fresh lime juice', 'น้ำมะนาวสด', 'l', 'sauce', 'SOP import'),
  ('Water', 'น้ำเปล่า', 'l', 'sauce', 'SOP import'),
  ('Yentafo sauce (Penta)', 'ซอสเย็นตาโฟเพนต้า', 'kg', 'sauce', 'SOP import'),
  ('Tom yum paste (Penta)', 'ต้มยำเพนต้า', 'kg', 'sauce', 'SOP import'),
  ('Chilli jam (nam prik pao)', 'น้ำพริกเผา', 'kg', 'sauce', 'SOP import'),
  ('Chilli jam oil', 'น้ำมันพริกเผา', 'l', 'sauce', 'SOP import'),
  ('Red curry paste', 'พริกแกงแดง', 'kg', 'sauce', 'SOP import'),
  ('Green curry paste', 'พริกแกงเขียวหวาน', 'kg', 'sauce', 'SOP import'),
  ('Massaman curry paste', 'พริกแกงมัสมั่น', 'kg', 'sauce', 'SOP import'),
  ('Fermented bean curd', 'เต้าหู้ยี้', 'kg', 'sauce', 'SOP import'),
  ('Pickled garlic', 'กระเทียมดอง', 'kg', 'sauce', 'SOP import'),
  ('Sweet pickled radish', 'ไชโป๊หวาน', 'kg', 'sauce', 'SOP import'),
  ('White sugar', 'น้ำตาลทราย', 'kg', 'sauce', 'SOP import'),
  ('Palm sugar', 'น้ำตาลปี๊บ', 'kg', 'sauce', 'SOP import'),
  ('Rock sugar', 'น้ำตาลกรวด', 'kg', 'sauce', 'SOP import'),
  ('Salt', 'เกลือ', 'kg', 'sauce', 'SOP import'),
  ('MSG', 'ผงชูรส', 'kg', 'sauce', 'SOP import'),
  ('Knorr seasoning powder', 'ผงปรุงรสคนอร์', 'kg', 'sauce', 'SOP import'),
  ('White pepper', 'พริกไทยขาว', 'kg', 'sauce', 'SOP import'),
  ('Chilli powder', 'พริกป่น', 'kg', 'sauce', 'SOP import'),
  ('Paprika powder', 'ผงปาปริก้า', 'kg', 'sauce', 'SOP import'),
  ('Lime powder', 'ผงมะนาว', 'kg', 'sauce', 'SOP import'),
  ('Star anise', 'โป๊ยกั๊ก', 'kg', 'sauce', 'SOP import'),
  ('Cinnamon', 'อบเชย', 'kg', 'sauce', 'SOP import'),
  ('Coriander seed', 'เม็ดผักชี', 'kg', 'sauce', 'SOP import'),
  ('Boat noodle powder', 'ผงก๋วยเตี๋ยวเรือ', 'kg', 'sauce', 'SOP import'),
  ('Chicken noodle powder', 'ผงก๋วยเตี๋ยวไก่', 'kg', 'sauce', 'SOP import'),
  ('Bicarbonate of soda', 'เบกกิ้งโซดา', 'kg', 'sauce', 'SOP import'),
  ('Jasmine rice (raw)', 'ข้าวหอมมะลิ', 'kg', 'other', 'SOP import'),
  ('Thin rice noodles (sen lek)', 'เส้นเล็ก', 'kg', 'other', 'SOP import'),
  ('Wide rice noodles (sen yai)', 'เส้นใหญ่', 'kg', 'other', 'SOP import'),
  ('Kelp noodles (sen kaew)', 'เส้นแก้ว', 'kg', 'other', 'SOP import'),
  ('Fried garlic', 'กระเทียมเจียว', 'kg', 'other', 'SOP import'),
  ('Fried shallots', 'หอมเจียว', 'kg', 'other', 'SOP import'),
  ('Fried wonton', 'เกี๊ยวทอด', 'kg', 'other', 'SOP import'),
  ('Crushed peanuts', 'ถั่วลิสงบด', 'kg', 'other', 'SOP import'),
  ('Cashew nuts', 'เม็ดมะม่วงหิมพานต์', 'kg', 'other', 'SOP import'),
  ('White sesame seeds', 'งาขาว', 'kg', 'other', 'SOP import'),
  ('Tapioca flour', 'แป้งมัน', 'kg', 'other', 'SOP import');

-- 3. Sauces -------------------------------------------------------
insert into public.sauces (name, name_th, updated_by) values
  ('Stir-fry sauce', 'ซอสผัด', 'SOP import'),
  ('Pad Thai sauce', 'ซอสผัดไทย', 'SOP import'),
  ('Vegan stir-fry sauce', 'ซอสผัดเจ', 'SOP import'),
  ('GF stir-fry sauce', 'ซอสผัดปลอดกลูเตน', 'SOP import'),
  ('Boat noodle soup', 'ซุปก๋วยเตี๋ยวเรือ', 'SOP import'),
  ('Clear noodle soup', 'ซุปก๋วยเตี๋ยวน้ำใส', 'SOP import'),
  ('Yentafo sauce', 'ซอสเย็นตาโฟ', 'SOP import'),
  ('Tom Yum stir-fry sauce', 'ซอสผัดต้มยำ', 'SOP import'),
  ('Dry noodle sauce', 'ซอสก๋วยเตี๋ยวแห้ง', 'SOP import'),
  ('Spicy & sour paste (clear tom yum)', 'เพสต้มยำน้ำใส', 'SOP import'),
  ('Creamy Tom Yum paste', 'เพสต้มยำน้ำข้น', 'SOP import'),
  ('Sukiyaki sauce', 'น้ำจิ้มสุกี้', 'SOP import'),
  ('Massaman curry sauce', 'แกงมัสมั่น', 'SOP import'),
  ('Cashew nut / chilli jam sauce', 'ซอสแคชชูนัท', 'SOP import'),
  ('Green curry sauce', 'แกงเขียวหวาน', 'SOP import'),
  ('Red curry sauce', 'แกงแดง', 'SOP import'),
  ('Chilli vinegar', 'พริกน้ำส้ม', 'SOP import'),
  ('Noodle base sauce', 'น้ำรองก๋วยเตี๋ยว', 'SOP import'),
  ('Lime juice mix', 'น้ำมะนาวผสม', 'SOP import'),
  ('Ajard (cucumber relish liquid)', 'น้ำอาจาด', 'SOP import'),
  ('Meat marinade (per 1 kg meat)', 'หมักเนื้อสัตว์', 'SOP import'),
  ('Chestnut sauce', 'ซอสแห้ว', 'SOP import'),
  ('Yum dressing', 'น้ำยำ', 'SOP import');

-- 4. Sauce recipes (ingredients and nested sauces) -----------------
-- Stir-fry sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Stir-fry sauce'), (select id from public.ingredients where name = 'Oyster sauce'), null::uuid, 9080),
  ((select id from public.sauces where name = 'Stir-fry sauce'), (select id from public.ingredients where name = 'Light soy sauce'), null::uuid, 2600),
  ((select id from public.sauces where name = 'Stir-fry sauce'), (select id from public.ingredients where name = 'Seasoning sauce (green cap)'), null::uuid, 2200),
  ((select id from public.sauces where name = 'Stir-fry sauce'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 2200),
  ((select id from public.sauces where name = 'Stir-fry sauce'), (select id from public.ingredients where name = 'Knorr seasoning powder'), null::uuid, 400);
-- Pad Thai sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'Tamarind juice'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'Palm sugar'), null::uuid, 3000),
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'Salt'), null::uuid, 100),
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 700),
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'Tomato sauce'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'Oyster sauce'), null::uuid, 700),
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'White vinegar'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'Paprika powder'), null::uuid, 100);
-- Vegan stir-fry sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Vegan stir-fry sauce'), (select id from public.ingredients where name = 'Shiitake mushroom sauce'), null::uuid, 5600),
  ((select id from public.sauces where name = 'Vegan stir-fry sauce'), (select id from public.ingredients where name = 'Light soy sauce'), null::uuid, 600),
  ((select id from public.sauces where name = 'Vegan stir-fry sauce'), (select id from public.ingredients where name = 'Seasoning sauce (green cap)'), null::uuid, 460),
  ((select id from public.sauces where name = 'Vegan stir-fry sauce'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Vegan stir-fry sauce'), (select id from public.ingredients where name = 'ABC sweet soy sauce'), null::uuid, 660);
-- GF stir-fry sauce: recipe not in the SOP yet
-- Boat noodle soup
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Water'), null::uuid, 16000),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Chicken carcass'), null::uuid, 3600),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Star anise'), null::uuid, 20),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Cinnamon'), null::uuid, 20),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Coriander root'), null::uuid, 60),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Knorr seasoning powder'), null::uuid, 75),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Galangal'), null::uuid, 60),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 100),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Pandan leaves'), null::uuid, 30),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 10),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Boat noodle powder'), null::uuid, 150),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Fermented bean curd'), null::uuid, 70),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Oyster sauce'), null::uuid, 100),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Seasoning sauce (green cap)'), null::uuid, 50),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Seasoning sauce (white cap)'), null::uuid, 50),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'ABC sweet soy sauce'), null::uuid, 100),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Salt'), null::uuid, 30),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Palm sugar'), null::uuid, 300),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Rock sugar'), null::uuid, 200),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Fried shallots'), null::uuid, 200),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Pickled garlic'), null::uuid, 70),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Coriander seed'), null::uuid, 20),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Coconut milk'), null::uuid, 200),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'MSG'), null::uuid, 75),
  ((select id from public.sauces where name = 'Boat noodle soup'), (select id from public.ingredients where name = 'Pork blood'), null::uuid, 2000);
-- Clear noodle soup
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Water'), null::uuid, 16000),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Knorr seasoning powder'), null::uuid, 200),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Daikon radish'), null::uuid, 800),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Pandan leaves'), null::uuid, 20),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 10),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Coriander root'), null::uuid, 60),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 60),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Salt'), null::uuid, 30),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Chicken carcass'), null::uuid, 3600),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Rock sugar'), null::uuid, 250),
  ((select id from public.sauces where name = 'Clear noodle soup'), (select id from public.ingredients where name = 'Chicken noodle powder'), null::uuid, 225);
-- Yentafo sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Tomato sauce'), null::uuid, 400),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Sriracha sauce'), null::uuid, 400),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Fermented bean curd'), null::uuid, 220),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 200),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'White vinegar'), null::uuid, 250),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Light soy sauce'), null::uuid, 80),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Oyster sauce'), null::uuid, 200),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Pickled garlic'), null::uuid, 100),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 70),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 10),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Salt'), null::uuid, 20),
  ((select id from public.sauces where name = 'Yentafo sauce'), (select id from public.ingredients where name = 'Yentafo sauce (Penta)'), null::uuid, 454);
-- Tom Yum stir-fry sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Tom Yum stir-fry sauce'), (select id from public.ingredients where name = 'Tom yum paste (Penta)'), null::uuid, 5400),
  ((select id from public.sauces where name = 'Tom Yum stir-fry sauce'), (select id from public.ingredients where name = 'Chilli jam (nam prik pao)'), null::uuid, 3200),
  ((select id from public.sauces where name = 'Tom Yum stir-fry sauce'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 600),
  ((select id from public.sauces where name = 'Tom Yum stir-fry sauce'), (select id from public.ingredients where name = 'Water'), null::uuid, 200),
  ((select id from public.sauces where name = 'Tom Yum stir-fry sauce'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 3000);
-- Dry noodle sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Dry noodle sauce'), (select id from public.ingredients where name = 'Light soy sauce'), null::uuid, 200),
  ((select id from public.sauces where name = 'Dry noodle sauce'), (select id from public.ingredients where name = 'Seasoning sauce (green cap)'), null::uuid, 600),
  ((select id from public.sauces where name = 'Dry noodle sauce'), (select id from public.ingredients where name = 'ABC sweet soy sauce'), null::uuid, 1200),
  ((select id from public.sauces where name = 'Dry noodle sauce'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 800),
  ((select id from public.sauces where name = 'Dry noodle sauce'), (select id from public.ingredients where name = 'Palm sugar'), null::uuid, 200),
  ((select id from public.sauces where name = 'Dry noodle sauce'), (select id from public.ingredients where name = 'Sriracha sauce'), null::uuid, 400),
  ((select id from public.sauces where name = 'Dry noodle sauce'), (select id from public.ingredients where name = 'White vinegar'), null::uuid, 200);
-- Spicy & sour paste (clear tom yum)
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Spicy & sour paste (clear tom yum)'), (select id from public.ingredients where name = 'Lime powder'), null::uuid, 250),
  ((select id from public.sauces where name = 'Spicy & sour paste (clear tom yum)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 1800),
  ((select id from public.sauces where name = 'Spicy & sour paste (clear tom yum)'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 2025),
  ((select id from public.sauces where name = 'Spicy & sour paste (clear tom yum)'), (select id from public.ingredients where name = 'White vinegar'), null::uuid, 450),
  ((select id from public.sauces where name = 'Spicy & sour paste (clear tom yum)'), (select id from public.ingredients where name = 'Water'), null::uuid, 2250);
-- Creamy Tom Yum paste
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), (select id from public.ingredients where name = 'Tom yum paste (Penta)'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), (select id from public.ingredients where name = 'Chilli jam (nam prik pao)'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), (select id from public.ingredients where name = 'Chilli jam oil'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), (select id from public.ingredients where name = 'Tamarind juice'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), (select id from public.ingredients where name = 'Salt'), null::uuid, 600),
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 400),
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), null::uuid, (select id from public.sauces where name = 'Lime juice mix'), 800);
-- Sukiyaki sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'Sriracha sauce'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'Tomato sauce'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 520),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 300),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 80),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'White vinegar'), null::uuid, 300),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'Sesame oil'), null::uuid, 100),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'Pickled garlic'), null::uuid, 140),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 250),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'Light soy sauce'), null::uuid, 200),
  ((select id from public.sauces where name = 'Sukiyaki sauce'), (select id from public.ingredients where name = 'White sesame seeds'), null::uuid, 400);
-- Massaman curry sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Massaman curry paste'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Tamarind juice'), null::uuid, 500),
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Palm sugar'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 50),
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Salt'), null::uuid, 30),
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Coconut milk'), null::uuid, 2500),
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Water'), null::uuid, 500),
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Star anise'), null::uuid, 10),
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Cinnamon'), null::uuid, 10);
-- Cashew nut / chilli jam sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Cashew nut / chilli jam sauce'), (select id from public.ingredients where name = 'Chilli jam (nam prik pao)'), null::uuid, 9000),
  ((select id from public.sauces where name = 'Cashew nut / chilli jam sauce'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 3000),
  ((select id from public.sauces where name = 'Cashew nut / chilli jam sauce'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 600),
  ((select id from public.sauces where name = 'Cashew nut / chilli jam sauce'), (select id from public.ingredients where name = 'Water'), null::uuid, 300);
-- Green curry sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Kaffir lime leaves'), null::uuid, 5),
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Green curry paste'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Knorr seasoning powder'), null::uuid, 50),
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Salt'), null::uuid, 20),
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 30),
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Coconut milk'), null::uuid, 5000),
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Water'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Palm sugar'), null::uuid, 550),
  ((select id from public.sauces where name = 'Green curry sauce'), (select id from public.ingredients where name = 'Vegetable oil'), null::uuid, 250);
-- Red curry sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Kaffir lime leaves'), null::uuid, 5),
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Red curry paste'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Knorr seasoning powder'), null::uuid, 50),
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Salt'), null::uuid, 20),
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 30),
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Coconut milk'), null::uuid, 5000),
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Water'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Palm sugar'), null::uuid, 550),
  ((select id from public.sauces where name = 'Red curry sauce'), (select id from public.ingredients where name = 'Vegetable oil'), null::uuid, 250);
-- Chilli vinegar
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Chilli vinegar'), (select id from public.ingredients where name = 'Green chilli'), null::uuid, 500),
  ((select id from public.sauces where name = 'Chilli vinegar'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 500),
  ((select id from public.sauces where name = 'Chilli vinegar'), (select id from public.ingredients where name = 'White vinegar'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Chilli vinegar'), (select id from public.ingredients where name = 'Salt'), null::uuid, 20);
-- Noodle base sauce
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Noodle base sauce'), null::uuid, (select id from public.sauces where name = 'Chilli vinegar'), 1000),
  ((select id from public.sauces where name = 'Noodle base sauce'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 500),
  ((select id from public.sauces where name = 'Noodle base sauce'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 500),
  ((select id from public.sauces where name = 'Noodle base sauce'), (select id from public.ingredients where name = 'Chilli powder'), null::uuid, 250),
  ((select id from public.sauces where name = 'Noodle base sauce'), (select id from public.ingredients where name = 'MSG'), null::uuid, 100),
  ((select id from public.sauces where name = 'Noodle base sauce'), (select id from public.ingredients where name = 'White vinegar'), null::uuid, 1000);
-- Lime juice mix
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Lime juice mix'), (select id from public.ingredients where name = 'Fresh lime juice'), null::uuid, 60),
  ((select id from public.sauces where name = 'Lime juice mix'), (select id from public.ingredients where name = 'Lime powder'), null::uuid, 100),
  ((select id from public.sauces where name = 'Lime juice mix'), (select id from public.ingredients where name = 'Water'), null::uuid, 300);
-- Ajard (cucumber relish liquid)
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Ajard (cucumber relish liquid)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 2000),
  ((select id from public.sauces where name = 'Ajard (cucumber relish liquid)'), (select id from public.ingredients where name = 'White vinegar'), null::uuid, 1000),
  ((select id from public.sauces where name = 'Ajard (cucumber relish liquid)'), (select id from public.ingredients where name = 'Salt'), null::uuid, 20);
-- Meat marinade (per 1 kg meat)
insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values
  ((select id from public.sauces where name = 'Meat marinade (per 1 kg meat)'), (select id from public.ingredients where name = 'Bicarbonate of soda'), null::uuid, 6),
  ((select id from public.sauces where name = 'Meat marinade (per 1 kg meat)'), (select id from public.ingredients where name = 'Water'), null::uuid, 150),
  ((select id from public.sauces where name = 'Meat marinade (per 1 kg meat)'), (select id from public.ingredients where name = 'Vegetable oil'), null::uuid, 60),
  ((select id from public.sauces where name = 'Meat marinade (per 1 kg meat)'), (select id from public.ingredients where name = 'Tapioca flour'), null::uuid, 15);
-- Chestnut sauce: recipe not in the SOP yet
-- Yum dressing: recipe not in the SOP yet

-- 5. Dishes: new hot bar entries ----------------------------------
insert into public.dishes (name, name_th, category, selling_price, uses_protein, updated_by) values
  ('Pad Krapow Pork Mince', 'ผัดกระเพราหมูสับ', 'hot_bar', 7.0, false, 'SOP import'),
  ('Pad Krapow Pork Mince with Rice', 'ผัดกระเพราหมูสับ ราดข้าว', 'hot_bar', 12.99, false, 'SOP import'),
  ('Chicken Chestnuts', 'ไก่ผัดแห้ว', 'hot_bar', 7.0, false, 'SOP import'),
  ('Chicken Chestnuts with Rice', 'ไก่ผัดแห้ว ราดข้าว', 'hot_bar', 12.99, false, 'SOP import'),
  ('Green Curry Chicken', 'แกงเขียวหวานไก่', 'hot_bar', 7.0, false, 'SOP import'),
  ('Green Curry Chicken with Rice', 'แกงเขียวหวานไก่ ราดข้าว', 'hot_bar', 12.99, false, 'SOP import'),
  ('Red Curry Chicken', 'แกงแดงไก่', 'hot_bar', 7.0, false, 'SOP import'),
  ('Red Curry Chicken with Rice', 'แกงแดงไก่ ราดข้าว', 'hot_bar', 12.99, false, 'SOP import'),
  ('Massaman Curry Chicken', 'แกงมัสมั่นไก่', 'hot_bar', 7.0, false, 'SOP import'),
  ('Massaman Curry Chicken with Rice', 'แกงมัสมั่นไก่ ราดข้าว', 'hot_bar', 12.99, false, 'SOP import');

-- 6. Dish settings (price / protein flag) -------------------------
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Thai Fried Rice';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Garlic & Pepper Stir Fry on Rice';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Tom Yum Fried Rice';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Pad See Eiw';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Chili Jam Stir Fry on Rice';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Pad Kra Pow on Rice';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Pad Thai';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Spicy Basil Fried Rice';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Red Curry Paste Stir Fried';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Chilli Salt Stir-Fry on Rice';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Pad Kee Mao with Rice Noodles';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Gai-Lan (Kana) Oyster Sauce over Rice';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Dry Sukiyaki Kelp Noodles';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Sen Kaeaw Salad – Kelp Noodle';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Tum Sen Lek – Thin Rice Noodle Salad';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Clear Noodle Soup';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Boat Noodles';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Spicy and Sour Soup';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Dry Noodles with Black Soy Sauce';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Creamy Tom Yum Noodles';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Pink Noodle Sauce';
update public.dishes set selling_price = 7.0, uses_protein = false, updated_by = 'SOP import' where name = 'Pad Krapow Pork Mince';
update public.dishes set selling_price = 12.99, uses_protein = false, updated_by = 'SOP import' where name = 'Pad Krapow Pork Mince with Rice';
update public.dishes set selling_price = 7.0, uses_protein = false, updated_by = 'SOP import' where name = 'Chicken Chestnuts';
update public.dishes set selling_price = 12.99, uses_protein = false, updated_by = 'SOP import' where name = 'Chicken Chestnuts with Rice';
update public.dishes set selling_price = 7.0, uses_protein = false, updated_by = 'SOP import' where name = 'Green Curry Chicken';
update public.dishes set selling_price = 12.99, uses_protein = false, updated_by = 'SOP import' where name = 'Green Curry Chicken with Rice';
update public.dishes set selling_price = 7.0, uses_protein = false, updated_by = 'SOP import' where name = 'Red Curry Chicken';
update public.dishes set selling_price = 12.99, uses_protein = false, updated_by = 'SOP import' where name = 'Red Curry Chicken with Rice';
update public.dishes set selling_price = 7.0, uses_protein = false, updated_by = 'SOP import' where name = 'Massaman Curry Chicken';
update public.dishes set selling_price = 12.99, uses_protein = false, updated_by = 'SOP import' where name = 'Massaman Curry Chicken with Rice';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Thai Fried Rice (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Garlic and Pepper (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Pad Ka Praw (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Spicy Basil Fried Rice (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Thai Salt and Chili (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Chili Jam Stir Fried (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Pad Kee Mao (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Red Curry Stir Fried (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Gai-Lan (Kana) Oyster Sauce (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = false, updated_by = 'SOP import' where name = 'Sen Keaw Salad (Vegan)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Thai Fried Rice (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Garlic and Pepper (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Pad Ka Praw (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Spicy Basil Fried Rice (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Thai Salt and Chili (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Chili Jam Stir Fried (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Red Curry Paste Stir Fried (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Gai-Lan (Kana) Oyster Sauce (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Pad Kee Mao (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Sen Keaw Salad (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Dry Sukiyaki (GF)';
update public.dishes set selling_price = 16.99, uses_protein = true, updated_by = 'SOP import' where name = 'Tum Sen Lek Salad (GF)';

-- 7. Dish recipes -------------------------------------------------
-- Thai Fried Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Thai Fried Rice'), (select id from public.ingredients where name = 'Brown onion'), null::uuid, 35),
  ((select id from public.dishes where name = 'Thai Fried Rice'), (select id from public.ingredients where name = 'Tomato'), null::uuid, 20),
  ((select id from public.dishes where name = 'Thai Fried Rice'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 55),
  ((select id from public.dishes where name = 'Thai Fried Rice'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Thai Fried Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Thai Fried Rice'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Thai Fried Rice'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Thai Fried Rice'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Garlic & Pepper Stir Fry on Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Garlic & Pepper Stir Fry on Rice'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic & Pepper Stir Fry on Rice'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 15),
  ((select id from public.dishes where name = 'Garlic & Pepper Stir Fry on Rice'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic & Pepper Stir Fry on Rice'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Garlic & Pepper Stir Fry on Rice'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic & Pepper Stir Fry on Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Tom Yum Fried Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), (select id from public.ingredients where name = 'Lemongrass'), null::uuid, 25),
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), (select id from public.ingredients where name = 'Kaffir lime leaves'), null::uuid, 2),
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), (select id from public.ingredients where name = 'Mushrooms'), null::uuid, 45),
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 15),
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), null::uuid, (select id from public.sauces where name = 'Tom Yum stir-fry sauce'), 45),
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Tom Yum Fried Rice'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad See Eiw
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad See Eiw'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Pad See Eiw'), (select id from public.ingredients where name = 'Wide rice noodles (sen yai)'), null::uuid, 270),
  ((select id from public.dishes where name = 'Pad See Eiw'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 65),
  ((select id from public.dishes where name = 'Pad See Eiw'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Pad See Eiw'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Pad See Eiw'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Chili Jam Stir Fry on Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Chili Jam Stir Fry on Rice'), (select id from public.ingredients where name = 'Mixed stir-fry vegetables'), null::uuid, 100),
  ((select id from public.dishes where name = 'Chili Jam Stir Fry on Rice'), null::uuid, (select id from public.sauces where name = 'Cashew nut / chilli jam sauce'), 30),
  ((select id from public.dishes where name = 'Chili Jam Stir Fry on Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Kra Pow on Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 100),
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), (select id from public.ingredients where name = 'ABC sweet soy sauce'), null::uuid, 15),
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), (select id from public.ingredients where name = 'Holy basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Thai
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Thai'), (select id from public.ingredients where name = 'Bean sprouts'), null::uuid, 80),
  ((select id from public.dishes where name = 'Pad Thai'), (select id from public.ingredients where name = 'Garlic chives'), null::uuid, 20),
  ((select id from public.dishes where name = 'Pad Thai'), (select id from public.ingredients where name = 'Sweet pickled radish'), null::uuid, 10),
  ((select id from public.dishes where name = 'Pad Thai'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Pad Thai'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 190),
  ((select id from public.dishes where name = 'Pad Thai'), null::uuid, (select id from public.sauces where name = 'Pad Thai sauce'), 60),
  ((select id from public.dishes where name = 'Pad Thai'), (select id from public.ingredients where name = 'Crushed peanuts'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Thai'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Spicy Basil Fried Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'Holy basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Red Curry Paste Stir Fried
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried'), (select id from public.ingredients where name = 'Kaffir lime leaves'), null::uuid, 2),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried'), (select id from public.ingredients where name = 'Red curry paste'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 30)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Chilli Salt Stir-Fry on Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Chilli Salt Stir-Fry on Rice'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Chilli Salt Stir-Fry on Rice'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Chilli Salt Stir-Fry on Rice'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 5),
  ((select id from public.dishes where name = 'Chilli Salt Stir-Fry on Rice'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Chilli Salt Stir-Fry on Rice'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Chilli Salt Stir-Fry on Rice'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Chilli Salt Stir-Fry on Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Kee Mao with Rice Noodles
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Young green peppercorns'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Fingerroot'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Thai basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Wide rice noodles (sen yai)'), null::uuid, 270),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Gai-Lan (Kana) Oyster Sauce over Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce over Rice'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 100),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce over Rice'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce over Rice'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce over Rice'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce over Rice'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce over Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Dry Sukiyaki Kelp Noodles
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Dry Sukiyaki Kelp Noodles'), (select id from public.ingredients where name = 'Kelp noodles (sen kaew)'), null::uuid, 250),
  ((select id from public.dishes where name = 'Dry Sukiyaki Kelp Noodles'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 55),
  ((select id from public.dishes where name = 'Dry Sukiyaki Kelp Noodles'), (select id from public.ingredients where name = 'Chinese cabbage'), null::uuid, 55),
  ((select id from public.dishes where name = 'Dry Sukiyaki Kelp Noodles'), (select id from public.ingredients where name = 'Morning glory'), null::uuid, 125),
  ((select id from public.dishes where name = 'Dry Sukiyaki Kelp Noodles'), null::uuid, (select id from public.sauces where name = 'Sukiyaki sauce'), 125)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Sen Kaeaw Salad – Kelp Noodle
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), null::uuid, (select id from public.sauces where name = 'Yum dressing'), 50),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 15),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Lime powder'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Tomato'), null::uuid, 20),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Kelp noodles (sen kaew)'), null::uuid, 250),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Shallots'), null::uuid, 15),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Enoki mushrooms'), null::uuid, 30),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Cabbage'), null::uuid, 50),
  ((select id from public.dishes where name = 'Sen Kaeaw Salad – Kelp Noodle'), (select id from public.ingredients where name = 'Cashew nuts'), null::uuid, 10)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Tum Sen Lek – Thin Rice Noodle Salad
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'Fermented fish sauce (pla ra)'), null::uuid, 50),
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 10),
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'MSG'), null::uuid, 2.5),
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'Lime'), null::uuid, 30),
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 2.5),
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'Tomato'), null::uuid, 40),
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 2),
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Clear Noodle Soup
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Clear Noodle Soup'), null::uuid, (select id from public.sauces where name = 'Clear noodle soup'), 250),
  ((select id from public.dishes where name = 'Clear Noodle Soup'), (select id from public.ingredients where name = 'Bean sprouts'), null::uuid, 30),
  ((select id from public.dishes where name = 'Clear Noodle Soup'), (select id from public.ingredients where name = 'Meatballs'), null::uuid, 45),
  ((select id from public.dishes where name = 'Clear Noodle Soup'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120),
  ((select id from public.dishes where name = 'Clear Noodle Soup'), (select id from public.ingredients where name = 'Fried garlic oil'), null::uuid, 10),
  ((select id from public.dishes where name = 'Clear Noodle Soup'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Clear Noodle Soup'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 3),
  ((select id from public.dishes where name = 'Clear Noodle Soup'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 3),
  ((select id from public.dishes where name = 'Clear Noodle Soup'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Boat Noodles
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Boat Noodles'), null::uuid, (select id from public.sauces where name = 'Boat noodle soup'), 250),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Bean sprouts'), null::uuid, 30),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 30),
  ((select id from public.dishes where name = 'Boat Noodles'), null::uuid, (select id from public.sauces where name = 'Noodle base sauce'), 15),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Thai basil'), null::uuid, 2),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Meatballs'), null::uuid, 45),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Fried garlic oil'), null::uuid, 10),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 3),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 3),
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Spicy and Sour Soup
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), null::uuid, (select id from public.sauces where name = 'Clear noodle soup'), 200),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), null::uuid, (select id from public.sauces where name = 'Spicy & sour paste (clear tom yum)'), 50),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Bean sprouts'), null::uuid, 30),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Pork mince'), null::uuid, 30),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Chilli powder'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Crushed peanuts'), null::uuid, 15),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Fried wonton'), null::uuid, 20),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Meatballs'), null::uuid, 45),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Fried garlic oil'), null::uuid, 10),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 3),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 3),
  ((select id from public.dishes where name = 'Spicy and Sour Soup'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Dry Noodles with Black Soy Sauce
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), null::uuid, (select id from public.sauces where name = 'Dry noodle sauce'), 50),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 30),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), null::uuid, (select id from public.sauces where name = 'Clear noodle soup'), 50),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'Meatballs'), null::uuid, 45),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'Fried garlic oil'), null::uuid, 10),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 3),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 3),
  ((select id from public.dishes where name = 'Dry Noodles with Black Soy Sauce'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Creamy Tom Yum Noodles
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), null::uuid, (select id from public.sauces where name = 'Clear noodle soup'), 200),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), null::uuid, (select id from public.sauces where name = 'Creamy Tom Yum paste'), 30),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Evaporated milk'), null::uuid, 30),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Mushrooms'), null::uuid, 45),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Choy sum'), null::uuid, 30),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Meatballs'), null::uuid, 45),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Fried garlic oil'), null::uuid, 10),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 3),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 3),
  ((select id from public.dishes where name = 'Creamy Tom Yum Noodles'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pink Noodle Sauce
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), null::uuid, (select id from public.sauces where name = 'Clear noodle soup'), 200),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), null::uuid, (select id from public.sauces where name = 'Yentafo sauce'), 50),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Morning glory'), null::uuid, 40),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Duck blood'), null::uuid, 40),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Fish strips'), null::uuid, 30),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Fried wonton'), null::uuid, 20),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Meatballs'), null::uuid, 45),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Fried garlic oil'), null::uuid, 10),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 3),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 3),
  ((select id from public.dishes where name = 'Pink Noodle Sauce'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Krapow Pork Mince
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Pork mince'), null::uuid, 185.19),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Vegetable oil'), null::uuid, 7.41),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 18.52),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 0.19),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 0.19),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Dried chilli'), null::uuid, 3.7),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 11.11),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'ABC sweet soy sauce'), null::uuid, 9.26),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 4.63),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Holy basil'), null::uuid, 9.26)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Krapow Pork Mince with Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Pork mince'), null::uuid, 185.19),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Vegetable oil'), null::uuid, 7.41),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 18.52),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 0.19),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 0.19),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Dried chilli'), null::uuid, 3.7),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 11.11),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'ABC sweet soy sauce'), null::uuid, 9.26),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 4.63),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Holy basil'), null::uuid, 9.26),
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Chicken Chestnuts
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Vegetable oil'), null::uuid, 14.29),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Brown onion'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Zucchini'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Broccoli'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Baby corn'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Chicken slice'), null::uuid, 50.0),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 17.86),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), null::uuid, (select id from public.sauces where name = 'Chestnut sauce'), 14.29),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 8.93),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Water chestnuts'), null::uuid, 8.93)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Chicken Chestnuts with Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Vegetable oil'), null::uuid, 14.29),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Brown onion'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Zucchini'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Broccoli'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Baby corn'), null::uuid, 21.43),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Chicken slice'), null::uuid, 50.0),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 17.86),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), null::uuid, (select id from public.sauces where name = 'Chestnut sauce'), 14.29),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 8.93),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Water chestnuts'), null::uuid, 8.93),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Green Curry Chicken
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Green Curry Chicken'), null::uuid, (select id from public.sauces where name = 'Green curry sauce'), 125.0),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Eggplant'), null::uuid, 55.56),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Chicken curry cut'), null::uuid, 37.04),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 11.11),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 11.11),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 4.63),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Thai basil'), null::uuid, 9.26)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Green Curry Chicken with Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), null::uuid, (select id from public.sauces where name = 'Green curry sauce'), 125.0),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Eggplant'), null::uuid, 55.56),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Chicken curry cut'), null::uuid, 37.04),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 11.11),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 11.11),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 4.63),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Thai basil'), null::uuid, 9.26),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Red Curry Chicken
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Red Curry Chicken'), null::uuid, (select id from public.sauces where name = 'Red curry sauce'), 140.62),
  ((select id from public.dishes where name = 'Red Curry Chicken'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken'), (select id from public.ingredients where name = 'Zucchini'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken'), (select id from public.ingredients where name = 'Chicken curry cut'), null::uuid, 37.5)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Red Curry Chicken with Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), null::uuid, (select id from public.sauces where name = 'Red curry sauce'), 140.62),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Zucchini'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Chicken curry cut'), null::uuid, 37.5),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Massaman Curry Chicken
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), null::uuid, (select id from public.sauces where name = 'Massaman curry sauce'), 132.35),
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), (select id from public.ingredients where name = 'Chicken curry cut'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), (select id from public.ingredients where name = 'Potato'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), (select id from public.ingredients where name = 'Brown onion'), null::uuid, 17.65)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Massaman Curry Chicken with Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Massaman Curry Chicken with Rice'), null::uuid, (select id from public.sauces where name = 'Massaman curry sauce'), 132.35),
  ((select id from public.dishes where name = 'Massaman Curry Chicken with Rice'), (select id from public.ingredients where name = 'Chicken curry cut'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken with Rice'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken with Rice'), (select id from public.ingredients where name = 'Potato'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken with Rice'), (select id from public.ingredients where name = 'Brown onion'), null::uuid, 17.65),
  ((select id from public.dishes where name = 'Massaman Curry Chicken with Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Thai Fried Rice (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Thai Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Brown onion'), null::uuid, 35),
  ((select id from public.dishes where name = 'Thai Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Tomato'), null::uuid, 20),
  ((select id from public.dishes where name = 'Thai Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 55),
  ((select id from public.dishes where name = 'Thai Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Thai Fried Rice (Vegan)'), null::uuid, (select id from public.sauces where name = 'Vegan stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Thai Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Thai Fried Rice (Vegan)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Thai Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Garlic and Pepper (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Garlic and Pepper (Vegan)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic and Pepper (Vegan)'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 15),
  ((select id from public.dishes where name = 'Garlic and Pepper (Vegan)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic and Pepper (Vegan)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Garlic and Pepper (Vegan)'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic and Pepper (Vegan)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Garlic and Pepper (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Ka Praw (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 100),
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), null::uuid, (select id from public.sauces where name = 'Vegan stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'ABC sweet soy sauce'), null::uuid, 15),
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'Holy basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Spicy Basil Fried Rice (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), null::uuid, (select id from public.sauces where name = 'Vegan stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Holy basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Thai Salt and Chili (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Thai Salt and Chili (Vegan)'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (Vegan)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (Vegan)'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (Vegan)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (Vegan)'), null::uuid, (select id from public.sauces where name = 'Vegan stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Thai Salt and Chili (Vegan)'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (Vegan)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Thai Salt and Chili (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Chili Jam Stir Fried (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Chili Jam Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Mixed stir-fry vegetables'), null::uuid, 100),
  ((select id from public.dishes where name = 'Chili Jam Stir Fried (Vegan)'), null::uuid, (select id from public.sauces where name = 'Cashew nut / chilli jam sauce'), 30),
  ((select id from public.dishes where name = 'Chili Jam Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Chili Jam Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Kee Mao (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Young green peppercorns'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Fingerroot'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Thai basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Wide rice noodles (sen yai)'), null::uuid, 270),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), null::uuid, (select id from public.sauces where name = 'Vegan stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Red Curry Stir Fried (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Kaffir lime leaves'), null::uuid, 2),
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Red curry paste'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), null::uuid, (select id from public.sauces where name = 'Vegan stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Gai-Lan (Kana) Oyster Sauce (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (Vegan)'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 100),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (Vegan)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (Vegan)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (Vegan)'), null::uuid, (select id from public.sauces where name = 'Vegan stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (Vegan)'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (Vegan)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Sen Keaw Salad (Vegan)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), null::uuid, (select id from public.sauces where name = 'Yum dressing'), 50),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 15),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Lime powder'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Tomato'), null::uuid, 20),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Kelp noodles (sen kaew)'), null::uuid, 250),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Shallots'), null::uuid, 15),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Enoki mushrooms'), null::uuid, 30),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Cabbage'), null::uuid, 50),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Cashew nuts'), null::uuid, 10),
  ((select id from public.dishes where name = 'Sen Keaw Salad (Vegan)'), (select id from public.ingredients where name = 'Firm tofu'), null::uuid, 100)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Thai Fried Rice (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Thai Fried Rice (GF)'), (select id from public.ingredients where name = 'Brown onion'), null::uuid, 35),
  ((select id from public.dishes where name = 'Thai Fried Rice (GF)'), (select id from public.ingredients where name = 'Tomato'), null::uuid, 20),
  ((select id from public.dishes where name = 'Thai Fried Rice (GF)'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 55),
  ((select id from public.dishes where name = 'Thai Fried Rice (GF)'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Thai Fried Rice (GF)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Thai Fried Rice (GF)'), null::uuid, (select id from public.sauces where name = 'GF stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Thai Fried Rice (GF)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Thai Fried Rice (GF)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Garlic and Pepper (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Garlic and Pepper (GF)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic and Pepper (GF)'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 15),
  ((select id from public.dishes where name = 'Garlic and Pepper (GF)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic and Pepper (GF)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Garlic and Pepper (GF)'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Garlic and Pepper (GF)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Ka Praw (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 100),
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), null::uuid, (select id from public.sauces where name = 'GF stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), (select id from public.ingredients where name = 'ABC sweet soy sauce'), null::uuid, 15),
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), (select id from public.ingredients where name = 'Holy basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1),
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Spicy Basil Fried Rice (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), null::uuid, (select id from public.sauces where name = 'GF stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'Holy basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Thai Salt and Chili (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Thai Salt and Chili (GF)'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (GF)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (GF)'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (GF)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (GF)'), null::uuid, (select id from public.sauces where name = 'GF stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Thai Salt and Chili (GF)'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Thai Salt and Chili (GF)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Chili Jam Stir Fried (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Chili Jam Stir Fried (GF)'), (select id from public.ingredients where name = 'Mixed stir-fry vegetables'), null::uuid, 100),
  ((select id from public.dishes where name = 'Chili Jam Stir Fried (GF)'), null::uuid, (select id from public.sauces where name = 'Cashew nut / chilli jam sauce'), 30),
  ((select id from public.dishes where name = 'Chili Jam Stir Fried (GF)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Red Curry Paste Stir Fried (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried (GF)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried (GF)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried (GF)'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried (GF)'), (select id from public.ingredients where name = 'Kaffir lime leaves'), null::uuid, 2),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried (GF)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried (GF)'), (select id from public.ingredients where name = 'Red curry paste'), null::uuid, 5),
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried (GF)'), null::uuid, (select id from public.sauces where name = 'GF stir-fry sauce'), 30)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Gai-Lan (Kana) Oyster Sauce (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (GF)'), (select id from public.ingredients where name = 'Gai lan (Chinese broccoli)'), null::uuid, 100),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (GF)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (GF)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (GF)'), null::uuid, (select id from public.sauces where name = 'GF stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (GF)'), (select id from public.ingredients where name = 'Fried garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Gai-Lan (Kana) Oyster Sauce (GF)'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Pad Kee Mao (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Young green peppercorns'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Fingerroot'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Snake beans'), null::uuid, 55),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Eggs'), null::uuid, 60),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Thai basil'), null::uuid, 5),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Wide rice noodles (sen yai)'), null::uuid, 270),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), null::uuid, (select id from public.sauces where name = 'GF stir-fry sauce'), 30),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'White pepper'), null::uuid, 1)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Sen Keaw Salad (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), null::uuid, (select id from public.sauces where name = 'Yum dressing'), 50),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Fish sauce'), null::uuid, 15),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Lime powder'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Tomato'), null::uuid, 20),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 10),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Kelp noodles (sen kaew)'), null::uuid, 250),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Shallots'), null::uuid, 15),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Enoki mushrooms'), null::uuid, 30),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 5),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Cabbage'), null::uuid, 50),
  ((select id from public.dishes where name = 'Sen Keaw Salad (GF)'), (select id from public.ingredients where name = 'Cashew nuts'), null::uuid, 10)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Dry Sukiyaki (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Dry Sukiyaki (GF)'), (select id from public.ingredients where name = 'Kelp noodles (sen kaew)'), null::uuid, 250),
  ((select id from public.dishes where name = 'Dry Sukiyaki (GF)'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 55),
  ((select id from public.dishes where name = 'Dry Sukiyaki (GF)'), (select id from public.ingredients where name = 'Chinese cabbage'), null::uuid, 55),
  ((select id from public.dishes where name = 'Dry Sukiyaki (GF)'), (select id from public.ingredients where name = 'Morning glory'), null::uuid, 125),
  ((select id from public.dishes where name = 'Dry Sukiyaki (GF)'), null::uuid, (select id from public.sauces where name = 'Sukiyaki sauce'), 125)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Tum Sen Lek Salad (GF)
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Fermented fish sauce (pla ra)'), null::uuid, 50),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'White sugar'), null::uuid, 10),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'MSG'), null::uuid, 2.5),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Lime'), null::uuid, 30),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Garlic'), null::uuid, 2.5),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Bird''s eye chilli'), null::uuid, 5),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Tomato'), null::uuid, 40),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Coriander'), null::uuid, 2),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;

-- 8. Protein options ----------------------------------------------
insert into public.protein_options (name, name_th, ingredient_id, grams, selling_price, sort_order) values
  ('Chicken', 'ไก่', (select id from public.ingredients where name = 'Chicken slice'), 100, 16.99, 0),
  ('Pork', 'หมู', (select id from public.ingredients where name = 'Pork slice'), 80, 16.99, 1),
  ('Beef', 'เนื้อ', (select id from public.ingredients where name = 'Beef slice'), 80, 16.99, 2),
  ('Tofu', 'เต้าหู้', (select id from public.ingredients where name = 'Firm tofu'), 100, 16.99, 3),
  ('No meat', 'ไม่ใส่เนื้อ', null, 0, 16.99, 4),
  ('Prawn', 'กุ้ง', (select id from public.ingredients where name = 'Prawns'), 120, 18.99, 5),
  ('Squid', 'ปลาหมึก', (select id from public.ingredients where name = 'Squid'), 120, 18.99, 6),
  ('Crispy pork', 'หมูกรอบ', (select id from public.ingredients where name = 'Crispy pork'), 120, 18.99, 7),
  ('Meatballs', 'ลูกชิ้น', (select id from public.ingredients where name = 'Meatballs'), 100, 18.99, 8);

commit;
