//
//  FilterBarView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct FilterBarView: View {
    let query: ObservationQuery
    let onSelectTaxon: () -> Void
    let onClearTaxon: () -> Void
    let onSelectQuality: (QualityFilter) -> Void
    let onSelectSortOrder: (ObservationSortOrder) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                taxonChip

                menuChip(title: query.quality.title, options: QualityFilter.allCases, selected: query.quality) {
                    onSelectQuality($0)
                }

                menuChip(title: query.sortOrder.title, options: ObservationSortOrder.allCases, selected: query.sortOrder) {
                    onSelectSortOrder($0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var taxonChip: some View {
        if query.taxon != nil {
            Button(action: onClearTaxon) {
                HStack(spacing: 6) {
                    Text(query.taxonTitle)
                        .lineLimit(1)
                    Image(systemName: "xmark")
                        .font(.caption.weight(.semibold))
                }
            }
            .buttonStyle(ChipButtonStyle(isActive: true))
            .accessibilityLabel("Clear species filter, currently \(query.taxonTitle)")
        } else {
            Button(action: onSelectTaxon) {
                HStack(spacing: 6) {
                    Text(query.taxonTitle)
                    Image(systemName: "magnifyingglass")
                        .font(.caption.weight(.semibold))
                }
            }
            .buttonStyle(ChipButtonStyle(isActive: false))
            .accessibilityLabel("Filter by species")
        }
    }

    private func menuChip<Option: FilterOption & Identifiable & Equatable>(
        title: String,
        options: [Option],
        selected: Option,
        onSelect: @escaping (Option) -> Void
    ) -> some View {
        Menu {
            ForEach(options) { option in
                Button {
                    onSelect(option)
                } label: {
                    if option == selected {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Text(option.title)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(title)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .chipShape(isActive: false)
        }
    }
}

protocol FilterOption {
    var title: String { get }
}

extension QualityFilter: FilterOption {}
extension ObservationSortOrder: FilterOption {}

private struct ChipButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .chipShape(isActive: isActive)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

private extension View {
    func chipShape(isActive: Bool) -> some View {
        font(.subheadline.weight(.medium))
            .foregroundStyle(isActive ? Color.white : Theme.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isActive ? Theme.accent : Theme.surface, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(isActive ? Color.clear : Theme.hairline, lineWidth: 1)
            }
    }
}
