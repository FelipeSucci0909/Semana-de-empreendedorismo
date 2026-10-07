# Zelo

**A Zélia marca a consulta e cuida de todo o caminho até lá. A família acompanha tudo.**

Projeto da Semana Concentrada de Empreendedorismo FGV (tema: Cidades Inteligentes).

## O problema

Filhos que trabalham faltam ao trabalho para levar os pais idosos a consultas. Na entrevista de campo, isso aconteceu cerca de 4 vezes num único mês. O idoso não consegue usar o app do convênio sozinho e não pode ir de Uber comum, porque alguém precisa ajudar a entrar no carro e estacionar perto. Muitas vezes ele sai da consulta sem entender o remédio ou o retorno. Quando ninguém da família pode ir, paga-se cerca de R$ 300 por dia a alguém de confiança.

## A solução

1. **Pedido e agendamento.** A Zélia, uma agente de IA dentro do app e também no WhatsApp, pergunta a cidade, o convênio (aceita foto da carteirinha) e a especialidade. Ela busca médicos, agenda e pede a autorização ao convênio. Pode ser usada pelo próprio idoso ou pelos filhos.
2. **Pacote modular.** A família escolhe:
   - acompanhante Zelo (R$ 180, até 4h);
   - como ir até a clínica: carro por aplicativo chamado pela Zélia (cerca de R$ 60), motorista Zelo (R$ 80, ajuda o idoso e espera a consulta) ou sem transporte;
   - veículo adaptado (+R$ 60).

   O resumo da consulta já vem incluso. Planos: **Grátis** (taxa de serviço de R$ 15 por atendimento), **Zelo+** (R$ 29,90/mês, sem taxa) e **Zelo Empresas** (pago pelo RH).
3. **No dia.** Motorista e acompanhante parceiros marcam cada etapa e a família acompanha em tempo real. A acompanhante grava a consulta, com consentimento, e registra o que o médico disse.
4. **Registro.** Resumo em linguagem simples, remédios com horário e próximos passos. Um botão pede à Zélia que marque o retorno.

## Demo online (QR code para os jurados)

A pasta `site/` é publicada no **Vercel** e é o que o QR code abre.

- **No celular:** abre como app, em tela cheia, com uma tela de boas-vindas ("Sou da família" / "Sou acompanhante"). No iPhone dá para "Adicionar à Tela de Início". No Android aparece o botão para baixar o APK.
- **No computador:** abre o palco da apresentação. O QR code no painel aponta para o próprio endereço publicado.
- **APK de Android (`site/zelo.apk`):** gerado pelo GitHub Actions (`.github/workflows/android.yml`) sempre que a demo muda. O projeto do app fica em `android/` e é um WebView com a mesma página.

### Publicar no Vercel (uma vez, cerca de 2 minutos)

1. Entre em [vercel.com](https://vercel.com) com a conta do GitHub e clique em **Add New… ▸ Project**.
2. Importe o repositório `FelipeSucci0909/Semana-de-empreendedorismo`.
3. Em **Project Name**, use algo curto, por exemplo `zelo-app`. Esse nome vira o endereço `zelo-app.vercel.app`.
4. Deixe **Framework Preset = Other** e não mude mais nada. O `vercel.json` já aponta para a pasta `site/`.
5. Clique em **Deploy**. A cada push na branch, o Vercel publica de novo sozinho.

## Rodar a demo do pitch (qualquer computador)

Abra **`demo/zelo.html`** no navegador (Chrome, Edge, Safari ou Firefox). É um arquivo único, com fontes embutidas, e funciona **sem internet**.

- **Família / Parceiro / Lado a lado:** use o painel à esquerda. Em "Lado a lado", tudo o que o parceiro marca aparece na hora para a família.
- **Pular para consulta agendada:** vai direto para o dia da consulta, se o tempo do pitch estiver curto.
- **Reiniciar demo:** volta ao início.
- No celular, a mesma página abre como app em tela cheia. Para trocar de perfil, use a aba Perfil.

Para editar, mexa em `demo/src/zelo.html` e gere de novo com `python3 demo/build.py`, que atualiza `demo/zelo.html` e `site/index.html`. Os ícones e a imagem de prévia são gerados com `python3 demo/assets.py`.

## App iOS (SwiftUI)

Fica em `ios/`. Abra `ios/Zelo.xcodeproj` no **Xcode 16 ou mais novo**.

- **iPhone (iOS 17+):** escolha um simulador ou o seu iPhone e rode com ⌘R. No aparelho, selecione o seu time em *Signing & Capabilities*.
- **Mac (macOS 14+):** escolha "My Mac". Ele abre o palco com os dois celulares lado a lado, como na demo web.

Se o projeto não abrir, crie em *File ▸ New ▸ Project ▸ Multiplatform ▸ App* um app chamado `Zelo` e arraste a pasta `ios/Zelo` para dentro dele, substituindo os arquivos gerados.

Estrutura:

```
ios/Zelo/
  ZeloApp.swift          entrada do app + palco do Mac
  Design/Theme.swift     tokens de cor e tipografia
  Design/Components.swift  card, botões, tags, linha do tempo, toast
  Model/Models.swift     médicos, serviços, agendamento, registros, preços
  Model/AppState.swift   roteiro da Zélia e estado compartilhado
  Familia/               Início, Zélia (chat), Acompanhar, Registro, Consultas, Perfil
  Parceiro/              Agenda, Atendimento, Ganhos, Treinamento, Perfil
```

## Design

O design system está em [`design-system/zelo/MASTER.md`](design-system/zelo/MASTER.md).

## O que é simulado (e precisa ser validado)

- **Integração com convênios e tokens.** No protótipo, a Zélia "lê" a carteirinha e o convênio "autoriza".
- **Pagamento, mapa e chamada ao 192.**
- **A Zélia segue um roteiro.** Ela entende as respostas sugeridas e algumas perguntas livres (remédio, status, preço, nova consulta).
- **Premissas a testar:** preço do veículo adaptado, repasse de 75% ao motorista, seleção e qualificação de acompanhantes, tipo de veículo e se o preço cobre a operação.
