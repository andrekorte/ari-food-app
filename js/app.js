/* Food tracker — kitchen costing app for Ari Thai Street Food.
 * iOS-app-style UI: fixed glass header, bottom tab bar (Home / Purchases),
 * full-screen searchable item pickers, collapsible ingredient categories.
 *
 * Data model: ingredients (kg or L, categorised meat/veg/sauce/other) with
 * purchase history; sauces = recipes of sauce ingredients, costed per gram;
 * dishes contain ingredients and/or sauces. Shared Supabase database with
 * roles: admin (full) and shopper (record purchases only).
 *
 * The purchases table's purchased_kg / wastage_kg columns hold whichever
 * unit the ingredient uses. The user enters "weight when bought" and
 * "weight after preparation"; wastage = bought − after.
 */

let db = null;
let session = null;
const state = {
  ingredients: [],
  dishes: [],
  sauces: [],
  saucesMissing: false, // categories/sauces migration not run yet
  stock: [],
  stockMissing: false,  // stock migration not run yet
  proteins: [],         // customer protein choices (chicken, pork, …)
  aliases: [],          // learned invoice wordings -> ingredient
  profile: null,        // this user's row in profiles (null = full access)
  view: { name: "home" },
  // Remembered navigation state so Back returns exactly where you were.
  ui: { openIng: new Set(), openDish: new Set(), openStock: new Set(),
        openSauce: false, homeScroll: 0 },
};
let draft = null;

const $app = document.getElementById("app");
const LOGO = `<img src="assets/ari-logo.png" alt="" class="brand-logo">`;
const APP_NAME = "Food tracker";
const CATS = ["meat", "veg", "sauce", "other"];
// Menu sections from ari-thaistreetfood.com.
const DISH_CATS = [
  "ala_carte", "noodle_soup", "hot_bar", "entree", "vegan", "gluten_free",
  "drinks", "dessert", "snacks", "special", "other",
];
const SITES = ["ari", "yindee", "sayhi"];

// Professional line-style SVG icons (stroke follows currentColor).
const I = (path) =>
  `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${path}</svg>`;
const ICONS = {
  home: I('<path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.7V21h14V9.7"/><path d="M9.5 21v-6h5v6"/>'),
  cart: I('<circle cx="9" cy="20" r="1.4"/><circle cx="17" cy="20" r="1.4"/><path d="M3 4h2.4l2.2 11.2a1.6 1.6 0 0 0 1.6 1.3h7.9a1.6 1.6 0 0 0 1.6-1.3L20.5 8H6.1"/>'),
  stock: I('<path d="M3 7.5 12 3l9 4.5-9 4.5z"/><path d="M3 7.5V16l9 4.5 9-4.5V7.5"/><path d="M12 12v8.5"/>'),
  sauce: I('<path d="M12 3s-6 7.2-6 11.2a6 6 0 0 0 12 0C18 10.2 12 3 12 3z"/>'),
  camera: I('<path d="M4 8h3l2-2.5h6L17 8h3a1.5 1.5 0 0 1 1.5 1.5V19a1.5 1.5 0 0 1-1.5 1.5H4A1.5 1.5 0 0 1 2.5 19V9.5A1.5 1.5 0 0 1 4 8z"/><circle cx="12" cy="14" r="3.5"/>'),
  photo: I('<rect x="3" y="5" width="18" height="15" rx="2"/><circle cx="9" cy="10.5" r="1.6"/><path d="M3.5 17.5 9 13l4 3.5 3.5-3 4 3.5"/>'),
  logout: I('<path d="M15 4h4.5v16H15"/><path d="M10 8l-4 4 4 4"/><path d="M6 12h9.5"/>'),
  check: I('<path d="M4.5 12.5 9.5 17.5 19.5 6.5"/>'),
};

/* ---------- helpers ---------- */

function esc(s) {
  return String(s ?? "").replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
  }[c]));
}

function money(n, dp = 2) {
  if (n == null || !isFinite(n)) return "–";
  return "$" + Number(n).toFixed(dp);
}

function fmtQty(n) {
  if (n == null || !isFinite(n)) return "–";
  return String(Number(Number(n).toFixed(3)));
}

function unitOf(ing) {
  const liquid = ing && ing.unit === "l";
  return {
    liquid,
    big: t(liquid ? "u_l" : "u_kg"),
    small: t(liquid ? "u_ml" : "u_g"),
  };
}

function catOf(ing) {
  return CATS.includes(ing.category) ? ing.category : "other";
}

// Display name: Thai name in Thai mode when one exists, else English.
function dName(x) {
  if (!x) return "";
  return LANG === "th" && x.name_th ? x.name_th : x.name;
}

// True once the Thai-names migration has run.
function hasNameTh() {
  return !state.ingredients.length || "name_th" in state.ingredients[0];
}

function dishCatOf(d) {
  return DISH_CATS.includes(d.category) ? d.category : "other";
}

// True once the dish-categories migration has run.
function hasDishCat() {
  return !state.dishes.length || "category" in state.dishes[0];
}

function dateShort(iso) {
  const d = new Date(iso);
  return d.toLocaleDateString(LANG === "th" ? "th-TH" : "en-AU", {
    day: "numeric", month: "short", year: "2-digit",
  });
}

function userName() {
  if (!session) return "";
  if (state.profile && state.profile.display_name) return state.profile.display_name;
  const meta = session.user.user_metadata || {};
  return meta.display_name || meta.full_name || session.user.email.split("@")[0];
}

// A user without a profiles row has full access (matches the RLS rules).
function isAdmin() {
  return !state.profile || state.profile.role === "admin";
}

function sortedPurchases(ing) {
  return (ing.purchases || [])
    .slice()
    .sort((a, b) => new Date(b.purchased_at) - new Date(a.purchased_at));
}

function purchaseStats(p) {
  if (!p) return null;
  const usable = Number(p.purchased_kg) - Number(p.wastage_kg || 0);
  if (!(usable > 0)) return null;
  const perBig = Number(p.price_paid) / usable;
  return { usable, perBig, perSmall: perBig / 1000 };
}

function ingredientStats(ing) {
  return purchaseStats(sortedPurchases(ing)[0]);
}

function findIngredient(id) {
  return state.ingredients.find((i) => i.id === id) || null;
}

function findSauce(id) {
  return state.sauces.find((s) => s.id === id) || null;
}

// Sauce batch: total grams, total cost, and cost per gram from its recipe.
// A sauce line may reference another sauce (e.g. tom yum stir-fry sauce
// contains stir-fry sauce); `seen` guards against a circular reference.
function sauceStats(sauce, seen) {
  if (!sauce) return null;
  seen = seen || new Set();
  if (seen.has(sauce.id)) return null;
  seen.add(sauce.id);
  const rows = sauce.sauce_ingredients || [];
  let grams = 0, cost = 0, complete = rows.length > 0;
  for (const r of rows) {
    const g = Number(r.grams);
    let per = null;
    if (r.sub_sauce_id) {
      const st = sauceStats(findSauce(r.sub_sauce_id), new Set(seen));
      per = st ? st.perG : null;
    } else {
      const st = ingredientStats(findIngredient(r.ingredient_id));
      per = st ? st.perSmall : null;
    }
    if (per == null || !(g > 0)) { complete = false; continue; }
    grams += g;
    cost += g * per;
  }
  if (!(grams > 0)) return null;
  return { grams, cost, perG: cost / grams, complete };
}

// Cost of one protein portion (null when its price isn't known yet).
function proteinCost(p) {
  if (!p || !p.ingredient_id) return 0;
  const st = ingredientStats(findIngredient(p.ingredient_id));
  return st ? Number(p.grams) * st.perSmall : null;
}

function proteinPrice(p, dish) {
  if (p && p.selling_price != null) return Number(p.selling_price);
  return dish && dish.selling_price != null ? Number(dish.selling_price) : null;
}

// Dish rows: [{kind: 'ing'|'sauce', id, grams}]
function rowUnitCost(row) {
  if (row.kind === "sauce") {
    const st = sauceStats(findSauce(row.id));
    return st ? st.perG : null;
  }
  const st = ingredientStats(findIngredient(row.id));
  return st ? st.perSmall : null;
}

function dishCost(rows) {
  let total = 0;
  let complete = rows.length > 0;
  for (const r of rows) {
    const per = r.id ? rowUnitCost(r) : null;
    const amount = Number(r.grams);
    if (per == null || !(amount > 0)) { complete = false; continue; }
    total += amount * per;
  }
  return { total, complete };
}

// Recipe rows of a sauce, in the same {kind,id,grams} shape as dishes.
function sauceRowsOf(sauce) {
  return (sauce.sauce_ingredients || []).map((r) =>
    r.sub_sauce_id
      ? { kind: "sauce", id: r.sub_sauce_id, grams: r.grams }
      : { kind: "ing", id: r.ingredient_id, grams: r.grams }
  );
}

function dishRowsOf(dish) {
  return (dish.dish_ingredients || []).map((r) =>
    r.sauce_id
      ? { kind: "sauce", id: r.sauce_id, grams: r.grams }
      : { kind: "ing", id: r.ingredient_id, grams: r.grams }
  );
}

/* ---------- confirmation toast ---------- */

let toastTimer = null;
function showToast(title, detail) {
  const old = document.getElementById("toast");
  if (old) old.remove();
  if (toastTimer) clearTimeout(toastTimer);
  const el = document.createElement("div");
  el.className = "toast";
  el.id = "toast";
  el.innerHTML = `<span class="ticon">${ICONS.check}</span>
    <span class="tbody"><strong>${esc(title)}</strong>${detail ? `<span>${esc(detail)}</span>` : ""}</span>`;
  document.body.appendChild(el);
  requestAnimationFrame(() => el.classList.add("in"));
  toastTimer = setTimeout(() => {
    el.classList.remove("in");
    setTimeout(() => el.remove(), 250);
  }, 4500);
}

/* ---------- data ---------- */

// Data is cached in memory so every tap renders instantly. A fetch only
// blocks rendering on first load; after saves/deletes the cache is marked
// stale, and returning to Home also revalidates quietly in the background
// so teammates' changes appear without slowing navigation down.
let dataFresh = false;
let lastRefreshAt = 0;

async function refreshData() {
  const jobs = [
    db.from("ingredients").select("*, purchases(*)").order("name"),
    db.from("dishes").select("*, dish_ingredients(*)").order("name"),
    // sauce_ingredients links to sauces twice (sauce_id and sub_sauce_id),
    // which makes an embedded select ambiguous — fetch the rows separately
    // and join them below.
    db.from("sauces").select("*").order("name"),
    db.from("sauce_ingredients").select("*"),
    db.from("stock_levels").select("*"),
    db.from("protein_options").select("*").order("sort_order"),
    db.from("ingredient_aliases").select("*"),
  ];
  if (!state.profileFetched) {
    jobs.push(db.from("profiles").select("*").eq("user_id", session.user.id).maybeSingle());
  }
  const [ings, dishes, sauces, sauceRows, stock, prots, aliases, prof] =
    await Promise.all(jobs);
  if (ings.error) throw ings.error;
  if (dishes.error) throw dishes.error;
  state.ingredients = ings.data;
  state.dishes = dishes.data;

  // Sauces arrive with a later migration — degrade gracefully without it.
  if (sauces.error || sauceRows.error) {
    console.error("sauces query failed:", sauces.error || sauceRows.error);
    state.sauces = [];
    state.saucesMissing = true;
  } else {
    const bySauce = {};
    for (const r of sauceRows.data) (bySauce[r.sauce_id] ||= []).push(r);
    state.sauces = sauces.data.map((x) => ({ ...x, sauce_ingredients: bySauce[x.id] || [] }));
    state.saucesMissing = false;
  }

  state.proteins = prots.error ? [] : prots.data;
  state.aliases = aliases.error ? [] : aliases.data;

  if (stock.error) {
    state.stock = [];
    state.stockMissing = true;
  } else {
    state.stock = stock.data;
    state.stockMissing = false;
  }

  if (prof) {
    state.profile = prof.error ? null : prof.data || null;
    state.profileFetched = true;
  }
  dataFresh = true;
  lastRefreshAt = Date.now();
}

/* ---------- navigation & chrome ---------- */

async function go(view, opts = {}) {
  if (state.view.name === "home" && view.name !== "home") {
    state.ui.homeScroll = window.scrollY;
  }
  if (opts.refresh) dataFresh = false;
  state.view = view;
  draft = null;
  await render();
  window.scrollTo(0, view.name === "home" ? state.ui.homeScroll : 0);

  // Background revalidation when idling on Home (never blocks a tap).
  if (dataFresh && view.name === "home" && Date.now() - lastRefreshAt > 15000) {
    refreshData().then(() => {
      if (state.view.name === "home") {
        const y = window.scrollY;
        renderHome();
        window.scrollTo(0, y);
      }
    }).catch(() => {});
  }
}

async function render() {
  if (!session) return renderLogin();
  if (!dataFresh) {
    try {
      await refreshData();
    } catch (e) {
      console.error(e);
      $app.innerHTML =
        header({ home: true }) +
        `<main class="content"><div class="error-box bad">${esc(t("load_failed"))}</div></main>`;
      wireHeader();
      return;
    }
  }
  const v = state.view;
  if (!isAdmin() && (v.name === "ingredient" || v.name === "dish" || v.name === "sauce")) {
    state.view = { name: "home" };
    return renderHome();
  }
  if (v.name === "ingredient") renderIngredient(v.id);
  else if (v.name === "dish") renderDish(v.id);
  else if (v.name === "sauce") renderSauce(v.id);
  else if (v.name === "basket") renderBasket();
  else if (v.name === "stock") renderStock();
  else renderHome();
}

function header({ home, title } = {}) {
  return `<header class="header">
    <span class="brandwrap">
      ${home
        ? `${LOGO}<span class="brand">${APP_NAME}</span>`
        : `<button class="back" id="btnBack">‹ ${esc(t("back"))}</button>
           <span class="htitle">${esc(title || "")}</span>`}
    </span>
    <span class="actions">
      <button class="chipbtn" id="btnLang">${LANG === "en" ? "ไทย" : "EN"}</button>
      ${home ? `<button class="chipbtn" id="btnLogout">${esc(userName())}<span class="icn">${ICONS.logout}</span></button>` : ""}
    </span>
  </header>`;
}

function wireHeader() {
  const back = document.getElementById("btnBack");
  if (back) back.onclick = () => go({ name: "home" });
  const lang = document.getElementById("btnLang");
  if (lang) lang.onclick = () => { toggleLang(); render(); };
  const out = document.getElementById("btnLogout");
  if (out) out.onclick = async () => {
    await db.auth.signOut();
    session = null;
    dataFresh = false;
    state.profile = null;
    state.profileFetched = false;
    renderLogin();
  };
}

function tabbar(active) {
  return `<nav class="tabbar"><div class="inner">
    <button class="tab ${active === "home" ? "active" : ""}" id="tabHome">
      <span class="ticon">${ICONS.home}</span>${esc(t("tab_home"))}
    </button>
    <button class="tab ${active === "basket" ? "active" : ""}" id="tabBasket">
      <span class="ticon">${ICONS.cart}</span>${esc(t("tab_purchase"))}
    </button>
    <button class="tab ${active === "stock" ? "active" : ""}" id="tabStock">
      <span class="ticon">${ICONS.stock}</span>${esc(t("tab_stock"))}
    </button>
  </div></nav>`;
}

function wireTabbar() {
  const h = document.getElementById("tabHome");
  if (h) h.onclick = () => go({ name: "home" });
  const b = document.getElementById("tabBasket");
  if (b) b.onclick = () => go({ name: "basket" });
  const st = document.getElementById("tabStock");
  if (st) st.onclick = () => go({ name: "stock" });
}

/* ---------- invite & password reset ---------- */

// Supabase invite and "forgot password" links come back with tokens in the
// URL fragment. supabase-js consumes them and creates a session; we just
// need to know which kind of link it was so we can ask for a new password.
function authLinkType() {
  const q = new URLSearchParams((window.location.hash || "").replace(/^#/, ""));
  if (q.get("error_description")) return { error: q.get("error_description") };
  const type = q.get("type");
  return ["invite", "recovery", "signup"].includes(type) ? { type } : null;
}

function clearAuthHash() {
  history.replaceState(null, "", window.location.pathname + window.location.search);
}

function renderSetPassword(kind, msg) {
  $app.innerHTML = `
    <div class="login-wrap">
      <div class="login-logo">
        <img src="assets/app-icon.png" alt="Ari Thai Street Food logo">
        <div class="name">${APP_NAME}</div>
        <div class="sub">${esc(kind === "invite" ? t("welcome") : t("tagline"))}</div>
      </div>
      <p class="muted" style="margin:0 0 1rem">${esc(kind === "invite" ? t("invite_hint") : t("reset_hint"))}</p>
      ${msg ? `<div class="error-box bad">${esc(msg)}</div>` : ""}
      <form id="pwForm">
        <div class="field">
          <label for="pw1">${esc(t("new_password"))}</label>
          <input type="password" id="pw1" autocomplete="new-password" required minlength="6">
        </div>
        <div class="field">
          <label for="pw2">${esc(t("repeat_password"))}</label>
          <input type="password" id="pw2" autocomplete="new-password" required minlength="6">
        </div>
        <button class="btn" type="submit">${esc(t("save_password"))}</button>
      </form>
    </div>`;
  document.getElementById("pwForm").onsubmit = async (e) => {
    e.preventDefault();
    const a = document.getElementById("pw1").value;
    const b = document.getElementById("pw2").value;
    if (a.length < 6) return renderSetPassword(kind, t("pw_too_short"));
    if (a !== b) return renderSetPassword(kind, t("pw_mismatch"));
    const { error } = await db.auth.updateUser({ password: a });
    if (error) { console.error(error); return renderSetPassword(kind, t("pw_failed")); }
    clearAuthHash();
    const { data } = await db.auth.getSession();
    session = data.session;
    dataFresh = false;
    if (session) go({ name: "home" });
    else renderLogin(t("pw_set_now_login"));
  };
}

/* ---------- login ---------- */

function renderLogin(errorMsg) {
  $app.innerHTML = `
    <div class="login-wrap">
      <div class="login-logo">
        <img src="assets/ari-logo.png" alt="Ari Thai Street Food logo">
        <div class="name">${APP_NAME}</div>
        <div class="sub">${esc(t("tagline"))}</div>
      </div>
      ${errorMsg ? `<div class="error-box bad">${esc(errorMsg)}</div>` : ""}
      <form id="loginForm">
        <div class="field">
          <label for="loginEmail">${esc(t("email"))}</label>
          <input type="email" id="loginEmail" autocomplete="email" required>
        </div>
        <div class="field">
          <label for="loginPassword">${esc(t("password"))}</label>
          <input type="password" id="loginPassword" autocomplete="current-password" required>
        </div>
        <button class="btn" type="submit">${esc(t("login"))}</button>
      </form>
      <p class="center" style="margin-top:1rem">
        <button class="linkbtn" id="btnForgot">${esc(t("forgot_password"))}</button>
      </p>
      <p class="center" style="margin-top:0.8rem">
        <button class="chipbtn" id="btnLangLogin">${LANG === "en" ? "ไทย" : "EN"}</button>
      </p>
    </div>`;
  document.getElementById("btnLangLogin").onclick = () => { toggleLang(); renderLogin(errorMsg); };
  document.getElementById("btnForgot").onclick = async () => {
    const email = (document.getElementById("loginEmail").value || "").trim();
    if (!email) return renderLogin(t("forgot_need_email"));
    const { error } = await db.auth.resetPasswordForEmail(email, {
      redirectTo: window.location.origin + window.location.pathname,
    });
    renderLogin(error ? t("forgot_failed") : t("forgot_sent"));
  };
  document.getElementById("loginForm").onsubmit = async (e) => {
    e.preventDefault();
    const email = document.getElementById("loginEmail").value.trim();
    const password = document.getElementById("loginPassword").value;
    const { data, error } = await db.auth.signInWithPassword({ email, password });
    if (error) return renderLogin(t("login_failed"));
    session = data.session;
    go({ name: "home" });
  };
}

/* ---------- home ---------- */

function ingRowHtml(ing) {
  const s = ingredientStats(ing);
  const u = unitOf(ing);
  const meta = s
    ? `${money(s.perBig)}/${u.big}`
    : `<span class="muted">${esc(t("no_price_yet"))}</span>`;
  return `<div class="lrow">
    <button class="lmain" ${isAdmin() ? `data-edit-ing="${ing.id}"` : "disabled"}>
      <span class="lname">${esc(dName(ing))}</span>
      <span class="lmeta num">${meta}</span>
      ${isAdmin() ? `<span class="chev">›</span>` : ""}
    </button>
    ${isAdmin() ? `<button class="xbtn" data-del-ing="${ing.id}" aria-label="${esc(t("delete_ingredient"))}">✕</button>` : ""}
  </div>`;
}

function renderHome() {
  const admin = isAdmin();

  const catSections = CATS.map((cat) => {
    const items = state.ingredients.filter((i) => catOf(i) === cat);
    return `<details class="group" data-ing-cat="${cat}" ${state.ui.openIng.has(cat) ? "open" : ""}>
      <summary>
        <span>${esc(t("cat_" + cat))}</span>
        <span class="gright"><span class="badge num">${items.length}</span><span class="chev">›</span></span>
      </summary>
      ${items.length ? items.map(ingRowHtml).join("") : `<p class="empty">${esc(t("no_ingredients"))}</p>`}
    </details>`;
  }).join("");

  const sauceRows = state.sauces.map((s) => {
    const st = sauceStats(s);
    const meta = st
      ? `${money(st.perG, 3)}/${t("u_g")}`
      : `<span class="muted">${esc(t("no_price_yet"))}</span>`;
    return `<div class="lrow">
      <button class="lmain" data-edit-sauce="${s.id}">
        <span class="lname">${esc(dName(s))}</span>
        <span class="lmeta num">${meta}</span>
        <span class="chev">›</span>
      </button>
    </div>`;
  }).join("");

  const dishRowHtml = (d) => {
    const rows = dishRowsOf(d);
    const c = dishCost(rows);
    let total = c.total;
    let sell = d.selling_price != null ? Number(d.selling_price) : null;
    // Dishes cooked with the customer's protein choice are shown at the
    // first protein option (chicken) — the dish screen compares them all.
    if (d.uses_protein && state.proteins.length) {
      const p = state.proteins[0];
      const pc = proteinCost(p);
      if (pc == null) c.complete = false; else total += pc;
      sell = proteinPrice(p, d);
    }
    const gpPct = sell > 0 && rows.length ? ((sell - total) / sell) * 100 : null;
    const meta = [
      rows.length ? money(total) + (c.complete ? "" : "*") : "–",
      gpPct == null ? null : gpPct.toFixed(0) + "%",
    ].filter(Boolean).join(" · ");
    return `<div class="lrow">
      <button class="lmain" data-edit-dish="${d.id}">
        <span class="lname">${esc(dName(d))}</span>
        <span class="lmeta num">${meta}</span>
        <span class="chev">›</span>
      </button>
    </div>`;
  };

  // Grouped by menu section once the migration has run; flat list before.
  const dishSections = hasDishCat()
    ? DISH_CATS.map((cat) => {
        const items = state.dishes.filter((d) => dishCatOf(d) === cat);
        if (!items.length) return "";
        return `<details class="group" data-dish-cat="${cat}" ${state.ui.openDish.has(cat) ? "open" : ""}>
          <summary>
            <span>${esc(t("dcat_" + cat))}</span>
            <span class="gright"><span class="badge num">${items.length}</span><span class="chev">›</span></span>
          </summary>
          ${items.map(dishRowHtml).join("")}
        </details>`;
      }).join("")
    : state.dishes.map(dishRowHtml).join("");

  $app.innerHTML = `
    ${header({ home: true })}
    <main class="content">
      ${state.saucesMissing && admin ? `<div class="error-box">${esc(t("sauces_migration_needed"))}</div>` : ""}

      <div class="card">
        <div class="card-head">
          <span class="card-title">${esc(t("ingredients"))}</span>
          <span class="count num">${state.ingredients.length} ${esc(t("items"))}</span>
        </div>
        ${catSections}
        ${admin ? `<div class="card-foot"><button class="btn ghost small" id="btnAddIng">${esc(t("add_ingredient"))}</button></div>` : ""}
      </div>

      ${admin && !state.saucesMissing ? `<div class="card">
        <div class="card-head">
          <span class="card-title">${esc(t("sauces"))}</span>
          <span class="count num">${state.sauces.length} ${esc(t("items"))}</span>
        </div>
        ${state.sauces.length ? `<details class="group" id="sauceGroup" ${state.ui.openSauce ? "open" : ""}>
          <summary>
            <span>${esc(t("all_sauces"))}</span>
            <span class="gright"><span class="badge num">${state.sauces.length}</span><span class="chev">›</span></span>
          </summary>
          ${sauceRows}
        </details>` : `<p class="empty">${esc(t("no_sauces"))}</p>`}
        <div class="card-foot"><button class="btn ghost small" id="btnAddSauce">${esc(t("add_sauce"))}</button></div>
      </div>` : ""}

      ${admin ? `<div class="card">
        <div class="card-head">
          <span class="card-title">${esc(t("dishes"))}</span>
          <span class="count num">${state.dishes.length} ${esc(t("items"))}</span>
        </div>
        ${state.dishes.length ? dishSections : `<p class="empty">${esc(t("no_dishes"))}</p>`}
        <div class="card-foot"><button class="btn ghost small" id="btnAddDish">${esc(t("add_dish"))}</button></div>
      </div>` : ""}
    </main>
    ${tabbar("home")}`;

  wireHeader();
  wireTabbar();

  // Remember which sections are open across navigation.
  $app.querySelectorAll("details[data-ing-cat]").forEach((d) => {
    d.addEventListener("toggle", () => {
      if (d.open) state.ui.openIng.add(d.dataset.ingCat);
      else state.ui.openIng.delete(d.dataset.ingCat);
    });
  });
  const sg = document.getElementById("sauceGroup");
  if (sg) sg.addEventListener("toggle", () => { state.ui.openSauce = sg.open; });
  $app.querySelectorAll("details[data-dish-cat]").forEach((d) => {
    d.addEventListener("toggle", () => {
      if (d.open) state.ui.openDish.add(d.dataset.dishCat);
      else state.ui.openDish.delete(d.dataset.dishCat);
    });
  });

  const addIng = document.getElementById("btnAddIng");
  if (addIng) addIng.onclick = () => go({ name: "ingredient", id: null });
  const addSauce = document.getElementById("btnAddSauce");
  if (addSauce) addSauce.onclick = () => go({ name: "sauce", id: null });
  const addDish = document.getElementById("btnAddDish");
  if (addDish) addDish.onclick = () => go({ name: "dish", id: null });

  $app.querySelectorAll("[data-edit-ing]").forEach((b) => {
    b.onclick = () => go({ name: "ingredient", id: b.dataset.editIng });
  });
  $app.querySelectorAll("[data-edit-sauce]").forEach((b) => {
    b.onclick = () => go({ name: "sauce", id: b.dataset.editSauce });
  });
  $app.querySelectorAll("[data-edit-dish]").forEach((b) => {
    b.onclick = () => go({ name: "dish", id: b.dataset.editDish });
  });
  $app.querySelectorAll("[data-del-ing]").forEach((b) => {
    b.onclick = async () => {
      if (!confirm(t("confirm_delete"))) return;
      const { error } = await db.from("ingredients").delete().eq("id", b.dataset.delIng);
      if (error) {
        // 23503 = foreign key violation: used by a dish or sauce.
        alert(error.code === "23503" ? t("ing_in_use") : t("save_failed"));
        return;
      }
      dataFresh = false;
      render();
    };
  });
}

/* ---------- full-screen searchable picker ---------- */

// groups: [{title, items: [{kind, id, label, sub}], open}]; onPick(item)
// opts.hint shows the recognised receipt text above the list so the user
// can compare it against the choices.
function openPicker(groups, onPick, opts = {}) {
  const overlay = document.createElement("div");
  overlay.className = "picker";
  // Categories start collapsed (the list is long); searching expands them.
  const groupHtml = () => groups.map((g, gi) => {
    const q = overlay.querySelector("input") ? overlay.querySelector("input").value.trim().toLowerCase() : "";
    const items = g.items.filter((it) => !q || it.label.toLowerCase().includes(q));
    if (!items.length) return "";
    return `<details class="pgroup" ${q || g.open ? "open" : ""}>
      <summary class="pgsummary">
        <span>${esc(g.title)}</span>
        <span class="gright"><span class="badge num">${items.length}</span><span class="chev">›</span></span>
      </summary>
      <div class="pgbody">
        ${items.map((it) => `<button class="prow" data-g="${gi}" data-id="${it.id}" data-kind="${it.kind}">
          <span class="pname">${it.sauce ? `<span class="sicon">${ICONS.sauce}</span>` : ""}${esc(it.label)}</span>
          <span class="psub num">${it.sub || ""}</span>
        </button>`).join("")}
      </div>
    </details>`;
  }).join("");

  overlay.innerHTML = `
    <div class="phead">
      <input type="search" placeholder="${esc(t("search"))}" aria-label="${esc(t("search"))}">
      <button class="pcancel">${esc(t("cancel"))}</button>
    </div>
    ${opts.hint ? `<div class="scanhint"><span class="shlabel">${esc(t("receipt_text"))}</span>“${esc(opts.hint)}”</div>` : ""}
    <div class="pbody">${""}</div>
    ${opts.allowCreate && isAdmin() ? `<div class="pgroup pcreatewrap">
      <button class="btn ghost small" id="pcToggle">＋ ${esc(t("new_ingredient"))}</button>
      <div id="pcForm" style="display:none">
        <div class="field" style="margin-top:0.8rem">
          <label for="pcName">${esc(t("ingredient_name"))}</label>
          <input type="text" id="pcName" value="${esc(opts.createDefault || "")}">
        </div>
        <div class="row2">
          <div class="field">
            <label for="pcCat">${esc(t("category"))}</label>
            <select id="pcCat">${CATS.map((c) => `<option value="${c}">${esc(t("cat_" + c))}</option>`).join("")}</select>
          </div>
          <div class="field">
            <label for="pcUnit">${esc(t("unit"))}</label>
            <select id="pcUnit"><option value="kg">${esc(t("unit_kg"))}</option><option value="l">${esc(t("unit_l"))}</option></select>
          </div>
        </div>
        <button class="btn small" id="pcCreate">${esc(t("create"))}</button>
      </div>
    </div>` : ""}`;
  document.body.appendChild(overlay);
  document.body.style.overflow = "hidden";

  const close = () => { overlay.remove(); document.body.style.overflow = ""; };
  const body = overlay.querySelector(".pbody");
  const refresh = () => {
    body.innerHTML = groupHtml();
    body.querySelectorAll(".prow").forEach((btn) => {
      btn.onclick = () => {
        const g = groups[Number(btn.dataset.g)];
        const item = g.items.find((it) => String(it.id) === btn.dataset.id && it.kind === btn.dataset.kind);
        close();
        onPick(item);
      };
    });
  };
  overlay.querySelector(".pcancel").onclick = close;
  overlay.querySelector("input").oninput = refresh;

  const pcToggle = overlay.querySelector("#pcToggle");
  if (pcToggle) {
    pcToggle.onclick = () => {
      const f = overlay.querySelector("#pcForm");
      const hidden = f.style.display === "none";
      f.style.display = hidden ? "" : "none";
      const nameInput = overlay.querySelector("#pcName");
      if (hidden && !nameInput.value) {
        nameInput.value = overlay.querySelector("input[type=search]").value;
      }
    };
    overlay.querySelector("#pcCreate").onclick = async () => {
      const name = overlay.querySelector("#pcName").value.trim();
      if (!name) return alert(t("need_name"));
      const fields = {
        name,
        unit: overlay.querySelector("#pcUnit").value,
        category: overlay.querySelector("#pcCat").value,
        updated_by: userName(),
      };
      const { data, error } = await db.from("ingredients").insert(fields).select().single();
      if (error) { console.error(error); return alert(t("save_failed")); }
      data.purchases = [];
      state.ingredients.push(data);
      state.ingredients.sort((a, b) => a.name.localeCompare(b.name));
      close();
      onPick({ kind: "ing", id: data.id });
    };
  }

  refresh();
  overlay.querySelector("input").focus();
}

function ingPickItem(ing) {
  const s = ingredientStats(ing);
  const u = unitOf(ing);
  return {
    kind: "ing", id: ing.id, label: dName(ing),
    sub: s ? `${money(s.perBig)}/${u.big}` : esc(t("no_price_yet")),
  };
}

function ingredientPickerGroups({ cats = CATS, includeSauceRecipes = false } = {}) {
  const groups = [];
  if (includeSauceRecipes) {
    // Dish picker order per spec: meat, vegetables, sauces, then the rest.
    const meat = state.ingredients.filter((i) => catOf(i) === "meat");
    const veg = state.ingredients.filter((i) => catOf(i) === "veg");
    const sauceIngs = state.ingredients.filter((i) => catOf(i) === "sauce");
    const other = state.ingredients.filter((i) => catOf(i) === "other");
    groups.push({ title: t("cat_meat"), items: meat.map(ingPickItem) });
    groups.push({ title: t("cat_veg"), items: veg.map(ingPickItem) });
    groups.push({
      title: t("sauces"),
      items: [
        ...state.sauces.map((s) => {
          const st = sauceStats(s);
          return {
            kind: "sauce", id: s.id, sauce: true, label: dName(s),
            sub: st ? `${money(st.perG, 3)}/${t("u_g")}` : esc(t("no_price_yet")),
          };
        }),
        ...sauceIngs.map(ingPickItem),
      ],
    });
    groups.push({ title: t("cat_other"), items: other.map(ingPickItem) });
  } else {
    for (const cat of cats) {
      const items = state.ingredients.filter((i) => catOf(i) === cat);
      if (items.length) groups.push({ title: t("cat_" + cat), items: items.map(ingPickItem) });
    }
  }
  return groups.filter((g) => g.items.length);
}

function pickedLabel(row) {
  if (!row.id) return null;
  if (row.kind === "sauce") {
    const s = findSauce(row.id);
    return s ? dName(s) : null;
  }
  const i = findIngredient(row.id);
  return i ? dName(i) : null;
}

function rowSuffix(row) {
  if (row.kind === "sauce" || !row.id) return t("u_g");
  const i = findIngredient(row.id);
  return i ? unitOf(i).small : t("u_g");
}

/* ---------- receipt scanning ---------- */

function downscaleImage(file, maxSide, quality) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => {
      const scale = Math.min(1, maxSide / Math.max(img.width, img.height));
      const c = document.createElement("canvas");
      c.width = Math.round(img.width * scale);
      c.height = Math.round(img.height * scale);
      c.getContext("2d").drawImage(img, 0, 0, c.width, c.height);
      URL.revokeObjectURL(img.src);
      resolve(c.toDataURL("image/jpeg", quality));
    };
    img.onerror = reject;
    img.src = URL.createObjectURL(file);
  });
}

// Big full-screen progress indicator while a receipt is being read.
function showScanOverlay() {
  hideScanOverlay();
  const el = document.createElement("div");
  el.className = "scanoverlay";
  el.id = "scanOverlay";
  el.innerHTML = `<div class="scanbox">
    <div class="spinner" aria-hidden="true"></div>
    <p class="sbig">${esc(t("scanning"))}</p>
    <p class="ssub">${esc(t("scanning_hint"))}</p>
  </div>`;
  document.body.appendChild(el);
}

function hideScanOverlay() {
  const el = document.getElementById("scanOverlay");
  if (el) el.remove();
}

async function scanReceipt(file) {
  const dataUrl = await downscaleImage(file, 1600, 0.85);
  const comma = dataUrl.indexOf(",");
  const mime = dataUrl.slice(5, dataUrl.indexOf(";"));
  const image = dataUrl.slice(comma + 1);
  const { data, error } = await db.functions.invoke("scan-receipt", {
    body: { image, mime },
  });
  if (error) throw error;
  if (data && data.error) throw new Error(data.error);
  return { items: (data && data.items) || [], siteHint: data && data.site_hint };
}

// Detect which site an invoice belongs to from its customer/delivery text.
function detectSite(hintText) {
  const h = normTxt(hintText);
  if (!h) return null;
  if (h.includes("yindee") || h.includes("yindy")) return "yindee";
  if (h.includes("sayhi") || h.includes("say hi")) return "sayhi";
  if (/\bari\b/.test(h)) return "ari";
  return null;
}

function normTxt(x) {
  return String(x || "").toLowerCase()
    .replace(/[^a-z0-9\u0e00-\u0e7f ]+/g, " ")
    .replace(/\s+/g, " ").trim();
}

// Score every ingredient against a receipt line (English or Thai name),
// best first. Used both for auto-matching and for "best matches" in the
// picker when the user resolves an uncertain line.
function scoreCandidates(name) {
  const n = normTxt(name);
  if (!n) return [];
  const scored = [];
  for (const ing of state.ingredients) {
    let best = 0;
    for (const cand of [ing.name, ing.name_th]) {
      if (!cand) continue;
      const c = normTxt(cand);
      let score = 0;
      if (c === n) score = 1;
      else if (c.includes(n) || n.includes(c)) score = 0.8;
      else {
        const nt = n.split(" ").filter((w) => w.length > 2);
        const ct = new Set(c.split(" "));
        const overlap = nt.filter((w) => ct.has(w)).length;
        score = nt.length ? (overlap / Math.max(nt.length, ct.size)) : 0;
      }
      if (score > best) best = score;
    }
    if (best > 0.15) scored.push({ ing, score: best });
  }
  return scored.sort((a, b) => b.score - a.score);
}

// Auto-match only with high confidence AND a clear winner — an ambiguous
// line (e.g. "Chicken" matching four chicken cuts) stays unresolved so the
// user picks from the best-matches list instead of a silent wrong guess.
// A wording the team has already resolved once — an exact, certain match.
function aliasMatch(name) {
  const key = normTxt(name);
  if (!key) return null;
  const a = state.aliases.find((x) => x.alias_key === key);
  return a ? findIngredient(a.ingredient_id) : null;
}

// Remember the user's choice so the same invoice wording matches next time.
async function learnAlias(text, ingredientId) {
  const key = normTxt(text);
  if (!key || !ingredientId) return;
  const existing = state.aliases.find((x) => x.alias_key === key);
  if (existing && existing.ingredient_id === ingredientId) return;
  const row = {
    alias_key: key, alias_text: String(text).trim(),
    ingredient_id: ingredientId, created_by: userName(),
  };
  const { data, error } = await db.from("ingredient_aliases")
    .upsert(row, { onConflict: "alias_key" }).select().maybeSingle();
  if (error) { console.error(error); return; }
  state.aliases = state.aliases.filter((x) => x.alias_key !== key);
  state.aliases.push(data || row);
}

function matchIngredient(name) {
  const known = aliasMatch(name);
  if (known) return known;
  const ranked = scoreCandidates(name);
  if (!ranked.length) return null;
  const top = ranked[0];
  if (top.score < 0.6) return null;
  if (ranked[1] && ranked[1].score >= top.score - 0.1) return null;
  return top.ing;
}

function scanItemToRow(item) {
  const known = aliasMatch(item.name);
  const ing = known || matchIngredient(item.name);
  let qty = Number(item.quantity);
  const unit = String(item.unit || "").toLowerCase();
  if (unit === "g" || unit === "ml") qty = qty / 1000;
  const price = Number(item.price);
  return {
    id: ing ? ing.id : "",
    auto: !!ing && !known,   // known wordings are certain, no verify flag
    qty: qty > 0 ? String(Number(qty.toFixed(3))) : "",
    price: isFinite(price) && price >= 0 ? String(price) : "",
    scanLabel: String(item.name || ""),
  };
}

/* ---------- basket: record a whole shopping trip ---------- */

function renderBasket(existingDraft) {
  draft = existingDraft || {
    site: localStorage.getItem("arifood_site") || "",
    rows: [{ id: "", qty: "", price: "" }],
  };

  const rowsHtml = draft.rows.map((r, idx) => {
    const ing = findIngredient(r.id);
    const label = ing ? dName(ing) : null;
    const suffix = ing ? unitOf(ing).big : t("u_kg");
    return `<div class="erow">
      <button class="pickbtn ${label ? "" : "placeholder"} ${r.auto && r.id ? "automatched" : ""}" data-b-pick="${idx}">
        ${esc(label || (r.scanLabel ? "? " + r.scanLabel : t("choose_item")))}
      </button>
      <input type="number" class="amt" data-b-qty="${idx}" step="0.001" min="0"
        inputmode="decimal" value="${esc(r.qty)}" aria-label="${esc(t("amount"))}">
      <span class="sfx" id="bSfx${idx}">${esc(suffix)}</span>
      <input type="number" class="amt" data-b-price="${idx}" step="0.01" min="0"
        inputmode="decimal" value="${esc(r.price)}" aria-label="${esc(t("price"))}" placeholder="$">
      <button class="xbtn" data-b-del="${idx}" aria-label="${esc(t("delete"))}">✕</button>
    </div>`;
  }).join("");

  $app.innerHTML = `
    ${header({ title: t("new_purchase") })}
    <main class="content">
      <p class="muted" style="margin:0.2rem 0 0.8rem; font-size:0.85rem">${esc(t("basket_hint"))}</p>
      <div class="field">
        <label>${esc(t("site"))}</label>
        <div class="seg" id="siteSeg">
          ${SITES.map((x) => `<button type="button" class="segbtn ${draft.site === x ? "active" : ""}" data-site="${x}">${esc(t("site_" + x))}</button>`).join("")}
        </div>
      </div>
      <div class="row2">
        <button class="btn ghost small" id="btnScan"><span class="binline">${ICONS.camera}</span>${esc(t("scan_receipt"))}</button>
        <button class="btn ghost small" id="btnUpload"><span class="binline">${ICONS.photo}</span>${esc(t("upload_receipt"))}</button>
      </div>
      <input type="file" id="scanFile" accept="image/*" capture="environment" style="display:none">
      <input type="file" id="uploadFile" accept="image/*" style="display:none">
      <div style="height:0.5rem"></div>
      ${rowsHtml}
      <button class="btn ghost small" id="btnAddRow">${esc(t("add_item"))}</button>
      <div class="calc">
        <div class="crow num"><span>${esc(t("basket_total"))}</span><strong id="basketTotal">$0.00</strong></div>
      </div>
      <button class="btn" id="btnSave">${esc(t("save_all"))}</button>
    </main>
    ${tabbar("basket")}`;

  wireHeader();
  wireTabbar();

  const captureDraft = () => {
    $app.querySelectorAll("[data-b-qty]").forEach((inp) => {
      draft.rows[Number(inp.dataset.bQty)].qty = inp.value;
    });
    $app.querySelectorAll("[data-b-price]").forEach((inp) => {
      draft.rows[Number(inp.dataset.bPrice)].price = inp.value;
    });
  };
  const updateTotal = () => {
    const total = draft.rows.reduce((sum, r) => sum + (Number(r.price) > 0 ? Number(r.price) : 0), 0);
    document.getElementById("basketTotal").textContent = money(total);
  };

  const setSite = (site) => {
    draft.site = site;
    localStorage.setItem("arifood_site", site);
    $app.querySelectorAll("#siteSeg .segbtn").forEach((b) => {
      b.classList.toggle("active", b.dataset.site === site);
    });
  };
  $app.querySelectorAll("#siteSeg .segbtn").forEach((b) => {
    b.onclick = () => setSite(b.dataset.site);
  });

  $app.querySelectorAll("[data-b-pick]").forEach((btn) => {
    btn.onclick = () => {
      const idx = Number(btn.dataset.bPick);
      const row = draft.rows[idx];
      const groups = ingredientPickerGroups();
      let opts = {};
      if (row.scanLabel) {
        const sugg = scoreCandidates(row.scanLabel).slice(0, 5)
          .map((x) => ingPickItem(x.ing));
        if (sugg.length) groups.unshift({ title: t("best_matches"), items: sugg, open: true });
        opts = { hint: row.scanLabel };
      }
      opts.allowCreate = true;
      opts.createDefault = row.scanLabel || "";
      openPicker(groups, (item) => {
        captureDraft();
        draft.rows[idx].id = item.id;
        draft.rows[idx].auto = false;
        // Teach the app this supplier wording for next time.
        if (row.scanLabel) learnAlias(row.scanLabel, item.id);
        renderBasket({ ...draft });
      }, opts);
    };
  });
  $app.querySelectorAll("[data-b-qty]").forEach((inp) => {
    inp.oninput = () => { draft.rows[Number(inp.dataset.bQty)].qty = inp.value; };
  });
  $app.querySelectorAll("[data-b-price]").forEach((inp) => {
    inp.oninput = () => { draft.rows[Number(inp.dataset.bPrice)].price = inp.value; updateTotal(); };
  });
  $app.querySelectorAll("[data-b-del]").forEach((b) => {
    b.onclick = () => {
      captureDraft();
      draft.rows.splice(Number(b.dataset.bDel), 1);
      if (!draft.rows.length) draft.rows.push({ id: "", qty: "", price: "" });
      renderBasket({ ...draft });
    };
  });
  document.getElementById("btnAddRow").onclick = () => {
    captureDraft();
    draft.rows.push({ id: "", qty: "", price: "" });
    renderBasket({ ...draft });
  };

  const processReceipt = async (file, btn) => {
    document.getElementById("btnScan").disabled = true;
    document.getElementById("btnUpload").disabled = true;
    showScanOverlay();
    captureDraft();
    try {
      const res = await scanReceipt(file);
      const site = detectSite(res.siteHint);
      if (site) draft.site = site;
      if (!res.items.length) {
        hideScanOverlay();
        alert(t("scan_none"));
        renderBasket({ ...draft });
        return;
      }
      const scanned = res.items.map(scanItemToRow);
      const existing = draft.rows.filter((r) => r.id || r.qty !== "" || r.price !== "");
      draft.rows = [...existing, ...scanned];
      renderBasket({ ...draft });
    } catch (err) {
      console.error(err);
      alert(t("scan_failed"));
      renderBasket({ ...draft });
    } finally {
      hideScanOverlay();
    }
  };
  document.getElementById("btnScan").onclick = () => document.getElementById("scanFile").click();
  document.getElementById("btnUpload").onclick = () => document.getElementById("uploadFile").click();
  document.getElementById("scanFile").onchange = (e) => {
    if (e.target.files[0]) processReceipt(e.target.files[0], document.getElementById("btnScan"));
  };
  document.getElementById("uploadFile").onchange = (e) => {
    if (e.target.files[0]) processReceipt(e.target.files[0], document.getElementById("btnUpload"));
  };

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const filled = draft.rows.filter((r) => r.id || r.qty !== "" || r.price !== "");
    const valid = filled.filter(
      (r) => r.id && Number(r.qty) > 0 && r.price !== "" && Number(r.price) >= 0
    );
    if (!valid.length || valid.length !== filled.length) return alert(t("need_basket"));
    if (!draft.site) return alert(t("need_site"));
    try {
      // Learn every scanned wording that ended up assigned to an ingredient.
      await Promise.all(valid.filter((r) => r.scanLabel)
        .map((r) => learnAlias(r.scanLabel, r.id)));
      const { error } = await db.from("purchases").insert(valid.map((r) => ({
        ingredient_id: r.id,
        purchased_kg: Number(r.qty),
        price_paid: Number(r.price),
        wastage_kg: 0,
        entered_by: userName(),
      })));
      if (error) throw error;
      // The bought amounts land in the chosen site's stock.
      if (!state.stockMissing) {
        const byIng = {};
        valid.forEach((r) => { byIng[r.id] = (byIng[r.id] || 0) + Number(r.qty); });
        const stockRows = Object.entries(byIng).map(([ingredient_id, add]) => ({
          ingredient_id,
          site: draft.site,
          qty: Math.max(0, (stockOf(ingredient_id, draft.site) ?? 0) + add),
          updated_at: new Date().toISOString(),
          updated_by: userName(),
        }));
        const st = await db.from("stock_levels")
          .upsert(stockRows, { onConflict: "ingredient_id,site" });
        if (st.error) throw st.error;
      }
      const spent = valid.reduce((sum, r) => sum + Number(r.price), 0);
      const site = draft.site;
      await go({ name: "home" }, { refresh: true });
      showToast(
        t("saved_purchase").replace("{n}", valid.length),
        `${money(spent)} · ${t("added_to_stock").replace("{site}", t("site_" + site))}`
      );
      return;
    } catch (e) {
      console.error(e); alert(t("save_failed"));
    }
  };

  updateTotal();
}

/* ---------- stock by site ---------- */

function stockOf(ingId, site) {
  const r = state.stock.find((x) => x.ingredient_id === ingId && x.site === site);
  return r ? Number(r.qty) : null;
}

function renderStock(existingDraft) {
  draft = existingDraft || { edits: {} };

  const stRow = (ing) => {
    const u = unitOf(ing);
    return `<div class="strow">
      <span class="stname">${esc(dName(ing))} <span class="stunit">${esc(u.big)}</span></span>
      ${SITES.map((site) => {
        const key = ing.id + "|" + site;
        const current = stockOf(ing.id, site);
        const val = key in draft.edits ? draft.edits[key] : (current == null ? "" : fmtQty(current));
        return `<input type="number" step="0.001" min="0" inputmode="decimal"
          data-st="${key}" value="${esc(val)}" aria-label="${esc(t("site_" + site))}">`;
      }).join("")}
    </div>`;
  };

  const sections = CATS.map((cat) => {
    const items = state.ingredients.filter((i) => catOf(i) === cat);
    if (!items.length) return "";
    return `<details class="group" data-st-cat="${cat}" ${state.ui.openStock.has(cat) ? "open" : ""}>
      <summary>
        <span>${esc(t("cat_" + cat))}</span>
        <span class="gright"><span class="badge num">${items.length}</span><span class="chev">›</span></span>
      </summary>
      <div class="sthead"><span></span>${SITES.map((x) => `<span>${esc(t("site_" + x))}</span>`).join("")}</div>
      ${items.map(stRow).join("")}
    </details>`;
  }).join("");

  $app.innerHTML = `
    ${header({ title: t("tab_stock") })}
    <main class="content">
      ${state.stockMissing
        ? `<div class="error-box">${esc(t("stock_migration_needed"))}</div>`
        : `<p class="muted" style="margin:0.2rem 0 0.8rem; font-size:0.85rem">${esc(t("stock_hint"))}</p>
      <button class="btn" id="btnStSave" disabled>${esc(t("save_changes"))}</button>
      <div style="height:0.6rem"></div>
      <div class="card">${sections}</div>
      <div class="calc" id="stockValue"></div>`}
    </main>
    ${tabbar("stock")}`;

  wireHeader();
  wireTabbar();
  if (state.stockMissing) return;

  // Value of everything currently in stock, using each ingredient's latest
  // purchase price. Reflects unsaved edits so the number moves as you type.
  const renderStockValue = () => {
    const el = document.getElementById("stockValue");
    if (!el) return;
    const perSite = {};
    let priced = 0, unpriced = 0;
    SITES.forEach((x) => (perSite[x] = 0));
    for (const ing of state.ingredients) {
      const st = ingredientStats(ing);
      for (const site of SITES) {
        const key = ing.id + "|" + site;
        const raw = key in draft.edits ? draft.edits[key] : stockOf(ing.id, site);
        const qty = Number(raw);
        if (!(qty > 0)) continue;
        if (st) { perSite[site] += qty * st.perBig; priced++; }
        else unpriced++;
      }
    }
    const total = SITES.reduce((a, x) => a + perSite[x], 0);
    el.innerHTML = `<div class="caption">${esc(t("stock_value"))}</div>
      ${SITES.map((x) => `<div class="crow num"><span>${esc(t("site_" + x))}</span><span>${money(perSite[x])}</span></div>`).join("")}
      <div class="crow num" style="border-top:1px solid var(--yellow); margin-top:0.35rem; padding-top:0.45rem">
        <span><strong>${esc(t("stock_value_total"))}</strong></span><strong>${money(total)}</strong>
      </div>
      ${unpriced ? `<div class="crow"><span class="muted" style="font-size:0.82rem">${esc(t("stock_value_partial").replace("{n}", unpriced))}</span></div>` : ""}`;
  };

  const saveBtn = document.getElementById("btnStSave");
  const updateSaveBtn = () => {
    const n = Object.keys(draft.edits).length;
    saveBtn.disabled = n === 0;
    saveBtn.textContent = n ? `${t("save_changes")} (${n})` : t("save_changes");
  };

  $app.querySelectorAll("details[data-st-cat]").forEach((d) => {
    d.addEventListener("toggle", () => {
      if (d.open) state.ui.openStock.add(d.dataset.stCat);
      else state.ui.openStock.delete(d.dataset.stCat);
    });
  });
  $app.querySelectorAll("[data-st]").forEach((inp) => {
    inp.oninput = () => {
      draft.edits[inp.dataset.st] = inp.value;
      updateSaveBtn();
      renderStockValue();
    };
  });

  saveBtn.onclick = async () => {
    const rows = [];
    for (const [key, val] of Object.entries(draft.edits)) {
      if (String(val).trim() === "") continue;
      const qty = Number(val);
      if (!(qty >= 0)) return alert(t("bad_numbers"));
      const [ingredient_id, site] = key.split("|");
      rows.push({
        ingredient_id, site, qty,
        updated_at: new Date().toISOString(), updated_by: userName(),
      });
    }
    if (!rows.length) return;
    try {
      const { error } = await db.from("stock_levels")
        .upsert(rows, { onConflict: "ingredient_id,site" });
      if (error) throw error;
      const n = rows.length;
      await go({ name: "stock" }, { refresh: true });
      showToast(t("saved_stock").replace("{n}", n));
      return;
    } catch (e) {
      console.error(e); alert(t("save_failed"));
    }
  };

  updateSaveBtn();
  renderStockValue();
}

/* ---------- ingredient editor ---------- */

function renderIngredient(id, existingDraft) {
  const ing = id ? findIngredient(id) : null;
  if (id && !ing) return go({ name: "home" });
  const isNew = !ing;
  const latest = ing ? sortedPurchases(ing)[0] : null;
  const latestAfter = latest
    ? Number(latest.purchased_kg) - Number(latest.wastage_kg || 0)
    : null;

  draft = existingDraft || {
    name: ing ? ing.name : "",
    name_th: ing ? ing.name_th || "" : "",
    unit: ing ? ing.unit || "kg" : "kg",
    category: ing ? catOf(ing) : "other",
    pQty: latest ? fmtQty(latest.purchased_kg) : "",
    pPrice: latest ? String(Number(latest.price_paid)) : "",
    pAfter: latest && Number(latest.wastage_kg) > 0 ? fmtQty(latestAfter) : "",
    pSite: localStorage.getItem("arifood_site") || "",
  };
  const u = unitOf({ unit: draft.unit });
  const boughtLbl = t(u.liquid ? "bought_v" : "bought_w");
  const afterLbl = t(u.liquid ? "after_v" : "after_w");

  const history = ing ? sortedPurchases(ing) : [];
  const historyRows = history.map((p, idx) => {
    const s = purchaseStats(p);
    return `<tr class="${idx === 0 ? "latest" : ""}">
      <td>${dateShort(p.purchased_at)}</td>
      <td class="num">${fmtQty(p.purchased_kg)} ${u.big}</td>
      <td class="num">${money(p.price_paid)}</td>
      <td class="num">${fmtQty(Number(p.purchased_kg) - Number(p.wastage_kg || 0))} ${u.big}</td>
      <td class="num">${s ? money(s.perBig) : "–"}</td>
      <td>${esc(p.entered_by || "")}</td>
      <td class="action"><button class="rowlink x" data-del-purchase="${p.id}" aria-label="${esc(t("delete"))}">✕</button></td>
    </tr>`;
  }).join("");

  $app.innerHTML = `
    ${header({ title: isNew ? t("new_ingredient") : t("edit_ingredient") })}
    <main class="content no-tabs">
      <div class="field">
        <label for="ingName">${esc(t("ingredient_name"))}</label>
        <input type="text" id="ingName" value="${esc(draft.name)}">
      </div>
      ${hasNameTh() ? `<div class="field">
        <label for="ingNameTh">${esc(t("name_th"))}</label>
        <input type="text" id="ingNameTh" value="${esc(draft.name_th)}">
      </div>` : ""}
      <div class="row2">
        <div class="field">
          <label for="ingCat">${esc(t("category"))}</label>
          <select id="ingCat">
            ${CATS.map((c) => `<option value="${c}" ${draft.category === c ? "selected" : ""}>${esc(t("cat_" + c))}</option>`).join("")}
          </select>
        </div>
        <div class="field">
          <label for="ingUnit">${esc(t("unit"))}</label>
          <select id="ingUnit">
            <option value="kg" ${draft.unit === "kg" ? "selected" : ""}>${esc(t("unit_kg"))}</option>
            <option value="l" ${draft.unit === "l" ? "selected" : ""}>${esc(t("unit_l"))}</option>
          </select>
        </div>
      </div>

      <div class="row2">
        <div class="field">
          <label for="pQty">${esc(boughtLbl)} (${esc(u.big)})</label>
          <input type="number" id="pQty" step="0.001" min="0" inputmode="decimal" value="${esc(draft.pQty)}">
        </div>
        <div class="field">
          <label for="pPrice">${esc(t("price_paid"))}</label>
          <input type="number" id="pPrice" step="0.01" min="0" inputmode="decimal" value="${esc(draft.pPrice)}">
        </div>
      </div>
      <div class="field">
        <label for="pAfter">${esc(afterLbl)} (${esc(u.big)})</label>
        <input type="number" id="pAfter" step="0.001" min="0" inputmode="decimal"
          value="${esc(draft.pAfter)}" placeholder="${esc(t("after_hint"))}">
      </div>
      ${state.stockMissing ? "" : `<div class="field">
        <label for="pSite">${esc(t("add_stock_site"))}</label>
        <select id="pSite">
          <option value="">${esc(t("no_site"))}</option>
          ${SITES.map((x) => `<option value="${x}" ${draft.pSite === x ? "selected" : ""}>${esc(t("site_" + x))}</option>`).join("")}
        </select>
      </div>`}

      <div class="calc">
        <div class="caption">${esc(t("auto_calc"))}</div>
        <div class="crow num"><span>${esc(t("usable_weight"))}</span><span id="calcUsable">–</span></div>
        <div class="crow num"><span>${esc(t("price_per"))} ${esc(u.big)}</span><strong id="calcPerBig">–</strong></div>
        <div class="crow num"><span>${esc(t("price_per"))} ${esc(u.small)}</span><strong id="calcPerSmall">–</strong></div>
      </div>

      <button class="btn" id="btnSave">${esc(t("save"))}</button>

      ${isNew ? "" : `
      <p class="section-label">${esc(t("purchase_history"))}</p>
      <div class="card"><div class="scroll-x" style="padding:0.3rem 0.6rem">
        ${history.length ? `<table class="list">
          <thead><tr>
            <th>${esc(t("date"))}</th><th class="num">${esc(t("purchased"))}</th>
            <th class="num">${esc(t("price"))}</th><th class="num">${esc(afterLbl)}</th>
            <th class="num">${esc(t("unit_price"))}</th><th>${esc(t("by"))}</th><th></th>
          </tr></thead>
          <tbody class="num">${historyRows}</tbody>
        </table>` : `<p class="empty" style="border:none">${esc(t("no_purchases"))}</p>`}
      </div></div>
      <button class="btn danger-link" id="btnDelete">${esc(t("delete_ingredient"))}</button>
      <p class="meta-line num">${esc(ing.updated_by || "")} · ${dateShort(ing.updated_at)}</p>`}
    </main>`;

  wireHeader();

  const inputs = ["pQty", "pPrice", "pAfter"].map((i) => document.getElementById(i));
  const captureDraft = () => {
    draft.name = document.getElementById("ingName").value;
    const th = document.getElementById("ingNameTh");
    if (th) draft.name_th = th.value;
    draft.category = document.getElementById("ingCat").value;
    draft.unit = document.getElementById("ingUnit").value;
    draft.pQty = inputs[0].value;
    draft.pPrice = inputs[1].value;
    draft.pAfter = inputs[2].value;
    const siteSel = document.getElementById("pSite");
    if (siteSel) draft.pSite = siteSel.value;
  };

  const readPurchase = () => {
    const bought = inputs[0].value.trim();
    const price = inputs[1].value.trim();
    const after = inputs[2].value.trim();
    if (!bought && !price) return { empty: true };
    const b = Number(bought);
    const pr = Number(price);
    const af = after === "" ? b : Number(after);
    if (!(b > 0) || !(pr >= 0) || price === "" || !(af > 0)) {
      alert(t("bad_numbers")); return { invalid: true };
    }
    if (af > b) { alert(t("after_too_big")); return { invalid: true }; }
    return { p: { purchased_kg: b, price_paid: pr, wastage_kg: b - af } };
  };

  const updateCalc = () => {
    const bought = Number(inputs[0].value);
    const price = Number(inputs[1].value);
    const after = inputs[2].value.trim() === "" ? bought : Number(inputs[2].value);
    const s = (bought > 0 && after > 0 && after <= bought && inputs[1].value.trim() !== "")
      ? { usable: after, perBig: price / after, perSmall: price / after / 1000 }
      : null;
    document.getElementById("calcUsable").textContent = s ? `${fmtQty(s.usable)} ${u.big}` : "–";
    document.getElementById("calcPerBig").textContent = s ? money(s.perBig) : "–";
    document.getElementById("calcPerSmall").textContent = s ? money(s.perSmall, 4) : "–";
  };
  inputs.forEach((i) => (i.oninput = updateCalc));

  document.getElementById("ingUnit").onchange = () => {
    captureDraft();
    renderIngredient(id, { ...draft });
  };

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const name = draft.name.trim();
    if (!name) return alert(t("need_name"));
    const r = readPurchase();
    if (r.invalid) return;
    // Only record a new purchase when the numbers changed (or first entry).
    const changed = r.p && (!latest ||
      Number(latest.purchased_kg) !== r.p.purchased_kg ||
      Number(latest.price_paid) !== r.p.price_paid ||
      Number(latest.wastage_kg || 0) !== r.p.wastage_kg);
    try {
      let ingredientId = id;
      const fields = { name, unit: draft.unit, category: draft.category, updated_by: userName() };
      if (hasNameTh()) fields.name_th = draft.name_th.trim() || null;
      if (isNew) {
        const { data, error } = await db.from("ingredients").insert(fields).select().single();
        if (error) throw error;
        ingredientId = data.id;
      } else {
        const { error } = await db.from("ingredients")
          .update({ ...fields, updated_at: new Date().toISOString() })
          .eq("id", ingredientId);
        if (error) throw error;
      }
      if (changed) {
        const { error } = await db.from("purchases").insert({
          ingredient_id: ingredientId, ...r.p, entered_by: userName(),
        });
        if (error) throw error;
        // A new purchase also lands in the chosen site's stock.
        if (draft.pSite && !state.stockMissing) {
          const st = await db.from("stock_levels").upsert([{
            ingredient_id: ingredientId,
            site: draft.pSite,
            qty: Math.max(0, (stockOf(ingredientId, draft.pSite) ?? 0) + r.p.purchased_kg),
            updated_at: new Date().toISOString(),
            updated_by: userName(),
          }], { onConflict: "ingredient_id,site" });
          if (st.error) throw st.error;
        }
      }
      go({ name: "home" }, { refresh: true });
    } catch (e) {
      console.error(e); alert(t("save_failed"));
    }
  };

  if (!isNew) {
    document.getElementById("btnDelete").onclick = async () => {
      if (!confirm(t("confirm_delete"))) return;
      const { error } = await db.from("ingredients").delete().eq("id", ing.id);
      if (error) {
        alert(error.code === "23503" ? t("ing_in_use") : t("save_failed"));
        return;
      }
      go({ name: "home" }, { refresh: true });
    };

    $app.querySelectorAll("[data-del-purchase]").forEach((b) => {
      b.onclick = async () => {
        if (!confirm(t("confirm_delete"))) return;
        const { error } = await db.from("purchases").delete().eq("id", b.dataset.delPurchase);
        if (error) { console.error(error); return alert(t("save_failed")); }
        go({ name: "ingredient", id: ing.id }, { refresh: true });
      };
    });
  }

  updateCalc();
}

/* ---------- sauce editor ---------- */

function renderSauce(id, existingDraft) {
  const sauce = id ? findSauce(id) : null;
  if (id && !sauce) return go({ name: "home" });
  const isNew = !sauce;
  draft = existingDraft || {
    name: sauce ? sauce.name : "",
    name_th: sauce ? sauce.name_th || "" : "",
    rows: sauce && (sauce.sauce_ingredients || []).length
      ? sauceRowsOf(sauce).map((r) => ({ ...r, grams: String(r.grams) }))
      : [{ kind: "ing", id: "", grams: "" }],
  };

  const rowsHtml = draft.rows.map((r, idx) => {
    const label = pickedLabel(r);
    return `<div class="erow">
      <button class="pickbtn ${label ? "" : "placeholder"}" data-s-pick="${idx}">
        ${r.kind === "sauce" && label ? `<span class="sicon">${ICONS.sauce}</span>` : ""}${esc(label || t("choose_item"))}
      </button>
      <input type="number" class="amt" data-s-g="${idx}" step="1" min="0"
        inputmode="numeric" value="${esc(r.grams)}" aria-label="${esc(t("amount"))}">
      <span class="sfx" id="sSfx${idx}">${esc(rowSuffix(r))}</span>
      <span class="rcost num" id="sCost${idx}">–</span>
      <button class="xbtn" data-s-del="${idx}" aria-label="${esc(t("delete"))}">✕</button>
    </div>`;
  }).join("");

  $app.innerHTML = `
    ${header({ title: isNew ? t("new_sauce") : t("edit_sauce") })}
    <main class="content no-tabs">
      <div class="field">
        <label for="sauceName">${esc(t("sauce_name"))}</label>
        <input type="text" id="sauceName" value="${esc(draft.name)}">
      </div>
      ${hasNameTh() ? `<div class="field">
        <label for="sauceNameTh">${esc(t("name_th"))}</label>
        <input type="text" id="sauceNameTh" value="${esc(draft.name_th)}">
      </div>` : ""}

      <p class="section-label">${esc(t("cat_sauce"))}</p>
      ${rowsHtml}
      <button class="btn ghost small" id="btnAddRow">${esc(t("add_row"))}</button>

      <div class="calc">
        <div class="caption">${esc(t("auto_calc"))}</div>
        <div class="crow num"><span>${esc(t("batch_size"))}</span><span id="batchSize">–</span></div>
        <div class="crow num"><span>${esc(t("batch_cost"))}</span><span id="batchCost">–</span></div>
        <div class="crow num"><span>${esc(t("cost_per_g"))}</span><strong id="perG">–</strong></div>
      </div>

      <button class="btn" id="btnSave">${esc(t("save"))}</button>
      ${isNew ? "" : `<button class="btn danger-link" id="btnDelete">${esc(t("delete_sauce"))}</button>
      <p class="meta-line num">${esc(sauce.updated_by || "")} · ${dateShort(sauce.updated_at)}</p>`}
    </main>`;

  wireHeader();

  const captureDraft = () => {
    draft.name = document.getElementById("sauceName").value;
    const th = document.getElementById("sauceNameTh");
    if (th) draft.name_th = th.value;
  };

  const updateTotals = () => {
    let grams = 0, cost = 0;
    draft.rows.forEach((r, idx) => {
      const per = r.id ? rowUnitCost(r) : null;
      const g = Number(r.grams);
      const cell = document.getElementById(`sCost${idx}`);
      if (per != null && g > 0) {
        if (cell) cell.textContent = money(g * per);
        grams += g;
        cost += g * per;
      } else if (cell) cell.textContent = "–";
    });
    document.getElementById("batchSize").textContent = grams > 0 ? `${fmtQty(grams)} ${t("u_g")}` : "–";
    document.getElementById("batchCost").textContent = grams > 0 ? money(cost) : "–";
    document.getElementById("perG").textContent = grams > 0 ? money(cost / grams, 4) : "–";
  };

  // Sauce recipes are built from "sauce ingredients".
  $app.querySelectorAll("[data-s-pick]").forEach((btn) => {
    btn.onclick = () => {
      const idx = Number(btn.dataset.sPick);
      const groups = ingredientPickerGroups({ cats: ["sauce", "veg", "other", "meat"] });
      const subs = state.sauces.filter((x) => x.id !== id).map((x) => {
        const st = sauceStats(x);
        return {
          kind: "sauce", id: x.id, sauce: true, label: dName(x),
          sub: st ? `${money(st.perG, 3)}/${t("u_g")}` : esc(t("no_price_yet")),
        };
      });
      if (subs.length) groups.push({ title: t("sauces"), items: subs });
      openPicker(groups, (item) => {
        captureDraft();
        draft.rows[idx].kind = item.kind;
        draft.rows[idx].id = item.id;
        renderSauce(id, { ...draft });
      }, { allowCreate: true });
    };
  });
  $app.querySelectorAll("[data-s-g]").forEach((inp) => {
    inp.oninput = () => { draft.rows[Number(inp.dataset.sG)].grams = inp.value; updateTotals(); };
  });
  $app.querySelectorAll("[data-s-del]").forEach((b) => {
    b.onclick = () => {
      captureDraft();
      draft.rows.splice(Number(b.dataset.sDel), 1);
      if (!draft.rows.length) draft.rows.push({ kind: "ing", id: "", grams: "" });
      renderSauce(id, { ...draft });
    };
  });
  document.getElementById("btnAddRow").onclick = () => {
    captureDraft();
    draft.rows.push({ kind: "ing", id: "", grams: "" });
    renderSauce(id, { ...draft });
  };

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const name = draft.name.trim();
    if (!name) return alert(t("need_name"));
    const rows = draft.rows
      .filter((r) => r.id && Number(r.grams) > 0)
      .map((r) => ({
        ingredient_id: r.kind === "sauce" ? null : r.id,
        sub_sauce_id: r.kind === "sauce" ? r.id : null,
        grams: Number(r.grams),
      }));
    try {
      let sauceId = id;
      const fields = { name, updated_at: new Date().toISOString(), updated_by: userName() };
      if (hasNameTh()) fields.name_th = draft.name_th.trim() || null;
      if (isNew) {
        const { data, error } = await db.from("sauces").insert(fields).select().single();
        if (error) throw error;
        sauceId = data.id;
      } else {
        const { error } = await db.from("sauces").update(fields).eq("id", sauceId);
        if (error) throw error;
        const del = await db.from("sauce_ingredients").delete().eq("sauce_id", sauceId);
        if (del.error) throw del.error;
      }
      if (rows.length) {
        const ins = await db.from("sauce_ingredients")
          .insert(rows.map((r) => ({ sauce_id: sauceId, ...r })));
        if (ins.error) throw ins.error;
      }
      go({ name: "home" }, { refresh: true });
    } catch (e) {
      console.error(e); alert(t("save_failed"));
    }
  };

  if (!isNew) {
    document.getElementById("btnDelete").onclick = async () => {
      if (!confirm(t("confirm_delete"))) return;
      const { error } = await db.from("sauces").delete().eq("id", sauce.id);
      if (error) {
        alert(error.code === "23503" ? t("sauce_in_use") : t("save_failed"));
        return;
      }
      go({ name: "home" }, { refresh: true });
    };
  }

  updateTotals();
}

/* ---------- dish editor ---------- */

function renderDish(id, existingDraft) {
  const dish = id ? state.dishes.find((d) => d.id === id) : null;
  if (id && !dish) return go({ name: "home" });
  const isNew = !dish;
  draft = existingDraft || {
    name: dish ? dish.name : "",
    name_th: dish ? dish.name_th || "" : "",
    category: dish ? dishCatOf(dish) : "other",
    uses_protein: dish ? !!dish.uses_protein : false,
    selling_price: dish && dish.selling_price != null ? String(dish.selling_price) : "",
    rows: dish && (dish.dish_ingredients || []).length
      ? dishRowsOf(dish).map((r) => ({ ...r, grams: String(r.grams) }))
      : [{ kind: "ing", id: "", grams: "" }],
  };

  const rowsHtml = draft.rows.map((r, idx) => {
    const label = pickedLabel(r);
    return `<div class="erow">
      <button class="pickbtn ${label ? "" : "placeholder"}" data-d-pick="${idx}">
        ${r.kind === "sauce" && label ? `<span class="sicon">${ICONS.sauce}</span>` : ""}${esc(label || t("choose_item"))}
      </button>
      <input type="number" class="amt" data-d-g="${idx}" step="1" min="0"
        inputmode="numeric" value="${esc(r.grams)}" aria-label="${esc(t("amount"))}">
      <span class="sfx" id="dSfx${idx}">${esc(rowSuffix(r))}</span>
      <span class="rcost num" id="dCost${idx}">–</span>
      <button class="xbtn" data-d-del="${idx}" aria-label="${esc(t("delete"))}">✕</button>
    </div>`;
  }).join("");

  $app.innerHTML = `
    ${header({ title: isNew ? t("new_dish") : t("edit_dish") })}
    <main class="content no-tabs">
      <div class="field">
        <label for="dishName">${esc(t("dish_name"))}</label>
        <input type="text" id="dishName" value="${esc(draft.name)}">
      </div>
      ${hasNameTh() ? `<div class="field">
        <label for="dishNameTh">${esc(t("name_th"))}</label>
        <input type="text" id="dishNameTh" value="${esc(draft.name_th)}">
      </div>` : ""}
      ${hasDishCat() ? `<div class="field">
        <label for="dishCat">${esc(t("category"))}</label>
        <select id="dishCat">
          ${DISH_CATS.map((c) => `<option value="${c}" ${draft.category === c ? "selected" : ""}>${esc(t("dcat_" + c))}</option>`).join("")}
        </select>
      </div>` : ""}

      <p class="section-label">${esc(t("dish_ingredients"))}</p>
      ${rowsHtml}
      <button class="btn ghost small" id="btnAddRow">${esc(t("add_row"))}</button>

      <div class="field" style="margin-top:1.1rem">
        <label for="dishSell">${esc(t("selling_price"))}</label>
        <input type="number" id="dishSell" step="0.01" min="0" inputmode="decimal"
          value="${esc(draft.selling_price)}">
      </div>

      ${state.proteins.length ? `<label class="checkrow">
        <input type="checkbox" id="dishProt" ${draft.uses_protein ? "checked" : ""}>
        <span>${esc(t("uses_protein"))}</span>
      </label>` : ""}

      <div class="calc">
        <div class="caption">${esc(t("cost_per_portion"))}</div>
        <div class="crow num"><span>${esc(draft.uses_protein ? t("base_cost") : t("total_cost"))}</span><strong id="dishTotal">–</strong></div>
        <div class="crow num"><span>${esc(t("gross_profit"))}</span><strong id="gpAbs">–</strong></div>
        <div class="crow num"><span>${esc(t("margin"))}</span><strong id="gpPct">–</strong></div>
      </div>

      <div id="protPanel"></div>

      <button class="btn" id="btnSave">${esc(t("save"))}</button>
      ${isNew ? "" : `<button class="btn danger-link" id="btnDelete">${esc(t("delete_dish"))}</button>
      <p class="meta-line num">${esc(dish.updated_by || "")} · ${dateShort(dish.updated_at)}</p>`}
    </main>`;

  wireHeader();

  const captureDraft = () => {
    draft.name = document.getElementById("dishName").value;
    const th = document.getElementById("dishNameTh");
    if (th) draft.name_th = th.value;
    draft.selling_price = document.getElementById("dishSell").value;
    const cat = document.getElementById("dishCat");
    if (cat) draft.category = cat.value;
    const pr = document.getElementById("dishProt");
    if (pr) draft.uses_protein = pr.checked;
  };

  // Cost / gross profit / margin for each protein the customer can pick.
  const renderProteinPanel = (base) => {
    const el = document.getElementById("protPanel");
    if (!el) return;
    if (!draft.uses_protein || !state.proteins.length) { el.innerHTML = ""; return; }
    const rows = state.proteins.map((p) => {
      const pc = proteinCost(p);
      const price = proteinPrice(p, dish || { selling_price: Number(draft.selling_price) || null });
      const total = pc == null ? null : base + pc;
      const gp = total != null && price != null ? price - total : null;
      const pct = gp != null && price > 0 ? (gp / price) * 100 : null;
      return `<tr>
        <td>${esc(dName(p))}${p.grams > 0 ? ` <span class="muted">${fmtQty(p.grams)} ${esc(t("u_g"))}</span>` : ""}</td>
        <td class="num">${total == null ? "–" : money(total)}</td>
        <td class="num">${price == null ? "–" : money(price)}</td>
        <td class="num ${gp != null && gp < 0 ? "neg" : ""}">${gp == null ? "–" : money(gp)}</td>
        <td class="num ${pct != null && pct < 0 ? "neg" : ""}">${pct == null ? "–" : pct.toFixed(0) + "%"}</td>
      </tr>`;
    }).join("");
    el.innerHTML = `<p class="section-label">${esc(t("by_protein"))}</p>
      <div class="card"><div class="scroll-x" style="padding:0.3rem 0.6rem">
        <table class="list">
          <thead><tr>
            <th>${esc(t("protein"))}</th><th class="num">${esc(t("cost"))}</th>
            <th class="num">${esc(t("price"))}</th><th class="num">${esc(t("gp"))}</th>
            <th class="num">${esc(t("margin"))}</th>
          </tr></thead>
          <tbody class="num">${rows}</tbody>
        </table>
      </div></div>`;
  };

  const updateTotals = () => {
    draft.rows.forEach((r, idx) => {
      const per = r.id ? rowUnitCost(r) : null;
      const amount = Number(r.grams);
      const cell = document.getElementById(`dCost${idx}`);
      if (cell) cell.textContent = per != null && amount > 0 ? money(amount * per) : "–";
    });
    const c = dishCost(draft.rows.filter((r) => r.id || r.grams !== ""));
    document.getElementById("dishTotal").textContent = money(c.total);
    renderProteinPanel(c.total);
    const sell = Number(document.getElementById("dishSell").value);
    const gpAbs = document.getElementById("gpAbs");
    const gpPct = document.getElementById("gpPct");
    if (sell > 0) {
      const gp = sell - c.total;
      gpAbs.textContent = money(gp);
      gpPct.textContent = ((gp / sell) * 100).toFixed(1) + "%";
      gpAbs.classList.toggle("neg", gp < 0);
      gpPct.classList.toggle("neg", gp < 0);
    } else {
      gpAbs.textContent = "–";
      gpPct.textContent = "–";
      gpAbs.classList.remove("neg");
      gpPct.classList.remove("neg");
    }
  };

  $app.querySelectorAll("[data-d-pick]").forEach((btn) => {
    btn.onclick = () => {
      const idx = Number(btn.dataset.dPick);
      openPicker(ingredientPickerGroups({ includeSauceRecipes: !state.saucesMissing }), (item) => {
        captureDraft();
        draft.rows[idx].kind = item.kind;
        draft.rows[idx].id = item.id;
        renderDish(id, { ...draft });
      }, { allowCreate: true });
    };
  });
  $app.querySelectorAll("[data-d-g]").forEach((inp) => {
    inp.oninput = () => { draft.rows[Number(inp.dataset.dG)].grams = inp.value; updateTotals(); };
  });
  $app.querySelectorAll("[data-d-del]").forEach((b) => {
    b.onclick = () => {
      captureDraft();
      draft.rows.splice(Number(b.dataset.dDel), 1);
      if (!draft.rows.length) draft.rows.push({ kind: "ing", id: "", grams: "" });
      renderDish(id, { ...draft });
    };
  });
  document.getElementById("btnAddRow").onclick = () => {
    captureDraft();
    draft.rows.push({ kind: "ing", id: "", grams: "" });
    renderDish(id, { ...draft });
  };
  document.getElementById("dishSell").oninput = updateTotals;
  const protBox = document.getElementById("dishProt");
  if (protBox) protBox.onchange = () => { captureDraft(); renderDish(id, { ...draft }); };

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const name = draft.name.trim();
    if (!name) return alert(t("need_name"));
    // A dish may be saved without a recipe yet (e.g. imported from the menu).
    const rows = draft.rows
      .filter((r) => r.id && Number(r.grams) > 0)
      .map((r) => ({
        ingredient_id: r.kind === "ing" ? r.id : null,
        sauce_id: r.kind === "sauce" ? r.id : null,
        grams: Number(r.grams),
      }));
    const sellRaw = draft.selling_price.trim();
    const selling_price = sellRaw === "" ? null : Number(sellRaw);

    try {
      let dishId = id;
      const fields = {
        name, selling_price,
        updated_at: new Date().toISOString(), updated_by: userName(),
      };
      if (hasDishCat()) fields.category = draft.category;
      if (hasNameTh()) fields.name_th = draft.name_th.trim() || null;
      if (state.proteins.length) fields.uses_protein = !!draft.uses_protein;
      if (isNew) {
        const { data, error } = await db.from("dishes").insert(fields).select().single();
        if (error) throw error;
        dishId = data.id;
      } else {
        const { error } = await db.from("dishes").update(fields).eq("id", dishId);
        if (error) throw error;
        const del = await db.from("dish_ingredients").delete().eq("dish_id", dishId);
        if (del.error) throw del.error;
      }
      if (rows.length) {
        const ins = await db.from("dish_ingredients")
          .insert(rows.map((r) => ({ dish_id: dishId, ...r })));
        if (ins.error) throw ins.error;
      }
      go({ name: "home" }, { refresh: true });
    } catch (e) {
      console.error(e); alert(t("save_failed"));
    }
  };

  if (!isNew) {
    document.getElementById("btnDelete").onclick = async () => {
      if (!confirm(t("confirm_delete"))) return;
      const { error } = await db.from("dishes").delete().eq("id", dish.id);
      if (error) { console.error(error); return alert(t("save_failed")); }
      go({ name: "home" }, { refresh: true });
    };
  }

  updateTotals();
}

/* ---------- boot ---------- */

function renderConfigMissing() {
  $app.innerHTML = `
    <div class="login-wrap">
      <div class="login-logo">
        <img src="assets/ari-logo.png" alt="Ari Thai Street Food logo">
        <div class="name">${APP_NAME}</div>
        <div class="sub">${esc(t("tagline"))}</div>
      </div>
      <div class="error-box">
        <strong>${esc(t("config_missing_title"))}</strong><br>
        ${esc(t("config_missing_body"))}
      </div>
    </div>`;
}

async function init() {
  if (
    !window.APP_CONFIG ||
    APP_CONFIG.SUPABASE_URL.startsWith("YOUR-") ||
    APP_CONFIG.SUPABASE_ANON_KEY.startsWith("YOUR-")
  ) {
    renderConfigMissing();
    return;
  }
  db = window.supabase.createClient(APP_CONFIG.SUPABASE_URL, APP_CONFIG.SUPABASE_ANON_KEY);

  // An invite or password-reset link lands here with tokens in the URL.
  const link = authLinkType();
  if (link && link.error) {
    clearAuthHash();
    return renderLogin(link.error);
  }
  if (link) {
    // Give supabase-js a moment to turn the URL tokens into a session.
    for (let i = 0; i < 20; i++) {
      const { data } = await db.auth.getSession();
      if (data.session) { session = data.session; break; }
      await new Promise((r) => setTimeout(r, 100));
    }
    return renderSetPassword(link.type);
  }

  const { data } = await db.auth.getSession();
  session = data.session;
  render();
}

init();
