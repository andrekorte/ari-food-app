// Supabase Edge Function: scan-receipt
// Receives a base64 photo of a receipt/invoice from the app, sends it to
// an AI vision model (OpenAI by default, Anthropic if only that key is
// set), and returns structured line items for the purchase basket, plus
// a site hint read from the invoice's customer/delivery details.
//
// Secrets (Edge Functions → Secrets):
//   OPENAI_API_KEY     — your OpenAI API key  (or ANTHROPIC_API_KEY)
//   SCAN_MODEL         — optional model override (default: gpt-5.6-luna)
//
// Deploy with "Verify JWT" enabled so only logged-in app users can call it.

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const PROMPT = `You are reading a photo of a shopping receipt or a wholesale supplier tax invoice for a Thai restaurant in Australia. Return ONLY a JSON object shaped exactly like:
{"site_hint":"Yindee Thai","items":[{"name":"CHICKEN BREAST FILLET SLICED","quantity":32.6,"unit":"kg","price":277.10}]}
Rules:
- name: the COMPLETE item description exactly as printed (e.g. "CHICKEN BREAST FILLET SLICED", never shortened to "Chicken"). Do not summarise, merge or translate names; keep Thai text as-is. Ignore product codes.
- Wholesale invoices often have columns like Quantity (number of packs), Weight, Price (per-kg rate) and Amount (line total). In that case: quantity = the WEIGHT value, unit = "kg", price = the LINE TOTAL from the Amount column — NOT the per-kg rate. Sanity check: weight × rate should roughly equal the amount you output.
- Simple shop receipts: quantity + unit = the amount bought (prefer "kg","g","l","ml"; use "each" for counted items, 0 if unknown), price = the line total.
- price: a plain number.
- site_hint: any customer / "Invoice To" / "Deliver To" name or address text on the document (e.g. "Yindee Thai"); null if none shown.
- Skip non-food lines: totals, GST/tax, bags, deposits, discounts, card fees, delivery fees.`;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const { image, mime } = await req.json();
    if (!image || !mime) return json({ error: "missing image" }, 400);

    const openaiKey = Deno.env.get("OPENAI_API_KEY");
    const anthropicKey = Deno.env.get("ANTHROPIC_API_KEY");
    let text = "";

    if (openaiKey) {
      const model = Deno.env.get("SCAN_MODEL") || "gpt-5.6-luna";
      const r = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "content-type": "application/json",
          authorization: `Bearer ${openaiKey}`,
        },
        body: JSON.stringify({
          model,
          response_format: { type: "json_object" },
          messages: [{
            role: "user",
            content: [
              { type: "text", text: PROMPT },
              { type: "image_url", image_url: { url: `data:${mime};base64,${image}` } },
            ],
          }],
        }),
      });
      const body = await r.json();
      if (!r.ok) return json({ error: body.error?.message || "OpenAI error" }, 502);
      text = body.choices?.[0]?.message?.content || "{}";
    } else if (anthropicKey) {
      const model = Deno.env.get("SCAN_MODEL") || "claude-haiku-4-5-20251001";
      const r = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "x-api-key": anthropicKey,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model,
          max_tokens: 2000,
          messages: [{
            role: "user",
            content: [
              { type: "image", source: { type: "base64", media_type: mime, data: image } },
              { type: "text", text: PROMPT },
            ],
          }],
        }),
      });
      const body = await r.json();
      if (!r.ok) return json({ error: body.error?.message || "Anthropic error" }, 502);
      text = body.content?.[0]?.text || "{}";
    } else {
      return json({ error: "No OPENAI_API_KEY or ANTHROPIC_API_KEY secret configured" }, 500);
    }

    let parsed;
    try {
      parsed = JSON.parse(text);
    } catch {
      const m = text.match(/\{[\s\S]*\}/);
      parsed = m ? JSON.parse(m[0]) : { items: [] };
    }
    return json({
      items: Array.isArray(parsed.items) ? parsed.items : [],
      site_hint: typeof parsed.site_hint === "string" ? parsed.site_hint : null,
    });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { ...cors, "content-type": "application/json" },
  });
}
