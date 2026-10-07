# Pitch do Zelo: guia para quem vai montar e apresentar

Este guia explica como o pitch do Zelo foi construído e como montá-lo de novo, em HTML ou em outra ferramenta (Google Slides, Canva, PowerPoint), com o mesmo visual. Também traz o roteiro de fala, o plano da demo e a preparação para as perguntas da banca.

---

## 1. Onde está e como abrir

| Arquivo | Para quê |
|---|---|
| `site/pitch/index.html` | O pitch publicado no Vercel, em `https://SEU-SITE.vercel.app/pitch/`. O QR code da demo aparece sozinho. |
| `pitch/zelo-pitch.html` | O mesmo pitch num arquivo único, com imagens embutidas, que **abre sem internet**. É o plano B. |
| `pitch/src/index.html` | O código-fonte dos slides. Edite este. |
| `pitch/img/` | As capturas do app usadas nos slides. |
| `pitch/build.py` | Gera os dois arquivos acima: `python3 pitch/build.py`. |

**Teclas durante a apresentação**

| Tecla | Faz |
|---|---|
| → / Espaço / Enter | Próximo slide |
| ← | Slide anterior |
| **N** | Mostra ou esconde as notas do apresentador, com o tempo de cada slide e um cronômetro (alvo: 3:00) |
| **F** | Tela cheia |
| **R** | Zera o cronômetro |
| **P** | Imprime ou salva em PDF, um slide por página |
| Home / End | Primeiro / último slide |

Também funciona com clique (lado direito avança, esquerdo volta) e com deslize no celular ou tablet.

Se o pitch não estiver publicado, abra o arquivo com `?demo=https://SEU-SITE.vercel.app` no fim do endereço para o QR aparecer.

---

## 2. As regras que seguimos (instruções do professor)

1. **Abrir com um gancho:** um dado marcante e real, "4 vezes" (faltas ao trabalho em um mês, da entrevista), seguido de uma pergunta para a plateia.
2. **Mostrar a dor antes da solução:** quem tem o problema, por que importa e o tamanho do mercado. Depois a solução, o diferencial e como ganhamos dinheiro.
3. **Trazer evidências sem poluir:** demo do protótipo (com QR para a banca testar) e um slide de "já validado / próximos testes". Planilhas ficam no apêndice.
4. **Ser breve:** 9 slides principais em cerca de 3 minutos (o limite é 5) e uma frase forte no final.
5. **Se a banca usar IA para avaliar:** toda afirmação é verificável (com fonte) ou marcada como **hipótese**, e os critérios ficam explícitos (por exemplo, a conta do mercado aparece por inteiro e os testes têm métrica).

---

## 3. Estrutura e roteiro de fala (cerca de 3 minutos)

| # | Slide | Tempo | O que dizer (resumo) |
|---|---|---|---|
| 1 | **Gancho:** "4 vezes" | 0:00–0:15 | "Quatro vezes. Foi quantas vezes a família que entrevistamos precisou faltar ao trabalho, em um só mês, para levar os avós ao médico." Pergunte: "Quem aqui já saiu do trabalho para levar um pai ou um avô a uma consulta?" |
| 2 | **A dor:** 3 cartões | 0:15–0:40 | Ninguém está disponível; o Uber não ajuda nem espera; o idoso sai da consulta sem entender. Quando ninguém pode ir, a família paga cerca de R$ 300 por dia a alguém de confiança. |
| 3 | **Quem e quanto** | 0:40–1:00 | Quem usa é o idoso; quem paga é o filho de 35 a 60 anos. São 32,1 milhões de pessoas com 60+ (IBGE, Censo 2022). Hipótese: 1% × 1 atendimento/mês × R$ 260 ≈ R$ 1 bi/ano. Começamos por São Paulo. |
| 4 | **Solução:** a Zélia + 3 passos | 1:00–1:25 | Pede à Zélia; monta o dia (acompanhante com carro por app, ou motorista Zelo); acompanha ao vivo e recebe o registro. |
| 5 | **Protótipo + QR** | 1:25–2:00 | "Funciona, com IA de verdade." Mostre o pacote, o acompanhamento e o registro. "Apontem a câmera e testem agora." |
| 6 | **Diferencial:** tabela | 2:00–2:15 | Cada alternativa resolve só um pedaço. O Zelo junta tudo, com parceiros certificados (COREN ativo e treinamento). |
| 7 | **Modelo de negócio** | 2:15–2:35 | Pago por atendimento; o Zelo fica com cerca de 21% (R$ 58 de R$ 275). Planos Grátis, Zelo+ (R$ 29,90) e Zelo Empresas (o RH paga). |
| 8 | **Evidências** | 2:35–2:50 | Já validado: dor, preços de referência, mentoria, protótipo. Próximos testes, cada um com sua métrica. |
| 9 | **Fechamento** | 2:50–3:00 | "Ninguém deveria ter que escolher entre o trabalho e o cuidado com os pais." Pedido: piloto com 10 famílias e 3 empresas. Agradeça e pare. |
| A1–A3 | **Apêndice** | Perguntas | Operação e parceiros · EBIT preliminar · Zélia no WhatsApp (simulação). |

O texto completo de cada slide está nas notas do apresentador (tecla **N**).

**Frase final.** Diga devagar, olhando para a banca, e não acrescente nada depois além de "Obrigado":
> "Ninguém deveria ter que escolher entre o trabalho e o cuidado com os pais."

---

## 4. Identidade visual

### Cores

| Nome | Hex | Uso |
|---|---|---|
| Fundo | `#EEF4F3` | Fundo dos slides claros |
| Superfície | `#FFFFFF` | Cartões |
| Superfície 2 | `#F4F8F7` | Cabeçalhos de tabela, etiquetas |
| Texto | `#0F2B2A` | Títulos e texto principal |
| Texto 2 | `#4A6261` | Texto de apoio, fontes |
| Borda | `#D3E2E0` | Linhas e bordas |
| **Primária (petróleo)** | `#0B6B70` | Marca, números, destaques, botões |
| Primária suave | `#DCEFEE` | Fundo de ícones e da coluna Zelo |
| **Tinta (fundo escuro)** | `#08494C` | Slides de gancho e de fechamento |
| **Destaque (terracota)** | `#B4532A` | A Zélia, palavras-chave em slide claro, números de impacto |
| Destaque claro | `#F0A27E` | Palavras-chave e números em slide escuro |
| Sucesso | `#1D7A4B` | ✓, "já validado", EBIT positivo |
| Atenção | `#8A5A00` (fundo `#FBF0D6`) | Etiqueta "hipótese", próximos testes |
| Erro | `#B42318` | EBIT negativo |

**Regra:** use uma cor de destaque por slide (terracota), sempre em palavras-chave, nunca em parágrafos inteiros. Nada de gradientes, roxo ou neon.

### Fontes (Google Fonts, gratuitas)

- **Títulos e números:** [Lexend](https://fonts.google.com/specimen/Lexend), peso 600 (semibold). No gancho, peso 500.
- **Texto:** [Source Sans 3](https://fonts.google.com/specimen/Source+Sans+3), pesos 400, 600 e 700.

Tamanhos num slide de 1920×1080 (no Google Slides, de 1920×1080 px, divida por cerca de 1,33 para converter em pt):

| Elemento | Tamanho | Detalhe |
|---|---|---|
| Rótulo do slide ("A DOR") | 24 px | Source Sans 3 bold, maiúsculas, espaçamento entre letras de 12%, cor primária |
| Título | 64–76 px | Lexend 600, entrelinha 1,1 |
| Número de impacto | 120–300 px | Lexend 600, terracota |
| Subtítulo de cartão | 34 px | Lexend 600 |
| Texto | 27–34 px | Source Sans 3, cor Texto 2 |
| Fonte / nota | 21 px | Source Sans 3, cor Texto 2, no rodapé |

**Regra prática:** se precisar de letra menor que 24 px no texto principal, o slide tem texto demais. Corte.

### Grade e formas

- **Slide:** 1920×1080 (16:9).
- **Margens:** 120 px nas laterais, 92 px no topo e cerca de 84 px embaixo.
- **Cartões:** fundo branco, cantos arredondados de 28 px, sombra bem leve (`0 12px 32px` a 7% de preto), espaçamento interno de 36 px e 28 px entre cartões.
- **Ícones:** traço de 2 px e cantos arredondados (estilo [Lucide](https://lucide.dev)), dentro de um quadrado de 64 px com cantos de 18 px e fundo primária suave.
- **Etiquetas ("QUEM USA", "HIPÓTESE"):** formato pílula, 20 px, maiúsculas.
- **Rodapé:** logo à esquerda e número do slide à direita.

### Logo do Zelo

- **Desenho:** um arco ("abraço") sobre um ponto. Arco branco de traço grosso e ponto terracota claro (`#F0A27E`), sobre um quadrado petróleo de cantos arredondados.
- **Nome:** "zelo", sempre em minúsculas, em Lexend 600.
- **Arquivos prontos:** `site/icon-512.png` (ícone) e `site/og.png` (imagem com nome e frase).

### Imagens

| Arquivo | Mostra | Slide |
|---|---|---|
| `pitch/img/app-chat-medicos.png` | Chat com a Zélia mostrando médicos e horários | 4 |
| `pitch/img/app-pacote.png` | Pacote do dia (acompanhante, carro por app, motorista Zelo) | 5 |
| `pitch/img/app-acompanhar.png` | Acompanhamento ao vivo (mapa + etapas) | 5 |
| `pitch/img/app-registro.png` | Registro da consulta (o que a médica disse, remédios) | 5 |
| `pitch/img/app-inicio.png` | Início do app | reserva |
| `pitch/img/app-parceiro.png` | Tela da acompanhante | reserva |
| `pitch/img/zelia-whatsapp-1.png`, `-2.png` | Simulação no WhatsApp | A3 |
| `docs/whatsapp/zelia-whatsapp-slide.png` | Slide pronto do WhatsApp | alternativa ao A3 |

As capturas são do protótipo real, em alta resolução e com fundo transparente. Para gerar de novo depois de mudar o app, abra a demo, monte o estado desejado e tire o print da área do celular. Também posso refazer as capturas automaticamente.

---

## 5. Montar em outra ferramenta (Slides, Canva, PowerPoint)

1. Crie uma apresentação **16:9** (1920×1080 no Canva; "Widescreen" no PowerPoint e no Google Slides).
2. Instale e selecione **Lexend** e **Source Sans 3**. No Google Slides: *Fontes ▸ Mais fontes*.
3. Defina o fundo `#EEF4F3`. Os slides 1 e 9 usam `#08494C`.
4. Siga a tabela da seção 3, slide por slide. Copie os textos de `pitch/src/index.html` (cada slide é um bloco `<section>`).
5. Insira as imagens de `pitch/img/`, com no máximo 3 celulares por slide.
6. **QR code:** gere um apontando para o endereço público da demo (veja a seção 6) e coloque nos slides 5 e 9, com pelo menos 300 px.
7. Cole o texto das notas (o `data-notas` de cada `<section>`) nas notas do apresentador.
8. Revise com o checklist da seção 8.

---

## 6. A demo ao vivo (slide 5)

**Antes do pitch**
- **QR code:**
  - Use o **endereço de produção** do Vercel (ex.: `zelo-app.vercel.app`), não um link de pré-visualização.
  - No Vercel, em *Settings ▸ Deployment Protection*, desligue a **Vercel Authentication**. Sem isso, o QR abre uma tela de login.
  - Teste o QR com um celular **que nunca entrou no Vercel**, de preferência no 4G.
- **IA:** confira se o chat mostra "Assistente com IA" e se responde a uma frase livre.
- **Demo limpa:** no notebook, clique em **Reiniciar demo** e deixe o modo **Lado a lado** aberto numa aba.

**Durante (35 s):** escolha um destes dois roteiros.
1. Pelo pitch: mostre as 3 telas do slide 5 e peça para a banca escanear o QR.
2. Ao vivo: troque de aba para a demo e clique em **Pular para consulta agendada**. Na coluna da acompanhante, avance 2 etapas e mostre a família vendo tudo em tempo real.

**Plano B sem internet:** `pitch/zelo-pitch.html` e `demo/zelo.html` abrem offline. A Zélia volta para o roteiro local automaticamente.

---

## 7. Ensaio

- [ ] Cronometre com a tecla **N**. O alvo é **3:00**; o máximo, 5:00.
- [ ] Ensaie com **alguém que não conhece o projeto**. Pergunte: "Qual é o problema? O que o Zelo faz? Como ganha dinheiro?" Se a pessoa não souber responder, ajuste o slide correspondente.
- [ ] Decore a abertura (slide 1) e a frase final (slide 9).
- [ ] Defina quem fala cada parte. Trocas de pessoa custam tempo, então use no máximo 2.
- [ ] Teste o QR em 2 celulares, um iPhone e um Android.

### Perguntas prováveis da banca (respostas curtas)

| Pergunta | Resposta |
|---|---|
| "Como vocês integram com o convênio?" | "Hoje é simulado. No piloto, nossa equipe agenda pelos canais que as clínicas já usam (MVP concierge). A integração direta com as operadoras, pelo padrão TISS da ANS, é o próximo passo." |
| "Como garantem a qualidade da acompanhante?" | "Exigimos COREN ativo ou curso de cuidador, verificamos antecedentes e referências, aplicamos o treinamento Zelo, e a família avalia cada atendimento." (apêndice A1) |
| "O negócio para em pé?" | "Com escala. O EBIT fica positivo por volta de 7.300 atendimentos por mês em São Paulo; as alavancas são o preço, o percentual retido e o Zelo Empresas." (apêndice A2) |
| "Por que não o Uber fazer isso?" | "Porque o Uber vende corrida e nós vendemos cuidado. O carro é commodity; a confiança está na acompanhante. Podemos inclusive usar o Uber e a 99 como parceiros de transporte." |
| "E a privacidade?" | "A gravação só acontece com consentimento da paciente e do médico. Dado de saúde é sensível pela LGPD e não vendemos dados." |
| "Quanto custa para a família?" | "Cerca de R$ 255 a R$ 275 por consulta com acompanhante, contra cerca de R$ 300 pelo dia de um cuidador informal, e com registro e acompanhamento ao vivo." |

---

## 8. Checklist final

- [ ] Todo número tem fonte no slide ou está marcado como **hipótese**.
- [ ] Nenhum texto principal menor que 24 px; no máximo cerca de 30 palavras por slide (o slide 8 é a exceção).
- [ ] Os QR codes funcionam sem login.
- [ ] O cronômetro marca cerca de 3:00 no ensaio.
- [ ] A última fala é a frase final.

### Fontes dos dados (confira antes de apresentar)

- **População 60+:** 32,1 milhões, 15,6% da população. Fonte: IBGE, Censo Demográfico 2022 (publicado em 2023), em [ibge.gov.br](https://www.ibge.gov.br).
- **"4 vezes em um mês", R$ 300/dia e R$ 80 no app:** entrevista de campo do grupo, 5/10/2026 (anotações no Granola).
- **Preços, margens e EBIT:** hipóteses do grupo, em `docs/estrategia.md` e `docs/zelo-ebit-preliminar.xlsx`.
