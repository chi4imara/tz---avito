//
//  RecentTaxaStore.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import Foundation
import Combine

@MainActor
final class RecentTaxaStore: ObservableObject {
    static let limit = 5

    @Published private(set) var taxa: [Taxon] = []

    private let defaults: UserDefaults
    private let key = "recentlySelectedTaxa"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        taxa = decodeStored()
    }

    func record(_ taxon: Taxon) {
        var updated = taxa.filter { $0.id != taxon.id }
        updated.insert(taxon, at: 0)
        taxa = Array(updated.prefix(Self.limit))
        persist()
    }

    func clear() {
        taxa = []
        persist()
    }

    private func decodeStored() -> [Taxon] {
        guard let data = defaults.data(forKey: key),
              let stored = try? JSONDecoder().decode([Taxon].self, from: data) else { return [] }
        return Array(stored.prefix(Self.limit))
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(taxa) else { return }
        defaults.set(data, forKey: key)
    }
}
