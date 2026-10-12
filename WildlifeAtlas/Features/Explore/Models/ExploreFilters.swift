//
//  ExploreFilters.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import Foundation

enum QualityFilter: String, CaseIterable, Identifiable, Sendable {
    case any
    case research

    var id: String { rawValue }

    var title: String {
        switch self {
        case .any: "Any grade"
        case .research: "Research grade"
        }
    }

    var apiValue: String? {
        switch self {
        case .any: nil
        case .research: QualityGrade.research.rawValue
        }
    }
}

enum ObservationSortOrder: String, CaseIterable, Identifiable, Sendable {
    case newestFirst
    case oldestFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newestFirst: "Newest"
        case .oldestFirst: "Oldest"
        }
    }

    var apiValue: String {
        switch self {
        case .newestFirst: "desc"
        case .oldestFirst: "asc"
        }
    }
}

struct ObservationQuery: Equatable, Sendable {
    var taxon: Taxon?
    var quality: QualityFilter = .any
    var sortOrder: ObservationSortOrder = .newestFirst
    var matchingTaxonIDs: [Int]?

    var taxonTitle: String {
        taxon?.displayName ?? "All wildlife"
    }

    var isDefault: Bool {
        taxon == nil && quality == .any && sortOrder == .newestFirst && matchingTaxonIDs == nil
    }
}
