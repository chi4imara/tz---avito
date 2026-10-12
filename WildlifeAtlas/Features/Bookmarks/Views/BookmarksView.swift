//
//  BookmarksView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject private var bookmarks: BookmarksStore
    
    var body: some View {
        NavigationStack {
            content
                .atlasBackground()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Bookmarks")
                            .font(Theme.display(.title3))
                            .foregroundStyle(Theme.accent)
                    }
                }
                .navigationDestination(for: WildlifeObservation.ID.self) { id in
                    ObservationDetailView(observationID: id)
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if bookmarks.observations.isEmpty {
            EmptyStateView(
                title: "No bookmarks yet",
                message: "Open an observation and tap the bookmark icon to keep it here for later.",
                symbolName: "bookmark"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(bookmarks.observations) { observation in
                        NavigationLink(value: observation.id) {
                            ObservationCardView(observation: observation)
                        }
                        .contextMenu {
                            Button("Remove bookmark", systemImage: "bookmark.slash", role: .destructive) {
                                bookmarks.remove(id: observation.id)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
    }
}
