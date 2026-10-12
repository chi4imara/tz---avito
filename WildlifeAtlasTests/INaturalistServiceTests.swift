//
//  INaturalistServiceTests.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import XCTest
@testable import WildlifeAtlas

final class INaturalistServiceTests: XCTestCase {
    private func makeService(json: String = Fixtures.observationsPage) -> (LiveINaturalistService, MockHTTPClient) {
        let client = MockHTTPClient(json: json)
        let service = LiveINaturalistService(client: client, baseURL: URL(string: "https://example.test/v2")!)
        return (service, client)
    }

    func testAlwaysRequestsWildObservations() async throws {
        let (service, client) = makeService()
        _ = try await service.observations(matching: ObservationQuery(), page: 1)
        XCTAssertEqual(client.queryValue("captive"), "false")
    }

    func testSortsByObservationDate() async throws {
        let (service, client) = makeService()
        var query = ObservationQuery()
        query.sortOrder = .oldestFirst

        _ = try await service.observations(matching: query, page: 1)

        XCTAssertEqual(client.queryValue("order_by"), "observed_on")
        XCTAssertEqual(client.queryValue("order"), "asc")
    }

    func testCombinesIndependentFilters() async throws {
        let (service, client) = makeService()
        var query = ObservationQuery()
        query.taxon = Taxon(id: 42069, name: "Vulpes vulpes", preferredCommonName: "Red Fox")
        query.quality = .research
        query.sortOrder = .newestFirst

        _ = try await service.observations(matching: query, page: 3)

        XCTAssertEqual(client.queryValue("taxon_id"), "42069")
        XCTAssertEqual(client.queryValue("quality_grade"), "research")
        XCTAssertEqual(client.queryValue("order"), "desc")
        XCTAssertEqual(client.queryValue("page"), "3")
    }

    func testOmitsQualityGradeForAnyGrade() async throws {
        let (service, client) = makeService()
        _ = try await service.observations(matching: ObservationQuery(), page: 1)

        XCTAssertNil(client.queryValue("quality_grade"))
        XCTAssertNil(client.queryValue("taxon_id"))
    }

    func testRequestsObservationByNumericIdentifier() async throws {
        let (service, client) = makeService()
        let observation = try await service.observation(id: 397_478_799)

        XCTAssertEqual(observation.id, 397_478_799)
        XCTAssertEqual(client.queryValue("id"), "397478799")
    }

    func testSearchesTaxaByTerm() async throws {
        let (service, client) = makeService(json: Fixtures.taxaAutocomplete)
        let taxa = try await service.searchTaxa(matching: "red f", limit: 12)

        XCTAssertEqual(taxa.map(\.displayName), ["Red Fox", "Red Imported Fire Ant"])
        XCTAssertEqual(client.queryValue("q"), "red f")
        XCTAssertEqual(client.queryValue("per_page"), "12")
    }

    func testMapsMissingObservationToNotFound() async throws {
        let empty = #"{ "total_results": 0, "page": 1, "per_page": 30, "results": [] }"#
        let (service, _) = makeService(json: empty)

        do {
            _ = try await service.observation(id: 1)
            XCTFail("expected NetworkError.notFound")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .notFound)
        }
    }
}
