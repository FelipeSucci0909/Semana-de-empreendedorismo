# Spec para agentes de IA: gerar o pitch do Zelo em HTML

> Este documento é uma especificação para um **agente de IA** (LLM com acesso a arquivos e a um navegador headless) reproduzir ou atualizar o pitch do Zelo no mesmo padrão. Siga as seções em ordem. Regras marcadas **DEVE** são obrigatórias; **EVITE** indica anti-padrões.

---

## 0. Objetivo e saída

- **Produto:** Zelo, um serviço em que a assistente de IA "Zélia" agenda a consulta médica do idoso e monta o dia (acompanhante Zelo + carro por app, ou motorista Zelo), e a família acompanha ao vivo e recebe o registro da consulta.
- **Público do pitch:** banca de jurados de um programa de empreendedorismo (FGV). A avaliação pode ser feita por humanos **ou por uma IA**.
- **Saída obrigatória:**
  1. `pitch/src/index.html`: código-fonte dos slides (HTML/CSS/JS puros, sem frameworks).
  2. `site/pitch/index.html`: versão publicada, gerada por `python3 pitch/build.py`.
  3. `pitch/zelo-pitch.html`: arquivo único offline, com as imagens embutidas em base64, gerado pelo mesmo script.
- **Duração-alvo:** 180 s (limite de 300 s). A soma de `data-tempo` dos slides principais **DEVE** ser 180 ± 10.

---

## 1. Fontes de verdade (leia antes de escrever)

| Conteúdo | Arquivo |
|---|---|
| Problema, solução, preços | `README.md` |
| Estratégia, planos, parceiros, canvas, hipóteses | `docs/estrategia.md` |
| Números do EBIT | `docs/zelo-ebit-preliminar.xlsx` (aba EBIT; recalcule se mudar premissas) |
| Design system (tokens) | `design-system/zelo/MASTER.md` |
| Evidências de campo | entrevista de 5/10/2026: ~4 faltas ao trabalho em 1 mês; cuidador ~R$ 300/dia; transporte por app ~R$ 80; idoso não vai de Uber sozinho; sai da consulta sem entender orientações |
| Dado de mercado | IBGE, Censo 2022: 32,1 mi de pessoas com 60+ (15,6% da população) |

**DEVE:** usar apenas números presentes nessas fontes. Para um número novo, cite a fonte no slide ou marque-o com a etiqueta `Hipótese`.

---

## 2. Regras de conteúdo (avaliadores humanos e IA)

1. **Afirmação verificável ou hipótese explícita.** Toda afirmação numérica precisa de fonte (`.fonte` no rodapé) ou da etiqueta `.tag.hip`.
2. **Mostrar a conta.** Estimativa de mercado em fórmula visível: `32,1 mi × 1% × 1/mês × R$ 260 × 12 ≈ R$ 1 bi/ano`.
3. **Critérios explícitos.** Cada "próximo teste" tem amostra e métrica (ex.: `10 famílias · % que aceita o preço`).
4. **Ordem obrigatória:** gancho → dor → quem/mercado → solução → evidência (protótipo) → diferencial → modelo de negócio → validação → fechamento.
5. **Densidade:** no máximo ~30 palavras de corpo por slide (o slide de validação pode chegar a ~60). Texto principal ≥ 24 px.
6. **EVITE:** superlativos sem prova ("revolucionário", "único no mundo"), números sem fonte, planilhas no corpo do pitch (vão para o apêndice), mais de 3 imagens de celular por slide.
7. **Fechamento:** uma frase forte e curta + o pedido concreto (piloto). Frase atual: "Ninguém deveria ter que escolher entre o trabalho e o cuidado com os pais."
8. **Idioma:** português do Brasil, frases curtas, sem jargão.

---

## 3. Estrutura dos slides (contrato)

| id | Classe | `data-tempo` | Conteúdo obrigatório |
|---|---|---|---|
| 1 | `slide escuro gancho` | 15 | Número de impacto gigante ("4 vezes") + frase com fonte (pesquisa de campo e data) |
| 2 | `slide` | 25 | Título da dor + 3 cartões (ícone, h3, ≤ 20 palavras) + `.fonte` com o custo atual (R$ 300/dia) |
| 3 | `slide` | 20 | Dado IBGE com fonte; "quem usa" × "quem paga"; cartão de hipótese de mercado com a fórmula |
| 4 | `slide` | 25 | Frase da solução + 3 passos numerados + 1 captura do app (`img/app-chat-medicos.png`) |
| 5 | `slide` | 35 | 3 capturas (pacote, acompanhar, registro) + QR da demo + URL legível |
| 6 | `slide` | 15 | Tabela comparativa: 4 colunas (app de corrida, cuidador avulso, app do convênio, **Zelo**) × 5 critérios |
| 7 | `slide` | 20 | 3 planos (Grátis R$ 0 + taxa R$ 15; Zelo+ R$ 29,90/mês; Zelo Empresas, o RH paga) + conta unitária (R$ 275 → R$ 58, 21%) + `.fonte` com as premissas |
| 8 | `slide` | 15 | Duas listas: "Já validado" (com origem) e "Próximos testes" (com amostra · métrica) |
| 9 | `slide escuro fechamento` | 10 | Frase final + slogan + pedido de piloto + QR |
| A1 | `slide` | 0 | Apêndice: modelos de operação e requisitos dos parceiros |
| A2 | `slide` | 0 | Apêndice: tabela de EBIT (3 cenários, ponto de equilíbrio) |
| A3 | `slide` | 0 | Apêndice: simulação do WhatsApp, etiquetada "Simulação · integração prevista" |

Cada `<section class="slide">` **DEVE** ter:
- `data-tempo="N"` (segundos; 0 nos apêndices);
- `data-notas="[m:ss–m:ss] fala completa..."`, com o roteiro do apresentador;
- um `.rodape` com o logo à esquerda e o número do slide à direita.

---

## 4. Tokens de design (copie exatamente)

```css
:root{
  --bg:#EEF4F3;--surface:#FFFFFF;--surface-2:#F4F8F7;--text:#0F2B2A;--text-2:#4A6261;--border:#D3E2E0;
  --primary:#0B6B70;--primary-soft:#DCEFEE;--ink:#08494C;--accent:#B4532A;--accent-2:#F0A27E;--accent-soft:#FBE9E0;
  --success:#1D7A4B;--success-soft:#DDF2E6;--warning:#8A5A00;--warning-soft:#FBF0D6;--danger:#B42318;
  --head:"Lexend",system-ui,sans-serif;--body:"Source Sans 3",system-ui,sans-serif;
}
```

- **Canvas fixo:** `.deck{width:1920px;height:1080px}`, escalado com `transform: scale(min(innerWidth/1920, innerHeight/1080))`.
- **Slide:** `padding: 92px 120px 84px`. A classe `.escuro` usa o fundo `--ink` e texto branco; o destaque passa a `--accent-2`.
- **Tipografia:**
  - `.rotulo`: 24 px, 700, maiúsculas, `letter-spacing:.12em`, cor `--primary`;
  - `h1`: 76 px; `h2`: 64 px; `h3`: 34 px; todos em Lexend 600 com `letter-spacing:-.015em`;
  - corpo: 27–34 px em Source Sans 3;
  - `.fonte`: 21 px.
- **Cartão:** `background:#fff; border-radius:28px; padding:36px; box-shadow:0 2px 3px rgba(15,43,42,.05),0 12px 32px rgba(15,43,42,.07)`.
- **Destaque de texto:** `<em>` (sem itálico) na cor `--accent`. No máximo 1 ou 2 por slide.
- **Ícones:** SVG inline 24×24, `stroke-width:2`, estilo Lucide, dentro de `.ic` (64×64, raio 18, fundo `--primary-soft`). **EVITE** emoji como ícone de interface.
- **Logo:** arco `M6 21a10 10 0 0 1 20 0` + círculo `cx=16 cy=21 r=3.6` preenchido com `#F0A27E`, sobre um quadrado `--primary` de raio 10. Wordmark "zelo" em minúsculas.
- **Fontes embutidas:** o build substitui `/*@FONTS@*/` por `@font-face` em base64 (Lexend 500/600 e Source Sans 3 400/600/700, subconjunto latino) usando `demo/build.py::font_faces()`. **DEVE** funcionar offline.

---

## 5. Comportamento obrigatório do deck (JS sem dependências)

- **Navegação:** → / Espaço / Enter / PageDown avançam; ← / Backspace / PageUp voltam; Home / End vão ao primeiro / último slide; clique (direita avança, esquerda volta); deslize no celular.
- **N** alterna o painel de notas: título "Slide i de n · ~Xs", o texto de `data-notas` e um cronômetro `m:ss / 3:00`, que começa no primeiro avanço. **R** zera o cronômetro.
- **F** alterna a tela cheia; **P** chama `print()`.
- **Hash `#n`** sincronizado com o slide atual (permite abrir num slide específico).
- **Barra de progresso** no rodapé (largura proporcional).
- **Impressão:** `@page{size:1920px 1080px;margin:0}`, um slide por página, sem a interface do apresentador.
- **QR code:** a biblioteca `qrcode-generator` (MIT) é embutida via `/*@QRLIB@*/`. Alvo: `?demo=URL` › constante `DEMO_PADRAO` › `new URL("../", location.href)` quando servido por http(s). Sem alvo, mostrar o aviso "QR aparece com o pitch publicado". O QR **DEVE** apontar para o domínio de **produção** (links de pré-visualização do Vercel exigem login).
- **Acessibilidade:** `alt` descritivo em todas as imagens, contraste AA, `prefers-reduced-motion` desliga a transição.

---

## 6. Imagens do protótipo

- **Origem:** capturas do elemento `.device` da demo (`demo/zelo.html`) com Playwright em `deviceScaleFactor: 2` e `omitBackground: true`, salvas em `pitch/img/`.
- **Roteiro de captura** (estado determinístico, demo offline = roteiro local da Zélia):
  1. Limpar o `localStorage` e definir `S.plano='plus'` (assim o áudio do registro aparece).
  2. Fluxo do chat: "Pra minha mãe, Maria" → "São Paulo" → "Enviar foto da carteirinha" → "Oftalmologista" → capture `app-chat-medicos.png`.
  3. Escolher o 1º horário → rolar até o cartão do pacote → capture `app-pacote.png`.
  4. Confirmar o pacote → "Eu pago" → "Pix" → "Avisar a Suzana" → Início → capture `app-inicio.png`.
  5. Modo "Lado a lado" → no parceiro, iniciar o atendimento e avançar 3 etapas → na família, abrir Acompanhar → capture `app-acompanhar.png`.
  6. Avançar, consentir, gravar e anotar → capture `app-parceiro.png` → concluir as etapas → Finalizar → abrir o registro → capture `app-registro.png`.
- Limpar os toasts antes de cada captura (`RT.toast = {}; renderAll()`).
- **EVITE:** mockups inventados. Use somente capturas do protótipo real ou simulações etiquetadas como tal (WhatsApp).

---

## 7. Procedimento de geração

1. Ler as fontes de verdade (seção 1) e registrar as divergências.
2. Escrever ou editar `pitch/src/index.html` respeitando as seções 3 a 5.
3. `python3 demo/build.py && python3 pitch/build.py`.
4. Servir `site/` (por exemplo `python3 -m http.server -d site 8765`) e abrir `/pitch/`.
5. **Verificação automática (DEVE passar):**
   - abrir todos os slides com Playwright em 1920×1080 e tirar um print de cada um; zero `pageerror`;
   - nenhum elemento ultrapassa os limites do slide (compare `scrollHeight` e `clientHeight` de cada `.slide`, e o retângulo dos filhos com o do slide);
   - soma de `data-tempo` dos slides 1–9 entre 170 e 190;
   - todo número do corpo do slide também aparece numa fonte da seção 1 ou numa `.tag.hip` / `.fonte` do mesmo slide;
   - o QR decodifica para a URL pública esperada.
6. **Revisão visual:** monte uma grade (3×4) com os prints e confira hierarquia, alinhamento e excesso de texto.
7. Fazer commit dos arquivos-fonte, de `site/pitch/` e de `pitch/zelo-pitch.html`.

---

## 8. Esqueleto mínimo de um slide

```html
<section class="slide" data-tempo="20"
  data-notas="[0:40–1:00] Fala completa do apresentador...">
  <p class="rotulo">Quem tem o problema e quanto vale</p>
  <h2>Título curto com <em>uma</em> palavra em destaque.</h2>
  <div class="cards c3" style="margin-top:56px">
    <div class="card"><div class="ic"><svg viewBox="0 0 24 24">…</svg></div>
      <h3>Subtítulo</h3><p>Até ~20 palavras.</p></div>
    <!-- … -->
  </div>
  <p class="fonte">Fonte: …  ·  ou etiqueta <span class="tag hip">Hipótese</span></p>
  <div class="rodape"><span class="logo">…</span><span>3</span></div>
</section>
```

---

## 9. Critérios de aceite (resumo para autoavaliação)

| Critério | Como verificar |
|---|---|
| Gancho com dado real nos primeiros 15 s | O slide 1 tem número + fonte |
| Dor antes da solução | A ordem dos slides segue a seção 3 |
| Mercado com conta explícita | A fórmula está visível no slide 3 |
| Evidência demonstrável | QR funcional + capturas reais no slide 5 |
| Modelo de receita claro | O slide 7 mostra planos + conta unitária |
| Hipóteses separadas de fatos | `.tag.hip` em toda estimativa |
| ~3 minutos | Soma de `data-tempo` ≈ 180 |
| Frase final forte | O slide 9 termina com a frase + pedido |
| Funciona offline | `pitch/zelo-pitch.html` abre sem rede |
