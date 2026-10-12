//
//  Theme.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import SwiftUI

enum Theme {
    static let background = dynamic(light: 0xF7F3EA, dark: 0x14140F)
    static let surface = dynamic(light: 0xFFFDF7, dark: 0x1E1E18)
    static let surfaceSecondary = dynamic(light: 0xEFE9DC, dark: 0x2A2A23)
    static let accent = dynamic(light: 0x1F4230, dark: 0x8FBF9F)
    static let accentSoft = dynamic(light: 0xE3EDE4, dark: 0x24382B)
    static let primaryText = dynamic(light: 0x1A1A15, dark: 0xF3F0E7)
    static let secondaryText = dynamic(light: 0x6B655A, dark: 0xA8A296)
    static let hairline = dynamic(light: 0xE2DBCC, dark: 0x33332B)
    static let warning = dynamic(light: 0xB4661C, dark: 0xE0A264)
    static let warningSoft = dynamic(light: 0xFBEEDC, dark: 0x3A2C18)

    static func display(_ style: Font.TextStyle, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .serif).weight(weight)
    }

    static let cardCornerRadius: CGFloat = 16

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension View {
    func atlasBackground() -> some View {
        background(Theme.background.ignoresSafeArea())
    }

    func atlasCard(cornerRadius: CGFloat = Theme.cardCornerRadius) -> some View {
        background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
