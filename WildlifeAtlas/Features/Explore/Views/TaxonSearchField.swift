//
//  TaxonSearchField.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct TaxonSearchField: View {
    @Binding var term: String
    var isFocused: FocusState<Bool>.Binding
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.secondaryText)

                TextField("Search species", text: $term)
                    .focused(isFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .foregroundStyle(Theme.primaryText)

                if !term.isEmpty {
                    Button {
                        term = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .accessibilityLabel("Clear search text")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Theme.surface, in: Capsule())
            .overlay {
                Capsule().stroke(Theme.hairline, lineWidth: 1)
            }

            if isFocused.wrappedValue {
                Button("Cancel", action: onCancel)
                    .font(.subheadline)
                    .tint(Theme.accent)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
    }
}
