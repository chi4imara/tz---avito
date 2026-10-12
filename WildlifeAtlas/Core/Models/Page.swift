//
//  Page.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

struct Page<Item: Decodable & Sendable>: Decodable, Sendable {
    let results: [Item]
    let page: Int
    let perPage: Int
    let totalResults: Int

    private enum CodingKeys: String, CodingKey {
        case results, page
        case perPage = "per_page"
        case totalResults = "total_results"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decode([Item].self, forKey: .results)
        page = try container.decodeFlexibleInt(forKey: .page) ?? 1
        perPage = try container.decodeFlexibleInt(forKey: .perPage) ?? results.count
        totalResults = try container.decodeFlexibleInt(forKey: .totalResults) ?? results.count
    }

    init(results: [Item], page: Int, perPage: Int, totalResults: Int) {
        self.results = results
        self.page = page
        self.perPage = perPage
        self.totalResults = totalResults
    }

    var hasNextPage: Bool {
        guard !results.isEmpty else { return false }
        let loaded = page * perPage
        return loaded < totalResults && loaded < Self.maximumReachableResults
    }

    static var maximumReachableResults: Int { 10_000 }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleInt(forKey key: Key) throws -> Int? {
        if let value = try? decodeIfPresent(Int.self, forKey: key) { return value }
        if let text = try? decodeIfPresent(String.self, forKey: key) { return Int(text) }
        return nil
    }
}
