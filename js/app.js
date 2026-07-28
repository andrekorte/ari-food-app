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
  profile: null,        // this user's row in profiles (null = full access)
  view: { name: "home" },
};
let draft = null;

const $app = document.getElementById("app");
const LOGO = `<img src="assets/ari-logo.png" alt="" class="brand-logo">`;
const APP_NAME = "Food tracker";
const CATS = ["meat", "veg", "sauce", "other"];
// Menu sections from ari-thaistreetfood.com.
const DISH_CATS = [
  "ala_carte", "noodle_soup", "entree", "vegan", "gluten_free",
  "drinks", "dessert", "snacks", "special", "other",
];

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
function sauceStats(sauce) {
  const rows = (sauce && sauce.sauce_ingredients) || [];
  let grams = 0, cost = 0, complete = rows.length > 0;
  for (const r of rows) {
    const st = ingredientStats(findIngredient(r.ingredient_id));
    const g = Number(r.grams);
    if (!st || !(g > 0)) { complete = false; continue; }
    grams += g;
    cost += g * st.perSmall;
  }
  if (!(grams > 0)) return null;
  return { grams, cost, perG: cost / grams, complete };
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

function dishRowsOf(dish) {
  return (dish.dish_ingredients || []).map((r) =>
    r.sauce_id
      ? { kind: "sauce", id: r.sauce_id, grams: r.grams }
      : { kind: "ing", id: r.ingredient_id, grams: r.grams }
  );
}

/* ---------- data ---------- */

async function loadData() {
  const [ings, dishes] = await Promise.all([
    db.from("ingredients").select("*, purchases(*)").order("name"),
    db.from("dishes").select("*, dish_ingredients(*)").order("name"),
  ]);
  if (ings.error) throw ings.error;
  if (dishes.error) throw dishes.error;
  state.ingredients = ings.data;
  state.dishes = dishes.data;

  // Sauces arrive with a later migration — degrade gracefully without it.
  const sauces = await db.from("sauces").select("*, sauce_ingredients(*)").order("name");
  if (sauces.error) {
    state.sauces = [];
    state.saucesMissing = true;
  } else {
    state.sauces = sauces.data;
    state.saucesMissing = false;
  }

  try {
    const { data } = await db.from("profiles")
      .select("*").eq("user_id", session.user.id).maybeSingle();
    state.profile = data || null;
  } catch (_e) {
    state.profile = null;
  }
}

/* ---------- navigation & chrome ---------- */

async function go(view) {
  state.view = view;
  draft = null;
  await render();
  window.scrollTo(0, 0);
}

async function render() {
  if (!session) return renderLogin();
  try {
    await loadData();
  } catch (e) {
    console.error(e);
    $app.innerHTML =
      header({ home: true }) +
      `<main class="content"><div class="error-box bad">${esc(t("load_failed"))}</div></main>`;
    wireHeader();
    return;
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
  else renderHome();
}

function header({ home, title } = {}) {
  return `<header class="header">
    <span class="brandwrap">
      ${home
        ? `${LOGO}<span class="brand">${APP_NAME}</span>`
        : `<button class="back" id="btnBack">‹ ${esc(t("home"))}</button>
           <span class="htitle">${esc(title || "")}</span>`}
    </span>
    <span class="actions">
      <button class="chipbtn" id="btnLang">${LANG === "en" ? "ไทย" : "EN"}</button>
      ${home ? `<button class="chipbtn" id="btnLogout">${esc(userName())} ⏻</button>` : ""}
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
    renderLogin();
  };
}

function tabbar(active) {
  return `<nav class="tabbar"><div class="inner">
    <button class="tab ${active === "home" ? "active" : ""}" id="tabHome">
      <span class="ticon">🏠</span>${esc(t("tab_home"))}
    </button>
    <button class="tab ${active === "basket" ? "active" : ""}" id="tabBasket">
      <span class="ticon">🛒</span>${esc(t("tab_purchase"))}
    </button>
  </div></nav>`;
}

function wireTabbar() {
  const h = document.getElementById("tabHome");
  if (h) h.onclick = () => go({ name: "home" });
  const b = document.getElementById("tabBasket");
  if (b) b.onclick = () => go({ name: "basket" });
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
      <p class="center" style="margin-top:1.4rem">
        <button class="chipbtn" id="btnLangLogin">${LANG === "en" ? "ไทย" : "EN"}</button>
      </p>
    </div>`;
  document.getElementById("btnLangLogin").onclick = () => { toggleLang(); renderLogin(errorMsg); };
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
      <span class="lname">${esc(ing.name)}</span>
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
    return `<details class="group">
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
        <span class="lname">${esc(s.name)}</span>
        <span class="lmeta num">${meta}</span>
        <span class="chev">›</span>
      </button>
    </div>`;
  }).join("");

  const dishRowHtml = (d) => {
    const rows = dishRowsOf(d);
    const c = dishCost(rows);
    const sell = d.selling_price != null ? Number(d.selling_price) : null;
    const gpPct = sell > 0 && rows.length ? ((sell - c.total) / sell) * 100 : null;
    const meta = [
      rows.length ? money(c.total) + (c.complete ? "" : "*") : "–",
      gpPct == null ? null : gpPct.toFixed(0) + "%",
    ].filter(Boolean).join(" · ");
    return `<div class="lrow">
      <button class="lmain" data-edit-dish="${d.id}">
        <span class="lname">${esc(d.name)}</span>
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
        return `<details class="group">
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
        ${state.sauces.length ? sauceRows : `<p class="empty">${esc(t("no_sauces"))}</p>`}
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
      render();
    };
  });
}

/* ---------- full-screen searchable picker ---------- */

// groups: [{title, items: [{kind, id, label, sub}]}]; onPick(item)
function openPicker(groups, onPick) {
  const overlay = document.createElement("div");
  overlay.className = "picker";
  const groupHtml = () => groups.map((g, gi) => {
    const q = overlay.querySelector("input") ? overlay.querySelector("input").value.trim().toLowerCase() : "";
    const items = g.items.filter((it) => !q || it.label.toLowerCase().includes(q));
    if (!items.length) return "";
    return `<div class="pgroup">
      <p class="pgtitle">${esc(g.title)}</p>
      <div class="pgbody">
        ${items.map((it) => `<button class="prow" data-g="${gi}" data-id="${it.id}" data-kind="${it.kind}">
          <span class="pname">${esc(it.label)}</span>
          <span class="psub num">${it.sub || ""}</span>
        </button>`).join("")}
      </div>
    </div>`;
  }).join("");

  overlay.innerHTML = `
    <div class="phead">
      <input type="search" placeholder="${esc(t("search"))}" aria-label="${esc(t("search"))}">
      <button class="pcancel">${esc(t("cancel"))}</button>
    </div>
    <div class="pbody">${""}</div>`;
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
  refresh();
  overlay.querySelector("input").focus();
}

function ingPickItem(ing) {
  const s = ingredientStats(ing);
  const u = unitOf(ing);
  return {
    kind: "ing", id: ing.id, label: ing.name,
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
            kind: "sauce", id: s.id, label: `🥣 ${s.name}`,
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
    return s ? `🥣 ${s.name}` : null;
  }
  const i = findIngredient(row.id);
  return i ? i.name : null;
}

function rowSuffix(row) {
  if (row.kind === "sauce" || !row.id) return t("u_g");
  const i = findIngredient(row.id);
  return i ? unitOf(i).small : t("u_g");
}

/* ---------- basket: record a whole shopping trip ---------- */

function renderBasket(existingDraft) {
  draft = existingDraft || { rows: [{ id: "", qty: "", price: "" }] };

  const rowsHtml = draft.rows.map((r, idx) => {
    const ing = findIngredient(r.id);
    const label = ing ? ing.name : null;
    const suffix = ing ? unitOf(ing).big : t("u_kg");
    return `<div class="erow">
      <button class="pickbtn ${label ? "" : "placeholder"}" data-b-pick="${idx}">
        ${esc(label || t("choose_item"))}
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
    ${header({ title: `🛒 ${t("new_purchase")}` })}
    <main class="content">
      <p class="muted" style="margin:0.2rem 0 0.8rem; font-size:0.85rem">${esc(t("basket_hint"))}</p>
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

  $app.querySelectorAll("[data-b-pick]").forEach((btn) => {
    btn.onclick = () => {
      const idx = Number(btn.dataset.bPick);
      openPicker(ingredientPickerGroups(), (item) => {
        captureDraft();
        draft.rows[idx].id = item.id;
        renderBasket({ ...draft });
      });
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

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const filled = draft.rows.filter((r) => r.id || r.qty !== "" || r.price !== "");
    const valid = filled.filter(
      (r) => r.id && Number(r.qty) > 0 && r.price !== "" && Number(r.price) >= 0
    );
    if (!valid.length || valid.length !== filled.length) return alert(t("need_basket"));
    try {
      const { error } = await db.from("purchases").insert(valid.map((r) => ({
        ingredient_id: r.id,
        purchased_kg: Number(r.qty),
        price_paid: Number(r.price),
        wastage_kg: 0,
        entered_by: userName(),
      })));
      if (error) throw error;
      go({ name: "home" });
    } catch (e) {
      console.error(e); alert(t("save_failed"));
    }
  };

  updateTotal();
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
    unit: ing ? ing.unit || "kg" : "kg",
    category: ing ? catOf(ing) : "other",
    pQty: latest ? fmtQty(latest.purchased_kg) : "",
    pPrice: latest ? String(Number(latest.price_paid)) : "",
    pAfter: latest && Number(latest.wastage_kg) > 0 ? fmtQty(latestAfter) : "",
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
    draft.category = document.getElementById("ingCat").value;
    draft.unit = document.getElementById("ingUnit").value;
    draft.pQty = inputs[0].value;
    draft.pPrice = inputs[1].value;
    draft.pAfter = inputs[2].value;
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
      }
      go({ name: "home" });
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
      go({ name: "home" });
    };

    $app.querySelectorAll("[data-del-purchase]").forEach((b) => {
      b.onclick = async () => {
        if (!confirm(t("confirm_delete"))) return;
        const { error } = await db.from("purchases").delete().eq("id", b.dataset.delPurchase);
        if (error) { console.error(error); return alert(t("save_failed")); }
        go({ name: "ingredient", id: ing.id });
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
    rows: sauce && (sauce.sauce_ingredients || []).length
      ? sauce.sauce_ingredients.map((r) => ({ id: r.ingredient_id, grams: String(r.grams) }))
      : [{ id: "", grams: "" }],
  };

  const rowsHtml = draft.rows.map((r, idx) => {
    const ing = findIngredient(r.id);
    const label = ing ? ing.name : null;
    const suffix = ing ? unitOf(ing).small : t("u_g");
    return `<div class="erow">
      <button class="pickbtn ${label ? "" : "placeholder"}" data-s-pick="${idx}">
        ${esc(label || t("choose_item"))}
      </button>
      <input type="number" class="amt" data-s-g="${idx}" step="1" min="0"
        inputmode="numeric" value="${esc(r.grams)}" aria-label="${esc(t("amount"))}">
      <span class="sfx" id="sSfx${idx}">${esc(suffix)}</span>
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
  };

  const updateTotals = () => {
    let grams = 0, cost = 0;
    draft.rows.forEach((r, idx) => {
      const st = r.id && ingredientStats(findIngredient(r.id));
      const g = Number(r.grams);
      const cell = document.getElementById(`sCost${idx}`);
      if (st && g > 0) {
        if (cell) cell.textContent = money(g * st.perSmall);
        grams += g;
        cost += g * st.perSmall;
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
      openPicker(ingredientPickerGroups({ cats: ["sauce", "veg", "other", "meat"] }), (item) => {
        captureDraft();
        draft.rows[idx].id = item.id;
        renderSauce(id, { ...draft });
      });
    };
  });
  $app.querySelectorAll("[data-s-g]").forEach((inp) => {
    inp.oninput = () => { draft.rows[Number(inp.dataset.sG)].grams = inp.value; updateTotals(); };
  });
  $app.querySelectorAll("[data-s-del]").forEach((b) => {
    b.onclick = () => {
      captureDraft();
      draft.rows.splice(Number(b.dataset.sDel), 1);
      if (!draft.rows.length) draft.rows.push({ id: "", grams: "" });
      renderSauce(id, { ...draft });
    };
  });
  document.getElementById("btnAddRow").onclick = () => {
    captureDraft();
    draft.rows.push({ id: "", grams: "" });
    renderSauce(id, { ...draft });
  };

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const name = draft.name.trim();
    if (!name) return alert(t("need_name"));
    const rows = draft.rows
      .filter((r) => r.id && Number(r.grams) > 0)
      .map((r) => ({ ingredient_id: r.id, grams: Number(r.grams) }));
    try {
      let sauceId = id;
      const fields = { name, updated_at: new Date().toISOString(), updated_by: userName() };
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
      go({ name: "home" });
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
      go({ name: "home" });
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
    category: dish ? dishCatOf(dish) : "other",
    selling_price: dish && dish.selling_price != null ? String(dish.selling_price) : "",
    rows: dish && (dish.dish_ingredients || []).length
      ? dishRowsOf(dish).map((r) => ({ ...r, grams: String(r.grams) }))
      : [{ kind: "ing", id: "", grams: "" }],
  };

  const rowsHtml = draft.rows.map((r, idx) => {
    const label = pickedLabel(r);
    return `<div class="erow">
      <button class="pickbtn ${label ? "" : "placeholder"}" data-d-pick="${idx}">
        ${esc(label || t("choose_item"))}
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

      <div class="calc">
        <div class="caption">${esc(t("cost_per_portion"))}</div>
        <div class="crow num"><span>${esc(t("total_cost"))}</span><strong id="dishTotal">–</strong></div>
        <div class="crow num"><span>${esc(t("gross_profit"))}</span><strong id="gpAbs">–</strong></div>
        <div class="crow num"><span>${esc(t("margin"))}</span><strong id="gpPct">–</strong></div>
      </div>

      <button class="btn" id="btnSave">${esc(t("save"))}</button>
      ${isNew ? "" : `<button class="btn danger-link" id="btnDelete">${esc(t("delete_dish"))}</button>
      <p class="meta-line num">${esc(dish.updated_by || "")} · ${dateShort(dish.updated_at)}</p>`}
    </main>`;

  wireHeader();

  const captureDraft = () => {
    draft.name = document.getElementById("dishName").value;
    draft.selling_price = document.getElementById("dishSell").value;
    const cat = document.getElementById("dishCat");
    if (cat) draft.category = cat.value;
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
      });
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
      go({ name: "home" });
    } catch (e) {
      console.error(e); alert(t("save_failed"));
    }
  };

  if (!isNew) {
    document.getElementById("btnDelete").onclick = async () => {
      if (!confirm(t("confirm_delete"))) return;
      const { error } = await db.from("dishes").delete().eq("id", dish.id);
      if (error) { console.error(error); return alert(t("save_failed")); }
      go({ name: "home" });
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
  const { data } = await db.auth.getSession();
  session = data.session;
  render();
}

init();
