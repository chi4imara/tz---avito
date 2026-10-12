//
//  ExploreViewModel.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import Foundation
import Combine

enum FeedLayout: CaseIterable, Sendable {
    case list
    case grid

    var symbolName: String {
        switch self {
        case .list: "square.fill.text.grid.1x2"
        case .grid: "square.grid.2x2"
        }
    }

    var toggled: FeedLayout {
        self == .list ? .grid : .list
    }

    var accessibilityLabel: String {
        self == .list ? "Switch to grid layout" : "Switch to list layout"
    }
}

@MainActor
final class ExploreViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case content
        case empty
        case failed(NetworkError)
    }

    @Published private(set) var observations: [WildlifeObservation] = []
    @Published private(set) var state: State = .loading
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var nextPageError: NetworkError?
    @Published private(set) var hasNextPage = false

    @Published private(set) var query = ObservationQuery()
    @Published var layout: FeedLayout = .list

    private let service: INaturalistService

    private var loadedPage = 0
    private var loadTask: Task<Void, Never>?
    private var generation = 0

    init(service: INaturalistService = LiveINaturalistService.shared) {
        self.service = service
    }

    func loadIfNeeded() {
        guard observations.isEmpty, loadTask == nil else { return }
        reload()
    }

    func reload() {
        loadTask?.cancel()
        generation += 1
        loadedPage = 0
        hasNextPage = false
        nextPageError = nil
        observations = []
        state = .loading

        let token = generation
        loadTask = Task { await loadPage(1, token: token) }
    }

    func refresh() async {
        loadTask?.cancel()
        generation += 1
        nextPageError = nil

        let token = generation
        let task = Task { await loadPage(1, token: token) }
        loadTask = task
        await task.value
    }

    func retry() {
        if case .failed = state {
            reload()
        } else {
            nextPageError = nil
            loadNextPage()
        }
    }

    func loadNextPageIfNeeded(currentItem observation: WildlifeObservation) {
        let threshold = 5
        guard let index = observations.firstIndex(where: { $0.id == observation.id }),
              index >= observations.count - threshold else { return }
        loadNextPage()
    }

    private func loadNextPage() {
        guard hasNextPage, !isLoadingNextPage, nextPageError == nil, case .content = state else { return }

        nextPageError = nil
        let token = generation
        let nextPage = loadedPage + 1
        loadTask = Task { await loadPage(nextPage, token: token) }
    }

    private func loadPage(_ page: Int, token: Int) async {
        let isFirstPage = page == 1
        if !isFirstPage { isLoadingNextPage = true }

        defer {
            if token == generation {
                isLoadingNextPage = false
                if isFirstPage { loadTask = nil }
            }
        }

        do {
            let result = try await service.observations(matching: query, page: page)
            guard token == generation else { return }

            apply(result, isFirstPage: isFirstPage)
        } catch is CancellationError {
            return
        } catch {
            guard token == generation else { return }

            let networkError = NetworkError(error)
            if isFirstPage {
                observations = []
                state = .failed(networkError)
            } else {
                nextPageError = networkError
            }
        }
    }

    private func apply(_ result: Page<WildlifeObservation>, isFirstPage: Bool) {
        let existing = Set(isFirstPage ? [] : observations.map(\.id))
        var incoming = result.results.filter { !existing.contains($0.id) }

        if isFirstPage, let ids = query.matchingTaxonIDs, !ids.isEmpty {
            incoming = prioritized(incoming, preferredTaxonIDs: ids)
        }

        observations = isFirstPage ? incoming : observations + incoming
        loadedPage = result.page
        hasNextPage = result.hasNextPage
        state = observations.isEmpty ? .empty : .content
    }

    private func prioritized(
        _ observations: [WildlifeObservation],
        preferredTaxonIDs: [Int]
    ) -> [WildlifeObservation] {
        var remaining = observations
        var ordered: [WildlifeObservation] = []

        for taxonID in preferredTaxonIDs {
            if let index = remaining.firstIndex(where: { $0.taxon?.id == taxonID }) {
                ordered.append(remaining.remove(at: index))
            }
        }

        return ordered + remaining
    }

    func updateSearchPreview(taxa: [Taxon]?) {
        let ids = taxa.map { $0.map(\.id) }
        guard query.matchingTaxonIDs != ids else { return }
        query.matchingTaxonIDs = ids
        reload()
    }

    func select(taxon: Taxon?) {
        guard query.taxon?.id != taxon?.id || query.matchingTaxonIDs != nil else { return }
        query.matchingTaxonIDs = nil
        query.taxon = taxon
        reload()
    }

    func select(quality: QualityFilter) {
        guard query.quality != quality else { return }
        query.quality = quality
        reload()
    }

    func select(sortOrder: ObservationSortOrder) {
        guard query.sortOrder != sortOrder else { return }
        query.sortOrder = sortOrder
        reload()
    }

    func clearAllFilters() {
        guard !query.isDefault else { return }
        query = ObservationQuery()
        reload()
    }

    func toggleLayout() {
        
        layout = layout.toggled
    }

    var emptyStateMessage: String {
        query.isDefault
            ? "iNaturalist returned no wild observations right now. Pull to refresh in a moment."
            : "No wild observations match the current filters. Try a different species, grade or order."
    }
}
