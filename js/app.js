/* Food tracker — kitchen costing app for Ari Thai Street Food.
 * Views: login → home (ingredient + dish overviews) → basket purchase,
 * add/edit ingredient, add/edit dish. All data lives in a shared Supabase
 * database; every logged-in team member reads and writes the same rows.
 *
 * Units: each ingredient is measured in kg (weight) or L (volume, e.g.
 * oil). Purchases/wastage are entered in that unit; dish amounts are the
 * matching small unit (g or mL). The purchases table's purchased_kg /
 * wastage_kg columns hold whichever unit the ingredient uses.
 */

let db = null;
let session = null;
const state = {
  ingredients: [], // each with .purchases[]
  dishes: [],      // each with .dish_ingredients[]
  profile: null,   // this user's row in profiles (null = full access)
  view: { name: "home" },
};
let draft = null; // working copy for the currently open editor

const $app = document.getElementById("app");
const LOGO = `<img src="assets/ari-logo.png" alt="" class="brand-logo">`;
const APP_NAME = "Food tracker";

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

// Unit labels for an ingredient: big = kg|L (purchases), small = g|mL (dishes).
function unitOf(ing) {
  const liquid = ing && ing.unit === "l";
  return {
    big: t(liquid ? "u_l" : "u_kg"),
    small: t(liquid ? "u_ml" : "u_g"),
  };
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

// Current price comes from the most recent purchase.
function ingredientStats(ing) {
  return purchaseStats(sortedPurchases(ing)[0]);
}

function findIngredient(id) {
  return state.ingredients.find((i) => i.id === id) || null;
}

function dishCost(rows) {
  let total = 0;
  let complete = rows.length > 0;
  for (const r of rows) {
    const s = r.ingredient_id && ingredientStats(findIngredient(r.ingredient_id));
    const amount = Number(r.grams);
    if (!s || !(amount > 0)) { complete = false; continue; }
    total += amount * s.perSmall;
  }
  return { total, complete };
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

  // Role lookup is best-effort: if the profiles table doesn't exist yet
  // (migration not run), everyone keeps full access.
  try {
    const { data } = await db.from("profiles")
      .select("*").eq("user_id", session.user.id).maybeSingle();
    state.profile = data || null;
  } catch (_e) {
    state.profile = null;
  }
}

/* ---------- navigation ---------- */

async function go(view) {
  state.view = view;
  draft = null;
  await render();
}

async function render() {
  if (!session) return renderLogin();
  try {
    await loadData();
  } catch (e) {
    console.error(e);
    $app.innerHTML =
      `<div class="topbar"><span class="brandwrap">${LOGO}<span class="brand">${APP_NAME}</span></span></div>` +
      `<div class="error-box bad">${esc(t("load_failed"))}</div>`;
    return;
  }
  const v = state.view;
  // Shoppers only get the home overview and the basket screen.
  if (!isAdmin() && (v.name === "ingredient" || v.name === "dish")) {
    state.view = { name: "home" };
    return renderHome();
  }
  if (v.name === "ingredient") renderIngredient(v.id);
  else if (v.name === "dish") renderDish(v.id);
  else if (v.name === "basket") renderBasket();
  else renderHome();
}

function topbar({ back } = {}) {
  return `<div class="topbar">
    <span class="brandwrap">
      ${back ? `<button class="back" id="btnBack">‹ ${esc(t("home"))}</button>` : ""}
      ${LOGO}<span class="brand">${APP_NAME}</span>
    </span>
    <span class="actions">
      <button class="chipbtn" id="btnLang">${LANG === "en" ? "ไทย" : "EN"}</button>
      <button class="chipbtn" id="btnLogout">${esc(userName())} · ${esc(t("logout"))}</button>
    </span>
  </div>`;
}

function wireTopbar() {
  const back = document.getElementById("btnBack");
  if (back) back.onclick = () => go({ name: "home" });
  document.getElementById("btnLang").onclick = () => { toggleLang(); render(); };
  document.getElementById("btnLogout").onclick = async () => {
    await db.auth.signOut();
    session = null;
    renderLogin();
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
      <p class="center" style="margin-top:1.4rem">
        <button class="chipbtn" id="btnLang">${LANG === "en" ? "ไทย" : "EN"}</button>
      </p>
    </div>`;
  document.getElementById("btnLang").onclick = () => { toggleLang(); renderLogin(errorMsg); };
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

function renderHome() {
  const ingRows = state.ingredients.map((ing) => {
    const s = ingredientStats(ing);
    const u = unitOf(ing);
    return `<tr>
      <td>${esc(ing.name)}</td>
      <td class="num">${s ? `${fmtQty(s.usable)} ${u.big}` : "–"}</td>
      <td class="num">${s ? `${money(s.perBig)}/${u.big}` : `<span class="muted">${esc(t("no_price_yet"))}</span>`}</td>
      <td class="action">${isAdmin() ? `<button class="rowlink" data-edit-ing="${ing.id}">${esc(t("edit"))}</button>
        <button class="rowlink x" data-del-ing="${ing.id}" aria-label="${esc(t("delete_ingredient"))}">✕</button>` : ""}</td>
    </tr>`;
  }).join("");

  const dishRows = state.dishes.map((d) => {
    const rows = d.dish_ingredients || [];
    const c = dishCost(rows);
    const sell = d.selling_price != null ? Number(d.selling_price) : null;
    const gpPct = sell > 0 && rows.length ? ((sell - c.total) / sell) * 100 : null;
    return `<tr>
      <td>${esc(d.name)}</td>
      <td class="num">${rows.length ? money(c.total) + (c.complete ? "" : " *") : "–"}</td>
      <td class="num">${sell != null ? money(sell) : "–"}</td>
      <td class="num">${gpPct == null ? "–" : gpPct.toFixed(0) + "%"}</td>
      <td class="action"><button class="rowlink" data-edit-dish="${d.id}">${esc(t("edit"))}</button></td>
    </tr>`;
  }).join("");

  $app.innerHTML = `
    ${topbar()}
    <button class="btn" id="btnBasket">🛒 ${esc(t("new_purchase"))}</button>
    <div style="height:1.1rem"></div>

    <div class="card">
      <div class="card-head">
        <span class="card-title">${esc(t("ingredients"))}</span>
        <span class="count num">${state.ingredients.length} ${esc(t("items"))}</span>
      </div>
      <div class="scroll-x">
        ${state.ingredients.length ? `<table class="list">
          <thead><tr>
            <th>${esc(t("ingredient"))}</th><th class="num">${esc(t("usable"))}</th>
            <th class="num">${esc(t("unit_price"))}</th><th></th>
          </tr></thead>
          <tbody class="num">${ingRows}</tbody>
        </table>` : `<p class="empty">${esc(t("no_ingredients"))}</p>`}
      </div>
      ${isAdmin() ? `<button class="btn ghost small" id="btnAddIng">${esc(t("add_ingredient"))}</button>` : ""}
    </div>

    ${isAdmin() ? `<div class="card">
      <div class="card-head">
        <span class="card-title">${esc(t("dishes"))}</span>
        <span class="count num">${state.dishes.length} ${esc(t("items"))}</span>
      </div>
      <div class="scroll-x">
        ${state.dishes.length ? `<table class="list">
          <thead><tr>
            <th>${esc(t("dish"))}</th><th class="num">${esc(t("cost"))}</th>
            <th class="num">${esc(t("price"))}</th><th class="num">${esc(t("gp"))}</th><th></th>
          </tr></thead>
          <tbody class="num">${dishRows}</tbody>
        </table>` : `<p class="empty">${esc(t("no_dishes"))}</p>`}
      </div>
      <button class="btn ghost small" id="btnAddDish">${esc(t("add_dish"))}</button>
    </div>` : ""}`;

  wireTopbar();
  document.getElementById("btnBasket").onclick = () => go({ name: "basket" });
  const addIng = document.getElementById("btnAddIng");
  if (addIng) addIng.onclick = () => go({ name: "ingredient", id: null });
  const addDish = document.getElementById("btnAddDish");
  if (addDish) addDish.onclick = () => go({ name: "dish", id: null });
  $app.querySelectorAll("[data-edit-ing]").forEach((b) => {
    b.onclick = () => go({ name: "ingredient", id: b.dataset.editIng });
  });
  $app.querySelectorAll("[data-del-ing]").forEach((b) => {
    b.onclick = async () => {
      if (!confirm(t("confirm_delete"))) return;
      const { error } = await db.from("ingredients").delete().eq("id", b.dataset.delIng);
      if (error) {
        // 23503 = foreign key violation: the ingredient is used by a dish.
        alert(error.code === "23503" ? t("ing_in_use") : t("save_failed"));
        return;
      }
      render();
    };
  });
  $app.querySelectorAll("[data-edit-dish]").forEach((b) => {
    b.onclick = () => go({ name: "dish", id: b.dataset.editDish });
  });
}

/* ---------- basket: record a whole shopping trip ---------- */

function ingSelectHtml(attr, selected) {
  return `<select ${attr}>
    <option value="">${esc(t("select_ingredient"))}</option>
    ${state.ingredients.map((i) => {
      const s = ingredientStats(i);
      const u = unitOf(i);
      const label = `${i.name}${s ? ` (${money(s.perBig)}/${u.big})` : ""}`;
      return `<option value="${i.id}" ${i.id === selected ? "selected" : ""}>${esc(label)}</option>`;
    }).join("")}
  </select>`;
}

function renderBasket(existingDraft) {
  draft = existingDraft || { rows: [{ ingredient_id: "", qty: "", price: "" }] };

  const rowsHtml = draft.rows.map((r, idx) => {
    const ing = findIngredient(r.ingredient_id);
    const suffix = ing ? unitOf(ing).big : t("u_kg");
    return `<tr>
      <td style="min-width:11rem">${ingSelectHtml(`data-b-ing="${idx}"`, r.ingredient_id)}</td>
      <td class="num" style="width:7.2rem">
        <span style="display:inline-flex; align-items:center; gap:0.3rem">
          <input type="number" data-b-qty="${idx}" step="0.001" min="0" inputmode="decimal"
            value="${esc(r.qty)}" aria-label="${esc(t("amount"))}" style="width:4.6rem">
          <span class="muted" style="font-size:0.75rem" id="bSfx${idx}">${esc(suffix)}</span>
        </span>
      </td>
      <td class="num" style="width:5.6rem">
        <input type="number" data-b-price="${idx}" step="0.01" min="0" inputmode="decimal"
          value="${esc(r.price)}" aria-label="${esc(t("price"))}">
      </td>
      <td class="action"><button class="rowlink x" data-b-del="${idx}" aria-label="${esc(t("delete"))}">✕</button></td>
    </tr>`;
  }).join("");

  $app.innerHTML = `
    ${topbar({ back: true })}
    <h2 style="margin:0.2rem 0 0.4rem; font-size:1.15rem">🛒 ${esc(t("new_purchase"))}</h2>
    <p class="muted" style="margin:0 0 1rem; font-size:0.85rem">${esc(t("basket_hint"))}</p>

    <div class="scroll-x">
      <table class="list">
        <thead><tr>
          <th>${esc(t("ingredient"))}</th><th class="num">${esc(t("amount"))}</th>
          <th class="num">${esc(t("price"))} ($)</th><th></th>
        </tr></thead>
        <tbody class="num">${rowsHtml}</tbody>
      </table>
    </div>
    <button class="btn ghost small" id="btnAddRow">${esc(t("add_item"))}</button>

    <div class="calc">
      <div class="caption">${esc(t("basket_total"))}</div>
      <div class="crow num"><span>${esc(t("basket_total"))}</span><strong id="basketTotal">$0.00</strong></div>
    </div>

    <button class="btn" id="btnSave">${esc(t("save_all"))}</button>`;

  wireTopbar();

  const captureDraft = () => {
    $app.querySelectorAll("[data-b-ing]").forEach((sel) => {
      draft.rows[Number(sel.dataset.bIng)].ingredient_id = sel.value;
    });
    $app.querySelectorAll("[data-b-qty]").forEach((inp) => {
      draft.rows[Number(inp.dataset.bQty)].qty = inp.value;
    });
    $app.querySelectorAll("[data-b-price]").forEach((inp) => {
      draft.rows[Number(inp.dataset.bPrice)].price = inp.value;
    });
  };

  const updateTotal = () => {
    const total = draft.rows.reduce((sum, r) => {
      const p = Number(r.price);
      return sum + (p > 0 ? p : 0);
    }, 0);
    document.getElementById("basketTotal").textContent = money(total);
  };

  $app.querySelectorAll("[data-b-ing]").forEach((sel) => {
    sel.onchange = () => {
      const idx = Number(sel.dataset.bIng);
      draft.rows[idx].ingredient_id = sel.value;
      const ing = findIngredient(sel.value);
      document.getElementById(`bSfx${idx}`).textContent = ing ? unitOf(ing).big : t("u_kg");
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
      if (!draft.rows.length) draft.rows.push({ ingredient_id: "", qty: "", price: "" });
      renderBasket({ ...draft });
    };
  });
  document.getElementById("btnAddRow").onclick = () => {
    captureDraft();
    draft.rows.push({ ingredient_id: "", qty: "", price: "" });
    renderBasket({ ...draft });
  };

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const filled = draft.rows.filter((r) => r.ingredient_id || r.qty !== "" || r.price !== "");
    const valid = filled.filter(
      (r) => r.ingredient_id && Number(r.qty) > 0 && Number(r.price) >= 0 && r.price !== ""
    );
    if (!valid.length || valid.length !== filled.length) return alert(t("need_basket"));
    try {
      const { error } = await db.from("purchases").insert(valid.map((r) => ({
        ingredient_id: r.ingredient_id,
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
  draft = existingDraft || {
    name: ing ? ing.name : "",
    unit: ing ? ing.unit || "kg" : "kg",
    pQty: "", pPrice: "", pWaste: "0",
  };
  const u = unitOf({ unit: draft.unit });

  const history = ing ? sortedPurchases(ing) : [];
  const historyRows = history.map((p, idx) => {
    const s = purchaseStats(p);
    return `<tr class="${idx === 0 ? "latest" : ""}">
      <td>${dateShort(p.purchased_at)}</td>
      <td class="num">${fmtQty(p.purchased_kg)} ${u.big}</td>
      <td class="num">${money(p.price_paid)}</td>
      <td class="num">${fmtQty(p.wastage_kg)} ${u.big}</td>
      <td class="num">${s ? money(s.perBig) : "–"}</td>
      <td>${esc(p.entered_by || "")}</td>
      <td class="action"><button class="rowlink x" data-del-purchase="${p.id}" aria-label="${esc(t("delete"))}">✕</button></td>
    </tr>`;
  }).join("");

  $app.innerHTML = `
    ${topbar({ back: true })}
    <h2 style="margin:0.2rem 0 1rem; font-size:1.15rem">
      ${esc(isNew ? t("new_ingredient") : t("edit_ingredient"))}
    </h2>
    <div class="field">
      <label for="ingName">${esc(t("ingredient_name"))}</label>
      <input type="text" id="ingName" value="${esc(draft.name)}">
    </div>
    <div class="field">
      <label for="ingUnit">${esc(t("unit"))}</label>
      <select id="ingUnit">
        <option value="kg" ${draft.unit === "kg" ? "selected" : ""}>${esc(t("unit_kg"))}</option>
        <option value="l" ${draft.unit === "l" ? "selected" : ""}>${esc(t("unit_l"))}</option>
      </select>
    </div>

    <p class="section-label">${esc(isNew ? t("first_purchase") : t("record_purchase"))}</p>
    <div class="row2">
      <div class="field">
        <label for="pQty">${esc(t("purchased_lbl"))} (${esc(u.big)})</label>
        <input type="number" id="pQty" step="0.001" min="0" inputmode="decimal" value="${esc(draft.pQty)}">
      </div>
      <div class="field">
        <label for="pPrice">${esc(t("price_paid"))}</label>
        <input type="number" id="pPrice" step="0.01" min="0" inputmode="decimal" value="${esc(draft.pPrice)}">
      </div>
    </div>
    <div class="field">
      <label for="pWaste">${esc(t("wastage_full"))} (${esc(u.big)}) — ${esc(t("wastage_hint"))}</label>
      <input type="number" id="pWaste" step="0.001" min="0" inputmode="decimal" value="${esc(draft.pWaste)}">
    </div>

    <div class="calc">
      <div class="caption">${esc(t("auto_calc"))}</div>
      <div class="crow num"><span>${esc(t("usable_weight"))}</span><span id="calcUsable">–</span></div>
      <div class="crow num"><span>${esc(t("price_per"))} ${esc(u.big)}</span><strong id="calcPerBig">–</strong></div>
      <div class="crow num"><span>${esc(t("price_per"))} ${esc(u.small)}</span><strong id="calcPerSmall">–</strong></div>
    </div>

    ${isNew ? "" : `<button class="btn ghost small" id="btnAddPurchase">${esc(t("add_purchase"))}</button>

    <p class="section-label">${esc(t("purchase_history"))}</p>
    <div class="scroll-x">
      ${history.length ? `<table class="list">
        <thead><tr>
          <th>${esc(t("date"))}</th><th class="num">${esc(t("purchased"))}</th>
          <th class="num">${esc(t("price"))}</th><th class="num">${esc(t("wastage"))}</th>
          <th class="num">${esc(t("unit_price"))}</th><th>${esc(t("by"))}</th><th></th>
        </tr></thead>
        <tbody class="num">${historyRows}</tbody>
      </table>` : `<p class="empty">${esc(t("no_purchases"))}</p>`}
    </div>`}

    <button class="btn" id="btnSave">${esc(t("save"))}</button>
    ${isNew ? "" : `<button class="btn danger-link" id="btnDelete">${esc(t("delete_ingredient"))}</button>
    <p class="meta-line num">${esc(ing.updated_by || "")} · ${dateShort(ing.updated_at)}</p>`}`;

  wireTopbar();

  const inputs = ["pQty", "pPrice", "pWaste"].map((i) => document.getElementById(i));
  const captureDraft = () => {
    draft.name = document.getElementById("ingName").value;
    draft.unit = document.getElementById("ingUnit").value;
    draft.pQty = inputs[0].value;
    draft.pPrice = inputs[1].value;
    draft.pWaste = inputs[2].value;
  };

  const updateCalc = () => {
    const s = purchaseStats({
      purchased_kg: inputs[0].value, price_paid: inputs[1].value, wastage_kg: inputs[2].value,
    });
    document.getElementById("calcUsable").textContent = s ? `${fmtQty(s.usable)} ${u.big}` : "–";
    document.getElementById("calcPerBig").textContent = s ? money(s.perBig) : "–";
    document.getElementById("calcPerSmall").textContent = s ? money(s.perSmall, 4) : "–";
  };
  inputs.forEach((i) => (i.oninput = updateCalc));

  // Changing the unit relabels the form — re-render, keeping typed values.
  document.getElementById("ingUnit").onchange = () => {
    captureDraft();
    renderIngredient(id, { ...draft });
  };

  const readPurchase = ({ required }) => {
    const purchased = inputs[0].value.trim();
    const price = inputs[1].value.trim();
    const waste = inputs[2].value.trim();
    if (!purchased && !price) {
      if (required) { alert(t("need_purchase")); return { invalid: true }; }
      return { empty: true };
    }
    const p = { purchased_kg: Number(purchased), price_paid: Number(price), wastage_kg: Number(waste || 0) };
    if (!(p.purchased_kg > 0) || p.price_paid < 0 || isNaN(p.price_paid) || p.wastage_kg < 0) {
      alert(t("bad_numbers")); return { invalid: true };
    }
    if (p.wastage_kg >= p.purchased_kg) { alert(t("wastage_too_big")); return { invalid: true }; }
    return { p };
  };

  const insertPurchase = async (ingredientId, p) => {
    const { error } = await db.from("purchases").insert({
      ingredient_id: ingredientId, ...p, entered_by: userName(),
    });
    if (error) throw error;
  };

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const name = draft.name.trim();
    if (!name) return alert(t("need_name"));
    try {
      if (isNew) {
        const r = readPurchase({ required: false });
        if (r.invalid) return;
        const { data, error } = await db.from("ingredients")
          .insert({ name, unit: draft.unit, updated_by: userName() }).select().single();
        if (error) throw error;
        if (r.p) await insertPurchase(data.id, r.p);
      } else {
        const r = readPurchase({ required: false });
        if (r.invalid) return;
        const { error } = await db.from("ingredients")
          .update({ name, unit: draft.unit, updated_at: new Date().toISOString(), updated_by: userName() })
          .eq("id", ing.id);
        if (error) throw error;
        if (r.p) await insertPurchase(ing.id, r.p);
      }
      go({ name: "home" });
    } catch (e) {
      console.error(e); alert(t("save_failed"));
    }
  };

  if (!isNew) {
    document.getElementById("btnAddPurchase").onclick = async () => {
      const r = readPurchase({ required: true });
      if (!r.p) return;
      try {
        await insertPurchase(ing.id, r.p);
        go({ name: "ingredient", id: ing.id });
      } catch (e) { console.error(e); alert(t("save_failed")); }
    };

    document.getElementById("btnDelete").onclick = async () => {
      if (!confirm(t("confirm_delete"))) return;
      const { error } = await db.from("ingredients").delete().eq("id", ing.id);
      if (error) {
        // 23503 = foreign key violation: the ingredient is referenced by a dish.
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

/* ---------- dish editor ---------- */

function renderDish(id, existingDraft) {
  const dish = id ? state.dishes.find((d) => d.id === id) : null;
  if (id && !dish) return go({ name: "home" });
  const isNew = !dish;
  draft = existingDraft || {
    name: dish ? dish.name : "",
    selling_price: dish && dish.selling_price != null ? String(dish.selling_price) : "",
    rows: dish && (dish.dish_ingredients || []).length
      ? dish.dish_ingredients.map((r) => ({ ingredient_id: r.ingredient_id, grams: String(r.grams) }))
      : [{ ingredient_id: "", grams: "" }],
  };

  const rowsHtml = draft.rows.map((r, idx) => {
    const ing = findIngredient(r.ingredient_id);
    const suffix = ing ? unitOf(ing).small : t("u_g");
    return `<tr>
      <td style="min-width:11rem">${ingSelectHtml(`data-row-ing="${idx}"`, r.ingredient_id)}</td>
      <td class="num" style="width:7rem">
        <span style="display:inline-flex; align-items:center; gap:0.3rem">
          <input type="number" data-row-g="${idx}" step="1" min="0" inputmode="numeric"
            value="${esc(r.grams)}" aria-label="${esc(t("amount"))}" style="width:4.2rem">
          <span class="muted" style="font-size:0.75rem" id="dSfx${idx}">${esc(suffix)}</span>
        </span>
      </td>
      <td class="num" id="rowCost${idx}" style="width:5rem">–</td>
      <td class="action"><button class="rowlink x" data-row-del="${idx}" aria-label="${esc(t("delete"))}">✕</button></td>
    </tr>`;
  }).join("");

  $app.innerHTML = `
    ${topbar({ back: true })}
    <h2 style="margin:0.2rem 0 1rem; font-size:1.15rem">
      ${esc(isNew ? t("new_dish") : t("edit_dish"))}
    </h2>
    <div class="field">
      <label for="dishName">${esc(t("dish_name"))}</label>
      <input type="text" id="dishName" value="${esc(draft.name)}">
    </div>

    <p class="section-label">${esc(t("dish_ingredients"))}</p>
    <div class="scroll-x">
      <table class="list">
        <thead><tr>
          <th>${esc(t("ingredient"))}</th><th class="num">${esc(t("amount"))}</th>
          <th class="num">${esc(t("cost"))}</th><th></th>
        </tr></thead>
        <tbody class="num">${rowsHtml}</tbody>
      </table>
    </div>
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
    <p class="meta-line num">${esc(dish.updated_by || "")} · ${dateShort(dish.updated_at)}</p>`}`;

  wireTopbar();

  const captureDraft = () => {
    draft.name = document.getElementById("dishName").value;
    draft.selling_price = document.getElementById("dishSell").value;
  };

  const updateTotals = () => {
    draft.rows.forEach((r, idx) => {
      const s = r.ingredient_id && ingredientStats(findIngredient(r.ingredient_id));
      const amount = Number(r.grams);
      const cell = document.getElementById(`rowCost${idx}`);
      if (cell) cell.textContent = s && amount > 0 ? money(amount * s.perSmall) : "–";
    });
    const c = dishCost(draft.rows);
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

  $app.querySelectorAll("[data-row-ing]").forEach((sel) => {
    sel.onchange = () => {
      const idx = Number(sel.dataset.rowIng);
      draft.rows[idx].ingredient_id = sel.value;
      const ing = findIngredient(sel.value);
      document.getElementById(`dSfx${idx}`).textContent = ing ? unitOf(ing).small : t("u_g");
      updateTotals();
    };
  });
  $app.querySelectorAll("[data-row-g]").forEach((inp) => {
    inp.oninput = () => { draft.rows[Number(inp.dataset.rowG)].grams = inp.value; updateTotals(); };
  });
  $app.querySelectorAll("[data-row-del]").forEach((b) => {
    b.onclick = () => {
      captureDraft();
      draft.rows.splice(Number(b.dataset.rowDel), 1);
      if (!draft.rows.length) draft.rows.push({ ingredient_id: "", grams: "" });
      renderDish(id, { ...draft });
    };
  });
  document.getElementById("btnAddRow").onclick = () => {
    captureDraft();
    draft.rows.push({ ingredient_id: "", grams: "" });
    renderDish(id, { ...draft });
  };
  document.getElementById("dishSell").oninput = updateTotals;

  document.getElementById("btnSave").onclick = async () => {
    captureDraft();
    const name = draft.name.trim();
    if (!name) return alert(t("need_name"));
    // A dish may be saved without a recipe yet (e.g. imported from the menu).
    const rows = draft.rows
      .filter((r) => r.ingredient_id && Number(r.grams) > 0)
      .map((r) => ({ ingredient_id: r.ingredient_id, grams: Number(r.grams) }));
    const sellRaw = draft.selling_price.trim();
    const selling_price = sellRaw === "" ? null : Number(sellRaw);

    try {
      let dishId = id;
      const fields = {
        name, selling_price,
        updated_at: new Date().toISOString(), updated_by: userName(),
      };
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
