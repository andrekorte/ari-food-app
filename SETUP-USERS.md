# Turning on the Users tab

Three steps, about five minutes. Do them in order.

## 1. Run the database script

Supabase → **SQL Editor** → **New query** → paste the whole of
`supabase/migration-2026-08-01h-users.sql` → **Run**.

This makes sure everyone who signs up gets the access level they were
invited with, and that your existing accounts keep full admin access.

## 2. Add the service role key as a secret

The Users tab can only work through an Edge Function, because listing
accounts, sending invites and deleting logins need Supabase's **service
role** key — a key that can do anything in your database. It must never be
put in the app itself: anyone could read it out of the page and take over
the database. Keeping it in a function means it stays on Supabase's servers.

1. Supabase → **Project Settings** → **API Keys**.
2. Find **service_role** and copy it. (It's hidden behind a *Reveal* button.
   Treat it like a password — don't paste it into email or chat.)
3. Go to **Edge Functions** → **Secrets** → **Add new secret**.
   - Name: `SUPABASE_SERVICE_ROLE_KEY`
   - Value: the key you copied
4. **Save**.

## 3. Deploy the function

If you have the Supabase CLI installed:

```
supabase functions deploy manage-users
```

Otherwise, in the dashboard: **Edge Functions** → **Create a function** →
name it exactly `manage-users` → paste the contents of
`supabase/functions/manage-users/index.ts` → **Deploy**.

## 4. Check the invite emails point at the app

Supabase → **Authentication** → **URL Configuration** → set **Site URL** to:

```
https://andrekorte.github.io/ari-food-app/
```

and add the same address under **Redirect URLs**. Without this, the link in
the invite email sends people to the wrong place.

---

## Using it

- **Users tab** (bottom right, admins only) lists everyone with an account,
  their access level, and whether they've signed in yet.
- **Add user** asks for an email, a name, and whether they're an Admin or a
  Shopper, then emails them a link to choose their own password.
- **Tap a person** to see their email, when they last signed in, change
  their access level, resend the invite, or delete the account.
- **Activity** on that page lists what they've done — invoices recorded,
  stock updated, ingredients and dishes added, edited or deleted — ten at a
  time, oldest loaded only when you ask.

**Admin** can do everything. **Shopper** can only record purchases and
stock; they don't see ingredient prices, dishes, the Users tab or the
change history.

Deleting someone removes their login only. Everything they recorded stays in
the purchase, stock and change histories with their name on it.

## Limits worth knowing

On Supabase's free plan the built-in mailer sends only a few invite emails
per hour, and they arrive from Supabase's own address rather than yours.
That's fine for adding staff now and then. If you ever want the emails to
come from an Ari address, that's an SMTP setting in
**Authentication → Emails** — say the word and I'll write it up.
