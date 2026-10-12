//
//  RootView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "binoculars") }
            
            BookmarksView()
                .tabItem { Label("Bookmarks", systemImage: "bookmark") }
        }
        .tint(Theme.accent)
    }
}
