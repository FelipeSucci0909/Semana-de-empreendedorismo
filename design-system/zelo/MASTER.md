# Zelo — Design System (fonte da verdade)

Gerado a partir da skill **ui-ux-pro-max** (consulta: *eldercare healthcare service family trust mobile app*, variância 3, movimento 3, densidade 3) e ajustado para o público do Zelo: idosos de 70+ e filhos de 35–55.

A skill sugeriu **Minimalismo / Swiss Style**, com ciano calmo e verde de saúde, Lexend + Source Sans 3, pouco movimento e nada de gradientes "de IA". Mantivemos a direção, mas trocamos o ciano claro por um **petróleo mais escuro** (contraste AA/AAA com texto branco) e acrescentamos um **terracota quente** para a Zélia, para que o app pareça cuidado humano e não um sistema hospitalar.

## Cores (tokens)

| Token | Claro | Escuro | Uso |
|---|---|---|---|
| `bg` | `#EEF4F3` | `#0B1716` | fundo das telas |
| `surface` | `#FFFFFF` | `#12211F` | cards |
| `surface-2` | `#F4F8F7` | `#182B29` | campos, botões secundários |
| `text` | `#0F2B2A` | `#E6F2F0` | texto principal |
| `text-2` | `#4A6261` | `#A3BDBA` | texto de apoio |
| `border` | `#D3E2E0` | `#26403D` | divisórias |
| `primary` | `#0B6B70` | `#5BC6C0` | ações principais, marca |
| `primary-soft` | `#DCEFEE` | `#163A38` | fundos de destaque |
| `primary-ink` | `#08494C` | `#0A3A3A` | cabeçalho do perfil Parceiro |
| `accent` | `#B4532A` | `#F0A27E` | Zélia, microfone, remédios |
| `success` | `#1D7A4B` | `#5DD08F` | etapas concluídas, confirmações |
| `warning` | `#8A5A00` | `#F2C062` | necessidades do idoso (parceiro) |
| `danger` | `#B42318` | `#FF8A7E` | emergência |

Na web, ficam em variáveis CSS (`demo/src/zelo.html`, `:root`). No iOS, em `Z.*` (`ios/Zelo/Design/Theme.swift`).

## Tipografia

- **Web:** Lexend (títulos, 500/600) e Source Sans 3 (texto, 400/600/700), embutidas no arquivo para funcionar offline.
- **iOS:** fonte do sistema com Dynamic Type; títulos em `.rounded`, que lembra a Lexend.
- Texto base de **17 pt**. Nada abaixo de 13 pt.

## Forma e espaçamento

- Espaçamento em múltiplos de 4 (12 / 14 / 16 / 18 / 24).
- Raios: 10 (pequeno), 16 (botões), 22 (cards), 28 (sheets).
- Sombra leve: `0 1px 2px` + `0 6px 20px` a 6–7% de opacidade.

## Regras de acessibilidade e UX (público sênior)

- Alvo de toque mínimo de **44 pt**. Botões principais têm **56 pt**.
- Uma ação principal por tela. Linguagem simples, sem jargão médico.
- Status sempre visível: o card "Agora" aparece no topo do Início durante o atendimento.
- Ícones em SVG / SF Symbols, nunca emoji. Botões só com ícone levam `aria-label` / `accessibilityLabel`.
- Respeitar `prefers-reduced-motion`. Animações de 150 a 400 ms, só para dar feedback.
- Modo escuro com os tokens acima, sem cinza sobre cinza.

## Componentes (mesmos nomes na web e no SwiftUI)

BolhaDeChat · RespostaRápida · CardDeMédico (`MedicoCard`) · LinhaDeServiço (toggle + preço) · CardDeConsulta (`ConsultaCard`) · LinhaDoTempo · Tag (`TagView`) · Botão primário / secundário / emergência (`ZButtonStyle`) · TabBar · AvatarZélia (`ZeliaAvatar`) · Toast.

## Evitar

Gradientes roxos ou rosa, brilhos, robôs, cores neon, animações pesadas, visual clínico e frio, e qualquer cara de "app de corrida".
