//
//  TaxonSearchViewModelTests.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import XCTest
@testable import WildlifeAtlas

@MainActor
final class TaxonSearchViewModelTests: XCTestCase {
    func testShortTermKeepsRecentsState() async {
        let service = StubINaturalistService()
        let viewModel = TaxonSearchViewModel(service: service)

        viewModel.term = "r"
        try? await Task.sleep(for: .milliseconds(400))

        XCTAssertEqual(viewModel.state, .recents)
        XCTAssertTrue(service.requestedSearchTerms.isEmpty)
    }

    func testSuccessfulSearchShowsResults() async {
        let service = StubINaturalistService()
        service.taxaResult = .success([
            Taxon(id: 1, name: "Vulpes vulpes", preferredCommonName: "Red Fox")
        ])
        let viewModel = TaxonSearchViewModel(service: service)

        viewModel.term = "red f"
        await waitUntil {
            if case .results(let taxa) = viewModel.state { return taxa.count == 1 }
            return false
        }

        XCTAssertEqual(service.requestedSearchTerms.last, "red f")
    }

    func testEmptySearchShowsEmptyState() async {
        let service = StubINaturalistService()
        service.taxaResult = .success([])
        let viewModel = TaxonSearchViewModel(service: service)

        viewModel.term = "zzzz"
        await waitUntil { viewModel.state == .empty }
    }

    func testFailedSearchShowsErrorAndRetryWorks() async {
        let service = StubINaturalistService()
        service.taxaResult = .failure(NetworkError.offline)
        let viewModel = TaxonSearchViewModel(service: service)

        viewModel.term = "fox"
        await waitUntil {
            if case .failed = viewModel.state { return true }
            return false
        }

        service.taxaResult = .success([Taxon(id: 1, name: "Vulpes vulpes")])
        viewModel.retry()
        await waitUntil {
            if case .results = viewModel.state { return true }
            return false
        }
    }

    func testResetReturnsToRecents() async {
        let service = StubINaturalistService()
        service.taxaResult = .success([Taxon(id: 1, name: "Vulpes vulpes")])
        let viewModel = TaxonSearchViewModel(service: service)

        viewModel.term = "fox"
        await waitUntil {
            if case .results = viewModel.state { return true }
            return false
        }

        viewModel.reset()
        XCTAssertEqual(viewModel.term, "")
        XCTAssertEqual(viewModel.state, .recents)
    }

    private func waitUntil(
        timeout: TimeInterval = 2,
        _ condition: @escaping @MainActor () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(20))
        }
        XCTFail("Condition was not met before timeout")
    }
}
