//
//  ObservationTileView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct ObservationTileView: View {
    let observation: WildlifeObservation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photo
            caption
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .atlasCard()
        .contentShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var photo: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                RemoteImage(url: observation.primaryPhoto?.url(.medium), symbolName: iconicSymbol)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding([.top, .horizontal], 10)
            .layoutPriority(1)
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(observation.displayName ?? "Unidentified observation")
                    .font(Theme.display(.subheadline))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                if let scientificName = observation.scientificName {
                    Text(scientificName)
                        .font(.caption.italic())
                        .foregroundStyle(Theme.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            HStack(alignment: .bottom, spacing: 6) {
                if let date = observation.observedDate {
                    Text(date.shortText)
                        .font(.caption2)
                        .foregroundStyle(Theme.secondaryText)
                }

                Spacer(minLength: 0)

                QualityBadge(grade: observation.qualityGrade)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
    }

    private var iconicSymbol: String {
        observation.taxon?.iconicTaxon?.symbolName ?? "photo"
    }
}
