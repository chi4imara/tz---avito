//
//  TestDoubles.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import Foundation
@testable import WildlifeAtlas

final class MockHTTPClient: HTTPClient, @unchecked Sendable {
    var responses: [Result<String, Error>]
    private(set) var requestedURLs: [URL] = []

    init(json: String) {
        responses = [.success(json)]
    }

    init(responses: [Result<String, Error>]) {
        self.responses = responses
    }

    func value<T: Decodable>(for request: URLRequest, as type: T.Type) async throws -> T {
        if let url = request.url { requestedURLs.append(url) }

        let index = min(max(requestedURLs.count - 1, 0), responses.count - 1)
        switch responses[index] {
        case .success(let json):
            do {
                return try JSONDecoder().decode(type, from: Data(json.utf8))
            } catch {
                throw NetworkError.decoding
            }
        case .failure(let error):
            throw error
        }
    }

    func queryValue(_ name: String, requestIndex: Int = 0) -> String? {
        guard requestedURLs.indices.contains(requestIndex),
              let components = URLComponents(url: requestedURLs[requestIndex], resolvingAgainstBaseURL: false) else {
            return nil
        }
        return components.queryItems?.first { $0.name == name }?.value
    }
}

final class StubINaturalistService: INaturalistService, @unchecked Sendable {
    var pages: [Int: Result<Page<WildlifeObservation>, Error>] = [:]
    var observationResult: Result<WildlifeObservation, Error> = .failure(NetworkError.notFound)
    var taxaResult: Result<[Taxon], Error> = .success([])
    var taxonDetailsResult: Result<Taxon, Error> = .failure(NetworkError.notFound)
    var delay: Duration = .zero

    private(set) var requestedQueries: [ObservationQuery] = []
    private(set) var requestedPages: [Int] = []
    private(set) var requestedSearchTerms: [String] = []

    func observations(matching query: ObservationQuery, page: Int) async throws -> Page<WildlifeObservation> {
        requestedQueries.append(query)
        requestedPages.append(page)
        if delay > .zero { try await Task.sleep(for: delay) }
        guard let result = pages[page] else {
            return Page(results: [], page: page, perPage: 30, totalResults: 0)
        }
        return try result.get()
    }

    func observation(id: Int) async throws -> WildlifeObservation {
        if delay > .zero { try await Task.sleep(for: delay) }
        return try observationResult.get()
    }

    func searchTaxa(matching term: String, limit: Int) async throws -> [Taxon] {
        requestedSearchTerms.append(term)
        if delay > .zero { try await Task.sleep(for: delay) }
        return try taxaResult.get()
    }

    func taxonDetails(id: Int) async throws -> Taxon {
        try taxonDetailsResult.get()
    }
}

extension WildlifeObservation {
    static func stub(id: Int, name: String = "Red Fox", grade: QualityGrade = .research) -> WildlifeObservation {
        let json = """
        {
          "id": \(id),
          "quality_grade": "\(grade.rawValue)",
          "observed_on": "2025-05-12",
          "time_observed_at": null,
          "place_guess": null,
          "obscured": false,
          "photos": [],
          "taxon": {
            "id": 42069,
            "name": "Vulpes vulpes",
            "preferred_common_name": "\(name)",
            "rank": "species",
            "iconic_taxon_name": "Mammalia"
          }
        }
        """
        return try! JSONDecoder().decode(WildlifeObservation.self, from: Data(json.utf8))
    }
}

extension Page where Item == WildlifeObservation {
    static func stub(_ observations: [WildlifeObservation], page: Int = 1, total: Int? = nil, perPage: Int = 30) -> Page<WildlifeObservation> {
        Page(results: observations, page: page, perPage: perPage, totalResults: total ?? observations.count)
    }
}
