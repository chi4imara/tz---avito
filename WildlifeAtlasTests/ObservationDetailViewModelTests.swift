//
//  ObservationDetailViewModelTests.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import XCTest
@testable import WildlifeAtlas

@MainActor
final class ObservationDetailViewModelTests: XCTestCase {
    func testLoadsObservationAndTaxonomy() async throws {
        let service = StubINaturalistService()
        let observation = try XCTUnwrap(
            try JSONDecoder()
                .decode(Page<WildlifeObservation>.self, from: Data(Fixtures.observationsPage.utf8))
                .results.first
        )
        let taxon = try XCTUnwrap(
            try JSONDecoder()
                .decode(Page<Taxon>.self, from: Data(Fixtures.taxonDetails.utf8))
                .results.first
        )
        service.observationResult = .success(observation)
        service.taxonDetailsResult = .success(taxon)

        let viewModel = ObservationDetailViewModel(observationID: observation.id, service: service)
        await viewModel.loadIfNeeded()

        guard case .content(let loaded) = viewModel.state else {
            return XCTFail("expected content")
        }
        XCTAssertEqual(loaded.id, observation.id)
        XCTAssertEqual(viewModel.taxonDetails?.primaryAncestors.count, 5)
    }

    func testFailureShowsFailedState() async {
        let service = StubINaturalistService()
        service.observationResult = .failure(NetworkError.notFound)
        let viewModel = ObservationDetailViewModel(observationID: 1, service: service)

        await viewModel.loadIfNeeded()

        guard case .failed(let error) = viewModel.state else {
            return XCTFail("expected failed")
        }
        XCTAssertEqual(error, .notFound)
    }

    func testLoadIfNeededDoesNotReloadContent() async throws {
        let service = StubINaturalistService()
        let observation = WildlifeObservation.stub(id: 5)
        service.observationResult = .success(observation)
        let viewModel = ObservationDetailViewModel(observationID: 5, service: service)

        await viewModel.loadIfNeeded()
        service.observationResult = .failure(NetworkError.offline)
        await viewModel.loadIfNeeded()

        guard case .content = viewModel.state else {
            return XCTFail("expected content to remain")
        }
    }
}
