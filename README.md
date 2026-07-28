# Food tracker — Ari Thai Street Food

A mobile-friendly kitchen costing app, styled after
[ari-thaistreetfood.com](https://ari-thaistreetfood.com/).

**Ingredients.** Enter what was bought, what it cost, and the wastage
(bones, trim, peel). The app spreads the price over the *usable* amount
only, giving the true price per kg/L and per g/mL. Every purchase is kept
as history; the newest purchase sets the current price. Ingredients are
measured in kilograms or litres (e.g. oil).

**New purchase (basket).** A shopping trip can be entered in one go from
the home screen — ingredient, amount, price per item — without wastage.

**Dishes.** Build a dish from the shared ingredient list by entering
grams/mL per ingredient. The app totals the cost per portion, and — given
a selling price — calculates gross profit and margin automatically. The
dish list is pre-seeded from the restaurant menu with selling prices.

**Team accounts & roles.** Everyone logs in with their own account and
shares one live database. Two roles: `admin` (full access) and `shopper`
(may only record shopping baskets; enforced by database row level
security, not just the UI).

The interface toggles between English and Thai. Prices are in Australian
dollars.

## Tech

- Static frontend (plain HTML/CSS/JS), hosted on GitHub Pages — no build step.
- [Supabase](https://supabase.com) for authentication and the shared
  Postgres database (free tier).
- `supabase/schema.sql` — full schema for a fresh install.
- `supabase/seed-ingredients.sql`, `supabase/seed-menu-dishes.sql` —
  optional starter data from the restaurant menu.
- `supabase/migration-*.sql` — incremental updates for databases created
  from an older schema.
- Configuration in `js/config.js` (project URL + public anon key).

## Setup

See [SETUP.md](SETUP.md) for the one-time setup.
