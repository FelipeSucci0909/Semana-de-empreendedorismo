// Webhook do WhatsApp (Twilio): a mesma Zélia do app, conversando pelo WhatsApp.
//
// No Twilio: Messaging > Try it out > Send a WhatsApp message > Sandbox settings >
// "When a message comes in" = https://SEU-SITE.vercel.app/api/whatsapp (POST).
//
// Variáveis no Vercel:
//   ANTHROPIC_API_KEY                      (obrigatória) IA da Zélia
//   TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN  (recomendadas) respostas sem limite de tempo + checagem de assinatura
//   KV_REST_API_URL/KV_REST_API_TOKEN ou UPSTASH_REDIS_REST_URL/UPSTASH_REDIS_REST_TOKEN
//                                          (opcional) memória da conversa; sem isso, fica na memória da função
import crypto from "node:crypto";
import { waitUntil } from "@vercel/functions";
import { perguntarZelia, medicosPara, PRECOS } from "./_zelia.js";

// ---------- Memória da conversa (por número de WhatsApp) ----------
const REDIS_URL = process.env.KV_REST_API_URL || process.env.UPSTASH_REDIS_REST_URL;
const REDIS_TOKEN = process.env.KV_REST_API_TOKEN || process.env.UPSTASH_REDIS_REST_TOKEN;
const memoria = new Map();
const TTL = 60 * 60 * 24 * 3; // 3 dias

async function redis(comando) {
  const r = await fetch(REDIS_URL, { method: "POST", headers: { Authorization: `Bearer ${REDIS_TOKEN}` }, body: JSON.stringify(comando) });
  const j = await r.json();
  if (j.error) throw new Error(j.error);
  return j.result;
}
const novaConversa = () => ({ historico: [], etapa: "conversa", pedido: { cidade: "", convenio: "", especialidade: "" }, opcoes: null, escolha: null, consulta: null });
async function carregar(id) {
  if (REDIS_URL && REDIS_TOKEN) { const v = await redis(["GET", `zelo:wa:${id}`]); return v ? JSON.parse(v) : novaConversa(); }
  return memoria.get(id) || novaConversa();
}
async function salvar(id, conversa) {
  conversa.historico = conversa.historico.slice(-30);
  if (REDIS_URL && REDIS_TOKEN) await redis(["SET", `zelo:wa:${id}`, JSON.stringify(conversa), "EX", TTL]);
  else memoria.set(id, conversa);
}

// ---------- Utilidades ----------
const brl = (n) => `R$ ${n.toLocaleString("pt-BR")}`;
const norm = (s) => String(s).toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").trim();
const negritoWhats = (s) => s.replace(/\*\*(.+?)\*\*/g, "*$1*");
const xml = (s) => s.replace(/[<>&'"]/g, (c) => ({ "<": "&lt;", ">": "&gt;", "&": "&amp;", "'": "&apos;", '"': "&quot;" }[c]));
function horaMenos(slot, minutos) {
  const m = /(\d{1,2})h(\d{2})?/.exec(slot || "");
  const total = (m ? +m[1] * 60 + +(m[2] || 0) : 540) - minutos;
  const h = Math.floor(total / 60), mm = total % 60;
  return `${h}h${mm ? String(mm).padStart(2, "0") : ""}`;
}

const PACOTES = [
  { titulo: "Acompanhante + carro por aplicativo", acompanhante: true, transporte: "app", total: PRECOS.acompanhante + PRECOS.carroApp + PRECOS.taxa },
  { titulo: "Acompanhante + motorista Zelo", acompanhante: true, transporte: "zelo", total: PRECOS.acompanhante + PRECOS.motorista + PRECOS.taxa },
  { titulo: "Só motorista Zelo (sem acompanhante)", acompanhante: false, transporte: "zelo", total: PRECOS.motorista + PRECOS.taxa },
  { titulo: "Só o agendamento", acompanhante: false, transporte: "nenhum", total: 0 },
];
const textoPacotes = () => [
  "Agora o dia da consulta. Responda com o *número*:",
  ...PACOTES.map((p, i) => `*${i + 1}.* ${p.titulo} — ${p.total ? brl(p.total) : "grátis"}`),
  `_Acompanhante Zelo: profissional de enfermagem, até 4h. Inclui a taxa de serviço de ${brl(PRECOS.taxa)} do plano Grátis._`,
].join("\n");

function estadoParaIA(c) {
  return {
    canal: "WhatsApp. Aqui não há cartões: quando você usa mostrar_medicos, o sistema envia uma lista numerada de horários e depois uma lista numerada de pacotes.",
    paciente: "Maria, 82 anos, mora em Perdizes (São Paulo), usa bengala, precisa de ajuda para entrar no carro",
    plano: "Grátis",
    etapa: c.etapa,
    pedido_em_andamento: c.pedido,
    opcoes_de_horario_na_tela: c.etapa === "escolher_horario" ? c.opcoes : null,
    consulta_marcada: c.consulta,
  };
}

// ---------- Conversa ----------
async function responder(c, texto, temMidia, site) {
  const t = norm(texto);
  if (/^(reiniciar|recomecar|reset|comecar de novo)$/.test(t)) {
    Object.assign(c, novaConversa());
    return ["Pronto, comecei do zero. Pra quem é a consulta?"];
  }
  const n = Number.parseInt(t, 10);
  const soNumero = /^\d{1,2}\.?$/.test(t);

  if (c.etapa === "escolher_horario" && soNumero && n >= 1 && n <= c.opcoes.length) {
    c.escolha = c.opcoes[n - 1];
    c.etapa = "escolher_pacote";
    const conv = c.pedido.convenio && !/particular/i.test(c.pedido.convenio) ? c.pedido.convenio : "";
    const msgs = [`Reservado: *${c.escolha.medico}*, ${c.escolha.horario}, em ${c.escolha.bairro}.${conv ? ` Pedi a autorização ao ${conv}: *autorizado*.` : ""}`, textoPacotes()];
    c.historico.push({ de: "familia", texto }, { de: "zelia", texto: msgs.join("\n") });
    return msgs;
  }

  if (c.etapa === "escolher_pacote" && soNumero && n >= 1 && n <= PACOTES.length) {
    const p = PACOTES[n - 1], e = c.escolha;
    c.consulta = { especialidade: c.pedido.especialidade, medico: e.medico, bairro: e.bairro, horario: e.horario, pacote: p.titulo, total: p.total ? brl(p.total) : "grátis" };
    c.etapa = "conversa";
    const linhas = [
      "✅ *Consulta confirmada*",
      `${c.pedido.especialidade} com ${e.medico}`,
      `${e.horario} · ${e.bairro}`,
      p.acompanhante ? "Acompanhante: Ana Souza (técnica de enfermagem)" : null,
      p.transporte === "zelo" ? `Motorista Zelo: Carlos · busca às ${horaMenos(e.horario, 50)}` : null,
      p.transporte === "app" ? `Saída de casa às ${horaMenos(e.horario, 50)}. Eu chamo o carro quando a Ana estiver pronta.` : null,
      p.total ? `Pagamento: Pix de ${brl(p.total)} (simulação)` : null,
    ].filter(Boolean).join("\n");
    const msgs = [linhas, `Vou lembrar a Maria na véspera e uma hora antes. No dia, você acompanha cada etapa pelo app: ${site}`];
    c.historico.push({ de: "familia", texto }, { de: "zelia", texto: msgs.join("\n") });
    return msgs;
  }

  // Conversa livre: a IA decide.
  c.historico.push({ de: "familia", texto: temMidia ? "[enviou a foto da carteirinha: Vida Plena Saúde, plano Ouro, final 4821]" : texto || "(mensagem vazia)" });
  if (temMidia) c.pedido.convenio = "Vida Plena Saúde";
  const out = await perguntarZelia(c.historico, estadoParaIA(c));
  if (out.cidade) c.pedido.cidade = out.cidade;
  if (out.convenio) c.pedido.convenio = out.convenio;
  if (out.especialidade) c.pedido.especialidade = out.especialidade;
  const msgs = out.mensagens.map(negritoWhats);
  c.historico.push({ de: "zelia", texto: out.mensagens.join("\n") });

  if (out.acao === "mostrar_medicos" && c.pedido.especialidade) {
    c.opcoes = medicosPara(c.pedido.especialidade).flatMap((m) =>
      m.slots.map((h) => ({ medico: m.nome, bairro: m.bairro, distancia: m.dist, acessibilidade: m.acess, horario: h })));
    c.etapa = "escolher_horario";
    const lista = [
      `Horários de *${c.pedido.especialidade}* perto da Maria. Responda com o *número*:`,
      ...c.opcoes.map((o, i) => `*${i + 1}.* ${o.horario} — ${o.medico}, ${o.bairro} (${o.distancia})`),
    ].join("\n");
    msgs.push(lista);
    c.historico.push({ de: "zelia", texto: lista });
  } else if (out.acao === "abrir_planos") {
    msgs.push(`Os planos estão no app, na aba Perfil: ${site}`);
  } else if (c.etapa === "escolher_horario") {
    msgs.push(`Para escolher, responda com o número do horário (1 a ${c.opcoes.length}).`);
  } else if (c.etapa === "escolher_pacote") {
    msgs.push(`Para escolher o pacote, responda com o número (1 a ${PACOTES.length}).`);
  }
  return msgs;
}

// ---------- Twilio ----------
function assinaturaValida(req, params) {
  const token = process.env.TWILIO_AUTH_TOKEN;
  if (!token || process.env.TWILIO_SKIP_SIGNATURE === "1") return true;
  const recebida = req.headers["x-twilio-signature"];
  if (!recebida) return false;
  const url = `https://${req.headers["x-forwarded-host"] || req.headers.host}${req.url}`;
  const dados = Object.keys(params).sort().reduce((acc, k) => acc + k + params[k], url);
  const esperada = crypto.createHmac("sha1", token).update(Buffer.from(dados, "utf-8")).digest("base64");
  const a = Buffer.from(recebida), b = Buffer.from(esperada);
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

async function enviarPelaApi(para, de, corpo) {
  const sid = process.env.TWILIO_ACCOUNT_SID, token = process.env.TWILIO_AUTH_TOKEN;
  const r = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`, {
    method: "POST",
    headers: { Authorization: "Basic " + Buffer.from(`${sid}:${token}`).toString("base64"), "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({ To: para, From: de, Body: corpo.slice(0, 1500) }),
  });
  if (!r.ok) console.error("Twilio", r.status, await r.text());
}

export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).send("use POST");
  let params = req.body || {};
  if (typeof params === "string") params = Object.fromEntries(new URLSearchParams(params));
  if (!assinaturaValida(req, params)) return res.status(403).send("assinatura inválida");

  const remetente = params.From, nossoNumero = params.To;
  if (!remetente) return res.status(400).send("sem remetente");
  const texto = String(params.Body || "").trim().slice(0, 1200);
  const temMidia = Number(params.NumMedia || 0) > 0;
  const site = process.env.SITE_URL || `https://${req.headers["x-forwarded-host"] || req.headers.host}`;

  const atender = async () => {
    let conversa;
    try { conversa = await carregar(remetente); } catch (error) { console.error("Memória", error); conversa = novaConversa(); }
    let msgs;
    try {
      msgs = await responder(conversa, texto, temMidia, site);
    } catch (error) {
      console.error("Zélia", error);
      msgs = [process.env.ANTHROPIC_API_KEY ? "Tive um probleminha agora. Pode mandar de novo?" : "A IA da Zélia ainda não foi ligada (falta a ANTHROPIC_API_KEY no Vercel)."];
    }
    try { await salvar(remetente, conversa); } catch (error) { console.error("Memória", error); }
    return msgs;
  };

  // Com as credenciais do Twilio, responde na hora e envia as mensagens depois (sem o limite de 15 s do webhook).
  if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
    waitUntil((async () => { for (const m of await atender()) await enviarPelaApi(remetente, nossoNumero, m); })());
    res.setHeader("Content-Type", "text/xml");
    return res.status(200).send("<Response/>");
  }
  const msgs = await atender();
  res.setHeader("Content-Type", "text/xml");
  return res.status(200).send(`<Response>${msgs.map((m) => `<Message>${xml(m)}</Message>`).join("")}</Response>`);
}
