# SOP rebuild — what was built and what was assumed

Built from: `A_la_carte.docx`, `noodle_menu.docx`, `Hot_bar_Ari.docx`,
`YINDEE_SOP_12062026.xlsx` (June 2026).

**Contents:** 113 ingredients · 23 sauces · 53 dish recipes (448 recipe
lines) · 9 protein options.

## How to apply

Run in the Supabase SQL editor, in this order:

1. `supabase/migration-2026-08-01-sop-rebuild-schema.sql` — adds nested
   sauces, protein options and the Hot bar category.
2. `supabase/rebuild-from-sop.sql` — wipes the old artificial data and
   loads everything from the SOPs. It runs as one transaction, so if
   anything fails nothing is changed.

## Measurement conversions used

| SOP measure | Grams / mL used |
|---|---|
| 1 โบว์เล็ก (small bowl) of meat | chicken 100, pork/beef 80, prawn/squid/crispy pork 120, tofu 100, meatballs 100 |
| 1 ทัพพี (scoop) of cooked rice | 250 g cooked → **170 g raw** per 1.5 scoops (1 : 2.2) |
| 1 ชิ้น (piece) of vegetable | 10 g |
| 1 ช้อนชา (tsp) | 5 g / mL |
| 1 ช้อนโต๊ะ (tbsp) | 15 g / mL |
| 1 oz | 30 mL |
| 1 กระบวย (dipper) | 250 mL |
| 1 โบว์กลาง (medium bowl) | 250–350 g — taken from the Hot bar doc per item |
| 1 ฟอง (egg) | 60 g |
| ranges ("5-6 ชิ้น") | midpoint |

## Judgement calls — please check these

1. **Garlic & Pepper** — the SOP lists no stir-fry sauce. Left exactly as
   written; add the sauce line in the app if it was an omission.
2. **Gai-Lan Oyster Sauce** — the SOP lists no gai lan, so **100 g** was
   added since the dish is named after it.
3. **"ถั่วซอย 1 ทัพพี"** (Pad Kra Pow) — a scoop of sliced beans taken as
   **100 g**, not 250 g like rice.
4. **"เส้นตามเลือก"** (noodle of choice) — defaults to **sen lek 120 g**.
5. **Spice level** — recipes use the *medium* chilli quantity.
6. **Marinade** — `หมักเนื้อสัตว์` is stored as a sauce (per 1 kg of meat)
   for reference; it is **not** added to each dish's protein cost.

## Provisional quantities (will be corrected from the invoices)

These SOP lines are given in packs rather than weights:

| Item | Recipe | Assumed |
|---|---|---|
| ซอสเห็ดหอม 8 ขวด | Vegan sauce | 8 × 700 mL = 5600 |
| โครงไก่ 3 | Boat & clear soup | 3 × 1200 g = 3600 |
| ผงก๋วยเตี๋ยวเรือ 2 | Boat soup | 2 sachets × 75 g = 150 |
| ผงก๋วยเตี๋ยวไก่ 3 ซอง | Clear soup | 3 × 75 g = 225 |
| เลือด 2 | Boat soup | 2 kg |
| ไชท้าว 1 ea | Clear soup | 800 g |
| ใบเตย 4–6 ea | Soups | 5 g each |
| พริกเผา 3 ถัง | Cashew sauce | 3 × 3000 g = 9000 |
| น้ำส้ม / เกลือ | Chilli vinegar | 1000 mL / 20 g (not stated) |

## Sauces with no recipe yet

Created but empty — they cost nothing until their recipe is added:

- **GF stir-fry sauce** — used by all 12 gluten-free dishes
- **Chestnut sauce** — used by Chicken Chestnuts
- **Yum dressing (น้ำยำ)** — used by Sen Kaeaw salad

## Hot bar yields — estimates

Batch recipes were divided by an assumed **250 g serve**:

| Dish | Serves per batch |
|---|---|
| Pad Krapow Pork Mince | 27 |
| Chicken Chestnuts | 14 |
| Green Curry Chicken | 27 |
| Red Curry Chicken | 16 |
| Massaman Curry Chicken | 17 |

Count the serves from one real batch and tell me the number — cost per
serve depends directly on it. Each hot bar dish exists twice: **$7**
(no rice) and **$12.99** (with rice).

## Dishes removed

31 bought-in items deleted: all Thai Snacks, Dessert, Entree and Special
categories. Ari's Drinks were kept (no recipes yet).

## Protein options

| Protein | Portion | Price |
|---|---|---|
| Chicken | 100 g | $16.99 |
| Pork | 80 g | $16.99 |
| Beef | 80 g | $16.99 |
| Tofu | 100 g | $16.99 |
| No meat | – | $16.99 |
| Prawn | 120 g | $18.99 |
| Squid | 120 g | $18.99 |
| Crispy pork | 120 g | $18.99 |
| Meatballs | 100 g | $18.99 |

Dishes flagged "customer chooses the protein" show a cost/margin table
for all nine, instead of being duplicated nine times.
