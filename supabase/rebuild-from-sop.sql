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
  ('Chicken breast fillet sliced', 'อกไก่สไลด์', 'kg', 'meat', 'SOP import'),
  ('Chicken maryland fillet diced', 'ไก่แมรี่แลนด์หั่นเต๋า', 'kg', 'meat', 'SOP import'),
  ('Chicken carcass', 'โครงไก่', 'kg', 'meat', 'SOP import'),
  ('Pork lean leg sliced', 'สะโพกหมูสไลด์', 'kg', 'meat', 'SOP import'),
  ('Pork topside denuded', 'หมูสะโพกบน', 'kg', 'meat', 'SOP import'),
  ('Pork mince', 'หมูสับ', 'kg', 'meat', 'SOP import'),
  ('Beef sliced 1.5mm', 'เนื้อวัวสไลด์', 'kg', 'meat', 'SOP import'),
  ('Beef topside sliced', 'เนื้อสันสะโพกสไลด์', 'kg', 'meat', 'SOP import'),
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
  ('Green beans', 'ถั่วฝักยาว', 'kg', 'veg', 'SOP import'),
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
  ('Lemon', 'เลมอน', 'kg', 'veg', 'SOP import'),
  ('Red onion', 'หอมหัวใหญ่แดง', 'kg', 'veg', 'SOP import'),
  ('Sawtooth coriander', 'ผักชีฝรั่ง', 'kg', 'veg', 'SOP import'),
  ('Oyster sauce', 'น้ำมันหอย', 'l', 'sauce', 'SOP import'),
  ('GF oyster sauce', 'น้ำมันหอยปลอดกลูเตน', 'kg', 'sauce', 'SOP import'),
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
  ('Tamarind concentrate', 'น้ำมะขาม', 'kg', 'sauce', 'SOP import'),
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
  ((select id from public.sauces where name = 'Pad Thai sauce'), (select id from public.ingredients where name = 'Tamarind concentrate'), null::uuid, 1000),
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
  ((select id from public.sauces where name = 'Creamy Tom Yum paste'), (select id from public.ingredients where name = 'Tamarind concentrate'), null::uuid, 1000),
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
  ((select id from public.sauces where name = 'Massaman curry sauce'), (select id from public.ingredients where name = 'Tamarind concentrate'), null::uuid, 500),
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
  ((select id from public.dishes where name = 'Pad Kra Pow on Rice'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 100),
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
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Pad Kee Mao with Rice Noodles'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Tum Sen Lek – Thin Rice Noodle Salad'), (select id from public.ingredients where name = 'Sawtooth coriander'), null::uuid, 2),
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
  ((select id from public.dishes where name = 'Boat Noodles'), (select id from public.ingredients where name = 'Sawtooth coriander'), null::uuid, 3),
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
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 18.52),
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
  ((select id from public.dishes where name = 'Pad Krapow Pork Mince with Rice'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 18.52),
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
  ((select id from public.dishes where name = 'Chicken Chestnuts'), (select id from public.ingredients where name = 'Chicken breast fillet sliced'), null::uuid, 50.0),
  ((select id from public.dishes where name = 'Chicken Chestnuts'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 17.86),
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
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Chicken breast fillet sliced'), null::uuid, 50.0),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), null::uuid, (select id from public.sauces where name = 'Stir-fry sauce'), 17.86),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Spring onion'), null::uuid, 8.93),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Water chestnuts'), null::uuid, 8.93),
  ((select id from public.dishes where name = 'Chicken Chestnuts with Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Green Curry Chicken
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Green Curry Chicken'), null::uuid, (select id from public.sauces where name = 'Green curry sauce'), 125.0),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Eggplant'), null::uuid, 55.56),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Chicken maryland fillet diced'), null::uuid, 37.04),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 11.11),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 11.11),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Red chilli'), null::uuid, 4.63),
  ((select id from public.dishes where name = 'Green Curry Chicken'), (select id from public.ingredients where name = 'Thai basil'), null::uuid, 9.26)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Green Curry Chicken with Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), null::uuid, (select id from public.sauces where name = 'Green curry sauce'), 125.0),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Eggplant'), null::uuid, 55.56),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Chicken maryland fillet diced'), null::uuid, 37.04),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 11.11),
  ((select id from public.dishes where name = 'Green Curry Chicken with Rice'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 11.11),
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
  ((select id from public.dishes where name = 'Red Curry Chicken'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken'), (select id from public.ingredients where name = 'Chicken maryland fillet diced'), null::uuid, 37.5)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Red Curry Chicken with Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), null::uuid, (select id from public.sauces where name = 'Red curry sauce'), 140.62),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Capsicum'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Zucchini'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 18.75),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Chicken maryland fillet diced'), null::uuid, 37.5),
  ((select id from public.dishes where name = 'Red Curry Chicken with Rice'), (select id from public.ingredients where name = 'Jasmine rice (raw)'), null::uuid, 170)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Massaman Curry Chicken
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), null::uuid, (select id from public.sauces where name = 'Massaman curry sauce'), 132.35),
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), (select id from public.ingredients where name = 'Chicken maryland fillet diced'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), (select id from public.ingredients where name = 'Carrot'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), (select id from public.ingredients where name = 'Potato'), null::uuid, 35.29),
  ((select id from public.dishes where name = 'Massaman Curry Chicken'), (select id from public.ingredients where name = 'Brown onion'), null::uuid, 17.65)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;
-- Massaman Curry Chicken with Rice
insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)
select * from (values
  ((select id from public.dishes where name = 'Massaman Curry Chicken with Rice'), null::uuid, (select id from public.sauces where name = 'Massaman curry sauce'), 132.35),
  ((select id from public.dishes where name = 'Massaman Curry Chicken with Rice'), (select id from public.ingredients where name = 'Chicken maryland fillet diced'), null::uuid, 35.29),
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
  ((select id from public.dishes where name = 'Pad Ka Praw (Vegan)'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 100),
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
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (Vegan)'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Pad Kee Mao (Vegan)'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Red Curry Stir Fried (Vegan)'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Pad Ka Praw (GF)'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 100),
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
  ((select id from public.dishes where name = 'Spicy Basil Fried Rice (GF)'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Red Curry Paste Stir Fried (GF)'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Pad Kee Mao (GF)'), (select id from public.ingredients where name = 'Green beans'), null::uuid, 55),
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
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Sawtooth coriander'), null::uuid, 2),
  ((select id from public.dishes where name = 'Tum Sen Lek Salad (GF)'), (select id from public.ingredients where name = 'Thin rice noodles (sen lek)'), null::uuid, 120)
) as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;

-- 8. Protein options ----------------------------------------------
insert into public.protein_options (name, name_th, ingredient_id, grams, selling_price, sort_order) values
  ('Chicken', 'ไก่', (select id from public.ingredients where name = 'Chicken breast fillet sliced'), 100, 16.99, 0),
  ('Pork', 'หมู', (select id from public.ingredients where name = 'Pork lean leg sliced'), 80, 16.99, 1),
  ('Beef', 'เนื้อ', (select id from public.ingredients where name = 'Beef sliced 1.5mm'), 80, 16.99, 2),
  ('Tofu', 'เต้าหู้', (select id from public.ingredients where name = 'Firm tofu'), 100, 16.99, 3),
  ('No meat', 'ไม่ใส่เนื้อ', null, 0, 16.99, 4),
  ('Prawn', 'กุ้ง', (select id from public.ingredients where name = 'Prawns'), 120, 18.99, 5),
  ('Squid', 'ปลาหมึก', (select id from public.ingredients where name = 'Squid'), 120, 18.99, 6),
  ('Crispy pork', 'หมูกรอบ', (select id from public.ingredients where name = 'Crispy pork'), 120, 18.99, 7),
  ('Meatballs', 'ลูกชิ้น', (select id from public.ingredients where name = 'Meatballs'), 100, 18.99, 8);


-- 9. Learned invoice wordings ------------------------------------
-- Supplier descriptions and product codes from the July 2026
-- invoices, so scans match first time without asking.
insert into public.ingredient_aliases (alias_key, alias_text, ingredient_id, created_by) values
  ('chicken breast fillet sliced', 'CHICKEN BREAST FILLET SLICED', (select id from public.ingredients where name = 'Chicken breast fillet sliced'), 'invoice import'),
  ('cbfsb', 'CBFSB', (select id from public.ingredients where name = 'Chicken breast fillet sliced'), 'invoice import'),
  ('cbfsb chicken breast fillet sliced', 'CBFSB CHICKEN BREAST FILLET SLICED', (select id from public.ingredients where name = 'Chicken breast fillet sliced'), 'invoice import'),
  ('chicken maryland fillet diced', 'CHICKEN MARYLAND FILLET DICED', (select id from public.ingredients where name = 'Chicken maryland fillet diced'), 'invoice import'),
  ('cmfdb', 'CMFDB', (select id from public.ingredients where name = 'Chicken maryland fillet diced'), 'invoice import'),
  ('pork lean leg sliced', 'PORK LEAN LEG SLICED', (select id from public.ingredients where name = 'Pork lean leg sliced'), 'invoice import'),
  ('pork lean leg slice', 'Pork Lean Leg Slice', (select id from public.ingredients where name = 'Pork lean leg sliced'), 'invoice import'),
  ('pllsb', 'PLLSB', (select id from public.ingredients where name = 'Pork lean leg sliced'), 'invoice import'),
  ('plls', 'PLLS', (select id from public.ingredients where name = 'Pork lean leg sliced'), 'invoice import'),
  ('fresh pork topside denuded iw 3kg 6 rw be prime', 'FRESH PORK - TOPSIDE DENUDED IW 3KG (6) RW BE PRIME', (select id from public.ingredients where name = 'Pork topside denuded'), 'invoice import'),
  ('fresh pork topside denuded', 'FRESH PORK TOPSIDE DENUDED', (select id from public.ingredients where name = 'Pork topside denuded'), 'invoice import'),
  ('pork mince course', 'PORK MINCE COURSE', (select id from public.ingredients where name = 'Pork mince'), 'invoice import'),
  ('pork mince', 'PORK MINCE', (select id from public.ingredients where name = 'Pork mince'), 'invoice import'),
  ('beef sliced 1 5mm tai', 'Beef Sliced 1.5mm (Tai)', (select id from public.ingredients where name = 'Beef sliced 1.5mm'), 'invoice import'),
  ('bn', 'BN', (select id from public.ingredients where name = 'Beef sliced 1.5mm'), 'invoice import'),
  ('beef sliced', 'BEEF SLICED', (select id from public.ingredients where name = 'Beef sliced 1.5mm'), 'invoice import'),
  ('beef topside sliced', 'Beef Topside Sliced', (select id from public.ingredients where name = 'Beef topside sliced'), 'invoice import'),
  ('bts', 'BTS', (select id from public.ingredients where name = 'Beef topside sliced'), 'invoice import'),
  ('pork belly cooked roast 4kg 3 rw 03960 primo', 'PORK BELLY COOKED ROAST 4KG(3) RW #03960 PRIMO', (select id from public.ingredients where name = 'Crispy pork'), 'invoice import'),
  ('pork belly cooked roast', 'PORK BELLY COOKED ROAST', (select id from public.ingredients where name = 'Crispy pork'), 'invoice import'),
  ('pork blood', 'Pork Blood', (select id from public.ingredients where name = 'Pork blood'), 'invoice import'),
  ('pbl', 'PBL', (select id from public.ingredients where name = 'Pork blood'), 'invoice import'),
  ('eggs 600g 15x1 dozen', 'EGGS - 600G 15X1 DOZEN', (select id from public.ingredients where name = 'Eggs'), 'invoice import'),
  ('eggs', 'EGGS', (select id from public.ingredients where name = 'Eggs'), 'invoice import'),
  ('sauce fish sauce 4 5l 3 squid', 'SAUCE - FISH SAUCE 4.5L (3) SQUID', (select id from public.ingredients where name = 'Fish sauce'), 'invoice import'),
  ('fish sauce squid', 'FISH SAUCE SQUID', (select id from public.ingredients where name = 'Fish sauce'), 'invoice import'),
  ('palm sugar 500g 30 sugar boy', 'PALM SUGAR 500G (30) SUGAR BOY', (select id from public.ingredients where name = 'Palm sugar'), 'invoice import'),
  ('palm sugar', 'PALM SUGAR', (select id from public.ingredients where name = 'Palm sugar'), 'invoice import'),
  ('bdb coconut sugar 10 1k pkt', 'BDB'' COCONUT SUGAR 10*1K-PKT', (select id from public.ingredients where name = 'Palm sugar'), 'invoice import'),
  ('bdb coconut sugar', 'BDB COCONUT SUGAR', (select id from public.ingredients where name = 'Palm sugar'), 'invoice import'),
  ('coconut sugar', 'COCONUT SUGAR', (select id from public.ingredients where name = 'Palm sugar'), 'invoice import'),
  ('sugar rock 400g 50', 'SUGAR ROCK 400G (50)', (select id from public.ingredients where name = 'Rock sugar'), 'invoice import'),
  ('sugar rock', 'SUGAR ROCK', (select id from public.ingredients where name = 'Rock sugar'), 'invoice import'),
  ('white sugar', 'WHITE SUGAR', (select id from public.ingredients where name = 'White sugar'), 'invoice import'),
  ('sugar white', 'SUGAR - WHITE', (select id from public.ingredients where name = 'White sugar'), 'invoice import'),
  ('sauce tomato gf 4ltr 3 heinz', 'SAUCE - TOMATO (GF) 4LTR (3) HEINZ', (select id from public.ingredients where name = 'Tomato sauce'), 'invoice import'),
  ('heinz tomato sauce g fre 3 4lt', 'HEINZ''TOMATO SAUCE G/FRE 3*4LT', (select id from public.ingredients where name = 'Tomato sauce'), 'invoice import'),
  ('heinz tomato sauce', 'HEINZ TOMATO SAUCE', (select id from public.ingredients where name = 'Tomato sauce'), 'invoice import'),
  ('msg 1kg 20', 'MSG 1KG (20)', (select id from public.ingredients where name = 'MSG'), 'invoice import'),
  ('msg', 'MSG', (select id from public.ingredients where name = 'MSG'), 'invoice import'),
  ('vinegar white 20ltr cask supra', 'VINEGAR - WHITE 20LTR CASK SUPRA', (select id from public.ingredients where name = 'White vinegar'), 'invoice import'),
  ('vinegar white', 'VINEGAR - WHITE', (select id from public.ingredients where name = 'White vinegar'), 'invoice import'),
  ('chicken seasoning powder 800g 10 knorr', 'CHICKEN SEASONING POWDER 800G (10) KNORR', (select id from public.ingredients where name = 'Knorr seasoning powder'), 'invoice import'),
  ('knorr chicken seasoning powder', 'KNORR CHICKEN SEASONING POWDER', (select id from public.ingredients where name = 'Knorr seasoning powder'), 'invoice import'),
  ('spice star anise whole 1kg csi', 'SPICE - STAR ANISE WHOLE 1KG CSI', (select id from public.ingredients where name = 'Star anise'), 'invoice import'),
  ('gh star aniseed 10 1k', 'GH''STAR ANISEED ***10*1K', (select id from public.ingredients where name = 'Star anise'), 'invoice import'),
  ('star aniseed', 'STAR ANISEED', (select id from public.ingredients where name = 'Star anise'), 'invoice import'),
  ('paste tamarind concentrate gluen free 1kg 12 aaa mountain', 'PASTE - TAMARIND CONCENTRATE GLUEN FREE 1KG(12) AAA MOUNTAIN', (select id from public.ingredients where name = 'Tamarind concentrate'), 'invoice import'),
  ('pg tamarind concentrat 12 850g', 'PG''TAMARIND CONCENTRAT 12*850G', (select id from public.ingredients where name = 'Tamarind concentrate'), 'invoice import'),
  ('tamarind concentrate', 'TAMARIND CONCENTRATE', (select id from public.ingredients where name = 'Tamarind concentrate'), 'invoice import'),
  ('sauce soya bean seasoning sauce 3lt 6 golden mountain', 'SAUCE - SOYA BEAN SEASONING SAUCE 3LT (6) GOLDEN MOUNTAIN', (select id from public.ingredients where name = 'Seasoning sauce (green cap)'), 'invoice import'),
  ('golden mountain seasoning sauce', 'GOLDEN MOUNTAIN SEASONING SAUCE', (select id from public.ingredients where name = 'Seasoning sauce (green cap)'), 'invoice import'),
  ('soya bean seasoning sauce', 'SOYA BEAN SEASONING SAUCE', (select id from public.ingredients where name = 'Seasoning sauce (green cap)'), 'invoice import'),
  ('oil vegetable oil 20l jerry can simply', 'OIL - VEGETABLE OIL 20L JERRY CAN SIMPLY', (select id from public.ingredients where name = 'Vegetable oil'), 'invoice import'),
  ('vegetable oil', 'VEGETABLE OIL', (select id from public.ingredients where name = 'Vegetable oil'), 'invoice import'),
  ('fz pandan leaves 200g x 36 ocha', 'FZ PANDAN LEAVES 200G X 36 OCHA', (select id from public.ingredients where name = 'Pandan leaves'), 'invoice import'),
  ('pandan leaves', 'PANDAN LEAVES', (select id from public.ingredients where name = 'Pandan leaves'), 'invoice import'),
  ('sauce chilli paste formula 8 3 2kg 4 chua hah seng', 'SAUCE - CHILLI PASTE FORMULA 8 3.2KG (4) CHUA HAH SENG', (select id from public.ingredients where name = 'Chilli jam (nam prik pao)'), 'invoice import'),
  ('chilli paste formula 8', 'CHILLI PASTE FORMULA 8', (select id from public.ingredients where name = 'Chilli jam (nam prik pao)'), 'invoice import'),
  ('chua hah seng chilli paste', 'CHUA HAH SENG CHILLI PASTE', (select id from public.ingredients where name = 'Chilli jam (nam prik pao)'), 'invoice import'),
  ('seasoning oil chilli oil 720g 12 chua hah seng', 'SEASONING OIL - CHILLI OIL 720G (12) CHUA HAH SENG', (select id from public.ingredients where name = 'Chilli jam oil'), 'invoice import'),
  ('chilli oil', 'CHILLI OIL', (select id from public.ingredients where name = 'Chilli jam oil'), 'invoice import'),
  ('paste tom yum paste instant hot sour 908g 12 penta', 'PASTE - TOM YUM PASTE INSTANT HOT SOUR 908G(12) PENTA', (select id from public.ingredients where name = 'Tom yum paste (Penta)'), 'invoice import'),
  ('penta tom yum paste 12 908g', 'PENTA'' TOM YUM PASTE 12*908G', (select id from public.ingredients where name = 'Tom yum paste (Penta)'), 'invoice import'),
  ('tom yum paste', 'TOM YUM PASTE', (select id from public.ingredients where name = 'Tom yum paste (Penta)'), 'invoice import'),
  ('sauce thin soy sauce f1 6kg 4 5l 3 healthy boy', 'SAUCE - THIN SOY SAUCE F1 6KG (4.5L) (3) HEALTHY BOY', (select id from public.ingredients where name = 'Light soy sauce'), 'invoice import'),
  ('hb thin soya sce f1 3 4 5l', 'HB''THIN SOYA SCE-F1 3*4.5L', (select id from public.ingredients where name = 'Light soy sauce'), 'invoice import'),
  ('thin soy sauce', 'THIN SOY SAUCE', (select id from public.ingredients where name = 'Light soy sauce'), 'invoice import'),
  ('healthy boy thin soy', 'HEALTHY BOY THIN SOY', (select id from public.ingredients where name = 'Light soy sauce'), 'invoice import'),
  ('fz chilli red 1kg 10', 'FZ CHILLI - RED 1KG (10)', (select id from public.ingredients where name = 'Red chilli'), 'invoice import'),
  ('chilli red', 'CHILLI - RED', (select id from public.ingredients where name = 'Red chilli'), 'invoice import'),
  ('canned baby corn cut a10 2 84kg x 3 ctn twin pine', 'CANNED - BABY CORN CUT A10 2.84KG X 3/CTN TWIN PINE', (select id from public.ingredients where name = 'Baby corn'), 'invoice import'),
  ('baby corn cut', 'BABY CORN CUT', (select id from public.ingredients where name = 'Baby corn'), 'invoice import'),
  ('pickled rhizome strip krachai in brine 454g 24 traded', 'PICKLED RHIZOME STRIP (KRACHAI) IN BRINE 454G (24) TRADED', (select id from public.ingredients where name = 'Fingerroot'), 'invoice import'),
  ('krachai', 'KRACHAI', (select id from public.ingredients where name = 'Fingerroot'), 'invoice import'),
  ('chilli dry small d jing 500g 20', 'CHILLI Dry Small ''D-Jing'' 500g (20)', (select id from public.ingredients where name = 'Dried chilli'), 'invoice import'),
  ('chilli dry small', 'CHILLI DRY SMALL', (select id from public.ingredients where name = 'Dried chilli'), 'invoice import'),
  ('lime powder seasoning knorr 400g 15', 'LIME POWDER Seasoning ''Knorr'' 400g (15)', (select id from public.ingredients where name = 'Lime powder'), 'invoice import'),
  ('lime powder', 'LIME POWDER', (select id from public.ingredients where name = 'Lime powder'), 'invoice import'),
  ('sriracha chilli sauce gramount 750ml 12', 'SRIRACHA CHILLI SAUCE ''Gramount'' 750ml (12)', (select id from public.ingredients where name = 'Sriracha sauce'), 'invoice import'),
  ('sriracha chilli sauce', 'SRIRACHA CHILLI SAUCE', (select id from public.ingredients where name = 'Sriracha sauce'), 'invoice import'),
  ('bean sprouts', 'Bean Sprouts', (select id from public.ingredients where name = 'Bean sprouts'), 'invoice import'),
  ('beask', 'BEASK', (select id from public.ingredients where name = 'Bean sprouts'), 'invoice import'),
  ('beans green', 'Beans - Green', (select id from public.ingredients where name = 'Green beans'), 'invoice import'),
  ('beac', 'BEAC', (select id from public.ingredients where name = 'Green beans'), 'invoice import'),
  ('green beans', 'GREEN BEANS', (select id from public.ingredients where name = 'Green beans'), 'invoice import'),
  ('broccoli', 'Broccoli', (select id from public.ingredients where name = 'Broccoli'), 'invoice import'),
  ('brok', 'BROK', (select id from public.ingredients where name = 'Broccoli'), 'invoice import'),
  ('capsicums red', 'Capsicums - Red', (select id from public.ingredients where name = 'Capsicum'), 'invoice import'),
  ('caprc', 'CAPRC', (select id from public.ingredients where name = 'Capsicum'), 'invoice import'),
  ('carrots', 'Carrots', (select id from public.ingredients where name = 'Carrot'), 'invoice import'),
  ('cark', 'CARK', (select id from public.ingredients where name = 'Carrot'), 'invoice import'),
  ('choy sum', 'Choy Sum', (select id from public.ingredients where name = 'Choy sum'), 'invoice import'),
  ('choyb', 'CHOYB', (select id from public.ingredients where name = 'Choy sum'), 'invoice import'),
  ('coriander', 'Coriander', (select id from public.ingredients where name = 'Coriander'), 'invoice import'),
  ('corb', 'CORB', (select id from public.ingredients where name = 'Coriander'), 'invoice import'),
  ('coriander sawtooth', 'Coriander - Sawtooth', (select id from public.ingredients where name = 'Sawtooth coriander'), 'invoice import'),
  ('corsb', 'CORSB', (select id from public.ingredients where name = 'Sawtooth coriander'), 'invoice import'),
  ('eggplant', 'Eggplant', (select id from public.ingredients where name = 'Eggplant'), 'invoice import'),
  ('eggpk', 'EGGPK', (select id from public.ingredients where name = 'Eggplant'), 'invoice import'),
  ('lemons', 'Lemons', (select id from public.ingredients where name = 'Lemon'), 'invoice import'),
  ('lemk', 'LEMK', (select id from public.ingredients where name = 'Lemon'), 'invoice import'),
  ('limes', 'Limes', (select id from public.ingredients where name = 'Lime'), 'invoice import'),
  ('limk', 'LIMK', (select id from public.ingredients where name = 'Lime'), 'invoice import'),
  ('mushrooms button', 'Mushrooms - Button', (select id from public.ingredients where name = 'Mushrooms'), 'invoice import'),
  ('musk', 'MUSK', (select id from public.ingredients where name = 'Mushrooms'), 'invoice import'),
  ('onions brown', 'Onions - Brown', (select id from public.ingredients where name = 'Brown onion'), 'invoice import'),
  ('onik', 'ONIK', (select id from public.ingredients where name = 'Brown onion'), 'invoice import'),
  ('onions red', 'Onions - Red', (select id from public.ingredients where name = 'Red onion'), 'invoice import'),
  ('onirk', 'ONIRK', (select id from public.ingredients where name = 'Red onion'), 'invoice import'),
  ('potatoes brushed', 'Potatoes - Brushed', (select id from public.ingredients where name = 'Potato'), 'invoice import'),
  ('potbk', 'POTBK', (select id from public.ingredients where name = 'Potato'), 'invoice import'),
  ('shallots', 'Shallots', (select id from public.ingredients where name = 'Spring onion'), 'invoice import'),
  ('eshb', 'ESHB', (select id from public.ingredients where name = 'Spring onion'), 'invoice import'),
  ('tomatoes gourmet', 'Tomatoes - Gourmet', (select id from public.ingredients where name = 'Tomato'), 'invoice import'),
  ('tomk', 'TOMK', (select id from public.ingredients where name = 'Tomato'), 'invoice import'),
  ('zucchini', 'Zucchini', (select id from public.ingredients where name = 'Zucchini'), 'invoice import'),
  ('zuck', 'ZUCK', (select id from public.ingredients where name = 'Zucchini'), 'invoice import'),
  ('garlic peeled', 'Garlic - Peeled', (select id from public.ingredients where name = 'Garlic'), 'invoice import'),
  ('garp', 'GARP', (select id from public.ingredients where name = 'Garlic'), 'invoice import'),
  ('thai basil', 'Thai Basil', (select id from public.ingredients where name = 'Thai basil'), 'invoice import'),
  ('bastk', 'BASTK', (select id from public.ingredients where name = 'Thai basil'), 'invoice import'),
  ('pg sweet paprika 10 1kg', 'PG''SWEET PAPRIKA 10*1KG', (select id from public.ingredients where name = 'Paprika powder'), 'invoice import'),
  ('sweet paprika', 'SWEET PAPRIKA', (select id from public.ingredients where name = 'Paprika powder'), 'invoice import'),
  ('lkk panda oyster fla sce 6 5lb', 'LKK''PANDA OYSTER FLA SCE 6*5LB', (select id from public.ingredients where name = 'Oyster sauce'), 'invoice import'),
  ('lkk panda oyster sauce', 'LKK PANDA OYSTER SAUCE', (select id from public.ingredients where name = 'Oyster sauce'), 'invoice import'),
  ('mkr oyster sauce 3x4500ml', 'MKR''OYSTER SAUCE 3X4500ML', (select id from public.ingredients where name = 'Oyster sauce'), 'invoice import'),
  ('oyster sauce', 'OYSTER SAUCE', (select id from public.ingredients where name = 'Oyster sauce'), 'invoice import'),
  ('mgc gf oyster sce 3 5 4kg', 'MGC'' GF OYSTER SCE 3*5.4KG', (select id from public.ingredients where name = 'GF oyster sauce'), 'invoice import'),
  ('gf oyster sauce', 'GF OYSTER SAUCE', (select id from public.ingredients where name = 'GF oyster sauce'), 'invoice import'),
  ('ad uht coconut milk 12 1l', 'AD(UHT) COCONUT MILK 12*1L', (select id from public.ingredients where name = 'Coconut milk'), 'invoice import'),
  ('coconut milk', 'COCONUT MILK', (select id from public.ingredients where name = 'Coconut milk'), 'invoice import'),
  ('mp masaman curry paste 12 1kg', 'MP''MASAMAN CURRY PASTE 12*1KG', (select id from public.ingredients where name = 'Massaman curry paste'), 'invoice import'),
  ('masaman curry paste', 'MASAMAN CURRY PASTE', (select id from public.ingredients where name = 'Massaman curry paste'), 'invoice import'),
  ('massaman curry paste', 'MASSAMAN CURRY PASTE', (select id from public.ingredients where name = 'Massaman curry paste'), 'invoice import'),
  ('mp green curry paste 12 1kg', 'MP'' GREEN CURRY PASTE 12*1KG', (select id from public.ingredients where name = 'Green curry paste'), 'invoice import'),
  ('green curry paste', 'GREEN CURRY PASTE', (select id from public.ingredients where name = 'Green curry paste'), 'invoice import'),
  ('mp red curry paste 12 1kg', 'MP'' RED CURRY PASTE 12*1KG', (select id from public.ingredients where name = 'Red curry paste'), 'invoice import'),
  ('red curry paste', 'RED CURRY PASTE', (select id from public.ingredients where name = 'Red curry paste'), 'invoice import'),
  ('hb vegi mushroom sce 12x800g', 'HB'' VEGI**MUSHROOM SCE 12X800G', (select id from public.ingredients where name = 'Shiitake mushroom sauce'), 'invoice import'),
  ('hb vegi mushroom sauce', 'HB VEGI MUSHROOM SAUCE', (select id from public.ingredients where name = 'Shiitake mushroom sauce'), 'invoice import'),
  ('mushroom sauce', 'MUSHROOM SAUCE', (select id from public.ingredients where name = 'Shiitake mushroom sauce'), 'invoice import'),
  ('abc sweet soy sce 3 6k', 'ABC'' SWEET SOY SCE 3*6K', (select id from public.ingredients where name = 'ABC sweet soy sauce'), 'invoice import'),
  ('abc sweet soy sauce', 'ABC SWEET SOY SAUCE', (select id from public.ingredients where name = 'ABC sweet soy sauce'), 'invoice import'),
  ('olssons cooking sea salt 10kg', 'OLSSONS'' COOKING SEA SALT 10KG', (select id from public.ingredients where name = 'Salt'), 'invoice import'),
  ('cooking sea salt', 'COOKING SEA SALT', (select id from public.ingredients where name = 'Salt'), 'invoice import'),
  ('pt yentafo sauce 12 454g', 'PT''YENTAFO SAUCE ***12*454G', (select id from public.ingredients where name = 'Yentafo sauce (Penta)'), 'invoice import'),
  ('yentafo sauce', 'YENTAFO SAUCE', (select id from public.ingredients where name = 'Yentafo sauce (Penta)'), 'invoice import'),
  ('pt chilli p s bean oil 3 3k', 'PT''CHILLI P/S''BEAN OIL ***3*3K', (select id from public.ingredients where name = 'Yentafo sauce (Penta)'), 'invoice import'),
  ('chilli p s bean oil', 'CHILLI P/S BEAN OIL', (select id from public.ingredients where name = 'Yentafo sauce (Penta)'), 'invoice import'),
  ('j j coriander seed 1kg', 'J&J CORIANDER SEED 1KG', (select id from public.ingredients where name = 'Coriander seed'), 'invoice import'),
  ('coriander seed', 'CORIANDER SEED', (select id from public.ingredients where name = 'Coriander seed'), 'invoice import'),
  ('c tho fun stir fry cut blue1k', 'C''THO FUN-STIR FRY**CUT-BLUE1K', (select id from public.ingredients where name = 'Wide rice noodles (sen yai)'), 'invoice import'),
  ('fun stir fry cut blue', 'FUN-STIR FRY CUT-BLUE', (select id from public.ingredients where name = 'Wide rice noodles (sen yai)'), 'invoice import'),
  ('cho fun stir fry', 'CHO FUN STIR FRY', (select id from public.ingredients where name = 'Wide rice noodles (sen yai)'), 'invoice import'),
  ('pg turnip ground sweet 30 400g', 'PG''TURNIP GROUND-SWEET 30*400G', (select id from public.ingredients where name = 'Sweet pickled radish'), 'invoice import'),
  ('turnip ground sweet', 'TURNIP GROUND-SWEET', (select id from public.ingredients where name = 'Sweet pickled radish'), 'invoice import'),
  ('v tiane jasmine rice 20kg', 'V/TIANE'' JASMINE RICE 20KG', (select id from public.ingredients where name = 'Jasmine rice (raw)'), 'invoice import'),
  ('jasmine rice', 'JASMINE RICE', (select id from public.ingredients where name = 'Jasmine rice (raw)'), 'invoice import'),
  ('instant noodle soup powder gosto spicy 208g 48', 'INSTANT NOODLE SOUP POWDER ''Gosto'' Spicy 208g (48)', (select id from public.ingredients where name = 'Boat noodle powder'), 'invoice import'),
  ('gosto spicy instant noodle soup powder', 'GOSTO SPICY INSTANT NOODLE SOUP POWDER', (select id from public.ingredients where name = 'Boat noodle powder'), 'invoice import'),
  ('instant noodle soup powder gosto 208g', 'INSTANT NOODLE SOUP POWDER ''Gosto'' 208g', (select id from public.ingredients where name = 'Chicken noodle powder'), 'invoice import'),
  ('gosto instant noodle soup powder', 'GOSTO INSTANT NOODLE SOUP POWDER', (select id from public.ingredients where name = 'Chicken noodle powder'), 'invoice import')
on conflict (alias_key) do update set ingredient_id = excluded.ingredient_id;

-- 10. Opening prices from the invoices ----------------------------
-- Each ingredient's most recent invoice line, so dish costs and
-- margins work from day one. No wastage recorded — add it per
-- ingredient in the app where prep loss matters.
insert into public.purchases (ingredient_id, purchased_kg, price_paid, wastage_kg, purchased_at, entered_by)
select * from (values
  ((select id from public.ingredients where name = 'Fish sauce'), 13.5, 49.95, 0, timestamptz '2026-07-14 09:00+10', 'invoice: B&E 3 x 4.5L Squid'),
  ((select id from public.ingredients where name = 'Palm sugar'), 15.0, 58.5, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 30 x 500g Sugar Boy'),
  ((select id from public.ingredients where name = 'Rock sugar'), 2.8, 21.0, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 7 x 400g'),
  ((select id from public.ingredients where name = 'Tomato sauce'), 8.0, 24.9, 0, timestamptz '2026-07-14 09:00+10', 'invoice: B&E 2 x 4L Heinz'),
  ((select id from public.ingredients where name = 'MSG'), 6.0, 35.1, 0, timestamptz '2026-07-14 09:00+10', 'invoice: B&E 6 x 1kg'),
  ((select id from public.ingredients where name = 'White vinegar'), 20.0, 21.85, 0, timestamptz '2026-07-14 09:00+10', 'invoice: B&E 20L cask'),
  ((select id from public.ingredients where name = 'Knorr seasoning powder'), 8.0, 72.0, 0, timestamptz '2026-07-14 09:00+10', 'invoice: B&E 10 x 800g'),
  ((select id from public.ingredients where name = 'Star anise'), 1.0, 25.0, 0, timestamptz '2026-07-15 09:00+10', 'invoice: T&D 1kg'),
  ((select id from public.ingredients where name = 'Tamarind concentrate'), 8.0, 67.2, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 8 x 1kg'),
  ((select id from public.ingredients where name = 'Seasoning sauce (green cap)'), 9.0, 31.5, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 3 x 3L Golden Mountain'),
  ((select id from public.ingredients where name = 'Vegetable oil'), 20.0, 58.0, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 20L'),
  ((select id from public.ingredients where name = 'Pandan leaves'), 1.2, 18.9, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 6 x 200g'),
  ((select id from public.ingredients where name = 'Chilli jam (nam prik pao)'), 9.6, 78.75, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 3 x 3.2kg Chua Hah Seng'),
  ((select id from public.ingredients where name = 'Chilli jam oil'), 2.16, 17.1, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 3 x 720g'),
  ((select id from public.ingredients where name = 'Tom yum paste (Penta)'), 10.896, 112.8, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 12 x 908g Penta'),
  ((select id from public.ingredients where name = 'Light soy sauce'), 13.5, 59.25, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E 3 x 4.5L Healthy Boy'),
  ((select id from public.ingredients where name = 'Eggs'), 18.0, 104.0, 0, timestamptz '2026-07-09 09:00+10', 'invoice: B&E 2 ctn x 15 dozen'),
  ((select id from public.ingredients where name = 'Red chilli'), 2.0, 19.4, 0, timestamptz '2026-07-09 09:00+10', 'invoice: B&E 2 x 1kg frozen'),
  ((select id from public.ingredients where name = 'Baby corn'), 8.52, 21.45, 0, timestamptz '2026-07-09 09:00+10', 'invoice: B&E 3 x 2.84kg cans'),
  ((select id from public.ingredients where name = 'Fingerroot'), 0.908, 6.6, 0, timestamptz '2026-07-09 09:00+10', 'invoice: B&E 2 x 454g krachai'),
  ((select id from public.ingredients where name = 'Pork mince'), 30.0, 255.0, 0, timestamptz '2026-07-10 09:00+10', 'invoice: OP Meats'),
  ((select id from public.ingredients where name = 'Dried chilli'), 10.0, 193.0, 0, timestamptz '2026-07-23 09:00+10', 'invoice: Tangola 20 x 500g'),
  ((select id from public.ingredients where name = 'Lime powder'), 2.4, 36.9, 0, timestamptz '2026-07-23 09:00+10', 'invoice: Tangola 6 x 400g Knorr'),
  ((select id from public.ingredients where name = 'Sriracha sauce'), 4.5, 40.5, 0, timestamptz '2026-07-23 09:00+10', 'invoice: Tangola 6 x 750ml'),
  ((select id from public.ingredients where name = 'Boat noodle powder'), 19.968, 312.0, 0, timestamptz '2026-07-23 09:00+10', 'invoice: Tangola 96 x 208g Gosto Spicy'),
  ((select id from public.ingredients where name = 'Pork blood'), 10.0, 70.0, 0, timestamptz '2026-07-16 09:00+10', 'invoice: Darra'),
  ((select id from public.ingredients where name = 'Beef sliced 1.5mm'), 1.14, 19.38, 0, timestamptz '2026-07-16 09:00+10', 'invoice: Darra beef sliced 1.5mm'),
  ((select id from public.ingredients where name = 'Pork topside denuded'), 17.03, 137.94, 0, timestamptz '2026-07-14 09:00+10', 'invoice: B&E fresh pork topside'),
  ((select id from public.ingredients where name = 'Crispy pork'), 30.3, 448.44, 0, timestamptz '2026-07-28 09:00+10', 'invoice: B&E pork belly cooked roast'),
  ((select id from public.ingredients where name = 'Chicken breast fillet sliced'), 32.6, 277.1, 0, timestamptz '2026-07-27 09:00+10', 'invoice: Darra'),
  ((select id from public.ingredients where name = 'Pork lean leg sliced'), 15.1, 135.9, 0, timestamptz '2026-07-27 09:00+10', 'invoice: Darra'),
  ((select id from public.ingredients where name = 'Beef topside sliced'), 11.82, 195.03, 0, timestamptz '2026-07-27 09:00+10', 'invoice: Darra'),
  ((select id from public.ingredients where name = 'Chicken maryland fillet diced'), 10.22, 117.53, 0, timestamptz '2026-07-27 09:00+10', 'invoice: Darra'),
  ((select id from public.ingredients where name = 'Bean sprouts'), 16.0, 72.0, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Green beans'), 10.0, 34.0, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh 1 box 10kg'),
  ((select id from public.ingredients where name = 'Broccoli'), 2.0, 15.98, 0, timestamptz '2026-07-10 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Capsicum'), 8.0, 29.95, 0, timestamptz '2026-07-10 09:00+10', 'invoice: Efresh 1 box 8kg'),
  ((select id from public.ingredients where name = 'Carrot'), 4.0, 11.96, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Choy sum'), 0.5, 3.98, 0, timestamptz '2026-07-10 09:00+10', 'invoice: Efresh 2 bunch @ 250g'),
  ((select id from public.ingredients where name = 'Coriander'), 0.32, 10.36, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh 4 bunch @ 80g'),
  ((select id from public.ingredients where name = 'Eggplant'), 3.0, 14.97, 0, timestamptz '2026-07-10 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Lemon'), 4.0, 19.96, 0, timestamptz '2026-07-10 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Lime'), 1.0, 6.99, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Mushrooms'), 1.0, 12.95, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh button'),
  ((select id from public.ingredients where name = 'Brown onion'), 3.0, 7.47, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Red onion'), 2.0, 3.98, 0, timestamptz '2026-07-10 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Potato'), 2.0, 5.98, 0, timestamptz '2026-07-10 09:00+10', 'invoice: Efresh brushed'),
  ((select id from public.ingredients where name = 'Spring onion'), 0.5, 9.95, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh 5 bunch @ 100g'),
  ((select id from public.ingredients where name = 'Tomato'), 1.0, 3.99, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh gourmet'),
  ((select id from public.ingredients where name = 'Zucchini'), 3.0, 10.47, 0, timestamptz '2026-07-10 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Garlic'), 4.0, 23.96, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh peeled'),
  ((select id from public.ingredients where name = 'Thai basil'), 1.0, 19.99, 0, timestamptz '2026-07-13 09:00+10', 'invoice: Efresh'),
  ((select id from public.ingredients where name = 'Paprika powder'), 1.0, 12.0, 0, timestamptz '2026-04-29 09:00+10', 'invoice: T&D'),
  ((select id from public.ingredients where name = 'Oyster sauce'), 13.608, 57.0, 0, timestamptz '2026-07-22 09:00+10', 'invoice: T&D 6 x 5lb LKK Panda'),
  ((select id from public.ingredients where name = 'Coconut milk'), 24.0, 110.4, 0, timestamptz '2026-07-22 09:00+10', 'invoice: T&D 24 x 1L'),
  ((select id from public.ingredients where name = 'Massaman curry paste'), 4.0, 28.8, 0, timestamptz '2026-07-22 09:00+10', 'invoice: T&D 4 x 1kg'),
  ((select id from public.ingredients where name = 'Green curry paste'), 6.0, 43.2, 0, timestamptz '2026-07-22 09:00+10', 'invoice: T&D 6 x 1kg'),
  ((select id from public.ingredients where name = 'Red curry paste'), 4.0, 28.8, 0, timestamptz '2026-04-29 09:00+10', 'invoice: T&D 4 x 1kg'),
  ((select id from public.ingredients where name = 'Shiitake mushroom sauce'), 1.6, 10.0, 0, timestamptz '2026-07-15 09:00+10', 'invoice: T&D 2 x 800g HB Vegi'),
  ((select id from public.ingredients where name = 'ABC sweet soy sauce'), 6.0, 23.5, 0, timestamptz '2026-04-29 09:00+10', 'invoice: T&D 1 x 6kg'),
  ((select id from public.ingredients where name = 'Salt'), 10.0, 9.5, 0, timestamptz '2026-07-15 09:00+10', 'invoice: T&D Olssons 10kg'),
  ((select id from public.ingredients where name = 'Yentafo sauce (Penta)'), 2.724, 25.2, 0, timestamptz '2026-07-22 09:00+10', 'invoice: T&D 6 x 454g Penta'),
  ((select id from public.ingredients where name = 'Coriander seed'), 1.0, 9.5, 0, timestamptz '2026-07-22 09:00+10', 'invoice: T&D 1kg'),
  ((select id from public.ingredients where name = 'Wide rice noodles (sen yai)'), 40.0, 140.0, 0, timestamptz '2026-07-09 09:00+10', 'invoice: T&D 40 x 1kg fresh cut'),
  ((select id from public.ingredients where name = 'Sweet pickled radish'), 2.0, 13.5, 0, timestamptz '2026-07-09 09:00+10', 'invoice: T&D 5 x 400g'),
  ((select id from public.ingredients where name = 'Jasmine rice (raw)'), 120.0, 234.0, 0, timestamptz '2026-07-09 09:00+10', 'invoice: T&D 6 x 20kg'),
  ((select id from public.ingredients where name = 'GF oyster sauce'), 16.2, 29.0, 0, timestamptz '2026-07-09 09:00+10', 'invoice: T&D 3 x 5.4kg MGC'),
  ((select id from public.ingredients where name = 'Water'), 1000.0, 2.0, 0, timestamptz '2026-07-01 09:00+10', 'invoice: nominal tap water cost')
) as v(ingredient_id, purchased_kg, price_paid, wastage_kg, purchased_at, entered_by)
where v.ingredient_id is not null;

commit;
