// Lê o pitch HTML renderizado (1920x1080) e exporta cada slide como uma lista de
// elementos com posição, cor e tipografia (layout.json). Ícones SVG e QR viram PNG.
// Uso: node pitch/pptx/extrair.cjs http://127.0.0.1:8765/pitch/ <pasta-saida>
const path = require("path");
const fs = require("fs");
const { chromium } = require(require("child_process").execSync("npm root -g").toString().trim() + "/playwright");

const URL = process.argv[2] || "http://127.0.0.1:8765/pitch/";
const OUT = process.argv[3] || path.join(__dirname, "build");

(async () => {
  fs.mkdirSync(path.join(OUT, "raster"), { recursive: true });
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 }, deviceScaleFactor: 3 });
  await page.goto(URL);
  await page.waitForTimeout(800);
  await page.addStyleTag({ content: ".slide{transition:none!important}.ajuda,.barra,.notas{display:none!important}" });
  const total = await page.evaluate(() => document.querySelectorAll(".slide").length);
  const slides = [];
  for (let i = 0; i < total; i++) {
    const dados = await page.evaluate((idx) => {
      document.querySelectorAll(".slide").forEach((s, k) => s.classList.toggle("on", k === idx));
      const slide = document.querySelectorAll(".slide")[idx];
      const S = slide.getBoundingClientRect();
      const itens = [];
      let rid = 0;
      const cor = (c) => {
        const m = /rgba?\(([^)]+)\)/.exec(c || "");
        if (!m) return null;
        const p = m[1].split(",").map((x) => parseFloat(x));
        const a = p.length === 4 ? p[3] : 1;
        if (a === 0) return null;
        return { hex: p.slice(0, 3).map((v) => Math.round(v).toString(16).padStart(2, "0")).join("").toUpperCase(), a };
      };
      const rel = (r) => ({ x: r.left - S.left, y: r.top - S.top, w: r.width, h: r.height });
      const visivel = (el) => { const cs = getComputedStyle(el); return cs.display !== "none" && cs.visibility !== "hidden" && parseFloat(cs.opacity) > 0; };
      const fonte = (cs) => ({
        fam: /Lexend/.test(cs.fontFamily) ? "Lexend" : "Source",
        peso: parseInt(cs.fontWeight, 10), tam: parseFloat(cs.fontSize), cor: cor(cs.color),
        caixa: cs.textTransform === "uppercase", esp: parseFloat(cs.letterSpacing) || 0,
      });
      // Tabelas com cantos arredondados: as células nos cantos herdam o arredondamento
      const cantoDe = (el, r) => {
        if (el.tagName === "TABLE") return null;
        const t = el.closest("table"); if (!t) return null;
        const rt = parseFloat(getComputedStyle(t).borderTopLeftRadius); if (!rt) return null;
        const T = t.getBoundingClientRect(), e = 1.5;
        const topo = Math.abs(r.top - T.top) < e, base = Math.abs(r.bottom - T.bottom) < e;
        const esq = Math.abs(r.left - T.left) < e, dir = Math.abs(r.right - T.right) < e;
        const c = topo && dir ? "tr" : topo && esq ? "tl" : base && dir ? "br" : base && esq ? "bl" : null;
        return c ? { canto: c, raio: rt } : null;
      };
      function caixa(el, cs, r) {
        const fundo = cor(cs.backgroundColor);
        const lados = ["Top", "Right", "Bottom", "Left"].map((l) => ({
          l, w: cs[`border${l}Style`] !== "none" ? parseFloat(cs[`border${l}Width`]) || 0 : 0, c: cor(cs[`border${l}Color`]) }));
        const uniforme = lados.every((b) => b.w === lados[0].w && b.w > 0 && (b.c || {}).hex === (lados[0].c || {}).hex);
        let borda = uniforme && lados[0].c ? { w: lados[0].w, cor: lados[0].c } : null;
        let sombra = null;
        const bs = cs.boxShadow;
        if (bs && bs !== "none") {
          const anel = /(rgba?\([^)]+\)) 0px 0px 0px (\d+(?:\.\d+)?)px/.exec(bs);
          if (anel) borda = { w: parseFloat(anel[2]), cor: cor(anel[1]), fora: true };
          if (/0px 12px 32px/.test(bs)) sombra = { blur: 32, dist: 12, alfa: 0.07 };
        }
        if (fundo || borda) {
          const raio = Math.min(parseFloat(cs.borderTopLeftRadius) || 0, r.width / 2, r.height / 2);
          itens.push({ tipo: "rect", ...rel(r), fundo, borda, raio, sombra, canto: cantoDe(el, r) });
        }
        // bordas de um lado só viram filetes
        if (!uniforme) for (const b of lados) {
          if (!b.w || !b.c) continue;
          const q = b.l === "Top" ? { left: r.left, top: r.top, width: r.width, height: b.w }
            : b.l === "Bottom" ? { left: r.left, top: r.bottom - b.w, width: r.width, height: b.w }
            : b.l === "Left" ? { left: r.left, top: r.top, width: b.w, height: r.height }
            : { left: r.right - b.w, top: r.top, width: b.w, height: r.height };
          itens.push({ tipo: "rect", ...rel(q), fundo: b.c, raio: 0 });
        }
        // pseudo-elemento ::before (marcadores das listas)
        const b = getComputedStyle(el, "::before");
        if (b.content && b.content !== "none" && b.display !== "none" && el.tagName === "LI") {
          const bwb = b.borderTopStyle !== "none" ? parseFloat(b.borderTopWidth) || 0 : 0;
          // "*{box-sizing:border-box}" não pega pseudo-elementos: a borda soma à largura
          const extra = b.boxSizing === "content-box" ? 2 * bwb + 2 * (parseFloat(b.paddingTop) || 0) : 0;
          const w = parseFloat(b.width) + extra, h = parseFloat(b.height) + extra, mt = parseFloat(b.marginTop) || 0;
          itens.push({ tipo: "rect", ...rel({ left: r.left, top: r.top + mt, width: w, height: h }), fundo: cor(b.backgroundColor),
            borda: bwb ? { w: bwb, cor: cor(b.borderTopColor) } : null, raio: Math.min(parseFloat(b.borderTopLeftRadius) || 0, w / 2, h / 2) });
        }
      }
      function textoDe(el) {
        const runs = []; const pendentes = [];
        const nos = [];
        function rec(n) {
          for (const c of n.childNodes) {
            if (c.nodeType === 3) {
              const t = c.textContent.replace(/\s+/g, " ");
              if (t) { runs.push({ t, ...fonte(getComputedStyle(c.parentElement)) }); nos.push(c); }
            } else if (c.nodeType === 1 && visivel(c)) {
              const cs = getComputedStyle(c);
              if (c.tagName === "BR") { runs.push({ quebra: true }); continue; }
              if (c.querySelector("svg,img") || c.tagName === "svg" || c.tagName === "IMG" || cs.backgroundColor !== "rgba(0, 0, 0, 0)" && cs.display !== "inline") { pendentes.push(c); continue; }
              // blocos filhos viram caixas de texto próprias (posição e entrelinha exatas)
              if (/^(block|flex|grid|list-item)$/.test(cs.display)) { pendentes.push(c); continue; }
              rec(c);
            }
          }
        }
        rec(el);
        // aparar espaços nas pontas e entre quebras
        const limpos = [];
        for (const r of runs) {
          if (r.quebra) { if (limpos.length && !limpos[limpos.length - 1].quebra) limpos.push(r); continue; }
          let t = r.t;
          const ant = limpos[limpos.length - 1];
          if (!ant || ant.quebra || /\s$/.test(ant.t)) t = t.replace(/^\s+/, "");
          if (t) limpos.push({ ...r, t });
        }
        while (limpos.length && limpos[limpos.length - 1].quebra) limpos.pop();
        if (limpos.length) limpos[limpos.length - 1].t = limpos[limpos.length - 1].t.replace(/\s+$/, "");
        // retângulo que o texto ocupa
        let L = 1e9, T = 1e9, R = -1e9, B = -1e9; let linhas = 0;
        for (const n of nos) {
          const rg = document.createRange(); rg.selectNodeContents(n);
          for (const q of rg.getClientRects()) { if (!q.width) continue; L = Math.min(L, q.left); T = Math.min(T, q.top); R = Math.max(R, q.right); B = Math.max(B, q.bottom); }
        }
        const cs = getComputedStyle(el), r = el.getBoundingClientRect();
        const cl = r.left + parseFloat(cs.paddingLeft) + parseFloat(cs.borderLeftWidth);
        const cr = r.right - parseFloat(cs.paddingRight) - parseFloat(cs.borderRightWidth);
        let alinh = /center/.test(cs.textAlign) ? "c" : /right|end/.test(cs.textAlign) ? "r" : "l";
        if (alinh === "l" && /flex|grid/.test(cs.display) && L - cl > 2 && Math.abs((L - cl) - (cr - R)) < 3) alinh = "c";
        const lh = cs.lineHeight === "normal" ? parseFloat(cs.fontSize) * 1.2 : parseFloat(cs.lineHeight);
        return { runs: limpos, caixaTexto: { L, T, R, B }, cl, cr, alinh, lh, pendentes };
      }
      function walk(el) {
        if (!visivel(el)) return;
        const cs = getComputedStyle(el), r = el.getBoundingClientRect();
        if (el !== slide) caixa(el, cs, r);
        if (el.tagName === "IMG") {
          const f = (cs.filter || "").includes("drop-shadow");
          itens.push({ tipo: "img", ...rel(r), src: el.getAttribute("src"), sombra: f });
          return;
        }
        if (el.tagName === "svg") {
          const id = `r${idx}_${rid++}`; el.setAttribute("data-rid", id);
          itens.push({ tipo: "raster", ...rel(r), id });
          return;
        }
        const temTexto = [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim());
        if (temTexto) {
          const tx = textoDe(el);
          if (tx.runs.length) {
            const { L, T, R, B } = tx.caixaTexto;
            let x, w;
            if (tx.alinh === "l") { x = L; w = Math.max(R, tx.cr) - L; }
            else if (tx.alinh === "c") { x = Math.min(L, tx.cl); w = Math.max(R, tx.cr) - x; }
            else { x = Math.min(L, tx.cl); w = R - x; }
            itens.push({ tipo: "texto", x: x - S.left, y: T - S.top, w, h: B - T, runs: tx.runs, alinh: tx.alinh, lh: tx.lh });
          }
          tx.pendentes.forEach(walk);
          return;
        }
        for (const c of el.children) walk(c);
      }
      walk(slide);
      return { fundo: cor(getComputedStyle(slide).backgroundColor), notas: slide.dataset.notas || "", itens };
    }, i);
    // rasteriza os SVGs marcados
    for (const it of dados.itens.filter((x) => x.tipo === "raster")) {
      const arq = path.join(OUT, "raster", `${it.id}.png`);
      await page.locator(`[data-rid="${it.id}"]`).screenshot({ path: arq, omitBackground: true });
      it.arquivo = arq;
    }
    slides.push(dados);
  }
  fs.writeFileSync(path.join(OUT, "layout.json"), JSON.stringify(slides, null, 1));
  console.log(`${total} slides, ${slides.reduce((a, s) => a + s.itens.length, 0)} elementos`);
  await browser.close();
})();
