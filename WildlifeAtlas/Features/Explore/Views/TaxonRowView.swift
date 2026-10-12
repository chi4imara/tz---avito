//
//  TaxonRowView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct TaxonRowView: View {
    let taxon: Taxon

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 2) {
                Text(taxon.displayName)
                    .font(Theme.display(.subheadline))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                if let scientificName = taxon.scientificName {
                    Text(scientificName)
                        .font(.footnote.italic())
                        .foregroundStyle(Theme.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                if let group = taxon.iconicTaxon {
                    Text(group.title)
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
                if let count = taxon.observationsCount {
                    Text("\(count.abbreviatedCount) obs")
                        .font(.caption2)
                        .foregroundStyle(Theme.secondaryText.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        RemoteImage(
            url: taxon.defaultPhoto?.url(.square),
            symbolName: taxon.iconicTaxon?.symbolName ?? "leaf",
            tint: taxon.iconicTaxon?.tint ?? Theme.secondaryText
        )
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
}
