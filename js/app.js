/* Arifood — kitchen costing app.
 * Views: login → home (ingredient + dish overviews) → add/edit ingredient,
 * add/edit dish. All data lives in a shared Supabase database; every
 * logged-in team member reads and writes the same rows.
 */

let db = null;
let session = null;
const state = {
  ingredients: [], // each with .purchases[]
  dishes: [],      // each with .dish_ingredients[]
  view: { name: "home" },
};
let draft = null; // working copy for the currently open editor

const $app = document.getElementById("app");

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

function kg(n) {
  if (n == null || !isFinite(n)) return "–";
  return Number(n).toFixed(2).replace(/\.?0+$/, (m) => (m === ".00" ? "" : m)) + " kg";
}

function dateShort(iso) {
  const d = new Date(iso);
  return d.toLocaleDateString(LANG === "th" ? "th-TH" : "en-AU", {
    day: "numeric", month: "short", year: "2-digit",
  });
}

function userName() {
  if (!session) return "";
  const meta = session.user.user_metadata || {};
  return meta.display_name || meta.full_name || session.user.email.split("@")[0];
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
  const perKg = Number(p.price_paid) / usable;
  return { usable, perKg, perG: perKg / 1000 };
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
  let complete = true;
  for (const r of rows) {
    const s = r.ingredient_id && ingredientStats(findIngredient(r.ingredient_id));
    const grams = Number(r.grams);
    if (!s || !(grams > 0)) { complete = false; continue; }
    total += grams * s.perG;
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
}

/* ---------- navigation ---------- */

async function go(view) {
  state.view = view;
  await render();
}

async function render() {
  if (!session) return renderLogin();
  try {
    await loadData();
  } catch (e) {
    console.error(e);
    $app.innerHTML =
      `<div class="topbar"><span class="brand">ARIFOOD</span></div>` +
      `<div class="error-box bad">${esc(t("load_failed"))}</div>`;
    return;
  }
  const v = state.view;
  if (v.name === "ingredient") renderIngredient(v.id);
  else if (v.name === "dish") renderDish(v.id);
  else renderHome();
}

function topbar({ back } = {}) {
  return `<div class="topbar">
    <span>
      ${back ? `<button class="back" id="btnBack">‹ ${esc(t("home"))}</button>` : ""}
      <span class="brand">ARIFOOD</span>
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
        <div class="name">ARIFOOD</div>
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
    return `<tr>
      <td>${esc(ing.name)}</td>
      <td class="num">${s ? kg(s.usable) : "–"}</td>
      <td class="num">${s ? s.perKg.toFixed(2) : "–"}</td>
      <td class="action"><button class="rowlink" data-edit-ing="${ing.id}">${esc(t("edit"))}</button></td>
    </tr>`;
  }).join("");

  const dishRows = state.dishes.map((d) => {
    const c = dishCost(d.dish_ingredients || []);
    const sell = d.selling_price != null ? Number(d.selling_price) : null;
    const gpPct = sell > 0 ? ((sell - c.total) / sell) * 100 : null;
    return `<tr>
      <td>${esc(d.name)}</td>
      <td class="num">${money(c.total)}${c.complete ? "" : " *"}</td>
      <td class="num">${gpPct == null ? "–" : gpPct.toFixed(0) + "%"}</td>
      <td class="action"><button class="rowlink" data-edit-dish="${d.id}">${esc(t("edit"))}</button></td>
    </tr>`;
  }).join("");

  $app.innerHTML = `
    ${topbar()}
    <div class="card">
      <div class="card-head">
        <span class="card-title">${esc(t("ingredients"))}</span>
        <span class="count num">${state.ingredients.length} ${esc(t("items"))}</span>
      </div>
      <div class="scroll-x">
        ${state.ingredients.length ? `<table class="list">
          <thead><tr>
            <th>${esc(t("ingredient"))}</th><th class="num">${esc(t("usable"))}</th>
            <th class="num">${esc(t("per_kg"))}</th><th></th>
          </tr></thead>
          <tbody class="num">${ingRows}</tbody>
        </table>` : `<p class="empty">${esc(t("no_ingredients"))}</p>`}
      </div>
      <button class="btn small" id="btnAddIng">${esc(t("add_ingredient"))}</button>
    </div>

    <div class="card">
      <div class="card-head">
        <span class="card-title">${esc(t("dishes"))}</span>
        <span class="count num">${state.dishes.length} ${esc(t("items"))}</span>
      </div>
      <div class="scroll-x">
        ${state.dishes.length ? `<table class="list">
          <thead><tr>
            <th>${esc(t("dish"))}</th><th class="num">${esc(t("cost"))}</th>
            <th class="num">${esc(t("gp"))}</th><th></th>
          </tr></thead>
          <tbody class="num">${dishRows}</tbody>
        </table>` : `<p class="empty">${esc(t("no_dishes"))}</p>`}
      </div>
      <button class="btn small" id="btnAddDish">${esc(t("add_dish"))}</button>
    </div>`;

  wireTopbar();
  document.getElementById("btnAddIng").onclick = () => go({ name: "ingredient", id: null });
  document.getElementById("btnAddDish").onclick = () => go({ name: "dish", id: null });
  $app.querySelectorAll("[data-edit-ing]").forEach((b) => {
    b.onclick = () => go({ name: "ingredient", id: b.dataset.editIng });
  });
  $app.querySelectorAll("[data-edit-dish]").forEach((b) => {
    b.onclick = () => go({ name: "dish", id: b.dataset.editDish });
  });
}

/* ---------- ingredient editor ---------- */

function renderIngredient(id) {
  const ing = id ? findIngredient(id) : null;
  if (id && !ing) return go({ name: "home" });
  const isNew = !ing;
  draft = { name: ing ? ing.name : "" };

  const history = ing ? sortedPurchases(ing) : [];
  const historyRows = history.map((p, idx) => {
    const s = purchaseStats(p);
    return `<tr class="${idx === 0 ? "latest" : ""}">
      <td>${dateShort(p.purchased_at)}</td>
      <td class="num">${kg(p.purchased_kg)}</td>
      <td class="num">${money(p.price_paid)}</td>
      <td class="num">${kg(p.wastage_kg)}</td>
      <td class="num">${s ? s.perKg.toFixed(2) : "–"}</td>
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

    <p class="section-label">${esc(isNew ? t("first_purchase") : t("record_purchase"))}</p>
    <div class="row2">
      <div class="field">
        <label for="pKg">${esc(t("purchased_kg"))}</label>
        <input type="number" id="pKg" step="0.001" min="0" inputmode="decimal">
      </div>
      <div class="field">
        <label for="pPrice">${esc(t("price_paid"))}</label>
        <input type="number" id="pPrice" step="0.01" min="0" inputmode="decimal">
      </div>
    </div>
    <div class="field">
      <label for="pWaste">${esc(t("wastage_kg"))} — ${esc(t("wastage_hint"))}</label>
      <input type="number" id="pWaste" step="0.001" min="0" inputmode="decimal" value="0">
    </div>

    <div class="calc">
      <div class="caption">${esc(t("auto_calc"))}</div>
      <div class="crow num"><span>${esc(t("usable_weight"))}</span><span id="calcUsable">–</span></div>
      <div class="crow num"><span>${esc(t("price_per_kg"))}</span><strong id="calcPerKg">–</strong></div>
      <div class="crow num"><span>${esc(t("price_per_gram"))}</span><strong id="calcPerG">–</strong></div>
    </div>

    ${isNew ? "" : `<button class="btn ghost small" id="btnAddPurchase">${esc(t("add_purchase"))}</button>

    <p class="section-label">${esc(t("purchase_history"))}</p>
    <div class="scroll-x">
      ${history.length ? `<table class="list">
        <thead><tr>
          <th>${esc(t("date"))}</th><th class="num">${esc(t("purchased"))}</th>
          <th class="num">${esc(t("price"))}</th><th class="num">${esc(t("wastage"))}</th>
          <th class="num">${esc(t("per_kg"))}</th><th>${esc(t("by"))}</th><th></th>
        </tr></thead>
        <tbody class="num">${historyRows}</tbody>
      </table>` : `<p class="empty">${esc(t("no_purchases"))}</p>`}
    </div>`}

    <button class="btn" id="btnSave">${esc(t("save"))}</button>
    ${isNew ? "" : `<button class="btn danger-link" id="btnDelete">${esc(t("delete_ingredient"))}</button>
    <p class="meta-line num">${esc(ing.updated_by || "")} · ${dateShort(ing.updated_at)}</p>`}`;

  wireTopbar();

  const inputs = ["pKg", "pPrice", "pWaste"].map((i) => document.getElementById(i));
  const updateCalc = () => {
    const s = purchaseStats({
      purchased_kg: inputs[0].value, price_paid: inputs[1].value, wastage_kg: inputs[2].value,
    });
    document.getElementById("calcUsable").textContent = s ? kg(s.usable) : "–";
    document.getElementById("calcPerKg").textContent = s ? money(s.perKg) : "–";
    document.getElementById("calcPerG").textContent = s ? money(s.perG, 4) : "–";
  };
  inputs.forEach((i) => (i.oninput = updateCalc));

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
    const name = document.getElementById("ingName").value.trim();
    if (!name) return alert(t("need_name"));
    try {
      if (isNew) {
        const r = readPurchase({ required: true });
        if (!r.p) return;
        const { data, error } = await db.from("ingredients")
          .insert({ name, updated_by: userName() }).select().single();
        if (error) throw error;
        await insertPurchase(data.id, r.p);
      } else {
        const r = readPurchase({ required: false });
        if (r.invalid) return;
        const { error } = await db.from("ingredients")
          .update({ name, updated_at: new Date().toISOString(), updated_by: userName() })
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
}

/* ---------- dish editor ---------- */

function renderDish(id) {
  const dish = id ? state.dishes.find((d) => d.id === id) : null;
  if (id && !dish) return go({ name: "home" });
  const isNew = !dish;
  draft = {
    name: dish ? dish.name : "",
    selling_price: dish && dish.selling_price != null ? String(dish.selling_price) : "",
    rows: dish
      ? (dish.dish_ingredients || []).map((r) => ({ ingredient_id: r.ingredient_id, grams: String(r.grams) }))
      : [{ ingredient_id: "", grams: "" }],
  };

  const options = (selected) =>
    `<option value="">${esc(t("select_ingredient"))}</option>` +
    state.ingredients.map((i) => {
      const s = ingredientStats(i);
      const label = `${i.name}${s ? ` (${money(s.perKg)}/kg)` : ` (${t("no_price_yet")})`}`;
      return `<option value="${i.id}" ${i.id === selected ? "selected" : ""}>${esc(label)}</option>`;
    }).join("");

  const rowsHtml = draft.rows.map((r, idx) => `<tr>
    <td style="min-width:11rem"><select data-row-ing="${idx}">${options(r.ingredient_id)}</select></td>
    <td class="num" style="width:6rem">
      <input type="number" data-row-g="${idx}" step="1" min="0" inputmode="numeric"
        value="${esc(r.grams)}" aria-label="${esc(t("grams"))}">
    </td>
    <td class="num" id="rowCost${idx}" style="width:5rem">–</td>
    <td class="action"><button class="rowlink x" data-row-del="${idx}" aria-label="${esc(t("delete"))}">✕</button></td>
  </tr>`).join("");

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
      <table class="list" id="rowsTable">
        <thead><tr>
          <th>${esc(t("ingredient"))}</th><th class="num">${esc(t("grams"))}</th>
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

  const updateTotals = () => {
    draft.rows.forEach((r, idx) => {
      const s = r.ingredient_id && ingredientStats(findIngredient(r.ingredient_id));
      const grams = Number(r.grams);
      const cell = document.getElementById(`rowCost${idx}`);
      cell.textContent = s && grams > 0 ? money(grams * s.perG) : "–";
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

  const rerenderRows = () => {
    // Re-render the whole editor but keep current field values in draft.
    draft.name = document.getElementById("dishName").value;
    draft.selling_price = document.getElementById("dishSell").value;
    const saved = { ...draft };
    renderDishFromDraft(id, saved);
  };

  $app.querySelectorAll("[data-row-ing]").forEach((sel) => {
    sel.onchange = () => { draft.rows[Number(sel.dataset.rowIng)].ingredient_id = sel.value; updateTotals(); };
  });
  $app.querySelectorAll("[data-row-g]").forEach((inp) => {
    inp.oninput = () => { draft.rows[Number(inp.dataset.rowG)].grams = inp.value; updateTotals(); };
  });
  $app.querySelectorAll("[data-row-del]").forEach((b) => {
    b.onclick = () => { draft.rows.splice(Number(b.dataset.rowDel), 1); rerenderRows(); };
  });
  document.getElementById("btnAddRow").onclick = () => {
    draft.rows.push({ ingredient_id: "", grams: "" });
    rerenderRows();
  };
  document.getElementById("dishSell").oninput = updateTotals;

  document.getElementById("btnSave").onclick = async () => {
    const name = document.getElementById("dishName").value.trim();
    if (!name) return alert(t("need_name"));
    const rows = draft.rows
      .filter((r) => r.ingredient_id && Number(r.grams) > 0)
      .map((r) => ({ ingredient_id: r.ingredient_id, grams: Number(r.grams) }));
    if (!rows.length) return alert(t("need_rows"));
    const sellRaw = document.getElementById("dishSell").value.trim();
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
      const ins = await db.from("dish_ingredients")
        .insert(rows.map((r) => ({ dish_id: dishId, ...r })));
      if (ins.error) throw ins.error;
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

// Re-enter the dish editor with an explicit draft (used after row add/remove
// so typed-but-unsaved values survive the re-render).
function renderDishFromDraft(id, savedDraft) {
  renderDish(id);
  draft.name = savedDraft.name;
  draft.selling_price = savedDraft.selling_price;
  draft.rows = savedDraft.rows.length ? savedDraft.rows : [{ ingredient_id: "", grams: "" }];
  document.getElementById("dishName").value = draft.name;
  document.getElementById("dishSell").value = draft.selling_price;
  // Rebuild row markup from the restored draft.
  const tbody = document.querySelector("#rowsTable tbody");
  const options = (selected) =>
    `<option value="">${esc(t("select_ingredient"))}</option>` +
    state.ingredients.map((i) => {
      const s = ingredientStats(i);
      const label = `${i.name}${s ? ` (${money(s.perKg)}/kg)` : ` (${t("no_price_yet")})`}`;
      return `<option value="${i.id}" ${i.id === selected ? "selected" : ""}>${esc(label)}</option>`;
    }).join("");
  tbody.innerHTML = draft.rows.map((r, idx) => `<tr>
    <td style="min-width:11rem"><select data-row-ing="${idx}">${options(r.ingredient_id)}</select></td>
    <td class="num" style="width:6rem">
      <input type="number" data-row-g="${idx}" step="1" min="0" inputmode="numeric"
        value="${esc(r.grams)}" aria-label="${esc(t("grams"))}">
    </td>
    <td class="num" id="rowCost${idx}" style="width:5rem">–</td>
    <td class="action"><button class="rowlink x" data-row-del="${idx}" aria-label="${esc(t("delete"))}">✕</button></td>
  </tr>`).join("");
  // Re-wire row handlers against the restored rows.
  const updateEvent = new Event("input");
  tbody.querySelectorAll("[data-row-ing]").forEach((sel) => {
    sel.onchange = () => {
      draft.rows[Number(sel.dataset.rowIng)].ingredient_id = sel.value;
      document.getElementById("dishSell").dispatchEvent(updateEvent);
    };
  });
  tbody.querySelectorAll("[data-row-g]").forEach((inp) => {
    inp.oninput = () => {
      draft.rows[Number(inp.dataset.rowG)].grams = inp.value;
      document.getElementById("dishSell").dispatchEvent(updateEvent);
    };
  });
  tbody.querySelectorAll("[data-row-del]").forEach((b) => {
    b.onclick = () => {
      draft.rows.splice(Number(b.dataset.rowDel), 1);
      renderDishFromDraft(id, { ...draft });
    };
  });
  document.getElementById("dishSell").dispatchEvent(updateEvent);
}

/* ---------- boot ---------- */

function renderConfigMissing() {
  $app.innerHTML = `
    <div class="login-wrap">
      <div class="login-logo">
        <div class="name">ARIFOOD</div>
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
