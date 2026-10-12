//
//  DateParsing.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

enum DateParsing {
    private static let timestampFormatter = makeFormatter("yyyy-MM-dd'T'HH:mm:ssXXXXX")
    private static let fractionalTimestampFormatter = makeFormatter("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX")
    private static let dayFormatter: DateFormatter = {
        let formatter = makeFormatter("yyyy-MM-dd")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static func makeFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter
    }

    static func timestamp(from string: String) -> Date? {
        timestampFormatter.date(from: string) ?? fractionalTimestampFormatter.date(from: string)
    }

    static func dayOnly(from string: String) -> Date? {
        dayFormatter.date(from: string)
    }

    static func timestampString(from date: Date, timeZone: TimeZone?) -> String {
        let formatter = makeFormatter("yyyy-MM-dd'T'HH:mm:ssXXXXX")
        formatter.timeZone = timeZone ?? .current
        return formatter.string(from: date)
    }

    static func dayOnlyString(from date: Date) -> String {
        dayFormatter.string(from: date)
    }

    static func timeZone(from string: String) -> TimeZone? {
        if string.hasSuffix("Z") { return TimeZone(secondsFromGMT: 0) }

        guard let signIndex = string.lastIndex(where: { $0 == "+" || $0 == "-" }),
              signIndex > string.startIndex else { return nil }

        let offset = string[string.index(after: signIndex)...].replacingOccurrences(of: ":", with: "")
        guard offset.count == 4, let value = Int(offset) else { return nil }

        let seconds = (value / 100) * 3600 + (value % 100) * 60
        return TimeZone(secondsFromGMT: string[signIndex] == "-" ? -seconds : seconds)
    }
}
