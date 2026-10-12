//
//  ObservationCardView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct ObservationCardView: View {
    let observation: WildlifeObservation

    private let photoSide: CGFloat = 104
    private let photoCornerRadius: CGFloat = 12
    private let cardPadding: CGFloat = 10

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            photo
            details
        }
        .padding(cardPadding)
        .atlasCard()
        .accessibilityElement(children: .combine)
    }

    private var photo: some View {
        RemoteImage(
            url: observation.primaryPhoto?.url(.medium),
            symbolName: iconicSymbol
        )
        .frame(width: photoSide, height: photoSide)
        .clipShape(RoundedRectangle(cornerRadius: photoCornerRadius, style: .continuous))
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(observation.displayName ?? "Unidentified observation")
                    .font(Theme.display(.headline))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(2)

                if let scientificName = observation.scientificName {
                    Text(scientificName)
                        .font(.subheadline.italic())
                        .foregroundStyle(Theme.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            HStack(alignment: .bottom, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    if let date = observation.observedDate {
                        IconLabel(symbolName: "calendar", text: date.shortText, font: .footnote)
                    }

                    if let place = observation.visiblePlace {
                        IconLabel(symbolName: "mappin.and.ellipse", text: place, font: .footnote)
                    }
                }

                Spacer(minLength: 0)

                QualityBadge(grade: observation.qualityGrade, style: .mark)
            }
        }
        .frame(height: photoSide, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var iconicSymbol: String {
        observation.taxon?.iconicTaxon?.symbolName ?? "photo"
    }
}
