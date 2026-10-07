import SwiftUI

struct ZeliaChatView: View {
    @Environment(AppState.self) private var app
    @State private var texto = ""
    @State private var ouvindo = false
    @FocusState private var focado: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(sub: "Sua assistente do Zelo", title: "Zélia", leading: { ZeliaAvatar() }, trailing: {
                TagView(text: "WhatsApp", icon: "message.fill", style: .ok)
            })

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(app.chat) { msg in
                            MensagemView(msg: msg).id(msg.id)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        if app.digitando { Digitando().id("digitando") }
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: app.chat.count) { rolar(proxy) }
                .onChange(of: app.digitando) { rolar(proxy) }
                .onAppear { rolar(proxy, animado: false) }
            }

            composer
        }
        .background(Z.bg)
        .zHideNavBar()
        .onAppear { app.iniciarConversa() }
    }

    private func rolar(_ proxy: ScrollViewProxy, animado: Bool = true) {
        let alvo: AnyHashable? = app.digitando ? AnyHashable("digitando") : app.chat.last.map { AnyHashable($0.id) }
        guard let alvo else { return }
        if animado { withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo(alvo, anchor: .bottom) } }
        else { proxy.scrollTo(alvo, anchor: .bottom) }
    }

    private var composer: some View {
        VStack(spacing: 10) {
            let opcoes = app.respostasRapidas
            if !opcoes.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(opcoes, id: \.self) { q in
                        Button(q) { app.responder(q) }
                            .font(.callout.weight(.bold))
                            .foregroundStyle(Z.primary)
                            .padding(.horizontal, 16)
                            .frame(minHeight: 44)
                            .background(Z.surface, in: Capsule())
                            .overlay(Capsule().strokeBorder(Z.primary, lineWidth: 1.5))
                            .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(spacing: 8) {
                Button { if app.flow == .convenio { app.responder("Foto da carteirinha", anexo: true) } } label: {
                    Image(systemName: "camera").font(.title3).frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Z.text2)
                .accessibilityLabel("Enviar foto")

                TextField(ouvindo ? "Ouvindo…" : "Fale com a Zélia", text: $texto)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 18)
                    .frame(height: 50)
                    .background(Z.surface2, in: Capsule())
                    .overlay(Capsule().strokeBorder(Z.border, lineWidth: 1.5))
                    .focused($focado)
                    .submitLabel(.send)
                    .onSubmit(enviar)

                if texto.isEmpty {
                    Button(action: falar) {
                        Image(systemName: "mic.fill").font(.title3)
                            .foregroundStyle(Z.onAccent)
                            .frame(width: 50, height: 50)
                            .background(Z.accent, in: Circle())
                            .scaleEffect(ouvindo ? 1.08 : 1)
                            .animation(ouvindo ? .easeInOut(duration: 0.5).repeatForever() : .default, value: ouvindo)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Falar por áudio")
                } else {
                    Button(action: enviar) {
                        Image(systemName: "paperplane.fill").font(.title3)
                            .foregroundStyle(Z.onPrimary)
                            .frame(width: 50, height: 50)
                            .background(Z.primary, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Enviar")
                }
            }
        }
        .padding(12)
        .background(Z.surface)
        .overlay(alignment: .top) { Divider() }
    }

    private func enviar() {
        let t = texto
        texto = ""
        app.responder(t)
    }

    /// Simula a fala: “ouve” por 1,5 s e envia a primeira resposta sugerida.
    private func falar() {
        guard !ouvindo, !app.digitando else { return }
        ouvindo = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1500))
            ouvindo = false
            if let q = app.respostasRapidas.first { app.responder(q) }
        }
    }
}

// MARK: - Mensagens

private struct Digitando: View {
    @State private var fase = false
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZeliaAvatar(size: 32)
            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle().fill(Z.text2).frame(width: 8, height: 8)
                        .opacity(fase ? 0.9 : 0.25)
                        .animation(.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2), value: fase)
                }
            }
            .padding(16)
            .background(Z.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .onAppear { fase = true }
        .accessibilityLabel("Zélia está digitando")
    }
}

struct MensagemView: View {
    @Environment(AppState.self) private var app
    let msg: ChatMsg

    private var textoSimples: String {
        if case let .texto(t) = msg.kind { return t }
        return ""
    }

    var body: some View {
        if msg.deMim {
            HStack {
                Spacer(minLength: 48)
                Group {
                    if msg.anexo {
                        Label("Foto da carteirinha", systemImage: "camera").fontWeight(.semibold)
                    } else {
                        Text(textoSimples)
                    }
                }
                .foregroundStyle(Z.onBubbleMe)
                .padding(.horizontal, 15).padding(.vertical, 12)
                .background(Z.bubbleMe, in: UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 20, bottomTrailingRadius: 6, topTrailingRadius: 20, style: .continuous))
            }
        } else {
            switch msg.kind {
            case .texto(let t):
                HStack(alignment: .bottom, spacing: 8) {
                    ZeliaAvatar(size: 32)
                    Text(LocalizedStringKey(t))
                        .padding(.horizontal, 15).padding(.vertical, 12)
                        .background(Z.surface, in: UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 6, bottomTrailingRadius: 20, topTrailingRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                    Spacer(minLength: 40)
                }
            case .nota(let icone, let t):
                Label(t, systemImage: icone)
                    .fontWeight(.semibold)
                    .foregroundStyle(Z.success)
                    .padding(.horizontal, 15).padding(.vertical, 12)
                    .background(Z.successSoft, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.leading, 40)
            case .medicos(let esp, let lista):
                VStack(spacing: 10) {
                    ForEach(Array(lista.enumerated()), id: \.offset) { di, d in
                        MedicoCard(medico: d, especialidade: esp, indice: di, msg: msg)
                    }
                }
            case .pacote:
                PacoteCard(msg: msg)
            case .confirmacao:
                if let a = app.agendamento { ConfirmacaoCard(agendamento: a) }
            }
        }
    }
}

private struct MedicoCard: View {
    @Environment(AppState.self) private var app
    let medico: Medico
    let especialidade: String
    let indice: Int
    let msg: ChatMsg

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                IconBadge(systemName: "stethoscope")
                VStack(alignment: .leading) {
                    Text(medico.nome).fontWeight(.semibold)
                    Text("\(especialidade) · \(medico.bairro) · \(medico.distancia)").font(.subheadline).foregroundStyle(Z.text2)
                }
            }
            TagView(text: medico.acessibilidade, icon: "figure.roll", style: .ok)
            FlowLayout(spacing: 8) {
                ForEach(Array(medico.horarios.enumerated()), id: \.offset) { si, h in
                    let escolhido = msg.escolha == SlotPick(medico: indice, horario: si)
                    Button(h) { app.escolherHorario(msgID: msg.id, medico: indice, horario: si) }
                        .font(.callout.weight(.bold))
                        .foregroundStyle(escolhido ? Z.onPrimary : Z.primary)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 44)
                        .background(escolhido ? Z.primary : Z.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Z.primary, lineWidth: 1.5))
                        .buttonStyle(.plain)
                        .disabled(msg.escolha != nil || app.flow != .medico)
                        .opacity(msg.escolha != nil && !escolhido ? 0.4 : 1)
                }
            }
        }
        .padding(14)
        .background(Z.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}

private struct PacoteCard: View {
    @Environment(AppState.self) private var app
    let msg: ChatMsg

    var body: some View {
        let sv = msg.travado ? (app.agendamento?.servicos ?? app.servicos) : app.servicos
        VStack(alignment: .leading, spacing: 4) {
            Eyebrow(text: "Pacote do dia")
            linha(\.transporte, sv, "car.fill", "Transporte ida e volta", "Motorista treinado ajuda a entrar e sair", brl(Precos.transporte))
            Divider()
            linha(\.adaptado, sv, "figure.roll", "Veículo adaptado", "Para cadeira de rodas", "+" + brl(Precos.adaptado))
            Divider()
            linha(\.acompanhante, sv, "heart", "Acompanhante na consulta", "Fica com a Maria e registra tudo", brl(Precos.acompanhante))
            Divider()
            HStack(spacing: 12) {
                IconBadge(systemName: "doc.text")
                VStack(alignment: .leading) {
                    Text("Resumo para a família").fontWeight(.semibold)
                    Text("O que o médico disse, remédios e retorno").font(.subheadline).foregroundStyle(Z.text2)
                }
                Spacer()
                TagView(text: "incluso", style: .ok)
            }
            .padding(.vertical, 10)
            HStack(alignment: .firstTextBaseline) {
                Text("Total").foregroundStyle(Z.text2)
                Spacer()
                Text(brl(sv.total)).font(.system(.title, design: .rounded).weight(.semibold))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: sv.total)
            }
            .padding(.vertical, 6)
            if !msg.travado {
                Button("Confirmar pacote") { app.confirmarPacote(msgID: msg.id) }
                    .buttonStyle(ZButtonStyle())
            }
        }
        .padding(14)
        .background(Z.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private func linha(_ kp: WritableKeyPath<Servicos, Bool>, _ sv: Servicos, _ icone: String,
                       _ titulo: String, _ sub: String, _ preco: String) -> some View {
        Button { app.alternarServico(kp) } label: {
            HStack(spacing: 12) {
                IconBadge(systemName: icone)
                VStack(alignment: .leading, spacing: 2) {
                    Text(titulo).fontWeight(.semibold)
                    Text(sub).font(.subheadline).foregroundStyle(Z.text2)
                    Text(preco).fontWeight(.bold).foregroundStyle(Z.primary)
                }
                Spacer()
                ZSwitch(isOn: sv[keyPath: kp])
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(msg.travado)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(sv[keyPath: kp] ? .isSelected : [])
        .accessibilityHint("Toque para incluir ou tirar do pacote")
    }
}

private struct ConfirmacaoCard: View {
    let agendamento: Agendamento

    var body: some View {
        let a = agendamento
        VStack(alignment: .leading, spacing: 8) {
            Label("Consulta confirmada", systemImage: "checkmark.circle.fill").font(.headline).foregroundStyle(Z.success)
            KeyValue(key: "Consulta", value: "\(a.especialidade) · \(a.horario)")
            KeyValue(key: "Médico", value: a.medico.nome)
            if a.servicos.transporte {
                KeyValue(key: "Busca em casa", value: a.hora(etapa: 1))
                KeyValue(key: "Motorista", value: "Carlos · \(Pessoas.placa)")
            }
            if a.servicos.acompanhante { KeyValue(key: "Acompanhante", value: Pessoas.acompanhante) }
            Divider()
            KeyValue(key: "Pago (\(a.pagamento))", value: brl(a.total))
        }
        .padding(14)
        .background(Z.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}
