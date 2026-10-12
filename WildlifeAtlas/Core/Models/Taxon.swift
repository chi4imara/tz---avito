//
//  Taxon.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

struct Taxon: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let preferredCommonName: String?
    let rank: String?
    let iconicTaxonName: String?
    let defaultPhoto: Photo?
    let ancestors: [Taxon]?
    let observationsCount: Int?

    private enum CodingKeys: String, CodingKey {
        case id, name, rank, ancestors
        case preferredCommonName = "preferred_common_name"
        case iconicTaxonName = "iconic_taxon_name"
        case defaultPhoto = "default_photo"
        case observationsCount = "observations_count"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        preferredCommonName = try container.decodeIfPresent(String.self, forKey: .preferredCommonName)
        rank = try container.decodeIfPresent(String.self, forKey: .rank)
        iconicTaxonName = try container.decodeIfPresent(String.self, forKey: .iconicTaxonName)
        defaultPhoto = try container.decodeIfPresent(Photo.self, forKey: .defaultPhoto)
        ancestors = try container.decodeIfPresent([Taxon].self, forKey: .ancestors)
        observationsCount = try container.decodeIfPresent(Int.self, forKey: .observationsCount)
    }

    init(
        id: Int,
        name: String,
        preferredCommonName: String? = nil,
        rank: String? = nil,
        iconicTaxonName: String? = nil,
        defaultPhoto: Photo? = nil,
        ancestors: [Taxon]? = nil,
        observationsCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.preferredCommonName = preferredCommonName
        self.rank = rank
        self.iconicTaxonName = iconicTaxonName
        self.defaultPhoto = defaultPhoto
        self.ancestors = ancestors
        self.observationsCount = observationsCount
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(preferredCommonName, forKey: .preferredCommonName)
        try container.encodeIfPresent(rank, forKey: .rank)
        try container.encodeIfPresent(iconicTaxonName, forKey: .iconicTaxonName)
        try container.encodeIfPresent(defaultPhoto, forKey: .defaultPhoto)
        try container.encodeIfPresent(ancestors, forKey: .ancestors)
        try container.encodeIfPresent(observationsCount, forKey: .observationsCount)
    }

    var displayName: String {
        if let preferredCommonName, !preferredCommonName.isEmpty { return preferredCommonName }
        return name
    }

    var scientificName: String? {
        guard !name.isEmpty, name != displayName else { return nil }
        return name
    }

    var rankTitle: String? {
        guard let rank, !rank.isEmpty else { return nil }
        return rank.replacingOccurrences(of: "_", with: " ").capitalized
    }

    var iconicTaxon: IconicTaxon? {
        IconicTaxon(apiName: iconicTaxonName)
    }

    var primaryAncestors: [Taxon] {
        let interestingRanks = ["kingdom", "phylum", "class", "order", "family", "genus"]
        return (ancestors ?? []).filter { interestingRanks.contains($0.rank ?? "") }
    }
}
