//
//  INaturalistService.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

protocol INaturalistService: Sendable {
    func observations(matching query: ObservationQuery, page: Int) async throws -> Page<WildlifeObservation>
    func observation(id: Int) async throws -> WildlifeObservation
    func searchTaxa(matching term: String, limit: Int) async throws -> [Taxon]
    func taxonDetails(id: Int) async throws -> Taxon
}

struct LiveINaturalistService: INaturalistService {
    static let shared = LiveINaturalistService()
    static let pageSize = 30

    private let client: HTTPClient
    private let baseURL: URL

    init(client: HTTPClient = URLSessionHTTPClient.shared, baseURL: URL = LiveINaturalistService.defaultBaseURL) {
        self.client = client
        self.baseURL = baseURL
    }

    static var defaultBaseURL: URL {
        URL(string: "https://api.inaturalist.org/v2")!
    }

    func observations(matching query: ObservationQuery, page: Int) async throws -> Page<WildlifeObservation> {
        var items = [
            URLQueryItem(name: "captive", value: "false"),
            URLQueryItem(name: "order_by", value: "observed_on"),
            URLQueryItem(name: "order", value: query.sortOrder.apiValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(Self.pageSize)),
            URLQueryItem(name: "fields", value: Self.observationFields)
        ]
        if let matchingIDs = query.matchingTaxonIDs, !matchingIDs.isEmpty {
            items.append(URLQueryItem(
                name: "taxon_id",
                value: matchingIDs.map(String.init).joined(separator: ",")
            ))
        } else if let taxonID = query.taxon?.id {
            items.append(URLQueryItem(name: "taxon_id", value: String(taxonID)))
        }
        if let grade = query.quality.apiValue {
            items.append(URLQueryItem(name: "quality_grade", value: grade))
        }

        return try await client.value(
            for: try request(path: "observations", items: items),
            as: Page<WildlifeObservation>.self
        )
    }

    func observation(id: Int) async throws -> WildlifeObservation {
        let items = [
            URLQueryItem(name: "id", value: String(id)),
            URLQueryItem(name: "fields", value: Self.observationDetailFields)
        ]
        let page: Page<WildlifeObservation> = try await client.value(
            for: try request(path: "observations", items: items),
            as: Page<WildlifeObservation>.self
        )
        guard let observation = page.results.first else { throw NetworkError.notFound }
        return observation
    }

    func searchTaxa(matching term: String, limit: Int) async throws -> [Taxon] {
        let items = [
            URLQueryItem(name: "q", value: term),
            URLQueryItem(name: "per_page", value: String(limit)),
            URLQueryItem(name: "is_active", value: "true"),
            URLQueryItem(name: "fields", value: Self.taxonSummaryFields)
        ]
        let page: Page<Taxon> = try await client.value(
            for: try request(path: "taxa/autocomplete", items: items),
            as: Page<Taxon>.self
        )
        return page.results
    }

    func taxonDetails(id: Int) async throws -> Taxon {
        let items = [URLQueryItem(name: "fields", value: Self.taxonDetailFields)]
        let page: Page<Taxon> = try await client.value(
            for: try request(path: "taxa/\(id)", items: items),
            as: Page<Taxon>.self
        )
        guard let taxon = page.results.first else { throw NetworkError.notFound }
        return taxon
    }

    private func request(path: String, items: [URLQueryItem]) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.unknown
        }
        components.queryItems = items.isEmpty ? nil : items

        guard let url = components.url else { throw NetworkError.unknown }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("WildlifeAtlas/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        return request
    }
}

private extension LiveINaturalistService {
    static let observationFields = fields(
        "id", "quality_grade", "observed_on", "time_observed_at", "place_guess",
        "geoprivacy", "taxon_geoprivacy", "obscured",
        "photos:(id:!t,url:!t)",
        "taxon:(id:!t,name:!t,rank:!t,preferred_common_name:!t,iconic_taxon_name:!t)"
    )

    static let observationDetailFields = fields(
        "id", "quality_grade", "observed_on", "time_observed_at", "place_guess",
        "geoprivacy", "taxon_geoprivacy", "obscured", "uri",
        "photos:(id:!t,url:!t,attribution:!t,license_code:!t)",
        "taxon:(id:!t,name:!t,rank:!t,preferred_common_name:!t,iconic_taxon_name:!t)",
        "user:(id:!t,login:!t,name:!t,icon_url:!t)"
    )

    static let taxonSummaryFields = fields(
        "id", "name", "rank", "preferred_common_name", "iconic_taxon_name",
        "observations_count",
        "default_photo:(id:!t,url:!t)"
    )

    static let taxonDetailFields = fields(
        "id", "name", "rank", "preferred_common_name",
        "ancestors:(id:!t,name:!t,rank:!t,preferred_common_name:!t)"
    )

    static func fields(_ names: String...) -> String {
        let entries = names.map { $0.contains(":") ? $0 : "\($0):!t" }
        return "(" + entries.joined(separator: ",") + ")"
    }
}
