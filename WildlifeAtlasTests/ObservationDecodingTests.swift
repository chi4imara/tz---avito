//
//  ObservationDecodingTests.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import XCTest
@testable import WildlifeAtlas

final class ObservationDecodingTests: XCTestCase {
    private func decode(_ json: String) throws -> Page<WildlifeObservation> {
        try JSONDecoder().decode(Page<WildlifeObservation>.self, from: Data(json.utf8))
    }

    func testDecodesFullObservation() throws {
        let observation = try XCTUnwrap(try decode(Fixtures.observationsPage).results.first)

        XCTAssertEqual(observation.id, 397_478_799)
        XCTAssertEqual(observation.displayName, "Red Fox")
        XCTAssertEqual(observation.scientificName, "Vulpes vulpes")
        XCTAssertEqual(observation.qualityGrade, .research)
        XCTAssertEqual(observation.photos.count, 2)
        XCTAssertEqual(observation.user?.displayName, "Clara Stuligross")
        XCTAssertEqual(observation.visiblePlace, "Walton Ln, Ardmore, PA, US")
        XCTAssertEqual(observation.webURL?.absoluteString, "https://www.inaturalist.org/observations/397478799")
    }

    func testKeepsObservationTimeZone() throws {
        let date = try XCTUnwrap(try decode(Fixtures.observationsPage).results.first?.observedDate)

        XCTAssertTrue(date.hasTime)
        XCTAssertEqual(date.timeZone?.secondsFromGMT(), -4 * 3600)
    }

    func testDecodesDateWithoutTime() throws {
        let date = try XCTUnwrap(try decode(Fixtures.dateOnlyObservation).results.first?.observedDate)

        XCTAssertFalse(date.hasTime)
        XCTAssertFalse(date.shortText.isEmpty)
    }

    func testDecodesObservationWithoutTaxonAndPhotos() throws {
        let observation = try XCTUnwrap(try decode(Fixtures.minimalObservation).results.first)

        XCTAssertNil(observation.displayName)
        XCTAssertNil(observation.primaryPhoto)
        XCTAssertNil(observation.observedDate)
        XCTAssertEqual(observation.qualityGrade, .casual)
    }

    func testUnknownQualityGradeFallsBackToCasual() throws {
        let observation = try XCTUnwrap(try decode(Fixtures.unknownGradeObservation).results.first)
        XCTAssertEqual(observation.qualityGrade, .casual)
    }

    func testHidesLocationForObscuredObservations() throws {
        for observation in try decode(Fixtures.obscuredObservations).results {
            XCTAssertTrue(observation.isLocationHidden, "id \(observation.id)")
            XCTAssertNil(observation.visiblePlace)
        }
    }

    func testDecodesTaxonAncestors() throws {
        let taxon = try XCTUnwrap(
            try JSONDecoder().decode(Page<Taxon>.self, from: Data(Fixtures.taxonDetails.utf8)).results.first
        )

        XCTAssertEqual(taxon.primaryAncestors.map(\.rank), ["kingdom", "class", "order", "family", "genus"])
        XCTAssertEqual(taxon.displayName, "Red Fox")
        XCTAssertEqual(taxon.iconicTaxon, .mammals)
    }

    func testObservationSurvivesEncodeDecodeRoundTrip() throws {
        let original = try XCTUnwrap(try decode(Fixtures.observationsPage).results.first)
        let restored = try JSONDecoder().decode(WildlifeObservation.self, from: try JSONEncoder().encode(original))
        XCTAssertEqual(restored, original)
    }

    func testPhotoLicenseTitleAndSizeReplacement() throws {
        let observation = try XCTUnwrap(try decode(Fixtures.observationsPage).results.first)
        let licensed = try XCTUnwrap(observation.photos.last)

        XCTAssertEqual(licensed.licenseTitle, "CC BY-NC")
        XCTAssertEqual(
            licensed.url(.medium)?.absoluteString,
            "https://static.inaturalist.org/photos/729026847/medium.jpg"
        )
    }
}
