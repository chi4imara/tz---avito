//
//  ExploreViewModelTests.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import XCTest
@testable import WildlifeAtlas

@MainActor
final class ExploreViewModelTests: XCTestCase {
    func testLoadIfNeededFetchesFirstPage() async {
        let service = StubINaturalistService()
        service.pages[1] = .success(.stub([.stub(id: 1), .stub(id: 2)], total: 60))
        let viewModel = ExploreViewModel(service: service)

        viewModel.loadIfNeeded()
        await waitUntil { viewModel.state == .content }

        XCTAssertEqual(viewModel.observations.map(\.id), [1, 2])
        XCTAssertTrue(viewModel.hasNextPage)
        XCTAssertEqual(service.requestedPages, [1])
        XCTAssertEqual(service.requestedQueries.first?.quality, .any)
    }

    func testEmptyPageShowsEmptyState() async {
        let service = StubINaturalistService()
        service.pages[1] = .success(.stub([], total: 0))
        let viewModel = ExploreViewModel(service: service)

        viewModel.reload()
        await waitUntil { viewModel.state == .empty }

        XCTAssertTrue(viewModel.observations.isEmpty)
    }

    func testFirstPageFailureShowsFailedState() async {
        let service = StubINaturalistService()
        service.pages[1] = .failure(NetworkError.offline)
        let viewModel = ExploreViewModel(service: service)

        viewModel.reload()
        await waitUntil {
            if case .failed = viewModel.state { return true }
            return false
        }

        XCTAssertTrue(viewModel.observations.isEmpty)
    }

    func testChangingFilterReloadsWithCombinedQuery() async {
        let service = StubINaturalistService()
        service.pages[1] = .success(.stub([.stub(id: 1)], total: 1))
        let viewModel = ExploreViewModel(service: service)

        viewModel.reload()
        await waitUntil { viewModel.state == .content }

        let taxon = Taxon(id: 42069, name: "Vulpes vulpes", preferredCommonName: "Red Fox")
        viewModel.select(taxon: taxon)
        viewModel.select(quality: .research)
        await waitUntil { service.requestedQueries.count >= 3 }

        let last = try! XCTUnwrap(service.requestedQueries.last)
        XCTAssertEqual(last.taxon?.id, 42069)
        XCTAssertEqual(last.quality, .research)
    }

    func testPaginationAppendsAndDeduplicates() async {
        let service = StubINaturalistService()
        service.pages[1] = .success(.stub([.stub(id: 1), .stub(id: 2)], total: 60))
        service.pages[2] = .success(.stub([.stub(id: 2), .stub(id: 3)], page: 2, total: 60))
        let viewModel = ExploreViewModel(service: service)

        viewModel.reload()
        await waitUntil { viewModel.state == .content }

        viewModel.loadNextPageIfNeeded(currentItem: .stub(id: 2))
        await waitUntil { viewModel.observations.count == 3 }

        XCTAssertEqual(viewModel.observations.map(\.id), [1, 2, 3])
        XCTAssertEqual(service.requestedPages, [1, 2])
    }

    func testNextPageErrorDoesNotClearLoadedContent() async {
        let service = StubINaturalistService()
        service.pages[1] = .success(.stub([.stub(id: 1)], total: 60))
        service.pages[2] = .failure(NetworkError.timedOut)
        let viewModel = ExploreViewModel(service: service)

        viewModel.reload()
        await waitUntil { viewModel.state == .content }

        viewModel.loadNextPageIfNeeded(currentItem: .stub(id: 1))
        await waitUntil { viewModel.nextPageError != nil }

        XCTAssertEqual(viewModel.state, .content)
        XCTAssertEqual(viewModel.observations.map(\.id), [1])
        XCTAssertEqual(viewModel.nextPageError, .timedOut)
    }

    func testRetryClearsNextPageErrorAndLoadsAgain() async {
        let service = StubINaturalistService()
        service.pages[1] = .success(.stub([.stub(id: 1)], total: 60))
        service.pages[2] = .failure(NetworkError.timedOut)
        let viewModel = ExploreViewModel(service: service)

        viewModel.reload()
        await waitUntil { viewModel.state == .content }
        viewModel.loadNextPageIfNeeded(currentItem: .stub(id: 1))
        await waitUntil { viewModel.nextPageError != nil }

        service.pages[2] = .success(.stub([.stub(id: 2)], page: 2, total: 60))
        viewModel.retry()
        await waitUntil { viewModel.observations.count == 2 }

        XCTAssertNil(viewModel.nextPageError)
        XCTAssertEqual(viewModel.observations.map(\.id), [1, 2])
    }

    func testToggleLayoutSwitchesListAndGrid() {
        let viewModel = ExploreViewModel(service: StubINaturalistService())
        XCTAssertEqual(viewModel.layout, .list)
        viewModel.toggleLayout()
        XCTAssertEqual(viewModel.layout, .grid)
        viewModel.toggleLayout()
        XCTAssertEqual(viewModel.layout, .list)
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
