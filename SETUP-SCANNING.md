# Receipt scanning — one-time setup

The 🧾 "Scan receipt" button on the Purchases screen sends a photo to an
AI vision model and pre-fills the basket. It needs two things set up once:
an OpenAI API key, and a small server function inside your Supabase
project that keeps the key secret.

## 1. Get your OpenAI API key

1. Go to <https://platform.openai.com> and log in.
2. Left sidebar → **API Keys** → **Create new secret key**.
   - Name: `arifood-scanner`
   - Project: Default project is fine.
3. Copy the key (starts with `sk-...`). It's shown only once — you'll
   paste it into Supabase in step 3. Don't put it anywhere public.

Cost: well under 1 cent per scanned receipt, taken from your credit
balance. Check usage anytime under **Usage** in the sidebar.

## 2. Create the edge function in Supabase

1. Supabase dashboard → your project → **Edge Functions** (left sidebar).
2. Click **Deploy a new function** → **Via Editor** (create in the browser).
3. Name it exactly: `scan-receipt`
4. Delete the sample code, and paste in the full contents of
   [`supabase/functions/scan-receipt/index.ts`](supabase/functions/scan-receipt/index.ts)
   from this repository.
5. Leave **Verify JWT** enabled (default) — this makes sure only
   logged-in app users can call it.
6. Click **Deploy function**.

## 3. Add the API key as a secret

1. Still under **Edge Functions**, open the **Secrets** tab
   (or Project Settings → Edge Functions → Secrets).
2. Add a secret:
   - Name: `OPENAI_API_KEY`
   - Value: the `sk-...` key from step 1
3. Save.

Optional extra secrets:
- `SCAN_MODEL` — override the model (default `gpt-5.6-luna`).
- `ANTHROPIC_API_KEY` — set this instead of the OpenAI key to run the
  scanner on Claude; the function uses whichever is configured.

## 4. Try it

Open the app → **Purchases** tab → **Scan receipt** → photograph a
receipt. After a few seconds the recognised items appear as basket rows:
matched ingredients are filled in; unmatched lines show the receipt text
with a "?" — tap to pick the right ingredient, fix any amounts, delete
lines you don't want, then **Save all**.

If it fails with a setup error, re-check that the function name is
`scan-receipt` and the `OPENAI_API_KEY` secret is saved.
