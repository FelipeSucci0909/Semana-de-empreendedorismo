// Função serverless (Vercel) que dá à Zélia uma IA de verdade no app.
// A chave fica só no servidor: configure ANTHROPIC_API_KEY nas variáveis de ambiente do projeto no Vercel.
// O app manda o histórico da conversa + o estado da demo e recebe as falas da Zélia em JSON.
import { perguntarZelia, statusDoErro } from "./_zelia.js";

export default async function handler(req, res) {
  // O app Android abre a página como arquivo local, então a origem pode ser "null".
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  if (req.method === "OPTIONS") return res.status(204).end();
  if (req.method !== "POST") return res.status(405).json({ erro: "use POST" });
  if (!process.env.ANTHROPIC_API_KEY) return res.status(503).json({ erro: "ANTHROPIC_API_KEY não configurada" });

  let corpo;
  try { corpo = typeof req.body === "string" ? JSON.parse(req.body || "{}") : req.body || {}; }
  catch { return res.status(400).json({ erro: "corpo inválido" }); }

  try {
    return res.status(200).json(await perguntarZelia(corpo.historico, corpo.estado));
  } catch (error) {
    const { status, erro } = statusDoErro(error);
    return res.status(status).json({ erro });
  }
}
