# Zelo

**A Zélia marca a consulta e cuida de todo o caminho até lá. A família acompanha tudo.**

Projeto da Semana Concentrada de Empreendedorismo FGV (tema: Cidades Inteligentes).

## O problema

Filhos que trabalham faltam ao trabalho para levar os pais idosos a consultas. Na entrevista de campo, isso aconteceu cerca de 4 vezes num único mês. O idoso não consegue usar o app do convênio sozinho e não pode ir de Uber comum, porque alguém precisa ajudar a entrar no carro e estacionar perto. Muitas vezes ele sai da consulta sem entender o remédio ou o retorno. Quando ninguém da família pode ir, paga-se cerca de R$ 300 por dia a alguém de confiança.

## A solução

1. **Pedido e agendamento.** A Zélia, uma agente de IA dentro do app e também no WhatsApp, pergunta a cidade, o convênio (aceita foto da carteirinha) e a especialidade. Ela busca médicos, agenda e pede a autorização ao convênio. Pode ser usada pelo próprio idoso ou pelos filhos.
2. **Pacote modular.** Transporte ida e volta (R$ 80), veículo adaptado (+R$ 40, estimativa) e acompanhante (R$ 300). O resumo da consulta para a família já vem incluso, e o preço é montado conforme o que se escolhe.
3. **No dia.** Motorista e acompanhante parceiros marcam cada etapa e a família acompanha em tempo real. A acompanhante grava a consulta, com consentimento, e registra o que o médico disse.
4. **Registro.** Resumo em linguagem simples, remédios com horário e próximos passos. Um botão pede à Zélia que marque o retorno.

## Rodar a demo do pitch (qualquer computador)

Abra **`demo/zelo.html`** no navegador (Chrome, Edge, Safari ou Firefox). É um arquivo único, com fontes embutidas, e funciona **sem internet**.

- **Família / Parceiro / Lado a lado:** use o painel à esquerda. Em "Lado a lado", tudo o que o parceiro marca aparece na hora para a família.
- **Pular para consulta agendada:** vai direto para o dia da consulta, se o tempo do pitch estiver curto.
- **Reiniciar demo:** volta ao início.
- No celular, a mesma página abre como app em tela cheia. Para trocar de perfil, use a aba Perfil.

Para editar, mexa em `demo/src/zelo.html` e gere de novo com `python3 demo/build.py`.

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
