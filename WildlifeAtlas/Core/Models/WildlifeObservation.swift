//
//  WildlifeObservation.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

struct WildlifeObservation: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let taxon: Taxon?
    let photos: [Photo]
    let user: ObservationUser?
    let qualityGrade: QualityGrade
    let observedDate: ObservedDate?
    let placeGuess: String?
    let webURL: URL?
    let geoprivacy: String?
    let taxonGeoprivacy: String?
    let isObscured: Bool

    private enum CodingKeys: String, CodingKey {
        case id, taxon, photos, user
        case qualityGrade = "quality_grade"
        case timeObservedAt = "time_observed_at"
        case observedOn = "observed_on"
        case placeGuess = "place_guess"
        case uri
        case geoprivacy
        case taxonGeoprivacy = "taxon_geoprivacy"
        case obscured
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        taxon = try container.decodeIfPresent(Taxon.self, forKey: .taxon)
        photos = try container.decodeIfPresent([Photo].self, forKey: .photos) ?? []
        user = try container.decodeIfPresent(ObservationUser.self, forKey: .user)
        qualityGrade = try container.decodeIfPresent(QualityGrade.self, forKey: .qualityGrade) ?? .casual

        if let timestamp = try container.decodeIfPresent(String.self, forKey: .timeObservedAt),
           let date = DateParsing.timestamp(from: timestamp) {
            observedDate = ObservedDate(date: date, hasTime: true, timeZone: DateParsing.timeZone(from: timestamp))
        } else if let day = try container.decodeIfPresent(String.self, forKey: .observedOn),
                  let date = DateParsing.dayOnly(from: day) {
            observedDate = ObservedDate(date: date, hasTime: false, timeZone: nil)
        } else {
            observedDate = nil
        }

        placeGuess = try container.decodeIfPresent(String.self, forKey: .placeGuess)
        webURL = try container.decodeIfPresent(URL.self, forKey: .uri)
        geoprivacy = try container.decodeIfPresent(String.self, forKey: .geoprivacy)
        taxonGeoprivacy = try container.decodeIfPresent(String.self, forKey: .taxonGeoprivacy)
        isObscured = try container.decodeIfPresent(Bool.self, forKey: .obscured) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(taxon, forKey: .taxon)
        try container.encode(photos, forKey: .photos)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encode(qualityGrade, forKey: .qualityGrade)
        if let observedDate {
            if observedDate.hasTime {
                try container.encode(
                    DateParsing.timestampString(from: observedDate.date, timeZone: observedDate.timeZone),
                    forKey: .timeObservedAt
                )
            } else {
                try container.encode(DateParsing.dayOnlyString(from: observedDate.date), forKey: .observedOn)
            }
        }
        try container.encodeIfPresent(placeGuess, forKey: .placeGuess)
        try container.encodeIfPresent(webURL, forKey: .uri)
        try container.encodeIfPresent(geoprivacy, forKey: .geoprivacy)
        try container.encodeIfPresent(taxonGeoprivacy, forKey: .taxonGeoprivacy)
        try container.encode(isObscured, forKey: .obscured)
    }

    var primaryPhoto: Photo? { photos.first }
    var displayName: String? { taxon?.displayName }
    var scientificName: String? { taxon?.scientificName }

    var isLocationHidden: Bool {
        let privateValues: Set<String> = ["obscured", "private"]
        if let geoprivacy, privateValues.contains(geoprivacy) { return true }
        if let taxonGeoprivacy, privateValues.contains(taxonGeoprivacy) { return true }
        return isObscured
    }

    var visiblePlace: String? {
        guard !isLocationHidden, let placeGuess, !placeGuess.isEmpty else { return nil }
        return placeGuess
    }

    var shareText: String {
        [displayName, scientificName].compactMap { $0 }.joined(separator: " · ")
    }
}

struct ObservedDate: Hashable, Sendable {
    let date: Date
    let hasTime: Bool
    let timeZone: TimeZone?
}
