//
//  ExploreView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @StateObject private var search = TaxonSearchViewModel()
    @FocusState private var isSearchFocused: Bool
    @EnvironmentObject private var recentTaxa: RecentTaxaStore
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                if isSearchFocused {
                    Color.black.opacity(0.12)
                        .ignoresSafeArea()
                        .onTapGesture { dismissSearch() }
                        .transition(.opacity)
                }
                
                VStack(spacing: 12) {
                    TaxonSearchField(term: $search.term, isFocused: $isSearchFocused) {
                        dismissSearch()
                    }
                    
                    if isSearchFocused {
                        TaxonSuggestionsView(
                            state: search.state,
                            recents: recentTaxa.taxa,
                            onSelect: apply(taxon:),
                            onClearRecents: recentTaxa.clear,
                            onRetry: search.retry
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    FilterBarView(
                        query: viewModel.query,
                        onSelectTaxon: { isSearchFocused = true },
                        onClearTaxon: { viewModel.select(taxon: nil) },
                        onSelectQuality: viewModel.select(quality:),
                        onSelectSortOrder: viewModel.select(sortOrder:)
                    )
                    
                    feed
                }
                .atlasBackground()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .navigationDestination(for: WildlifeObservation.ID.self) { id in
                ObservationDetailView(observationID: id)
            }
            .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
        }
        .task { viewModel.loadIfNeeded() }
        .onChange(of: search.state) { state in
            handleSearchState(state)
        }
    }

    private func handleSearchState(_ state: TaxonSearchViewModel.State) {
        switch state {
        case .results(let taxa):
            viewModel.updateSearchPreview(taxa: taxa)
        case .recents, .empty, .failed:
            viewModel.updateSearchPreview(taxa: nil)
        case .loading:
            break
        }
    }
    
    @ViewBuilder
    private var feed: some View {
        switch viewModel.state {
        case .loading:
            LoadingStateView()
            
        case .empty:
            emptyState
            
        case .failed(let error):
            ErrorStateView(error: error) { viewModel.reload() }
            
        case .content:
            ScrollView {
                switch viewModel.layout {
                case .list: listContent
                case .grid: gridContent
                }
                footer
            }
            .refreshable { await viewModel.refresh() }
        }
    }
    
    @ViewBuilder
    private var emptyState: some View {
        if viewModel.query.isDefault {
            EmptyStateView(title: "No observations found", message: viewModel.emptyStateMessage)
        } else {
            EmptyStateView(
                title: "No observations found",
                message: viewModel.emptyStateMessage,
                actionTitle: "Reset filters",
                action: { viewModel.clearAllFilters() }
            )
        }
    }
    
    private var listContent: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.observations) { observation in
                NavigationLink(value: observation.id) {
                    ObservationCardView(observation: observation)
                }
                .onAppear { viewModel.loadNextPageIfNeeded(currentItem: observation) }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var gridContent: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(viewModel.observations) { observation in
                NavigationLink(value: observation.id) {
                    ObservationTileView(observation: observation)
                }
                .onAppear { viewModel.loadNextPageIfNeeded(currentItem: observation) }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var footer: some View {
        if let error = viewModel.nextPageError {
            PageErrorFooter(error: error, retry: viewModel.retry)
        } else if viewModel.isLoadingNextPage {
            PageLoadingFooter()
        } else {
            Color.clear.frame(height: 12)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Wild Atlas")
                .font(Theme.display(.title2))
                .foregroundStyle(Theme.accent)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                    viewModel.toggleLayout()
                }
            } label: {
                Image(systemName: viewModel.layout.toggled.symbolName)
            }
            .tint(Theme.accent)
            .accessibilityLabel(viewModel.layout.accessibilityLabel)
        }
    }
    
    private func apply(taxon: Taxon) {
        recentTaxa.record(taxon)
        viewModel.select(taxon: taxon)
        dismissSearch()
    }

    private func dismissSearch() {
        isSearchFocused = false
        search.reset()
        viewModel.updateSearchPreview(taxa: nil)
    }
}
