//
//  WildlifeAtlasApp.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

@main
struct WildlifeAtlasApp: App {
    @StateObject private var bookmarks = BookmarksStore()
    @StateObject private var recentTaxa = RecentTaxaStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(bookmarks)
                .environmentObject(recentTaxa)
                .task { await bookmarks.load() }
        }
    }
}
