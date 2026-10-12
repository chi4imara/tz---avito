//
//  TaxonomyStripView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct TaxonomyStripView: View {
    let taxon: Taxon

    var body: some View {
        let ranks = taxon.primaryAncestors

        if !ranks.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(ranks.enumerated()), id: \.element.id) { index, ancestor in
                        column(for: ancestor)

                        if index < ranks.count - 1 {
                            Divider()
                                .frame(height: 32)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .atlasCard(cornerRadius: 12)
        }
    }

    private func column(for ancestor: Taxon) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ancestor.rankTitle ?? "")
                .font(.caption2)
                .foregroundStyle(Theme.secondaryText)
            Text(ancestor.name)
                .font(Theme.display(.footnote, weight: .semibold))
                .foregroundStyle(Theme.primaryText)
        }
        .padding(.horizontal, 14)
        .accessibilityElement(children: .combine)
    }
}
