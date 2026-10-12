//
//  TaxonSuggestionsView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct TaxonSuggestionsView: View {
    let state: TaxonSearchViewModel.State
    let recents: [Taxon]
    let onSelect: (Taxon) -> Void
    let onClearRecents: () -> Void
    let onRetry: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch state {
            case .recents:
                if recents.isEmpty {
                    hint("Start typing to search the iNaturalist catalogue of species.")
                } else {
                    header("Recently used", trailing: "Clear", action: onClearRecents)
                    taxaList(recents)
                }
                
            case .loading:
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Searching…")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                }
                .padding(16)
                
            case .results(let taxa):
                header("Choose a species to filter observations")
                taxaList(taxa)
                
            case .empty:
                hint("No species match this search.")
                
            case .failed(let error):
                VStack(alignment: .leading, spacing: 8) {
                    Text(error.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primaryText)
                    Text(error.message)
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
                    Button("Try again", action: onRetry)
                        .font(.footnote.weight(.semibold))
                        .tint(Theme.accent)
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 20)
        .background(
            PopoverShape()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
    }
    
    private func header(_ title: String, trailing: String? = nil, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.secondaryText)
            
            Spacer(minLength: 8)
            
            if let trailing, let action {
                Button(trailing, action: action)
                    .font(.footnote)
                    .tint(Theme.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }
    
    private func hint(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Theme.secondaryText)
            .padding(16)
    }
    
    private func taxaList(_ taxa: [Taxon]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(taxa) { taxon in
                    Button {
                        onSelect(taxon)
                    } label: {
                        TaxonRowView(taxon: taxon)
                    }
                    
                    if taxon.id != taxa.last?.id {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .frame(maxHeight: 340)
    }
}
