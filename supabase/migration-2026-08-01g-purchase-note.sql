-- "Entered by" should name the person who recorded the purchase. The opening
-- invoices loaded during set-up put the invoice description in that column
-- instead (e.g. "invoice: B&E 3 x 4.5L Squid"), which showed up in the
-- purchase history where a name belongs. Move that text to its own note
-- column, where the app shows it under the ingredient line.
-- Run once in the Supabase SQL editor.

alter table public.purchases
  add column if not exists note text;

update public.purchases
   set note = regexp_replace(entered_by, '^invoice:\s*', ''),
       entered_by = 'Set-up import'
 where entered_by like 'invoice:%';
