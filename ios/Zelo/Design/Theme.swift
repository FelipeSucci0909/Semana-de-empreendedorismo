import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

// MARK: - Tokens de cor (espelham as variáveis CSS da demo web)

extension PlatformColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension Color {
    /// Cor que muda sozinha entre modo claro e escuro.
    static func dyn(_ light: UInt32, _ dark: UInt32) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
        #else
        return Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? NSColor(hex: dark) : NSColor(hex: light)
        })
        #endif
    }
}

enum Z {
    static let bg = Color.dyn(0xEEF4F3, 0x0B1716)
    static let surface = Color.dyn(0xFFFFFF, 0x12211F)
    static let surface2 = Color.dyn(0xF4F8F7, 0x182B29)
    static let text = Color.dyn(0x0F2B2A, 0xE6F2F0)
    static let text2 = Color.dyn(0x4A6261, 0xA3BDBA)
    static let border = Color.dyn(0xD3E2E0, 0x26403D)

    static let primary = Color.dyn(0x0B6B70, 0x5BC6C0)
    static let onPrimary = Color.dyn(0xFFFFFF, 0x062221)
    static let primarySoft = Color.dyn(0xDCEFEE, 0x163A38)
    static let primaryInk = Color.dyn(0x08494C, 0x0A3A3A)

    static let accent = Color.dyn(0xB4532A, 0xF0A27E)
    static let onAccent = Color.dyn(0xFFFFFF, 0x2A1206)
    static let accentSoft = Color.dyn(0xFBE9E0, 0x3A2418)

    static let success = Color.dyn(0x1D7A4B, 0x5DD08F)
    static let successSoft = Color.dyn(0xDDF2E6, 0x12301F)
    static let warning = Color.dyn(0x8A5A00, 0xF2C062)
    static let warningSoft = Color.dyn(0xFBF0D6, 0x33280F)
    static let danger = Color.dyn(0xB42318, 0xFF8A7E)
    static let dangerSoft = Color.dyn(0xFDE4E1, 0x3A1612)

    static let bubbleMe = Color.dyn(0x0B6B70, 0x1E5856)
    static let onBubbleMe = Color.dyn(0xFFFFFF, 0xF1FBFA)

    static let radiusMD: CGFloat = 16
    static let radiusLG: CGFloat = 22
}

// MARK: - Tipografia (Dynamic Type; títulos arredondados no lugar da Lexend)

extension Font {
    static let zLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.semibold)
    static let zTitle = Font.system(.title2, design: .rounded).weight(.semibold)
    static let zHeadline = Font.system(.title3, design: .rounded).weight(.semibold)
    static let zEyebrow = Font.footnote.weight(.bold)
}
