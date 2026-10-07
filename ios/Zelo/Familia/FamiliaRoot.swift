import SwiftUI

struct FamiliaRoot: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app
        TabView(selection: $app.famTab) {
            NavigationStack { InicioView() }
                .tabItem { Label("Início", systemImage: "house") }
                .tag(FamTab.inicio)
            NavigationStack { ZeliaChatView() }
                .tabItem { Label("Zélia", systemImage: "bubble.left.and.bubble.right") }
                .tag(FamTab.zelia)
            NavigationStack { ConsultasView() }
                .tabItem { Label("Consultas", systemImage: "calendar") }
                .tag(FamTab.consultas)
                .badge(app.registros.contains(where: \.novo) ? 1 : 0)
            NavigationStack { FamiliaPerfilView() }
                .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
                .tag(FamTab.perfil)
        }
        .tint(Z.primary)
        .overlay(alignment: .top) {
            if let t = app.toastFamilia {
                ToastView(toast: t).padding(.top, 8).id(t.id)
            }
        }
        .onChange(of: app.famTab) {
            if app.famTab == .zelia { app.iniciarConversa() }
        }
    }
}

// MARK: - Início

struct InicioView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(sub: "Cuidando de", title: "Maria, 82", leading: { Iniciais(text: "M") }, trailing: {
                Image(systemName: "bell").font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Z.surface, in: Circle())
                    .accessibilityLabel("Notificações")
            })
            ScrollView {
                VStack(spacing: 14) {
                    if let a = app.agendamento, app.trip.emAndamento { cardAgora(a) }
                    cardZelia
                    if let a = app.agendamento, !app.trip.emAndamento { ConsultaCard(agendamento: a) }
                    if app.agendamento == nil { semConsulta }
                    if let r = app.registros.first { cardUltimoRegistro(r) }
                    cardRemedios
                }
                .padding(16)
            }
        }
        .background(Z.bg)
        .zHideNavBar()
    }

    private func cardAgora(_ a: Agendamento) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AGORA · \(a.hora(etapa: app.trip.etapa))").font(.zEyebrow).opacity(0.85)
            Text(app.textoEtapaFamilia(app.trip.etapa)).font(.zTitle)
            Label("\(Pessoas.motorista) com a Maria", systemImage: "car.fill")
            NavigationLink { AcompanharView() } label: { Text("Acompanhar ao vivo") }
                .buttonStyle(ZButtonStyle(kind: .inverted, compact: true))
        }
        .foregroundStyle(Z.onPrimary)
        .zCard(Z.primary)
        .accessibilityElement(children: .contain)
    }

    private var cardZelia: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZeliaAvatar()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Oi! Sou a Zélia.").font(.headline)
                    Text(app.agendamento == nil ? "Precisa marcar uma consulta? Eu cuido de tudo."
                                                : "Posso marcar o retorno, tirar dúvidas ou explicar um remédio.")
                        .foregroundStyle(Z.text2)
                }
            }
            Button { app.famTab = .zelia } label: { Label("Falar com a Zélia", systemImage: "bubble.left") }
                .buttonStyle(ZButtonStyle())
        }
        .zCard(Z.primarySoft, shadow: false)
    }

    private var semConsulta: some View {
        VStack(spacing: 10) {
            IconBadge(systemName: "calendar")
            Text("Nenhuma consulta marcada").font(.zHeadline)
            Text("Peça para a Zélia. Ela busca o médico, agenda e organiza o transporte.")
                .multilineTextAlignment(.center).foregroundStyle(Z.text2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .zCard()
    }

    private func cardUltimoRegistro(_ r: Registro) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(text: "Último registro")
            HStack(spacing: 12) {
                IconBadge(systemName: "doc.text")
                VStack(alignment: .leading) {
                    Text("\(r.especialidade) · \(r.data)").fontWeight(.semibold)
                    Text(r.medico).font(.subheadline).foregroundStyle(Z.text2)
                }
                Spacer()
                if r.novo { TagView(text: "novo", style: .accent) }
            }
            NavigationLink { RegistroView(registroID: r.id) } label: { Text("Ver o que o médico disse") }
                .buttonStyle(ZButtonStyle(kind: .secondary, compact: true))
        }
        .zCard()
    }

    @ViewBuilder private var cardRemedios: some View {
        let remedios = app.registros.flatMap(\.remedios).reduce(into: [Remedio]()) { acc, r in
            if !acc.contains(where: { $0.nome == r.nome }) { acc.append(r) }
        }
        if !remedios.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: "Remédios da Maria")
                ForEach(remedios.prefix(3), id: \.nome) { m in
                    HStack(spacing: 12) {
                        IconBadge(systemName: "pills", tint: Z.accent, fill: Z.accentSoft)
                        VStack(alignment: .leading) {
                            Text(m.nome).fontWeight(.semibold)
                            Text(m.dose).font(.subheadline).foregroundStyle(Z.text2)
                        }
                        Spacer()
                        Text(m.quando).fontWeight(.semibold)
                    }
                    .padding(.vertical, 6)
                }
            }
            .zCard()
        }
    }
}

struct ConsultaCard: View {
    @Environment(AppState.self) private var app
    let agendamento: Agendamento

    var body: some View {
        let a = agendamento
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: app.trip.finalizado ? "Consulta concluída" : "Próxima consulta")
            Text("\(a.especialidade) · \(a.horario)").font(.zHeadline)
            Label("\(a.medico.nome) · \(a.medico.bairro)", systemImage: "stethoscope").foregroundStyle(Z.text2)
            FlowLayout(spacing: 6) {
                if a.convenio != "Particular" { TagView(text: "Convênio autorizado", icon: "checkmark.shield", style: .ok) }
                if a.servicos.transporte { TagView(text: "Busca às \(a.hora(etapa: 1))", icon: "car.fill", style: .ok) }
                if a.servicos.adaptado { TagView(text: "Veículo adaptado", icon: "figure.roll", style: .ok) }
                if a.servicos.acompanhante { TagView(text: "Acompanhante: Ana", icon: "heart", style: .ok) }
            }
            if app.trip.finalizado, let r = app.registros.first {
                NavigationLink { RegistroView(registroID: r.id) } label: { Text("Ver registro da consulta") }
                    .buttonStyle(ZButtonStyle(compact: true))
            } else {
                NavigationLink { AcompanharView() } label: { Text("Acompanhar o dia") }
                    .buttonStyle(ZButtonStyle(compact: true))
            }
        }
        .zCard()
    }
}

// MARK: - Consultas

struct ConsultasView: View {
    @Environment(AppState.self) private var app
    @State private var aba = 0

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(sub: "Maria, 82", title: "Consultas")
            ScrollView {
                VStack(spacing: 14) {
                    Picker("Filtro", selection: $aba) {
                        Text("Próximas").tag(0)
                        Text("Anteriores").tag(1)
                    }
                    .pickerStyle(.segmented)

                    if aba == 0 {
                        if let a = app.agendamento, !app.trip.finalizado {
                            ConsultaCard(agendamento: a)
                        } else {
                            VStack(spacing: 10) {
                                Text("Nada marcado").font(.zHeadline)
                                Button("Marcar com a Zélia") { app.famTab = .zelia }
                                    .buttonStyle(ZButtonStyle(compact: true))
                            }
                            .zCard()
                        }
                    } else {
                        VStack(spacing: 0) {
                            ForEach(app.registros) { r in
                                NavigationLink { RegistroView(registroID: r.id) } label: {
                                    HStack(spacing: 12) {
                                        IconBadge(systemName: "doc.text")
                                        VStack(alignment: .leading) {
                                            Text(r.especialidade).fontWeight(.semibold)
                                            Text("\(r.data) · \(r.medico)").font(.subheadline).foregroundStyle(Z.text2)
                                        }
                                        Spacer()
                                        if r.novo { TagView(text: "novo", style: .accent) }
                                        Image(systemName: "chevron.right").foregroundStyle(Z.text2)
                                    }
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                if r.id != app.registros.last?.id { Divider() }
                            }
                        }
                        .zCard()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Eyebrow(text: "Quem recebe os registros")
                        pessoa("V", "Você", "responsável · paga os serviços", ativa: false)
                        Divider()
                        pessoa("S", "Suzana", app.suzana ? "recebe etapas e registros" : "ainda não convidada", ativa: app.suzana)
                    }
                    .zCard()
                }
                .padding(16)
            }
        }
        .background(Z.bg)
        .zHideNavBar()
    }

    private func pessoa(_ ini: String, _ nome: String, _ sub: String, ativa: Bool) -> some View {
        HStack(spacing: 12) {
            Iniciais(text: ini)
            VStack(alignment: .leading) {
                Text(nome).fontWeight(.semibold)
                Text(sub).font(.subheadline).foregroundStyle(Z.text2)
            }
            Spacer()
            if ativa { TagView(text: "ativa", style: .ok) }
        }
    }
}

// MARK: - Perfil

struct FamiliaPerfilView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Perfil")
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            Iniciais(text: "M", size: 64)
                            VStack(alignment: .leading) {
                                Text("Maria, 82").font(.zTitle)
                                Text(Pessoas.endereco).foregroundStyle(Z.text2)
                            }
                        }
                        FlowLayout(spacing: 6) {
                            TagView(text: "Usa bengala", icon: "figure.walk")
                            TagView(text: "Ajuda para entrar no carro", icon: "car")
                            TagView(text: "Enxerga pouco de perto", icon: "eye")
                        }
                    }
                    .zCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Eyebrow(text: "Convênio")
                        KeyValue(key: "Plano", value: "Vida Plena Saúde · Ouro")
                        KeyValue(key: "Carteirinha", value: "final 4821")
                    }
                    .zCard()

                    HStack(spacing: 12) {
                        IconBadge(systemName: "message.fill", tint: Z.success, fill: Z.successSoft)
                        VStack(alignment: .leading) {
                            Text("Zélia no WhatsApp").fontWeight(.semibold)
                            Text("Maria e você conversam com ela por lá também").font(.subheadline).foregroundStyle(Z.text2)
                        }
                        Spacer()
                        TagView(text: "conectado", style: .ok)
                    }
                    .zCard()

                    Button { app.papel = .parceiro } label: { Label("Entrar como parceiro", systemImage: "arrow.left.arrow.right") }
                        .buttonStyle(ZButtonStyle(kind: .secondary))
                }
                .padding(16)
            }
        }
        .background(Z.bg)
        .zHideNavBar()
    }
}
