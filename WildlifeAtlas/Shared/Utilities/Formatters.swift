//
//  Formatters.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

extension ObservedDate {
    var shortText: String {
        format(dateStyle: .medium, timeStyle: .none)
    }

    var fullText: String {
        hasTime ? format(dateStyle: .long, timeStyle: .short) : format(dateStyle: .long, timeStyle: .none)
    }

    private func format(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.timeZone = hasTime ? (timeZone ?? .current) : TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}

extension Int {
    var abbreviatedCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = self >= 10_000 ? 0 : 1

        switch self {
        case 1_000_000...:
            return (formatter.string(from: NSNumber(value: Double(self) / 1_000_000)) ?? "\(self)") + "M"
        case 1_000...:
            return (formatter.string(from: NSNumber(value: Double(self) / 1_000)) ?? "\(self)") + "K"
        default:
            return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        }
    }
}
