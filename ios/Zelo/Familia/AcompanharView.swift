import SwiftUI
import MapKit

struct AcompanharView: View {
    @Environment(AppState.self) private var app

    private static let casa = CLLocationCoordinate2D(latitude: -23.5372, longitude: -46.6795)
    private static let clinica = CLLocationCoordinate2D(latitude: -23.5617, longitude: -46.6880)
    private static let rota: [CLLocationCoordinate2D] = [
        casa,
        CLLocationCoordinate2D(latitude: -23.5450, longitude: -46.6795),
        CLLocationCoordinate2D(latitude: -23.5450, longitude: -46.6880),
        clinica
    ]
    private static let inicio = CLLocationCoordinate2D(latitude: -23.5320, longitude: -46.6760)
    private static let meio = CLLocationCoordinate2D(latitude: -23.5450, longitude: -46.6840)

    private var posicaoCarro: CLLocationCoordinate2D {
        switch app.trip.etapa {
        case ..<1: return Self.inicio
        case 1: return Self.casa
        case 2, 3: return Self.clinica
        case 4: return Self.meio
        default: return Self.casa
        }
    }

    var body: some View {
        if let a = app.agendamento {
            ScrollView {
                VStack(spacing: 14) {
                    mapa
                    pessoas(a)
                    VStack(alignment: .leading, spacing: 12) {
                        Eyebrow(text: "Andamento")
                        LinhaDoTempo(itens: itens(a))
                    }
                    .zCard()
                    if app.trip.finalizado, let r = app.registros.first {
                        NavigationLink { RegistroView(registroID: r.id) } label: {
                            Label("Ver registro da consulta", systemImage: "doc.text")
                        }
                        .buttonStyle(ZButtonStyle())
                    }
                    HStack(spacing: 10) {
                        Button { app.famTab = .zelia } label: { Label("Zélia", systemImage: "bubble.left") }
                            .buttonStyle(ZButtonStyle(kind: .secondary, compact: true))
                        Button {} label: { Label("Ligar", systemImage: "phone.fill") }
                            .buttonStyle(ZButtonStyle(kind: .secondary, compact: true))
                    }
                }
                .padding(16)
            }
            .background(Z.bg)
            .navigationTitle("\(a.especialidade) · hoje")
            .zInlineTitle()
        } else {
            ContentUnavailableView("Nenhuma consulta marcada", systemImage: "calendar")
        }
    }

    private var mapa: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -23.5480, longitude: -46.6820),
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)))) {
            MapPolyline(coordinates: Self.rota)
                .stroke(Z.primary, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            Marker("Casa da Maria", systemImage: "house.fill", coordinate: Self.casa).tint(Z.primary)
            Marker("Clínica", systemImage: "cross.case.fill", coordinate: Self.clinica).tint(Z.accent)
            Annotation("Carlos", coordinate: posicaoCarro) {
                Image(systemName: "car.fill")
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Z.primary, in: Circle())
                    .overlay(Circle().strokeBorder(.white, lineWidth: 3))
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: Z.radiusLG, style: .continuous))
        .animation(.easeInOut(duration: 1.2), value: app.trip.etapa)
        .accessibilityLabel("Mapa do trajeto com a posição do carro")
    }

    private func pessoas(_ a: Agendamento) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Iniciais(text: Pessoas.motoristaIni)
                VStack(alignment: .leading) {
                    Text(Pessoas.motorista).fontWeight(.semibold)
                    Text("\(Pessoas.carro) · \(Pessoas.placa) · ★ \(Pessoas.nota)").font(.subheadline).foregroundStyle(Z.text2)
                }
            }
            if a.servicos.acompanhante {
                HStack(spacing: 12) {
                    Iniciais(text: Pessoas.acompanhanteIni)
                    VStack(alignment: .leading) {
                        Text(Pessoas.acompanhante).fontWeight(.semibold)
                        Text("Acompanhante · \(Pessoas.acompanhanteCargo)").font(.subheadline).foregroundStyle(Z.text2)
                    }
                }
            }
        }
        .zCard()
    }

    private func itens(_ a: Agendamento) -> [LinhaDoTempo.Item] {
        let t = app.trip
        var lista = Etapa.todas.indices.map { i in
            LinhaDoTempo.Item(id: i, titulo: app.textoEtapaFamilia(i),
                              detalhe: t.etapa >= i ? a.hora(etapa: i) : "previsto \(a.hora(etapa: i))",
                              feito: t.etapa >= i, atual: i == t.etapa && !t.finalizado && i < 5)
        }
        lista.append(LinhaDoTempo.Item(id: 99, titulo: "Registro da consulta enviado",
                                       detalhe: t.finalizado ? "pronto para ver" : "depois da consulta",
                                       feito: t.finalizado, atual: false))
        return lista
    }
}

// MARK: - Registro da consulta

struct RegistroView: View {
    @Environment(AppState.self) private var app
    let registroID: String
    @State private var tocando = false
    @State private var progresso = 0.0

    var body: some View {
        if let r = app.registros.first(where: { $0.id == registroID }) {
            ScrollView {
                VStack(spacing: 14) {
                    if let audio = r.audio { player(audio) }

                    VStack(alignment: .leading, spacing: 10) {
                        Eyebrow(text: r.medico.hasPrefix("Dra.") ? "O que a médica disse" : "O que o médico disse")
                        Text(r.resumo).font(.title3).lineSpacing(3)
                        Text("\(r.medico) · registrado por \(r.registradoPor)").font(.subheadline).foregroundStyle(Z.text2)
                    }
                    .zCard()

                    if !r.remedios.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Eyebrow(text: "Remédios")
                            ForEach(r.remedios, id: \.nome) { m in
                                HStack(alignment: .top, spacing: 12) {
                                    IconBadge(systemName: "pills", tint: Z.accent, fill: Z.accentSoft)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(m.nome).fontWeight(.semibold)
                                        Text(m.dose)
                                        Text("\(m.quando) · \(m.duracao)").font(.subheadline).foregroundStyle(Z.text2)
                                    }
                                }
                            }
                        }
                        .zCard()
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Eyebrow(text: "Próximos passos")
                        ForEach(r.proximos, id: \.self) { p in
                            Label(p, systemImage: "circle.fill").labelStyle(Marcador())
                        }
                        Button("Pedir à Zélia para marcar o retorno") { app.pedirRetorno(de: r.especialidade) }
                            .buttonStyle(ZButtonStyle(compact: true))
                    }
                    .zCard()

                    if !r.notas.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Eyebrow(text: "Observação da acompanhante")
                            Text(r.notas)
                        }
                        .zCard()
                    }

                    Button { app.famTab = .zelia } label: { Label("Tirar dúvida com a Zélia", systemImage: "bubble.left") }
                        .buttonStyle(ZButtonStyle(kind: .secondary, compact: true))
                }
                .padding(16)
            }
            .background(Z.bg)
            .navigationTitle("\(r.especialidade) · \(r.data)")
            .zInlineTitle()
            .onAppear { app.marcarLido(r.id) }
        } else {
            ContentUnavailableView("Registro não encontrado", systemImage: "doc.text")
        }
    }

    private func player(_ duracao: String) -> some View {
        HStack(spacing: 12) {
            Button {
                tocando.toggle()
                withAnimation(tocando ? .linear(duration: 24 * (1 - progresso)) : .default) { progresso = tocando ? 1 : progresso }
            } label: {
                Image(systemName: tocando ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .foregroundStyle(Z.onPrimary)
                    .frame(width: 48, height: 48)
                    .background(Z.primary, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(tocando ? "Pausar áudio da consulta" : "Ouvir áudio da consulta")
            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: progresso).tint(Z.primary)
                Text("Áudio da consulta · \(duracao) · gravado com consentimento").font(.subheadline).foregroundStyle(Z.text2)
            }
        }
        .zCard()
    }
}

private struct Marcador: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle().fill(Z.primary).frame(width: 7, height: 7).alignmentGuide(.firstTextBaseline) { $0[.bottom] - 2 }
            configuration.title
        }
    }
}
