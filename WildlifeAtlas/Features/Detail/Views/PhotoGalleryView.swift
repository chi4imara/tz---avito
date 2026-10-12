//
//  PhotoGalleryView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct PhotoGalleryView: View {
    let photos: [Photo]
    var showsPageControl: Bool = true

    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                ZStack {
                    Theme.surfaceSecondary
                    RemoteImage(
                        url: photo.url(.large),
                        symbolName: "photo",
                        contentMode: .fit
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
                .padding(.horizontal, 16)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: showsPageControl && photos.count > 1 ? .always : .never))
        .overlay(alignment: .topTrailing) { counter }
    }

    @ViewBuilder
    private var counter: some View {
        if photos.count > 1 {
            Text("\(selection + 1)/\(photos.count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.black.opacity(0.45), in: Capsule())
                .padding(.trailing, 26)
                .padding(.top, 10)
                .accessibilityLabel("Photo \(selection + 1) of \(photos.count)")
        }
    }
}

struct ObservationHeroPhoto: View {
    let photo: Photo?

    var body: some View {
        Color.clear
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                RemoteImage(url: photo?.url(.large), symbolName: "photo", contentMode: .fill)
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
    }
}

struct AdditionalPhotosCard: View {
    let extraCount: Int
    let preview: Photo?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RemoteImage(url: preview?.url(.square), symbolName: "photo")
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(extraCount == 1 ? "Additional photo" : "Additional photos")
                        .font(Theme.display(.subheadline))
                        .foregroundStyle(Theme.primaryText)
                    Text("\(extraCount) more from this observation")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }

                Spacer(minLength: 0)

                HStack(spacing: 4) {
                    Text("\(extraCount)")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Theme.secondaryText)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Theme.surfaceSecondary, in: Capsule())
            }
            .padding(12)
            .atlasCard(cornerRadius: 12)
        }
        .accessibilityLabel("Show \(extraCount) more photos")
    }
}
