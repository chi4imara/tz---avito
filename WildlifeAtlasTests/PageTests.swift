//
//  PageTests.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import XCTest
@testable import WildlifeAtlas

final class PageTests: XCTestCase {
    private func page(page: Int, perPage: Int, total: Int, count: Int? = nil) -> Page<WildlifeObservation> {
        let results = (0..<(count ?? perPage)).map { WildlifeObservation.stub(id: page * 1000 + $0) }
        return Page(results: results, page: page, perPage: perPage, totalResults: total)
    }

    func testHasNextPageWhileResultsRemain() {
        XCTAssertTrue(page(page: 1, perPage: 30, total: 100).hasNextPage)
        XCTAssertTrue(page(page: 3, perPage: 30, total: 100).hasNextPage)
    }

    func testHasNoNextPageOnLastPage() {
        XCTAssertFalse(page(page: 4, perPage: 30, total: 100).hasNextPage)
    }

    func testHasNoNextPageWhenResultsAreEmpty() {
        XCTAssertFalse(page(page: 1, perPage: 30, total: 100, count: 0).hasNextPage)
    }

    func testStopsAtApiPaginationLimit() {
        XCTAssertFalse(page(page: 334, perPage: 30, total: 156_371).hasNextPage)
    }

    func testDecodesStringCounters() throws {
        let json = #"{ "total_results": "2", "page": "1", "per_page": "30", "results": [] }"#
        let decoded = try JSONDecoder().decode(Page<WildlifeObservation>.self, from: Data(json.utf8))

        XCTAssertEqual(decoded.totalResults, 2)
        XCTAssertEqual(decoded.page, 1)
        XCTAssertEqual(decoded.perPage, 30)
    }
}
