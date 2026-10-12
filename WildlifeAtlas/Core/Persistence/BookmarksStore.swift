//
//  BookmarksStore.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import Foundation
import Combine

@MainActor
final class BookmarksStore: ObservableObject {
    @Published private(set) var observations: [WildlifeObservation] = []

    private let storage: JSONFileStorage
    private var bookmarkedIDs: Set<Int> = []
    private var saveTask: Task<Void, Never>?

    init(storage: JSONFileStorage = JSONFileStorage(fileName: "bookmarks.json")) {
        self.storage = storage
    }

    func load() async {
        guard observations.isEmpty else { return }
        let stored = await storage.load([WildlifeObservation].self) ?? []
        observations = stored
        bookmarkedIDs = Set(stored.map(\.id))
    }

    func contains(_ id: Int) -> Bool {
        bookmarkedIDs.contains(id)
    }

    func toggle(_ observation: WildlifeObservation) {
        if contains(observation.id) {
            remove(id: observation.id)
        } else {
            observations.insert(observation, at: 0)
            bookmarkedIDs.insert(observation.id)
            persist()
        }
    }

    func remove(id: Int) {
        observations.removeAll { $0.id == id }
        bookmarkedIDs.remove(id)
        persist()
    }

    func refreshSnapshotIfNeeded(with observation: WildlifeObservation) {
        guard let index = observations.firstIndex(where: { $0.id == observation.id }) else { return }
        observations[index] = observation
        persist()
    }

    func waitUntilSaved() async {
        await saveTask?.value
    }

    private func persist() {
        let snapshot = observations
        let previous = saveTask
        saveTask = Task { [storage] in
            await previous?.value
            await storage.save(snapshot)
        }
    }
}
