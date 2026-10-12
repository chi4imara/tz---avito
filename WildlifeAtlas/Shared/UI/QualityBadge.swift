//
//  QualityBadge.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import SwiftUI

struct QualityBadge: View {
    enum Style {
        case mark
        case pill
    }

    let grade: QualityGrade
    var style: Style = .mark

    var body: some View {
        switch style {
        case .mark:
            markBadge
        case .pill:
            pillBadge
        }
    }

    private var markBadge: some View {
        VStack(spacing: 1) {
            Text(grade.markLetter)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text(grade.markCaption)
                .font(.system(size: 8, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(markForeground)
        .frame(width: 48, height: 48)
        .background(markBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityLabel("Quality: \(grade.detailTitle)")
    }

    private var pillBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: grade.symbolName)
                .font(.caption.weight(.semibold))
            Text(grade.detailTitle)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .foregroundStyle(markForeground)
        .background(markBackground, in: Capsule())
        .accessibilityLabel("Quality: \(grade.detailTitle)")
    }

    private var markForeground: Color {
        switch grade {
        case .research, .needsID: Theme.accent
        case .casual: Theme.warning
        }
    }

    private var markBackground: Color {
        switch grade {
        case .research: Theme.accentSoft
        case .needsID: Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.28, green: 0.32, blue: 0.18, alpha: 1)
                : UIColor(red: 0.91, green: 0.93, blue: 0.82, alpha: 1)
        })
        case .casual: Theme.warningSoft
        }
    }
}

struct IconLabel: View {
    let symbolName: String
    let text: String
    var font: Font = .subheadline

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbolName)
                .font(font.weight(.regular))
                .foregroundStyle(Theme.secondaryText)
                .frame(width: 16)
            Text(text)
                .font(font)
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(1)
        }
    }
}
