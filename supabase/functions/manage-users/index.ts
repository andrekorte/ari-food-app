// Account management for the Users tab.
//
// Listing accounts, sending invites and deleting logins all need Supabase's
// service_role key, which must never reach the browser — anyone could read
// it out of the app and get full access to the database. So it lives here
// as an Edge Function secret, and every request is checked twice: the caller
// must be signed in, and their profile role must be 'admin'.
//
// Supabase gives every Edge Function SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY
// automatically, so normally there is nothing to configure. If a project has
// the legacy keys turned off, add the sb_secret_… key from
// Settings → API Keys as a secret named SERVICE_KEY and this picks it up.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });

const URL_ = Deno.env.get("SUPABASE_URL")!;
const SERVICE =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ||   // provided automatically
  Deno.env.get("SERVICE_KEY") ||                 // sb_secret_… added by hand
  "";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  if (!SERVICE) {
    return json({
      error: "No service key available. Add the sb_secret_… key from " +
             "Settings → API Keys as an Edge Function secret named SERVICE_KEY.",
    }, 500);
  }

  const auth = req.headers.get("Authorization") || "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Not signed in." }, 401);

  const admin = createClient(URL_, SERVICE, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // Who is asking? Checking the caller's token against the same client
  // avoids needing a second key just to read the session.
  const { data: me, error: meErr } = await admin.auth.getUser(auth.slice(7));
  if (meErr || !me?.user) return json({ error: "Not signed in." }, 401);

  // Are they allowed? A missing profile row is treated as admin only for
  // the very first account, matching public.is_admin() in the database.
  const { data: prof } = await admin
    .from("profiles").select("role").eq("user_id", me.user.id).maybeSingle();
  if (prof && prof.role !== "admin") {
    return json({ error: "Admins only." }, 403);
  }

  let body: Record<string, unknown> = {};
  try {
    body = await req.json();
  } catch {
    return json({ error: "Bad request." }, 400);
  }
  const action = String(body.action || "");

  try {
    if (action === "list") {
      const users: Record<string, unknown>[] = [];
      // listUsers is paged; the team is small but page through anyway.
      for (let page = 1; page <= 20; page++) {
        const { data, error } = await admin.auth.admin.listUsers({ page, perPage: 100 });
        if (error) throw error;
        users.push(...data.users);
        if (data.users.length < 100) break;
      }
      const { data: profiles } = await admin.from("profiles").select("*");
      const byId = new Map((profiles || []).map((p) => [p.user_id, p]));
      return json({
        users: users.map((u: any) => {
          const p: any = byId.get(u.id) || {};
          return {
            id: u.id,
            email: u.email,
            display_name: p.display_name || (u.user_metadata || {}).display_name || null,
            role: p.role || "shopper",
            created_at: u.created_at,
            last_sign_in_at: u.last_sign_in_at,
            // Invited but hasn't set a password yet.
            pending: !u.last_sign_in_at,
            is_self: u.id === me.user.id,
          };
        }),
      });
    }

    if (action === "invite") {
      const email = String(body.email || "").trim().toLowerCase();
      const role = body.role === "admin" ? "admin" : "shopper";
      const name = String(body.display_name || "").trim();
      if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
        return json({ error: "That doesn't look like an email address." }, 400);
      }
      const redirectTo = String(body.redirect_to || "") || undefined;
      const { data, error } = await admin.auth.admin.inviteUserByEmail(email, {
        data: { role, display_name: name || email.split("@")[0] },
        redirectTo,
      });
      if (error) {
        // Already invited or already a user — say so plainly.
        const msg = /already/i.test(error.message)
          ? "That email already has an account."
          : error.message;
        return json({ error: msg }, 400);
      }
      // The signup trigger creates the profile row; make sure the role
      // sticks even if the trigger migration hasn't been run.
      await admin.from("profiles").upsert(
        { user_id: data.user.id, display_name: name || email.split("@")[0], role },
        { onConflict: "user_id" },
      );
      return json({ ok: true, id: data.user.id });
    }

    if (action === "set_role") {
      const id = String(body.user_id || "");
      const role = body.role === "admin" ? "admin" : "shopper";
      if (id === me.user.id && role !== "admin") {
        return json({ error: "You can't remove your own admin access." }, 400);
      }
      const { error } = await admin.from("profiles")
        .upsert({ user_id: id, role }, { onConflict: "user_id" });
      if (error) throw error;
      return json({ ok: true });
    }

    if (action === "resend") {
      const email = String(body.email || "").trim().toLowerCase();
      const redirectTo = String(body.redirect_to || "") || undefined;
      const { error } = await admin.auth.admin.inviteUserByEmail(email, { redirectTo });
      if (error) return json({ error: error.message }, 400);
      return json({ ok: true });
    }

    if (action === "delete") {
      const id = String(body.user_id || "");
      if (id === me.user.id) {
        return json({ error: "You can't delete your own account." }, 400);
      }
      // Everything they recorded stays: purchases, stock changes and the
      // change log store the person's name as plain text, not a link.
      const { error } = await admin.auth.admin.deleteUser(id);
      if (error) throw error;
      await admin.from("profiles").delete().eq("user_id", id);
      return json({ ok: true });
    }

    return json({ error: "Unknown action." }, 400);
  } catch (e) {
    console.error(e);
    return json({ error: (e as Error).message || "Something went wrong." }, 500);
  }
});
