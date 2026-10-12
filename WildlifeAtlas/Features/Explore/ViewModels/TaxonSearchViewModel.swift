//
//  TaxonSearchViewModel.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import Foundation
import Combine

@MainActor
final class TaxonSearchViewModel: ObservableObject {
    enum State: Equatable {
        case recents
        case loading
        case results([Taxon])
        case empty
        case failed(NetworkError)
    }

    @Published var term: String = "" {
        didSet {
            guard term != oldValue else { return }
            scheduleSearch()
        }
    }

    @Published private(set) var state: State = .recents

    private let service: INaturalistService
    private let resultLimit: Int
    private var searchTask: Task<Void, Never>?

    private let debounceNanoseconds: UInt64 = 300_000_000
    private let minimumTermLength = 2

    init(service: INaturalistService = LiveINaturalistService.shared, resultLimit: Int = 12) {
        self.service = service
        self.resultLimit = resultLimit
    }

    func reset() {
        searchTask?.cancel()
        searchTask = nil
        term = ""
        state = .recents
    }

    func retry() {
        scheduleSearch(immediately: true)
    }

    private func scheduleSearch(immediately: Bool = false) {
        searchTask?.cancel()

        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumTermLength else {
            state = .recents
            searchTask = nil
            return
        }

        state = .loading
        searchTask = Task {
            if !immediately {
                try? await Task.sleep(nanoseconds: debounceNanoseconds)
                guard !Task.isCancelled else { return }
            }
            await search(trimmed)
        }
    }

    private func search(_ trimmed: String) async {
        do {
            let taxa = try await service.searchTaxa(matching: trimmed, limit: resultLimit)
            guard !Task.isCancelled else { return }
            state = taxa.isEmpty ? .empty : .results(taxa)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(NetworkError(error))
        }
    }
}
