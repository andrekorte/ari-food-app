#!/usr/bin/env python3
"""Generate the SOP rebuild SQL for the Food tracker app."""

# ---------------- ingredients: key -> (en, th, unit, category) ----------------
ING = {
  # proteins
  "chicken_slice": ("Chicken breast fillet sliced", "อกไก่สไลด์", "kg", "meat"),
  "chicken_curry": ("Chicken maryland fillet diced", "ไก่แมรี่แลนด์หั่นเต๋า", "kg", "meat"),
  "chicken_carcass": ("Chicken carcass", "โครงไก่", "kg", "meat"),
  "pork_slice": ("Pork lean leg sliced", "สะโพกหมูสไลด์", "kg", "meat"),
  "pork_topside": ("Pork topside denuded", "หมูสะโพกบน", "kg", "meat"),
  "pork_mince": ("Pork mince", "หมูสับ", "kg", "meat"),
  "beef_slice": ("Beef sliced 1.5mm", "เนื้อวัวสไลด์", "kg", "meat"),
  "beef_topside": ("Beef topside sliced", "เนื้อสันสะโพกสไลด์", "kg", "meat"),
  "prawn": ("Prawns", "กุ้ง", "kg", "meat"),
  "squid": ("Squid", "ปลาหมึก", "kg", "meat"),
  "crispy_pork": ("Crispy pork", "หมูกรอบ", "kg", "meat"),
  "tofu": ("Firm tofu", "เต้าหู้แข็ง", "kg", "meat"),
  "meatballs": ("Meatballs", "ลูกชิ้น", "kg", "meat"),
  "fish_balls": ("Fish balls", "ลูกชิ้นปลา", "kg", "meat"),
  "egg": ("Eggs", "ไข่ไก่", "kg", "meat"),
  "duck_blood": ("Duck blood", "เลือดเป็ด", "kg", "meat"),
  "pork_blood": ("Pork blood", "เลือดหมู", "kg", "meat"),
  "fish_strips": ("Fish strips", "ปลาเส้น", "kg", "meat"),
  "pork_crackling": ("Pork crackling", "กากหมู", "kg", "meat"),
  # vegetables & aromatics
  "brown_onion": ("Brown onion", "หอมหัวใหญ่", "kg", "veg"),
  "shallot": ("Shallots", "หอมแดง", "kg", "veg"),
  "spring_onion": ("Spring onion", "ต้นหอม", "kg", "veg"),
  "tomato": ("Tomato", "มะเขือเทศ", "kg", "veg"),
  "gai_lan": ("Gai lan (Chinese broccoli)", "ผักคะน้า", "kg", "veg"),
  "napa": ("Chinese cabbage", "ผักกาดขาว", "kg", "veg"),
  "cabbage": ("Cabbage", "กะหล่ำปลี", "kg", "veg"),
  "choy_sum": ("Choy sum", "ผักกวางตุ้ง", "kg", "veg"),
  "morning_glory": ("Morning glory", "ผักบุ้ง", "kg", "veg"),
  "bean_sprouts": ("Bean sprouts", "ถั่วงอก", "kg", "veg"),
  "garlic_chives": ("Garlic chives", "กุยช่าย", "kg", "veg"),
  "snake_bean": ("Green beans", "ถั่วฝักยาว", "kg", "veg"),
  "carrot": ("Carrot", "แครอท", "kg", "veg"),
  "capsicum": ("Capsicum", "พริกหวาน", "kg", "veg"),
  "zucchini": ("Zucchini", "ซูกินี", "kg", "veg"),
  "broccoli": ("Broccoli", "บรอกโคลี", "kg", "veg"),
  "baby_corn": ("Baby corn", "ข้าวโพดอ่อน", "kg", "veg"),
  "eggplant": ("Eggplant", "มะเขือ", "kg", "veg"),
  "potato": ("Potato", "มันฝรั่ง", "kg", "veg"),
  "water_chestnut": ("Water chestnuts", "แห้ว", "kg", "veg"),
  "mushroom": ("Mushrooms", "เห็ด", "kg", "veg"),
  "enoki": ("Enoki mushrooms", "เห็ดเข็มทอง", "kg", "veg"),
  "mixed_stirfry_veg": ("Mixed stir-fry vegetables", "ชุดผัดรวม", "kg", "veg"),
  "garlic": ("Garlic", "กระเทียมสด", "kg", "veg"),
  "red_chilli": ("Red chilli", "พริกแดง", "kg", "veg"),
  "green_chilli": ("Green chilli", "พริกเขียว", "kg", "veg"),
  "birdseye": ("Bird's eye chilli", "พริกขี้หนู", "kg", "veg"),
  "dried_chilli": ("Dried chilli", "พริกแห้ง", "kg", "veg"),
  "holy_basil": ("Holy basil", "ใบกระเพรา", "kg", "veg"),
  "thai_basil": ("Thai basil", "ใบโหระพา", "kg", "veg"),
  "coriander": ("Coriander", "ผักชี", "kg", "veg"),
  "coriander_root": ("Coriander root", "รากผักชี", "kg", "veg"),
  "lemongrass": ("Lemongrass", "ตะไคร้", "kg", "veg"),
  "galangal": ("Galangal", "ข่า", "kg", "veg"),
  "fingerroot": ("Fingerroot", "กระชาย", "kg", "veg"),
  "green_peppercorn": ("Young green peppercorns", "พริกไทยอ่อน", "kg", "veg"),
  "kaffir_leaf": ("Kaffir lime leaves", "ใบมะกรูด", "kg", "veg"),
  "pandan": ("Pandan leaves", "ใบเตย", "kg", "veg"),
  "daikon": ("Daikon radish", "หัวไชเท้า", "kg", "veg"),
  "lime": ("Lime", "มะนาว", "kg", "veg"),
  "lemon": ("Lemon", "เลมอน", "kg", "veg"),
  "red_onion": ("Red onion", "หอมหัวใหญ่แดง", "kg", "veg"),
  "sawtooth_coriander": ("Sawtooth coriander", "ผักชีฝรั่ง", "kg", "veg"),
  # sauces, pastes, seasonings (bought in)
  "oyster_sauce": ("Oyster sauce", "น้ำมันหอย", "l", "sauce"),
  "gf_oyster_sauce": ("GF oyster sauce", "น้ำมันหอยปลอดกลูเตน", "kg", "sauce"),
  "light_soy": ("Light soy sauce", "ซีอิ๊วขาว", "l", "sauce"),
  "seasoning_green": ("Seasoning sauce (green cap)", "ซอสปรุงรสฝาเขียว", "l", "sauce"),
  "seasoning_white": ("Seasoning sauce (white cap)", "ซอสปรุงรสฝาขาว", "l", "sauce"),
  "abc_sauce": ("ABC sweet soy sauce", "ซอส ABC", "l", "sauce"),
  "shiitake_sauce": ("Shiitake mushroom sauce", "ซอสเห็ดหอม", "l", "sauce"),
  "fish_sauce": ("Fish sauce", "น้ำปลา", "l", "sauce"),
  "pla_ra": ("Fermented fish sauce (pla ra)", "น้ำปลาร้า", "l", "sauce"),
  "vinegar": ("White vinegar", "น้ำส้มสายชู", "l", "sauce"),
  "sriracha": ("Sriracha sauce", "ซอสศรีราชา", "l", "sauce"),
  "tomato_sauce": ("Tomato sauce", "ซอสมะเขือเทศ", "l", "sauce"),
  "sesame_oil": ("Sesame oil", "น้ำมันงา", "l", "sauce"),
  "veg_oil": ("Vegetable oil", "น้ำมันพืช", "l", "sauce"),
  "garlic_oil": ("Fried garlic oil", "น้ำมันกระเทียมเจียว", "l", "sauce"),
  "coconut_milk": ("Coconut milk", "กะทิ", "l", "sauce"),
  "evaporated_milk": ("Evaporated milk", "นมข้นจืด", "l", "sauce"),
  "tamarind": ("Tamarind concentrate", "น้ำมะขาม", "kg", "sauce"),
  "lime_juice": ("Fresh lime juice", "น้ำมะนาวสด", "l", "sauce"),
  "water": ("Water", "น้ำเปล่า", "l", "sauce"),
  "yentafo_penta": ("Yentafo sauce (Penta)", "ซอสเย็นตาโฟเพนต้า", "kg", "sauce"),
  "tomyum_penta": ("Tom yum paste (Penta)", "ต้มยำเพนต้า", "kg", "sauce"),
  "chilli_jam": ("Chilli jam (nam prik pao)", "น้ำพริกเผา", "kg", "sauce"),
  "chilli_jam_oil": ("Chilli jam oil", "น้ำมันพริกเผา", "l", "sauce"),
  "red_curry_paste": ("Red curry paste", "พริกแกงแดง", "kg", "sauce"),
  "green_curry_paste": ("Green curry paste", "พริกแกงเขียวหวาน", "kg", "sauce"),
  "massaman_paste": ("Massaman curry paste", "พริกแกงมัสมั่น", "kg", "sauce"),
  "fermented_beancurd": ("Fermented bean curd", "เต้าหู้ยี้", "kg", "sauce"),
  "pickled_garlic": ("Pickled garlic", "กระเทียมดอง", "kg", "sauce"),
  "sweet_radish": ("Sweet pickled radish", "ไชโป๊หวาน", "kg", "sauce"),
  "white_sugar": ("White sugar", "น้ำตาลทราย", "kg", "sauce"),
  "palm_sugar": ("Palm sugar", "น้ำตาลปี๊บ", "kg", "sauce"),
  "rock_sugar": ("Rock sugar", "น้ำตาลกรวด", "kg", "sauce"),
  "salt": ("Salt", "เกลือ", "kg", "sauce"),
  "msg": ("MSG", "ผงชูรส", "kg", "sauce"),
  "knorr": ("Knorr seasoning powder", "ผงปรุงรสคนอร์", "kg", "sauce"),
  "white_pepper": ("White pepper", "พริกไทยขาว", "kg", "sauce"),
  "chilli_powder": ("Chilli powder", "พริกป่น", "kg", "sauce"),
  "paprika": ("Paprika powder", "ผงปาปริก้า", "kg", "sauce"),
  "lime_powder": ("Lime powder", "ผงมะนาว", "kg", "sauce"),
  "star_anise": ("Star anise", "โป๊ยกั๊ก", "kg", "sauce"),
  "cinnamon": ("Cinnamon", "อบเชย", "kg", "sauce"),
  "coriander_seed": ("Coriander seed", "เม็ดผักชี", "kg", "sauce"),
  "boat_noodle_powder": ("Boat noodle powder", "ผงก๋วยเตี๋ยวเรือ", "kg", "sauce"),
  "chicken_noodle_powder": ("Chicken noodle powder", "ผงก๋วยเตี๋ยวไก่", "kg", "sauce"),
  "bicarb": ("Bicarbonate of soda", "เบกกิ้งโซดา", "kg", "sauce"),
  # other
  "jasmine_rice": ("Jasmine rice (raw)", "ข้าวหอมมะลิ", "kg", "other"),
  "sen_lek": ("Thin rice noodles (sen lek)", "เส้นเล็ก", "kg", "other"),
  "sen_yai": ("Wide rice noodles (sen yai)", "เส้นใหญ่", "kg", "other"),
  "kelp_noodle": ("Kelp noodles (sen kaew)", "เส้นแก้ว", "kg", "other"),
  "fried_garlic": ("Fried garlic", "กระเทียมเจียว", "kg", "other"),
  "fried_shallot": ("Fried shallots", "หอมเจียว", "kg", "other"),
  "fried_wonton": ("Fried wonton", "เกี๊ยวทอด", "kg", "other"),
  "peanuts_crushed": ("Crushed peanuts", "ถั่วลิสงบด", "kg", "other"),
  "cashew_nuts": ("Cashew nuts", "เม็ดมะม่วงหิมพานต์", "kg", "other"),
  "white_sesame": ("White sesame seeds", "งาขาว", "kg", "other"),
  "tapioca_flour": ("Tapioca flour", "แป้งมัน", "kg", "other"),
}

# ---------------- sauces: key -> (en, th, [(kind, key, grams)]) ----------------
# kind 'i' = ingredient, 's' = another sauce.  Quantities are the SOP batch.
SAUCE = {
 "stirfry_sauce": ("Stir-fry sauce", "ซอสผัด", [
    ("i","oyster_sauce",9080), ("i","light_soy",2600), ("i","seasoning_green",2200),
    ("i","white_sugar",2200), ("i","knorr",400)]),
 "padthai_sauce": ("Pad Thai sauce", "ซอสผัดไทย", [
    ("i","tamarind",1000), ("i","palm_sugar",3000), ("i","salt",100), ("i","fish_sauce",700),
    ("i","tomato_sauce",1000), ("i","oyster_sauce",700), ("i","vinegar",1000), ("i","paprika",100)]),
 "vegan_sauce": ("Vegan stir-fry sauce", "ซอสผัดเจ", [
    ("i","shiitake_sauce",5600), ("i","light_soy",600), ("i","seasoning_green",460),
    ("i","white_sugar",1000), ("i","abc_sauce",660)]),
 "gf_sauce": ("GF stir-fry sauce", "ซอสผัดปลอดกลูเตน", []),
 "boat_soup": ("Boat noodle soup", "ซุปก๋วยเตี๋ยวเรือ", [
    ("i","water",16000), ("i","chicken_carcass",3600), ("i","star_anise",20), ("i","cinnamon",20),
    ("i","coriander_root",60), ("i","knorr",75), ("i","galangal",60), ("i","garlic",100),
    ("i","pandan",30), ("i","white_pepper",10), ("i","boat_noodle_powder",150),
    ("i","fermented_beancurd",70), ("i","oyster_sauce",100), ("i","seasoning_green",50),
    ("i","seasoning_white",50), ("i","abc_sauce",100), ("i","salt",30), ("i","palm_sugar",300),
    ("i","rock_sugar",200), ("i","fried_shallot",200), ("i","pickled_garlic",70),
    ("i","coriander_seed",20), ("i","coconut_milk",200), ("i","msg",75), ("i","pork_blood",2000)]),
 "clear_soup": ("Clear noodle soup", "ซุปก๋วยเตี๋ยวน้ำใส", [
    ("i","water",16000), ("i","knorr",200), ("i","daikon",800), ("i","pandan",20),
    ("i","white_pepper",10), ("i","coriander_root",60), ("i","garlic",60), ("i","salt",30),
    ("i","chicken_carcass",3600), ("i","rock_sugar",250), ("i","chicken_noodle_powder",225)]),
 "yentafo_sauce": ("Yentafo sauce", "ซอสเย็นตาโฟ", [
    ("i","tomato_sauce",400), ("i","sriracha",400), ("i","fermented_beancurd",220),
    ("i","white_sugar",200), ("i","vinegar",250), ("i","light_soy",80), ("i","oyster_sauce",200),
    ("i","pickled_garlic",100), ("i","garlic",70), ("i","red_chilli",10), ("i","salt",20),
    ("i","yentafo_penta",454)]),
 "tomyum_stirfry": ("Tom Yum stir-fry sauce", "ซอสผัดต้มยำ", [
    ("i","tomyum_penta",5400), ("i","chilli_jam",3200), ("i","white_sugar",600),
    ("i","water",200), ("s","stirfry_sauce",3000)]),
 "dry_noodle_sauce": ("Dry noodle sauce", "ซอสก๋วยเตี๋ยวแห้ง", [
    ("i","light_soy",200), ("i","seasoning_green",600), ("i","abc_sauce",1200),
    ("i","white_sugar",800), ("i","palm_sugar",200), ("i","sriracha",400), ("i","vinegar",200)]),
 "spicy_sour": ("Spicy & sour paste (clear tom yum)", "เพสต้มยำน้ำใส", [
    ("i","lime_powder",250), ("i","white_sugar",1800), ("i","fish_sauce",2025),
    ("i","vinegar",450), ("i","water",2250)]),
 "creamy_tomyum": ("Creamy Tom Yum paste", "เพสต้มยำน้ำข้น", [
    ("i","tomyum_penta",1000), ("i","chilli_jam",1000), ("i","chilli_jam_oil",1000),
    ("i","tamarind",1000), ("i","salt",600), ("i","fish_sauce",400), ("i","white_sugar",1000),
    ("s","lime_mix",800)]),
 "sukiyaki_sauce": ("Sukiyaki sauce", "น้ำจิ้มสุกี้", [
    ("i","sriracha",1000), ("i","tomato_sauce",1000), ("i","white_sugar",520), ("i","garlic",300),
    ("i","red_chilli",80), ("i","vinegar",300), ("i","sesame_oil",100), ("i","pickled_garlic",140),
    ("i","coriander",250), ("i","light_soy",200), ("i","white_sesame",400)]),
 "massaman_sauce": ("Massaman curry sauce", "แกงมัสมั่น", [
    ("i","massaman_paste",1000), ("i","tamarind",500), ("i","palm_sugar",1000), ("i","fish_sauce",50),
    ("i","salt",30), ("i","coconut_milk",2500), ("i","water",500), ("i","star_anise",10),
    ("i","cinnamon",10)]),
 "cashew_sauce": ("Cashew nut / chilli jam sauce", "ซอสแคชชูนัท", [
    ("i","chilli_jam",9000), ("s","stirfry_sauce",3000), ("i","white_sugar",600), ("i","water",300)]),
 "green_curry_sauce": ("Green curry sauce", "แกงเขียวหวาน", [
    ("i","kaffir_leaf",5), ("i","green_curry_paste",1000), ("i","knorr",50), ("i","salt",20),
    ("i","fish_sauce",30), ("i","coconut_milk",5000), ("i","water",1000), ("i","palm_sugar",550),
    ("i","veg_oil",250)]),
 "red_curry_sauce": ("Red curry sauce", "แกงแดง", [
    ("i","kaffir_leaf",5), ("i","red_curry_paste",1000), ("i","knorr",50), ("i","salt",20),
    ("i","fish_sauce",30), ("i","coconut_milk",5000), ("i","water",1000), ("i","palm_sugar",550),
    ("i","veg_oil",250)]),
 "chilli_vinegar": ("Chilli vinegar", "พริกน้ำส้ม", [
    ("i","green_chilli",500), ("i","red_chilli",500), ("i","vinegar",1000), ("i","salt",20)]),
 "noodle_base_sauce": ("Noodle base sauce", "น้ำรองก๋วยเตี๋ยว", [
    ("s","chilli_vinegar",1000), ("i","fish_sauce",500), ("i","white_sugar",500),
    ("i","chilli_powder",250), ("i","msg",100), ("i","vinegar",1000)]),
 "lime_mix": ("Lime juice mix", "น้ำมะนาวผสม", [
    ("i","lime_juice",60), ("i","lime_powder",100), ("i","water",300)]),
 "ajard": ("Ajard (cucumber relish liquid)", "น้ำอาจาด", [
    ("i","white_sugar",2000), ("i","vinegar",1000), ("i","salt",20)]),
 "meat_marinade": ("Meat marinade (per 1 kg meat)", "หมักเนื้อสัตว์", [
    ("i","bicarb",6), ("i","water",150), ("i","veg_oil",60), ("i","tapioca_flour",15)]),
 "yum_dressing": ("Yum dressing", "น้ำยำ", []),
}

RICE = ("i", "jasmine_rice", 170)   # 1.5 scoops cooked (375 g) at 1:2.2

# ---------------- dishes ----------------
# (menu name, category, price, uses_protein, lines)
DISH = []

def d(name, cat, price, prot, lines, name_th=None, new=False):
    DISH.append(dict(name=name, cat=cat, price=price, prot=prot,
                     lines=lines, name_th=name_th, new=new))

# --- a la carte (per portion) ---
d("Thai Fried Rice", "ala_carte", 16.99, True, [
  ("i","brown_onion",35), ("i","tomato",20), ("i","gai_lan",55), ("i","egg",60), RICE,
  ("s","stirfry_sauce",30), ("i","lime",10), ("i","white_pepper",1)])
d("Garlic & Pepper Stir Fry on Rice", "ala_carte", 16.99, True, [
  ("i","white_sugar",5), ("i","spring_onion",15), ("i","garlic",5), ("i","white_pepper",1),
  ("i","fried_garlic",5), RICE])
d("Tom Yum Fried Rice", "ala_carte", 16.99, True, [
  ("i","lemongrass",25), ("i","kaffir_leaf",2), ("i","mushroom",45), ("i","spring_onion",15),
  ("i","egg",60), RICE, ("s","tomyum_stirfry",45), ("i","lime",10), ("i","white_pepper",1)])
d("Pad See Eiw", "ala_carte", 16.99, True, [
  ("i","egg",60), ("i","sen_yai",270), ("i","gai_lan",65), ("s","stirfry_sauce",30),
  ("i","lime",10), ("i","white_pepper",1)])
d("Chili Jam Stir Fry on Rice", "ala_carte", 16.99, True, [
  ("i","mixed_stirfry_veg",100), ("s","cashew_sauce",30), RICE])
d("Pad Kra Pow on Rice", "ala_carte", 16.99, True, [
  ("i","snake_bean",100), ("i","birdseye",5), ("i","garlic",5), ("s","stirfry_sauce",30),
  ("i","abc_sauce",15), ("i","holy_basil",5), ("i","white_pepper",1), RICE])
d("Pad Thai", "ala_carte", 16.99, True, [
  ("i","bean_sprouts",80), ("i","garlic_chives",20), ("i","sweet_radish",10), ("i","egg",60),
  ("i","sen_lek",190), ("s","padthai_sauce",60), ("i","peanuts_crushed",5), ("i","lime",10)])
d("Spicy Basil Fried Rice", "ala_carte", 16.99, True, [
  ("i","snake_bean",55), ("i","birdseye",5), ("i","garlic",5), ("i","egg",60), RICE,
  ("s","stirfry_sauce",30), ("i","holy_basil",5), ("i","lime",10), ("i","white_pepper",1)])
d("Red Curry Paste Stir Fried", "ala_carte", 16.99, True, [
  ("i","white_sugar",5), ("i","garlic",5), ("i","snake_bean",55), ("i","kaffir_leaf",2),
  ("i","birdseye",5), ("i","red_curry_paste",5), ("s","stirfry_sauce",30)])
d("Chilli Salt Stir-Fry on Rice", "ala_carte", 16.99, True, [
  ("i","red_chilli",5), ("i","garlic",5), ("i","spring_onion",5), ("i","white_sugar",5),
  ("s","stirfry_sauce",30), ("i","fried_garlic",5), RICE])
d("Pad Kee Mao with Rice Noodles", "ala_carte", 16.99, True, [
  ("i","birdseye",5), ("i","garlic",5), ("i","green_peppercorn",5), ("i","fingerroot",5),
  ("i","snake_bean",55), ("i","egg",60), ("i","thai_basil",5), ("i","sen_yai",270),
  ("s","stirfry_sauce",30), ("i","lime",10), ("i","white_pepper",1)])
d("Gai-Lan (Kana) Oyster Sauce over Rice", "ala_carte", 16.99, True, [
  ("i","gai_lan",100), ("i","garlic",5), ("i","birdseye",5), ("s","stirfry_sauce",30),
  ("i","fried_garlic",5), RICE])
d("Dry Sukiyaki Kelp Noodles", "ala_carte", 16.99, True, [
  ("i","kelp_noodle",250), ("i","carrot",55), ("i","napa",55), ("i","morning_glory",125),
  ("s","sukiyaki_sauce",125)])
d("Sen Kaeaw Salad – Kelp Noodle", "ala_carte", 16.99, True, [
  ("s","yum_dressing",50), ("i","fish_sauce",15), ("i","lime_powder",5), ("i","tomato",20),
  ("i","lime",10), ("i","birdseye",5), ("i","kelp_noodle",250), ("i","shallot",15),
  ("i","enoki",30), ("i","coriander",5), ("i","spring_onion",5), ("i","cabbage",50),
  ("i","cashew_nuts",10)])
d("Tum Sen Lek – Thin Rice Noodle Salad", "ala_carte", 16.99, True, [
  ("i","pla_ra",50), ("i","white_sugar",10), ("i","msg",2.5), ("i","lime",30),
  ("i","garlic",2.5), ("i","birdseye",5), ("i","tomato",40), ("i","sawtooth_coriander",2),
  ("i","sen_lek",120)])

# --- noodle soups (per bowl) ---
NOODLE_COMMON = [("i","meatballs",45), ("i","sen_lek",120), ("i","garlic_oil",10),
                 ("i","fried_garlic",5), ("i","coriander",3), ("i","spring_onion",3),
                 ("i","white_pepper",1)]
d("Clear Noodle Soup", "noodle_soup", 16.99, True,
  [("s","clear_soup",250), ("i","bean_sprouts",30)] + NOODLE_COMMON)
d("Boat Noodles", "noodle_soup", 16.99, True,
  [("s","boat_soup",250), ("i","bean_sprouts",30), ("i","gai_lan",30),
   ("s","noodle_base_sauce",15), ("i","thai_basil",2), ("i","sawtooth_coriander",3)] + NOODLE_COMMON)
d("Spicy and Sour Soup", "noodle_soup", 16.99, True,
  [("s","clear_soup",200), ("s","spicy_sour",50), ("i","bean_sprouts",30),
   ("i","pork_mince",30), ("i","chilli_powder",5), ("i","peanuts_crushed",15),
   ("i","fried_wonton",20)] + NOODLE_COMMON)
d("Dry Noodles with Black Soy Sauce", "noodle_soup", 16.99, True,
  [("s","dry_noodle_sauce",50), ("i","gai_lan",30), ("i","lime",10),
   ("s","clear_soup",50)] + NOODLE_COMMON)
d("Creamy Tom Yum Noodles", "noodle_soup", 16.99, True,
  [("s","clear_soup",200), ("s","creamy_tomyum",30), ("i","evaporated_milk",30),
   ("i","mushroom",45), ("i","choy_sum",30)] + NOODLE_COMMON)
d("Pink Noodle Sauce", "noodle_soup", 16.99, True,
  [("s","clear_soup",200), ("s","yentafo_sauce",50), ("i","morning_glory",40),
   ("i","duck_blood",40), ("i","fish_strips",30), ("i","fried_wonton",20)] + NOODLE_COMMON)

# --- hot bar: batch recipes divided by estimated yield (250 g serves) ---
HOTBAR = [
  ("Pad Krapow Pork Mince", "ผัดกระเพราหมูสับ", 27, [
    ("i","pork_mince",5000), ("i","veg_oil",200), ("i","snake_bean",500), ("i","garlic",5),
    ("i","red_chilli",5), ("i","dried_chilli",100), ("s","stirfry_sauce",300),
    ("i","abc_sauce",250), ("i","red_chilli",125), ("i","holy_basil",250)]),
  ("Chicken Chestnuts", "ไก่ผัดแห้ว", 14, [
    ("i","veg_oil",200), ("i","brown_onion",300), ("i","carrot",300), ("i","capsicum",300),
    ("i","zucchini",300), ("i","broccoli",300), ("i","baby_corn",300), ("i","chicken_slice",700),
    ("s","stirfry_sauce",250), ("i","spring_onion",125),
    ("i","water_chestnut",125)]),
  ("Green Curry Chicken", "แกงเขียวหวานไก่", 27, [
    ("s","green_curry_sauce",3375), ("i","eggplant",1500), ("i","chicken_curry",1000),
    ("i","capsicum",300), ("i","snake_bean",300), ("i","red_chilli",125), ("i","thai_basil",250)]),
  ("Red Curry Chicken", "แกงแดงไก่", 16, [
    ("s","red_curry_sauce",2250), ("i","carrot",300), ("i","capsicum",300), ("i","zucchini",300),
    ("i","snake_bean",300), ("i","chicken_curry",600)]),
  ("Massaman Curry Chicken", "แกงมัสมั่นไก่", 17, [
    ("s","massaman_sauce",2250), ("i","chicken_curry",600), ("i","carrot",600),
    ("i","potato",600), ("i","brown_onion",300)]),
]
for name, th, yld, batch in HOTBAR:
    per = [(k, key, round(g / yld, 2)) for k, key, g in batch]
    d(name, "hot_bar", 7.00, False, per, name_th=th, new=True)
    d(name + " with Rice", "hot_bar", 12.99, False, per + [RICE], name_th=th + " ราดข้าว", new=True)

# --- vegan: base recipe, vegan sauce, tofu, no egg ---
VEGAN = [("Thai Fried Rice (Vegan)", "Thai Fried Rice"),
         ("Garlic and Pepper (Vegan)", "Garlic & Pepper Stir Fry on Rice"),
         ("Pad Ka Praw (Vegan)", "Pad Kra Pow on Rice"),
         ("Spicy Basil Fried Rice (Vegan)", "Spicy Basil Fried Rice"),
         ("Thai Salt and Chili (Vegan)", "Chilli Salt Stir-Fry on Rice"),
         ("Chili Jam Stir Fried (Vegan)", "Chili Jam Stir Fry on Rice"),
         ("Pad Kee Mao (Vegan)", "Pad Kee Mao with Rice Noodles"),
         ("Red Curry Stir Fried (Vegan)", "Red Curry Paste Stir Fried"),
         ("Gai-Lan (Kana) Oyster Sauce (Vegan)", "Gai-Lan (Kana) Oyster Sauce over Rice"),
         ("Sen Keaw Salad (Vegan)", "Sen Kaeaw Salad – Kelp Noodle")]
GF = [("Thai Fried Rice (GF)", "Thai Fried Rice"),
      ("Garlic and Pepper (GF)", "Garlic & Pepper Stir Fry on Rice"),
      ("Pad Ka Praw (GF)", "Pad Kra Pow on Rice"),
      ("Spicy Basil Fried Rice (GF)", "Spicy Basil Fried Rice"),
      ("Thai Salt and Chili (GF)", "Chilli Salt Stir-Fry on Rice"),
      ("Chili Jam Stir Fried (GF)", "Chili Jam Stir Fry on Rice"),
      ("Red Curry Paste Stir Fried (GF)", "Red Curry Paste Stir Fried"),
      ("Gai-Lan (Kana) Oyster Sauce (GF)", "Gai-Lan (Kana) Oyster Sauce over Rice"),
      ("Pad Kee Mao (GF)", "Pad Kee Mao with Rice Noodles"),
      ("Sen Keaw Salad (GF)", "Sen Kaeaw Salad – Kelp Noodle"),
      ("Dry Sukiyaki (GF)", "Dry Sukiyaki Kelp Noodles"),
      ("Tum Sen Lek Salad (GF)", "Tum Sen Lek – Thin Rice Noodle Salad")]

by_name = {x["name"]: x for x in DISH}
for name, base in VEGAN:
    src = by_name[base]
    lines = [l for l in src["lines"] if l[1] != "egg"]
    lines = [("s","vegan_sauce",g) if (k=="s" and key=="stirfry_sauce") else (k,key,g)
             for k,key,g in lines]
    lines.append(("i","tofu",100))
    d(name, "vegan", 16.99, False, lines)
for name, base in GF:
    src = by_name[base]
    lines = [("s","gf_sauce",g) if (k=="s" and key=="stirfry_sauce") else (k,key,g)
             for k,key,g in src["lines"]]
    d(name, "gluten_free", 16.99, True, lines)

# ---------------- proteins ----------------
PROTEIN = [("Chicken","ไก่","chicken_slice",100,16.99),
           ("Pork","หมู","pork_slice",80,16.99),
           ("Beef","เนื้อ","beef_slice",80,16.99),   # sliced 1.5mm, per Andre
           ("Tofu","เต้าหู้","tofu",100,16.99),
           ("No meat","ไม่ใส่เนื้อ",None,0,16.99),
           ("Prawn","กุ้ง","prawn",120,18.99),
           ("Squid","ปลาหมึก","squid",120,18.99),
           ("Crispy pork","หมูกรอบ","crispy_pork",120,18.99),
           ("Meatballs","ลูกชิ้น","meatballs",100,18.99)]

# ---------------- emit SQL ----------------
def q(s):
    return "'" + str(s).replace("'", "''") + "'"

out = []
w = out.append
w("-- Food tracker: rebuild ingredients, sauces and dish recipes from the")
w("-- Ari / Yindee SOPs (A la carte, Noodle menu, Hot bar, YINDEE SOP xlsx).")
w("-- Run AFTER migration-2026-08-01-sop-rebuild-schema.sql.")
w("-- WARNING: this deletes all existing ingredients, sauces, recipes,")
w("-- purchases and stock levels (all dummy data) and replaces them.")
w("")
w("begin;")
w("")
w("-- 1. Clear the old artificial data --------------------------------")
w("delete from public.dish_ingredients;")
w("delete from public.sauce_ingredients;")
w("delete from public.sauces;")
w("delete from public.protein_options;")
w("delete from public.stock_levels;")
w("delete from public.purchases;")
w("delete from public.ingredients;")
w("")
w("-- Remove bought-in dishes that are not cooked in-house")
w("delete from public.dishes where category in ('snacks','dessert','entree','special');")
w("")
w("-- 2. Ingredients --------------------------------------------------")
w("insert into public.ingredients (name, name_th, unit, category, updated_by) values")
rows = [f"  ({q(en)}, {q(th)}, {q(u)}, {q(c)}, 'SOP import')"
        for en, th, u, c in ING.values()]
w(",\n".join(rows) + ";")
w("")
w("-- 3. Sauces -------------------------------------------------------")
w("insert into public.sauces (name, name_th, updated_by) values")
rows = [f"  ({q(en)}, {q(th)}, 'SOP import')" for en, th, _ in SAUCE.values()]
w(",\n".join(rows) + ";")
w("")
w("-- 4. Sauce recipes (ingredients and nested sauces) -----------------")
for key, (en, th, lines) in SAUCE.items():
    if not lines:
        w(f"-- {en}: recipe not in the SOP yet")
        continue
    w(f"-- {en}")
    vals = []
    for kind, k, g in lines:
        if kind == "i":
            vals.append(f"  ((select id from public.sauces where name = {q(en)}), "
                        f"(select id from public.ingredients where name = {q(ING[k][0])}), null::uuid, {g})")
        else:
            vals.append(f"  ((select id from public.sauces where name = {q(en)}), null::uuid, "
                        f"(select id from public.sauces where name = {q(SAUCE[k][0])}), {g})")
    w("insert into public.sauce_ingredients (sauce_id, ingredient_id, sub_sauce_id, grams) values")
    w(",\n".join(vals) + ";")
w("")
w("-- 5. Dishes: new hot bar entries ----------------------------------")
new_dishes = [x for x in DISH if x["new"]]
if new_dishes:
    w("insert into public.dishes (name, name_th, category, selling_price, uses_protein, updated_by) values")
    rows = [f"  ({q(x['name'])}, {q(x['name_th'])}, {q(x['cat'])}, {x['price']}, "
            f"{'true' if x['prot'] else 'false'}, 'SOP import')" for x in new_dishes]
    w(",\n".join(rows) + ";")
w("")
w("-- 6. Dish settings (price / protein flag) -------------------------")
for x in DISH:
    w(f"update public.dishes set selling_price = {x['price']}, "
      f"uses_protein = {'true' if x['prot'] else 'false'}, updated_by = 'SOP import' "
      f"where name = {q(x['name'])};")
w("")
w("-- 7. Dish recipes -------------------------------------------------")
for x in DISH:
    if not x["lines"]:
        continue
    w(f"-- {x['name']}")
    vals = []
    for kind, k, g in x["lines"]:
        if kind == "i":
            vals.append(f"  ((select id from public.dishes where name = {q(x['name'])}), "
                        f"(select id from public.ingredients where name = {q(ING[k][0])}), null::uuid, {g})")
        else:
            vals.append(f"  ((select id from public.dishes where name = {q(x['name'])}), null::uuid, "
                        f"(select id from public.sauces where name = {q(SAUCE[k][0])}), {g})")
    w("insert into public.dish_ingredients (dish_id, ingredient_id, sauce_id, grams)")
    w("select * from (values")
    w(",\n".join(vals))
    w(") as v(dish_id, ingredient_id, sauce_id, grams) where v.dish_id is not null;")
w("")
w("-- 8. Protein options ----------------------------------------------")
w("insert into public.protein_options (name, name_th, ingredient_id, grams, selling_price, sort_order) values")
rows = []
for i, (en, th, ing, g, price) in enumerate(PROTEIN):
    ref = "null" if ing is None else f"(select id from public.ingredients where name = {q(ING[ing][0])})"
    rows.append(f"  ({q(en)}, {q(th)}, {ref}, {g}, {price}, {i})")
w(",\n".join(rows) + ";")
w("")
w("commit;")

open("/workspace/ari-food-app/supabase/rebuild-from-sop.sql", "w").write("\n".join(out) + "\n")
print("ingredients:", len(ING), " sauces:", len(SAUCE), " dishes:", len(DISH),
      " proteins:", len(PROTEIN))
print("dish recipe lines:", sum(len(x["lines"]) for x in DISH))
