import SwiftUI

// MARK: - Card

struct ZCard: ViewModifier {
    var fill: Color = Z.surface
    var shadow = true

    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill, in: RoundedRectangle(cornerRadius: Z.radiusLG, style: .continuous))
            .shadow(color: .black.opacity(shadow ? 0.06 : 0), radius: 10, y: 4)
    }
}

extension View {
    func zCard(_ fill: Color = Z.surface, shadow: Bool = true) -> some View {
        modifier(ZCard(fill: fill, shadow: shadow))
    }

    /// Esconde a barra de navegação nas telas raiz (usamos cabeçalho próprio).
    @ViewBuilder func zHideNavBar() -> some View {
        #if os(iOS)
        self.toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder func zInlineTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

// MARK: - Botões

struct ZButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, danger, dangerSolid, inverted }
    var kind: Kind = .primary
    var compact = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let (fg, bg, stroke): (Color, Color, Color) = {
            switch kind {
            case .primary: return (Z.onPrimary, Z.primary, .clear)
            case .secondary: return (Z.text, Z.surface2, Z.border)
            case .danger: return (Z.danger, Z.dangerSoft, Z.danger)
            case .dangerSolid: return (.white, Z.danger, .clear)
            case .inverted: return (Z.primary, Z.onPrimary, .clear)
            }
        }()
        return configuration.label
            .font(.system(compact ? .callout : .headline, design: .rounded).weight(.bold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: compact ? 48 : 56)
            .foregroundStyle(fg)
            .background(bg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(stroke, lineWidth: kind == .danger ? 2 : 1.5))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(isEnabled ? 1 : 0.45)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}

// MARK: - Peças pequenas

struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.zEyebrow)
            .tracking(0.8)
            .foregroundStyle(Z.text2)
    }
}

struct ZeliaAvatar: View {
    var size: CGFloat = 44
    var body: some View {
        Text("Z")
            .font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
            .foregroundStyle(Z.onAccent)
            .frame(width: size, height: size)
            .background(Z.accent, in: Circle())
            .accessibilityHidden(true)
    }
}

struct Iniciais: View {
    let text: String
    var size: CGFloat = 44
    var body: some View {
        Text(text)
            .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
            .foregroundStyle(Z.primary)
            .frame(width: size, height: size)
            .background(Z.primarySoft, in: Circle())
            .accessibilityHidden(true)
    }
}

struct IconBadge: View {
    let systemName: String
    var tint: Color = Z.primary
    var fill: Color = Z.primarySoft
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 42, height: 42)
            .background(fill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct TagView: View {
    enum Style { case neutral, ok, warn, accent }
    let text: String
    var icon: String?
    var style: Style = .neutral

    var body: some View {
        let (fg, bg): (Color, Color) = {
            switch style {
            case .neutral: return (Z.text2, Z.surface2)
            case .ok: return (Z.success, Z.successSoft)
            case .warn: return (Z.warning, Z.warningSoft)
            case .accent: return (Z.accent, Z.accentSoft)
            }
        }()
        HStack(spacing: 5) {
            if let icon { Image(systemName: icon).font(.caption.weight(.semibold)) }
            Text(text)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(fg)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(bg, in: Capsule())
    }
}

struct KeyValue: View {
    let key: String
    let value: String
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(key).foregroundStyle(Z.text2)
            Spacer(minLength: 12)
            Text(value).fontWeight(.semibold).multilineTextAlignment(.trailing)
        }
    }
}

/// Cabeçalho das telas raiz (substitui a barra de navegação padrão).
struct ScreenHeader<Leading: View, Trailing: View>: View {
    var sub: String?
    let title: String
    var dark = false
    @ViewBuilder var leading: Leading
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            leading
            VStack(alignment: .leading, spacing: 0) {
                if let sub {
                    Text(sub).font(.subheadline.weight(.semibold))
                        .foregroundStyle(dark ? Color.white.opacity(0.75) : Z.text2)
                }
                Text(title).font(.zTitle).lineLimit(1)
            }
            Spacer(minLength: 0)
            trailing
        }
        .foregroundStyle(dark ? Color.white : Z.text)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(dark ? Z.primaryInk : Z.bg)
    }
}

extension ScreenHeader where Leading == EmptyView, Trailing == EmptyView {
    init(sub: String? = nil, title: String, dark: Bool = false) {
        self.init(sub: sub, title: title, dark: dark, leading: { EmptyView() }, trailing: { EmptyView() })
    }
}

/// Interruptor no estilo da demo (pílula verde).
struct ZSwitch: View {
    let isOn: Bool
    var body: some View {
        Capsule()
            .fill(isOn ? Z.success : Z.border)
            .frame(width: 52, height: 32)
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle().fill(.white).shadow(radius: 1, y: 1).padding(3)
            }
            .animation(.easeOut(duration: 0.2), value: isOn)
            .accessibilityHidden(true)
    }
}

// MARK: - Layout que quebra linha (respostas rápidas, tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, width: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            width = max(width, x - spacing)
        }
        return CGSize(width: proposal.width ?? width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Linha do tempo

struct LinhaDoTempo: View {
    struct Item: Identifiable {
        let id: Int
        let titulo: String
        let detalhe: String
        let feito: Bool
        let atual: Bool
    }
    let itens: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(itens) { item in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(item.feito ? Z.success : Z.surface)
                                .overlay(Circle().strokeBorder(item.feito ? Z.success : (item.atual ? Z.primary : Z.border), lineWidth: 2))
                            if item.feito {
                                Image(systemName: "checkmark").font(.caption.weight(.heavy)).foregroundStyle(.white)
                            }
                        }
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(item.atual ? Z.primarySoft : .clear).padding(-5))
                        if item.id != itens.last?.id {
                            Rectangle().fill(item.feito ? Z.success : Z.border).frame(width: 2).frame(minHeight: 22)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.titulo)
                            .fontWeight(item.atual ? .bold : .regular)
                            .foregroundStyle(item.feito || item.atual ? Z.text : Z.text2)
                        Text(item.detalhe).font(.subheadline).foregroundStyle(Z.text2)
                    }
                    .padding(.bottom, 14)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

// MARK: - Toast

struct ToastView: View {
    let toast: Toast
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Z.accent)
                Image(systemName: toast.icone).font(.subheadline.weight(.bold)).foregroundStyle(Z.onAccent)
            }
            .frame(width: 34, height: 34)
            Text(toast.texto).font(.callout.weight(.semibold))
            Spacer(minLength: 0)
        }
        .foregroundStyle(Z.bg)
        .padding(12)
        .background(Z.text, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 14, y: 8)
        .padding(.horizontal, 12)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityAddTraits(.updatesFrequently)
    }
}
