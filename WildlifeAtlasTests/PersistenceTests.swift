//
//  PersistenceTests.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import XCTest
@testable import WildlifeAtlas

@MainActor
final class PersistenceTests: XCTestCase {
    func testRecentTaxaKeepsFiveUniqueNewestFirst() {
        let suite = "WildlifeAtlasTests.RecentTaxa.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = RecentTaxaStore(defaults: defaults)
        for id in 1...7 {
            store.record(Taxon(id: id, name: "Taxon \(id)"))
        }
        store.record(Taxon(id: 3, name: "Taxon 3"))

        XCTAssertEqual(store.taxa.map(\.id), [3, 7, 6, 5, 4])
        XCTAssertEqual(RecentTaxaStore(defaults: defaults).taxa.map(\.id), [3, 7, 6, 5, 4])
    }

    func testRecentTaxaClearRemovesPersistedValues() {
        let suite = "WildlifeAtlasTests.RecentTaxaClear.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = RecentTaxaStore(defaults: defaults)
        store.record(Taxon(id: 1, name: "Fox"))
        store.clear()

        XCTAssertTrue(store.taxa.isEmpty)
        XCTAssertTrue(RecentTaxaStore(defaults: defaults).taxa.isEmpty)
    }

    func testBookmarksTogglePersistRefreshAndReload() async throws {
        let storage = JSONFileStorage(fileName: "bookmarks-test-\(UUID().uuidString).json")
        let store = BookmarksStore(storage: storage)

        store.toggle(WildlifeObservation.stub(id: 10, name: "Fox"))
        store.toggle(WildlifeObservation.stub(id: 11, name: "Owl"))
        XCTAssertEqual(store.observations.map(\.id), [11, 10])
        XCTAssertTrue(store.contains(10))

        let detailed = try XCTUnwrap(
            try JSONDecoder()
                .decode(Page<WildlifeObservation>.self, from: Data(Fixtures.observationsPage.utf8))
                .results.first
        )
        store.toggle(detailed)
        store.refreshSnapshotIfNeeded(with: detailed)
        XCTAssertEqual(store.observations.first { $0.id == detailed.id }?.photos.count, 2)

        store.toggle(WildlifeObservation.stub(id: 10, name: "Fox"))
        XCTAssertFalse(store.contains(10))
        await store.waitUntilSaved()

        let reloaded = BookmarksStore(storage: storage)
        await reloaded.load()
        XCTAssertTrue(reloaded.contains(11))
        XCTAssertTrue(reloaded.contains(detailed.id))
        XCTAssertFalse(reloaded.contains(10))
    }
}
