import SwiftUI

@main
struct ZeloApp: App {
    @State private var app = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(app)
        }
        #if os(macOS)
        .defaultSize(width: 1240, height: 900)
        #endif
    }
}

struct RootView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        #if os(macOS)
        PalcoMac()
        #else
        Group {
            switch app.papel {
            case .familia: FamiliaRoot()
            case .parceiro: ParceiroRoot()
            }
        }
        .animation(.default, value: app.papel)
        #endif
    }
}

#if os(macOS)
/// No Mac (apresentação): painel com roteiro e os celulares lado a lado.
struct PalcoMac: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 12) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Z.onPrimary)
                        .frame(width: 48, height: 48)
                        .background(Z.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Text("zelo").font(.system(size: 34, weight: .semibold, design: .rounded))
                }
                Text("A Zélia marca a consulta e cuida de todo o caminho até lá. A família acompanha tudo.")
                    .font(.system(.title3, design: .rounded).weight(.medium))
                Picker("Visualizar", selection: $app.modoPalco) {
                    ForEach(ModoPalco.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: "Roteiro da demo")
                    ForEach(Array(roteiro.enumerated()), id: \.offset) { i, passo in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(i + 1)").font(.footnote.weight(.bold)).foregroundStyle(Z.primary)
                                .frame(width: 24, height: 24).background(Z.primarySoft, in: Circle())
                            Text(passo).foregroundStyle(Z.text2)
                        }
                    }
                }
                Button { app.pularParaAgendada() } label: { Label("Pular para consulta agendada", systemImage: "bolt.fill") }
                    .buttonStyle(ZButtonStyle(kind: .secondary, compact: true))
                Button { app.reiniciar() } label: { Label("Reiniciar demo", systemImage: "arrow.counterclockwise") }
                    .buttonStyle(ZButtonStyle(kind: .secondary, compact: true))
                Spacer()
                Text("Protótipo · Semana Concentrada de Empreendedorismo FGV · 2026. Convênio, pagamento e mapa são simulados.")
                    .font(.footnote).foregroundStyle(Z.text2)
            }
            .padding(24)
            .frame(width: 320)
            .background(Z.surface)

            HStack(spacing: 32) {
                if app.modoPalco != .parceiro { telefone("Família · você cuidando da Maria") { FamiliaRoot() } }
                if app.modoPalco != .familia { telefone("Parceiro · Carlos, motorista") { ParceiroRoot() } }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Z.bg.opacity(0.6))
        }
        .foregroundStyle(Z.text)
    }

    private let roteiro = [
        "Peça a consulta à Zélia: cidade, convênio e especialidade.",
        "Escolha médico e horário: a Zélia pede a autorização ao convênio.",
        "Monte o pacote: transporte, veículo adaptado, acompanhante.",
        "No parceiro, avance as etapas do dia.",
        "A família acompanha em tempo real e recebe o registro."
    ]

    private func telefone<Content: View>(_ titulo: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 10) {
            Text(titulo).font(.headline).foregroundStyle(Z.text2)
            content()
                .frame(width: 393, height: 780)
                .background(Z.bg)
                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 40, style: .continuous).strokeBorder(Color.black.opacity(0.85), lineWidth: 10))
                .shadow(color: .black.opacity(0.2), radius: 24, y: 16)
        }
    }
}
#endif
