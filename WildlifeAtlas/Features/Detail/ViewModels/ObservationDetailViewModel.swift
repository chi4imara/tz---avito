//
//  ObservationDetailViewModel.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import Foundation
import Combine

@MainActor
final class ObservationDetailViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case content(WildlifeObservation)
        case failed(NetworkError)
    }

    let observationID: WildlifeObservation.ID

    @Published private(set) var state: State = .loading
    @Published private(set) var taxonDetails: Taxon?

    private let service: INaturalistService

    init(observationID: WildlifeObservation.ID, service: INaturalistService = LiveINaturalistService.shared) {
        self.observationID = observationID
        self.service = service
    }

    func loadIfNeeded() async {
        if case .content = state { return }
        if case .failed = state { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let observation = try await service.observation(id: observationID)
            state = .content(observation)
            await loadTaxonDetails(for: observation.taxon?.id)
        } catch is CancellationError {
            return
        } catch {
            state = .failed(NetworkError(error))
        }
    }

    private func loadTaxonDetails(for taxonID: Int?) async {
        guard let taxonID else { return }
        taxonDetails = try? await service.taxonDetails(id: taxonID)
    }
}
