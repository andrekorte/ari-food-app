-- Group purchases into the basket they were saved with, and remember
-- which site they went to, so the Purchases screen can show a history.
-- Run once in the Supabase SQL editor.

alter table public.purchases
  add column if not exists batch_id uuid;
alter table public.purchases
  add column if not exists site text
  check (site is null or site in ('ari', 'yindee', 'sayhi'));

create index if not exists purchases_batch_idx on public.purchases (batch_id);
create index if not exists purchases_at_idx on public.purchases (purchased_at desc);
