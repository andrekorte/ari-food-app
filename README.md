# Arifood — kitchen costing app

A mobile-friendly web app that calculates what every dish really costs.

**Part 1 — Ingredients.** Enter what was bought, what it cost, and the wastage
(bones, trim, peel). The app spreads the price over the *usable* weight only,
giving the true price per kg and per gram. Every purchase is kept as history,
so prices can be tracked over time; the newest purchase sets the current price.

**Part 2 — Dishes.** Build a dish from the shared ingredient list by entering
grams per ingredient. The app totals the cost per portion, and — given a
selling price — calculates gross profit and margin automatically.

Multiple team members log in with their own accounts and share one live
database. The interface can be switched between English and Thai. Prices are
in Australian dollars.

## Tech

- Static frontend (plain HTML/CSS/JS), hosted on GitHub Pages — no build step.
- [Supabase](https://supabase.com) for authentication and the shared Postgres
  database (free tier). Schema in `supabase/schema.sql`.
- Configuration in `js/config.js` (project URL + public anon key).

## Setup

See [SETUP.md](SETUP.md) for the one-time setup (about 15 minutes).
