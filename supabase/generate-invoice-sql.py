#!/usr/bin/env python3
"""Generate alias + opening-price SQL from the supplier invoices."""
import re, sys
sys.path.insert(0, '/workspace/ari-food-app/supabase')
import importlib.util
spec = importlib.util.spec_from_file_location("gen", "/workspace/ari-food-app/supabase/generate-sop-sql.py")
gen = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gen)
ING = gen.ING

# ---- aliases: ingredient key -> list of invoice wordings / product codes ----
ALIAS = {
 "chicken_slice": ["CHICKEN BREAST FILLET SLICED", "CBFSB", "CBFSB CHICKEN BREAST FILLET SLICED"],
 "chicken_curry": ["CHICKEN MARYLAND FILLET DICED", "CMFDB"],
 "pork_slice": ["PORK LEAN LEG SLICED", "Pork Lean Leg Slice", "PLLSB", "PLLS"],
 "pork_topside": ["FRESH PORK - TOPSIDE DENUDED IW 3KG (6) RW BE PRIME", "FRESH PORK TOPSIDE DENUDED"],
 "pork_mince": ["PORK MINCE COURSE", "PORK MINCE"],
 "beef_slice": ["Beef Sliced 1.5mm (Tai)", "BN", "BEEF SLICED"],
 "beef_topside": ["Beef Topside Sliced", "BTS"],
 "crispy_pork": ["PORK BELLY COOKED ROAST 4KG(3) RW #03960 PRIMO", "PORK BELLY COOKED ROAST"],
 "pork_blood": ["Pork Blood", "PBL"],
 "egg": ["EGGS - 600G 15X1 DOZEN", "EGGS"],
 "fish_sauce": ["SAUCE - FISH SAUCE 4.5L (3) SQUID", "FISH SAUCE SQUID"],
 "palm_sugar": ["PALM SUGAR 500G (30) SUGAR BOY", "PALM SUGAR", "BDB' COCONUT SUGAR 10*1K-PKT",
                "BDB COCONUT SUGAR", "COCONUT SUGAR"],
 "rock_sugar": ["SUGAR ROCK 400G (50)", "SUGAR ROCK"],
 "white_sugar": ["WHITE SUGAR", "SUGAR - WHITE"],
 "tomato_sauce": ["SAUCE - TOMATO (GF) 4LTR (3) HEINZ", "HEINZ'TOMATO SAUCE G/FRE 3*4LT",
                  "HEINZ TOMATO SAUCE"],
 "msg": ["MSG 1KG (20)", "MSG"],
 "vinegar": ["VINEGAR - WHITE 20LTR CASK SUPRA", "VINEGAR - WHITE"],
 "knorr": ["CHICKEN SEASONING POWDER 800G (10) KNORR", "KNORR CHICKEN SEASONING POWDER"],
 "star_anise": ["SPICE - STAR ANISE WHOLE 1KG CSI", "GH'STAR ANISEED ***10*1K", "STAR ANISEED"],
 "tamarind": ["PASTE - TAMARIND CONCENTRATE GLUEN FREE 1KG(12) AAA MOUNTAIN",
              "PG'TAMARIND CONCENTRAT 12*850G", "TAMARIND CONCENTRATE"],
 "seasoning_green": ["SAUCE - SOYA BEAN SEASONING SAUCE 3LT (6) GOLDEN MOUNTAIN",
                     "GOLDEN MOUNTAIN SEASONING SAUCE", "SOYA BEAN SEASONING SAUCE"],
 "veg_oil": ["OIL - VEGETABLE OIL 20L JERRY CAN SIMPLY", "VEGETABLE OIL"],
 "pandan": ["FZ PANDAN LEAVES 200G X 36 OCHA", "PANDAN LEAVES"],
 "chilli_jam": ["SAUCE - CHILLI PASTE FORMULA 8 3.2KG (4) CHUA HAH SENG",
                "CHILLI PASTE FORMULA 8", "CHUA HAH SENG CHILLI PASTE"],
 "chilli_jam_oil": ["SEASONING OIL - CHILLI OIL 720G (12) CHUA HAH SENG", "CHILLI OIL"],
 "tomyum_penta": ["PASTE - TOM YUM PASTE INSTANT HOT SOUR 908G(12) PENTA",
                  "PENTA' TOM YUM PASTE 12*908G", "TOM YUM PASTE"],
 "light_soy": ["SAUCE - THIN SOY SAUCE F1 6KG (4.5L) (3) HEALTHY BOY",
               "HB'THIN SOYA SCE-F1 3*4.5L", "THIN SOY SAUCE", "HEALTHY BOY THIN SOY"],
 "red_chilli": ["FZ CHILLI - RED 1KG (10)", "CHILLI - RED"],
 "baby_corn": ["CANNED - BABY CORN CUT A10 2.84KG X 3/CTN TWIN PINE", "BABY CORN CUT"],
 "fingerroot": ["PICKLED RHIZOME STRIP (KRACHAI) IN BRINE 454G (24) TRADED", "KRACHAI"],
 "dried_chilli": ["CHILLI Dry Small 'D-Jing' 500g (20)", "CHILLI DRY SMALL"],
 "lime_powder": ["LIME POWDER Seasoning 'Knorr' 400g (15)", "LIME POWDER"],
 "sriracha": ["SRIRACHA CHILLI SAUCE 'Gramount' 750ml (12)", "SRIRACHA CHILLI SAUCE"],
 "bean_sprouts": ["Bean Sprouts", "BEASK"],
 "snake_bean": ["Beans - Green", "BEAC", "GREEN BEANS"],
 "broccoli": ["Broccoli", "BROK"],
 "capsicum": ["Capsicums - Red", "CAPRC"],
 "carrot": ["Carrots", "CARK"],
 "choy_sum": ["Choy Sum", "CHOYB"],
 "coriander": ["Coriander", "CORB"],
 "sawtooth_coriander": ["Coriander - Sawtooth", "CORSB"],
 "eggplant": ["Eggplant", "EGGPK"],
 "lemon": ["Lemons", "LEMK"],
 "lime": ["Limes", "LIMK"],
 "mushroom": ["Mushrooms - Button", "MUSK"],
 "brown_onion": ["Onions - Brown", "ONIK"],
 "red_onion": ["Onions - Red", "ONIRK"],
 "potato": ["Potatoes - Brushed", "POTBK"],
 "spring_onion": ["Shallots", "ESHB"],
 "tomato": ["Tomatoes - Gourmet", "TOMK"],
 "zucchini": ["Zucchini", "ZUCK"],
 "garlic": ["Garlic - Peeled", "GARP"],
 "thai_basil": ["Thai Basil", "BASTK"],
 "paprika": ["PG'SWEET PAPRIKA 10*1KG", "SWEET PAPRIKA"],
 "oyster_sauce": ["LKK'PANDA OYSTER FLA SCE 6*5LB", "LKK PANDA OYSTER SAUCE",
                  "MKR'OYSTER SAUCE 3X4500ML", "OYSTER SAUCE"],
 "gf_oyster_sauce": ["MGC' GF OYSTER SCE 3*5.4KG", "GF OYSTER SAUCE"],
 "coconut_milk": ["AD(UHT) COCONUT MILK 12*1L", "COCONUT MILK"],
 "massaman_paste": ["MP'MASAMAN CURRY PASTE 12*1KG", "MASAMAN CURRY PASTE", "MASSAMAN CURRY PASTE"],
 "green_curry_paste": ["MP' GREEN CURRY PASTE 12*1KG", "GREEN CURRY PASTE"],
 "red_curry_paste": ["MP' RED CURRY PASTE 12*1KG", "RED CURRY PASTE"],
 "shiitake_sauce": ["HB' VEGI**MUSHROOM SCE 12X800G", "HB VEGI MUSHROOM SAUCE", "MUSHROOM SAUCE"],
 "abc_sauce": ["ABC' SWEET SOY SCE 3*6K", "ABC SWEET SOY SAUCE"],
 "salt": ["OLSSONS' COOKING SEA SALT 10KG", "COOKING SEA SALT"],
 "yentafo_penta": ["PT'YENTAFO SAUCE ***12*454G", "YENTAFO SAUCE",
                   "PT'CHILLI P/S'BEAN OIL ***3*3K", "CHILLI P/S BEAN OIL"],
 "coriander_seed": ["J&J CORIANDER SEED 1KG", "CORIANDER SEED"],
 "sen_yai": ["C'THO FUN-STIR FRY**CUT-BLUE1K", "FUN-STIR FRY CUT-BLUE", "CHO FUN STIR FRY"],
 "sweet_radish": ["PG'TURNIP GROUND-SWEET 30*400G", "TURNIP GROUND-SWEET"],
 "jasmine_rice": ["V/TIANE' JASMINE RICE 20KG", "JASMINE RICE"],
 "boat_noodle_powder": ["INSTANT NOODLE SOUP POWDER 'Gosto' Spicy 208g (48)",
                        "GOSTO SPICY INSTANT NOODLE SOUP POWDER"],
 "chicken_noodle_powder": ["INSTANT NOODLE SOUP POWDER 'Gosto' 208g",
                           "GOSTO INSTANT NOODLE SOUP POWDER"],
}

# ---- opening purchases: (ingredient key, qty in kg/L, total price, date, note) ----
BUY = [
 ("fish_sauce", 13.5, 49.95, "2026-07-14", "B&E 3 x 4.5L Squid"),
 ("palm_sugar", 15.0, 58.50, "2026-07-28", "B&E 30 x 500g Sugar Boy"),
 ("rock_sugar", 2.8, 21.00, "2026-07-28", "B&E 7 x 400g"),
 ("tomato_sauce", 8.0, 24.90, "2026-07-14", "B&E 2 x 4L Heinz"),
 ("msg", 6.0, 35.10, "2026-07-14", "B&E 6 x 1kg"),
 ("vinegar", 20.0, 21.85, "2026-07-14", "B&E 20L cask"),
 ("knorr", 8.0, 72.00, "2026-07-14", "B&E 10 x 800g"),
 ("star_anise", 1.0, 25.00, "2026-07-15", "T&D 1kg"),
 ("tamarind", 8.0, 67.20, "2026-07-28", "B&E 8 x 1kg"),
 ("seasoning_green", 9.0, 31.50, "2026-07-28", "B&E 3 x 3L Golden Mountain"),
 ("veg_oil", 20.0, 58.00, "2026-07-28", "B&E 20L"),
 ("pandan", 1.2, 18.90, "2026-07-28", "B&E 6 x 200g"),
 ("chilli_jam", 9.6, 78.75, "2026-07-28", "B&E 3 x 3.2kg Chua Hah Seng"),
 ("chilli_jam_oil", 2.16, 17.10, "2026-07-28", "B&E 3 x 720g"),
 ("tomyum_penta", 10.896, 112.80, "2026-07-28", "B&E 12 x 908g Penta"),
 ("light_soy", 13.5, 59.25, "2026-07-28", "B&E 3 x 4.5L Healthy Boy"),
 ("egg", 18.0, 104.00, "2026-07-09", "B&E 2 ctn x 15 dozen"),
 ("red_chilli", 2.0, 19.40, "2026-07-09", "B&E 2 x 1kg frozen"),
 ("baby_corn", 8.52, 21.45, "2026-07-09", "B&E 3 x 2.84kg cans"),
 ("fingerroot", 0.908, 6.60, "2026-07-09", "B&E 2 x 454g krachai"),
 ("pork_mince", 30.0, 255.00, "2026-07-10", "OP Meats"),
 ("dried_chilli", 10.0, 193.00, "2026-07-23", "Tangola 20 x 500g"),
 ("lime_powder", 2.4, 36.90, "2026-07-23", "Tangola 6 x 400g Knorr"),
 ("sriracha", 4.5, 40.50, "2026-07-23", "Tangola 6 x 750ml"),
 ("boat_noodle_powder", 19.968, 312.00, "2026-07-23", "Tangola 96 x 208g Gosto Spicy"),
 ("pork_blood", 10.0, 70.00, "2026-07-16", "Darra"),
 ("beef_slice", 1.14, 19.38, "2026-07-16", "Darra beef sliced 1.5mm"),
 ("pork_topside", 17.03, 137.94, "2026-07-14", "B&E fresh pork topside"),
 ("crispy_pork", 30.30, 448.44, "2026-07-28", "B&E pork belly cooked roast"),
 ("chicken_slice", 32.60, 277.10, "2026-07-27", "Darra"),
 ("pork_slice", 15.10, 135.90, "2026-07-27", "Darra"),
 ("beef_topside", 11.82, 195.03, "2026-07-27", "Darra"),
 ("chicken_curry", 10.22, 117.53, "2026-07-27", "Darra"),
 ("bean_sprouts", 16.0, 72.00, "2026-07-13", "Efresh"),
 ("snake_bean", 10.0, 34.00, "2026-07-13", "Efresh 1 box 10kg"),
 ("broccoli", 2.0, 15.98, "2026-07-10", "Efresh"),
 ("capsicum", 8.0, 29.95, "2026-07-10", "Efresh 1 box 8kg"),
 ("carrot", 4.0, 11.96, "2026-07-13", "Efresh"),
 ("choy_sum", 0.5, 3.98, "2026-07-10", "Efresh 2 bunch @ 250g"),
 ("coriander", 0.32, 10.36, "2026-07-13", "Efresh 4 bunch @ 80g"),
 ("eggplant", 3.0, 14.97, "2026-07-10", "Efresh"),
 ("lemon", 4.0, 19.96, "2026-07-10", "Efresh"),
 ("lime", 1.0, 6.99, "2026-07-13", "Efresh"),
 ("mushroom", 1.0, 12.95, "2026-07-13", "Efresh button"),
 ("brown_onion", 3.0, 7.47, "2026-07-13", "Efresh"),
 ("red_onion", 2.0, 3.98, "2026-07-10", "Efresh"),
 ("potato", 2.0, 5.98, "2026-07-10", "Efresh brushed"),
 ("spring_onion", 0.5, 9.95, "2026-07-13", "Efresh 5 bunch @ 100g"),
 ("tomato", 1.0, 3.99, "2026-07-13", "Efresh gourmet"),
 ("zucchini", 3.0, 10.47, "2026-07-10", "Efresh"),
 ("garlic", 4.0, 23.96, "2026-07-13", "Efresh peeled"),
 ("thai_basil", 1.0, 19.99, "2026-07-13", "Efresh"),
 ("paprika", 1.0, 12.00, "2026-04-29", "T&D"),
 ("oyster_sauce", 13.608, 57.00, "2026-07-22", "T&D 6 x 5lb LKK Panda"),
 ("coconut_milk", 24.0, 110.40, "2026-07-22", "T&D 24 x 1L"),
 ("massaman_paste", 4.0, 28.80, "2026-07-22", "T&D 4 x 1kg"),
 ("green_curry_paste", 6.0, 43.20, "2026-07-22", "T&D 6 x 1kg"),
 ("red_curry_paste", 4.0, 28.80, "2026-04-29", "T&D 4 x 1kg"),
 ("shiitake_sauce", 1.6, 10.00, "2026-07-15", "T&D 2 x 800g HB Vegi"),
 ("abc_sauce", 6.0, 23.50, "2026-04-29", "T&D 1 x 6kg"),
 ("salt", 10.0, 9.50, "2026-07-15", "T&D Olssons 10kg"),
 ("yentafo_penta", 2.724, 25.20, "2026-07-22", "T&D 6 x 454g Penta"),
 ("coriander_seed", 1.0, 9.50, "2026-07-22", "T&D 1kg"),
 ("sen_yai", 40.0, 140.00, "2026-07-09", "T&D 40 x 1kg fresh cut"),
 ("sweet_radish", 2.0, 13.50, "2026-07-09", "T&D 5 x 400g"),
 ("jasmine_rice", 120.0, 234.00, "2026-07-09", "T&D 6 x 20kg"),
 ("gf_oyster_sauce", 16.2, 29.00, "2026-07-09", "T&D 3 x 5.4kg MGC"),
 ("water", 1000.0, 2.00, "2026-07-01", "nominal tap water cost"),
]

def q(s):
    return "'" + str(s).replace("'", "''") + "'"

def norm(x):
    x = str(x).lower()
    x = re.sub(r"[^a-z0-9฀-๿ ]+", " ", x)
    return re.sub(r"\s+", " ", x).strip()

out = []
w = out.append
w("")
w("-- 9. Learned invoice wordings ------------------------------------")
w("-- Supplier descriptions and product codes from the July 2026")
w("-- invoices, so scans match first time without asking.")
w("insert into public.ingredient_aliases (alias_key, alias_text, ingredient_id, created_by) values")
rows, seen = [], set()
for key, texts in ALIAS.items():
    for txt in texts:
        k = norm(txt)
        if not k or k in seen:
            continue
        seen.add(k)
        rows.append(f"  ({q(k)}, {q(txt)}, "
                    f"(select id from public.ingredients where name = {q(ING[key][0])}), 'invoice import')")
w(",\n".join(rows))
w("on conflict (alias_key) do update set ingredient_id = excluded.ingredient_id;")
w("")
w("-- 10. Opening prices from the invoices ----------------------------")
w("-- Each ingredient's most recent invoice line, so dish costs and")
w("-- margins work from day one. No wastage recorded — add it per")
w("-- ingredient in the app where prep loss matters.")
w("insert into public.purchases (ingredient_id, purchased_kg, price_paid, wastage_kg, purchased_at, entered_by, note)")
w("select * from (values")
vals = []
for key, qty, price, date, note in BUY:
    vals.append(f"  ((select id from public.ingredients where name = {q(ING[key][0])}), "
                f"{qty}, {price}, 0, timestamptz {q(date + ' 09:00+10')}, "
                f"'Set-up import', {q(note)})")
w(",\n".join(vals))
w(") as v(ingredient_id, purchased_kg, price_paid, wastage_kg, purchased_at, entered_by, note)")
w("where v.ingredient_id is not null;")

open("/tmp/claude-0/-home-user-excercise-app/59585d0f-b213-557e-822e-98372ef79416/scratchpad/invoice_part.sql", "w").write("\n".join(out) + "\n")
print("aliases:", len(rows), " opening purchases:", len(BUY))
