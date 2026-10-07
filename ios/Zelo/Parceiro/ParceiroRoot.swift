import SwiftUI
import Charts

struct ParceiroRoot: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app
        TabView(selection: $app.parTab) {
            NavigationStack { AgendaView() }
                .tabItem { Label("Agenda", systemImage: "calendar") }
                .tag(ParTab.agenda)
            NavigationStack { GanhosView() }
                .tabItem { Label("Ganhos", systemImage: "dollarsign.circle") }
                .tag(ParTab.ganhos)
            NavigationStack { TreinamentoView() }
                .tabItem { Label("Treinamento", systemImage: "graduationcap") }
                .tag(ParTab.treino)
            NavigationStack { ParceiroPerfilView() }
                .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
                .tag(ParTab.perfil)
        }
        .tint(Z.primary)
        .overlay(alignment: .top) {
            if let t = app.toastParceiro {
                ToastView(toast: t).padding(.top, 8).id(t.id)
            }
        }
    }
}

// MARK: - Agenda

struct AgendaView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app
        VStack(spacing: 0) {
            ScreenHeader(sub: "Motorista parceiro · \(Pessoas.nota) ★", title: "Olá, Carlos", dark: true, leading: { EmptyView() }, trailing: {
                Toggle(app.online ? "Disponível" : "Pausado", isOn: $app.online)
                    .toggleStyle(.switch)
                    .tint(Z.success)
                    .fixedSize()
                    .font(.subheadline.weight(.bold))
            })
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        stat("\(app.agendamento == nil ? 2 : 3)", "atendimentos hoje")
                        stat(brl((app.agendamento?.servicos.repasseMotorista ?? 0) + 120), "a receber hoje")
                    }
                    Eyebrow(text: "Quinta, 15/10")
                    if let a = app.agendamento { cardMaria(a) } else { semPedidos }
                    outro("13h00 · João, 76", "Lapa → Hospital · Vila Clementino", tag: "Cadeira de rodas")
                    outro("16h30 · Lúcia, 88", "Laboratório → Casa · Pompeia", tag: nil)
                }
                .padding(16)
            }
        }
        .background(Z.bg)
        .zHideNavBar()
    }

    private func stat(_ valor: String, _ rotulo: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(valor).font(.zTitle)
            Text(rotulo).font(.subheadline.weight(.semibold)).foregroundStyle(Z.text2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Z.surface, in: RoundedRectangle(cornerRadius: Z.radiusMD, style: .continuous))
    }

    private func cardMaria(_ a: Agendamento) -> some View {
        let t = app.trip
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(formatarHora(a.minutos - 65)) · Maria, 82").font(.zHeadline)
                Spacer()
                if t.finalizado { TagView(text: "concluído", style: .ok) }
                else if t.etapa >= 0 { TagView(text: "em andamento", style: .accent) }
                else { TagView(text: "próximo") }
            }
            Label("Perdizes → \(a.medico.bairro) · volta prevista \(a.hora(etapa: 5))", systemImage: "mappin.and.ellipse")
                .foregroundStyle(Z.text2)
            FlowLayout(spacing: 6) {
                TagView(text: "Ajuda para entrar no carro", icon: "car", style: .warn)
                TagView(text: "Usa bengala", icon: "figure.walk", style: .warn)
                if a.servicos.adaptado { TagView(text: "Cadeira de rodas", icon: "figure.roll", style: .warn) }
                if a.servicos.acompanhante { TagView(text: "Com a Ana", icon: "heart") }
            }
            NavigationLink { AtendimentoView() } label: {
                Text(t.finalizado ? "Ver atendimento" : (t.etapa >= 0 ? "Continuar atendimento" : "Iniciar atendimento"))
            }
            .buttonStyle(ZButtonStyle())
        }
        .zCard()
    }

    private var semPedidos: some View {
        VStack(spacing: 8) {
            IconBadge(systemName: "calendar")
            Text("Sem novos pedidos").font(.zHeadline)
            Text("Quando a família agendar com a Zélia, o atendimento aparece aqui.")
                .multilineTextAlignment(.center).foregroundStyle(Z.text2)
        }
        .frame(maxWidth: .infinity)
        .zCard()
    }

    private func outro(_ titulo: String, _ trajeto: String, tag: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(titulo).font(.headline)
                Spacer()
                TagView(text: "só transporte")
            }
            Label(trajeto, systemImage: "mappin.and.ellipse").foregroundStyle(Z.text2)
            if let tag { TagView(text: tag, icon: "figure.roll", style: .warn) }
        }
        .zCard()
        .opacity(0.8)
    }
}

// MARK: - Atendimento

struct AtendimentoView: View {
    @Environment(AppState.self) private var app
    @State private var confirmarSOS = false

    var body: some View {
        @Bindable var app = app
        if let a = app.agendamento {
            let t = app.trip
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label {
                            Text("**Buscar:** \(Pessoas.endereco)\n**Levar:** \(a.medico.nome) · \(a.medico.bairro)")
                        } icon: { Image(systemName: "mappin.and.ellipse") }
                        FlowLayout(spacing: 6) {
                            TagView(text: "Ajuda para entrar no carro", icon: "car", style: .warn)
                            TagView(text: "Usa bengala", icon: "figure.walk", style: .warn)
                            TagView(text: "Enxerga pouco de perto", icon: "eye", style: .warn)
                        }
                        HStack(spacing: 10) {
                            Button {} label: { Label("Família", systemImage: "phone.fill") }
                                .buttonStyle(ZButtonStyle(kind: .secondary, compact: true))
                            Button {} label: { Label("Rota", systemImage: "map") }
                                .buttonStyle(ZButtonStyle(kind: .secondary, compact: true))
                        }
                    }
                    .zCard()

                    VStack(alignment: .leading, spacing: 6) {
                        Eyebrow(text: "Etapas · a família vê em tempo real")
                        ForEach(Etapa.todas.indices, id: \.self) { i in
                            HStack(spacing: 12) {
                                Image(systemName: t.etapa >= i ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundStyle(t.etapa >= i ? Z.success : Z.border)
                                Text(Etapa.todas[i].parceiro).foregroundStyle(t.etapa >= i ? Z.text : Z.text2)
                                Spacer()
                                if t.etapa >= i { Text(a.hora(etapa: i)).font(.subheadline).foregroundStyle(Z.text2) }
                            }
                            .frame(minHeight: 44)
                        }
                    }
                    .zCard()

                    if t.finalizado {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Atendimento finalizado", systemImage: "checkmark.circle.fill").font(.headline).foregroundStyle(Z.success)
                            Text("Registro enviado à família. Você recebe **\(brl(a.servicos.repasseMotorista))** por este atendimento.")
                        }
                        .zCard(Z.primarySoft, shadow: false)
                    } else if t.etapa + 1 < Etapa.todas.count {
                        Button { app.avancarEtapa() } label: { Label(Etapa.todas[t.etapa + 1].parceiro, systemImage: "checkmark") }
                            .buttonStyle(ZButtonStyle())
                    } else {
                        Button { app.finalizar() } label: { Label("Finalizar e enviar à família", systemImage: "doc.text") }
                            .buttonStyle(ZButtonStyle())
                    }

                    if a.servicos.acompanhante && t.etapa >= 3 && !t.finalizado { gravacao(a) }

                    Button(role: .destructive) { confirmarSOS = true } label: {
                        Label("Emergência", systemImage: "exclamationmark.triangle.fill")
                    }
                    .buttonStyle(ZButtonStyle(kind: .danger))
                }
                .padding(16)
            }
            .background(Z.bg)
            .navigationTitle("Maria, 82 · \(a.horario)")
            .zInlineTitle()
            .confirmationDialog("Ligar para o SAMU (192) e avisar a família?", isPresented: $confirmarSOS, titleVisibility: .visible) {
                Button("Sim, ligar 192", role: .destructive) { app.emergencia() }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("A família recebe a sua localização na hora.")
            }
        } else {
            ContentUnavailableView("Sem atendimento", systemImage: "car")
        }
    }

    private func gravacao(_ a: Agendamento) -> some View {
        @Bindable var app = app
        let t = app.trip
        return VStack(alignment: .leading, spacing: 12) {
            Eyebrow(text: "Registro da consulta · Ana")
            Toggle("A Maria e \(a.medico.ehMedica ? "a médica" : "o médico") autorizaram a gravação", isOn: $app.trip.consentimento)
                .tint(Z.success)
            if t.gravando {
                Label("Gravando · \(t.segundosGravados / 60):\(String(format: "%02d", t.segundosGravados % 60))", systemImage: "record.circle")
                    .font(.headline).foregroundStyle(Z.danger)
                    .symbolEffect(.pulse)
            }
            Button(t.gravando ? "Parar gravação" : (t.gravou ? "Continuar gravando" : "Gravar consulta")) { app.alternarGravacao() }
                .buttonStyle(ZButtonStyle(kind: t.gravando ? .danger : .secondary, compact: true))
                .disabled(!t.consentimento)
            Text("Observações para a família").font(.subheadline.weight(.bold))
            TextField("Ex.: a médica pediu para voltar em 3 meses com exame", text: $app.trip.notas, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Z.surface2, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Z.border, lineWidth: 1.5))
        }
        .zCard()
    }
}

// MARK: - Ganhos, treinamento e perfil

private struct Dia: Identifiable {
    let id: String
    let valor: Int
}

struct GanhosView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        let hoje = (app.agendamento?.servicos.repasseMotorista ?? 0) + 120
        let dias = [Dia(id: "Seg", valor: 180), Dia(id: "Ter", valor: 240), Dia(id: "Qua", valor: 120), Dia(id: "Qui", valor: hoje)]
        VStack(spacing: 0) {
            ScreenHeader(sub: "Semana de 12 a 18/10", title: "Ganhos", dark: true)
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Eyebrow(text: "Total da semana")
                        Text(brl(dias.reduce(0) { $0 + $1.valor })).font(.zLargeTitle)
                        Chart(dias) { d in
                            BarMark(x: .value("Dia", d.id), y: .value("Valor", d.valor))
                                .foregroundStyle(d.id == "Qui" ? Z.primary : Z.primarySoft)
                                .cornerRadius(8)
                                .annotation(position: .top) { Text(brl(d.valor)).font(.caption.weight(.semibold)).foregroundStyle(Z.text2) }
                        }
                        .chartYAxis(.hidden)
                        .frame(height: 170)
                    }
                    .zCard()
                    VStack(alignment: .leading, spacing: 8) {
                        Eyebrow(text: "Como você ganha")
                        Text("Você recebe \(Int(Precos.repasseMotorista * 100))% do valor do transporte de cada atendimento. O pagamento cai toda semana.")
                    }
                    .zCard()
                }
                .padding(16)
            }
        }
        .background(Z.bg)
        .zHideNavBar()
    }
}

struct TreinamentoView: View {
    private struct Modulo: Identifiable {
        var id: String { nome }
        let nome: String
        let progresso: Double
    }
    private let modulos = [
        Modulo(nome: "Embarque e desembarque seguro", progresso: 1), Modulo(nome: "Comunicação com idosos", progresso: 1),
        Modulo(nome: "Cadeira de rodas e veículo adaptado", progresso: 1), Modulo(nome: "Primeiros socorros", progresso: 0.6),
        Modulo(nome: "Privacidade e consentimento (LGPD)", progresso: 0)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(sub: "Credenciamento Zelo", title: "Treinamento", dark: true)
            ScrollView {
                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "checkmark.shield")
                        VStack(alignment: .leading) {
                            Text("Parceiro credenciado").fontWeight(.semibold)
                            Text("Antecedentes verificados · CNH com EAR · 3 de 5 módulos").font(.subheadline)
                        }
                    }
                    .zCard(Z.primarySoft, shadow: false)

                    VStack(alignment: .leading, spacing: 14) {
                        Eyebrow(text: "Módulos")
                        ForEach(modulos) { m in
                            let nome = m.nome, p = m.progresso
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(nome).fontWeight(.semibold)
                                    Spacer()
                                    if p >= 1 { TagView(text: "concluído", style: .ok) }
                                    else if p > 0 { TagView(text: "\(Int(p * 100))%", style: .warn) }
                                    else { TagView(text: "começar") }
                                }
                                ProgressView(value: p).tint(p >= 1 ? Z.success : Z.warning)
                            }
                        }
                    }
                    .zCard()
                }
                .padding(16)
            }
        }
        .background(Z.bg)
        .zHideNavBar()
    }
}

struct ParceiroPerfilView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Perfil", dark: true)
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 14) {
                            Iniciais(text: Pessoas.motoristaIni, size: 64)
                            VStack(alignment: .leading) {
                                Text(Pessoas.motorista).font(.zTitle)
                                Text("Motorista parceiro · \(Pessoas.nota) ★").foregroundStyle(Z.text2)
                            }
                        }
                        KeyValue(key: "Veículo", value: Pessoas.carro)
                        KeyValue(key: "Placa", value: Pessoas.placa)
                    }
                    .zCard()
                    Button { app.papel = .familia } label: { Label("Entrar como família", systemImage: "arrow.left.arrow.right") }
                        .buttonStyle(ZButtonStyle(kind: .secondary))
                }
                .padding(16)
            }
        }
        .background(Z.bg)
        .zHideNavBar()
    }
}
