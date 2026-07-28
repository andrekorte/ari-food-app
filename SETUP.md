# Arifood — one-time setup

The app itself is finished. These steps connect it to its database and put it
online. You only do this once; it takes about 15 minutes and costs nothing.

## 1. Create a Supabase project (the database + logins)

1. Go to <https://supabase.com> and sign up (free).
2. Click **New project**.
   - Name: `arifood`
   - Database password: pick anything strong and save it somewhere (you rarely need it again).
   - Region: **Sydney** (closest to Australia).
3. Wait a minute or two while the project is created.

## 2. Turn off self-registration

Only accounts you create should be able to log in.

1. In the Supabase dashboard go to **Authentication → Sign In / Providers**.
2. Turn **off** "Allow new users to sign up".

## 3. Create the database tables

1. In the dashboard go to **SQL Editor**.
2. Open the file `supabase/schema.sql` from this repository, copy all of it,
   paste it into the editor and press **Run**.
3. It should say "Success. No rows returned".

## 4. Create the user accounts

1. Go to **Authentication → Users → Add user → Create new user**.
2. Enter an email and a password for each team member (e.g. you and your wife).
3. Tell each person their email + password — they log in with these in the app.
   (The part of the email before the @ is shown as their name in the app.)

## 5. Connect the app to the project

1. In the dashboard go to **Project Settings → API** (or "Data API").
2. Copy two values:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon / public key** (a long string — this one is safe to publish)
3. Open `js/config.js` in this repository and replace the two placeholder
   values, then commit and push the change.

## 6. Put the app online with GitHub Pages

1. On GitHub, open this repository → **Settings → Pages**.
2. Under "Build and deployment", set **Source: Deploy from a branch**,
   branch **main**, folder **/ (root)**. Save.
3. After a minute the app is live at:
   **https://andrekorte.github.io/ari-food-app/**

Open that link on a phone, log in, and start entering ingredients.
Tip: in the phone browser choose "Add to Home Screen" to get an app icon.

## Everyday use — nothing to maintain

- All data is stored in Supabase; everyone who logs in sees the same live data.
- The free tier comfortably covers a small team's usage.
- To add or remove a team member later: Supabase dashboard → Authentication → Users.
