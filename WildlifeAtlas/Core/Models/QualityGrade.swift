//
//  QualityGrade.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

enum QualityGrade: String, Codable, Hashable, Sendable {
    case research
    case needsID = "needs_id"
    case casual

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = QualityGrade(rawValue: raw) ?? .casual
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var markLetter: String {
        switch self {
        case .research: "A"
        case .needsID: "B"
        case .casual: "C"
        }
    }

    var markCaption: String {
        switch self {
        case .research: "Excellent"
        case .needsID: "Good"
        case .casual: "Fair"
        }
    }

    var detailTitle: String {
        switch self {
        case .research: "Research grade"
        case .needsID: "Needs ID"
        case .casual: "Casual"
        }
    }

    var title: String { detailTitle }

    var symbolName: String {
        switch self {
        case .research: "checkmark.seal.fill"
        case .needsID: "questionmark.circle.fill"
        case .casual: "leaf.fill"
        }
    }
}
