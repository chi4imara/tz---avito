//
//  RemoteImage.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import SwiftUI

struct RemoteImage<Placeholder: View>: View {
    private let url: URL?
    private let contentMode: ContentMode
    private let placeholder: Placeholder

    @State private var image: UIImage?

    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder()
        _image = State(initialValue: url.flatMap { ImageLoader.shared.cachedImage(for: $0) })
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                placeholder
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .clipped()
        .contentShape(Rectangle())
        .task(id: url) {
            await load(url)
        }
    }

    private func load(_ url: URL?) async {
        guard let url else {
            image = nil
            return
        }

        if let cached = ImageLoader.shared.cachedImage(for: url) {
            image = cached
            return
        }

        image = nil
        do {
            let loaded = try await ImageLoader.shared.image(for: url)
            guard !Task.isCancelled else { return }
            image = loaded
        } catch {
        }
    }
}

extension RemoteImage where Placeholder == ImagePlaceholder {
    init(
        url: URL?,
        symbolName: String = "photo",
        tint: Color = Theme.secondaryText,
        contentMode: ContentMode = .fill
    ) {
        self.init(url: url, contentMode: contentMode) {
            ImagePlaceholder(symbolName: symbolName, tint: tint)
        }
    }
}

struct ImagePlaceholder: View {
    let symbolName: String
    var tint: Color = Theme.secondaryText

    var body: some View {
        ZStack {
            Theme.surfaceSecondary
            Image(systemName: symbolName)
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(tint.opacity(0.5))
        }
    }
}
