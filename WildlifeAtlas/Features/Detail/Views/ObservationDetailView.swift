//
//  ObservationDetailView.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import SwiftUI

struct ObservationDetailView: View {
    @StateObject private var viewModel: ObservationDetailViewModel
    @EnvironmentObject private var bookmarks: BookmarksStore
    @State private var galleryPresentation: GalleryPresentation?

    init(observationID: WildlifeObservation.ID) {
        _viewModel = StateObject(wrappedValue: ObservationDetailViewModel(observationID: observationID))
    }

    var body: some View {
        content
            .atlasBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(item: $galleryPresentation) { presentation in
                GallerySheet(photos: presentation.photos) {
                    galleryPresentation = nil
                }
            }
            .task {
                await viewModel.loadIfNeeded()
                if case .content(let observation) = viewModel.state {
                    bookmarks.refreshSnapshotIfNeeded(with: observation)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingStateView(title: "Loading observation…")

        case .failed(let error):
            ErrorStateView(error: error) {
                Task { await viewModel.load() }
            }

        case .content(let observation):
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    hero(for: observation)
                    heading(for: observation)
                    taxonomy
                    detailsCard(for: observation)
                    additionalPhotos(for: observation)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private func hero(for observation: WildlifeObservation) -> some View {
        ObservationHeroPhoto(photo: observation.primaryPhoto)
            .onTapGesture {
                guard !observation.photos.isEmpty else { return }
                galleryPresentation = GalleryPresentation(photos: observation.photos)
            }
    }

    private func heading(for observation: WildlifeObservation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(observation.displayName ?? "Unidentified observation")
                    .font(Theme.display(.title))
                    .foregroundStyle(Theme.primaryText)

                if let scientificName = observation.scientificName {
                    Text(scientificName)
                        .font(.title3.italic())
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Spacer(minLength: 0)

            QualityBadge(grade: observation.qualityGrade, style: .pill)
        }
    }

    @ViewBuilder
    private var taxonomy: some View {
        if let taxon = viewModel.taxonDetails {
            TaxonomyStripView(taxon: taxon)
        }
    }

    private func detailsCard(for observation: WildlifeObservation) -> some View {
        VStack(spacing: 0) {
            if let date = observation.observedDate {
                FactRow(
                    symbolName: "calendar",
                    title: "Observed on",
                    value: date.fullText
                )
            }

            if observation.isLocationHidden {
                divider
                FactRow(
                    symbolName: "lock.fill",
                    title: "Location obscured",
                    value: "Exact location is hidden for private observations and sensitive species."
                )
            } else if let place = observation.visiblePlace {
                divider
                FactRow(
                    symbolName: "mappin.and.ellipse",
                    title: "Approximate location",
                    value: place,
                    note: "Reported by the observer; not an exact position."
                )
            }

            if let user = observation.user, let name = user.displayName {
                divider
                authorRow(name: name, user: user, license: observation.primaryPhoto?.licenseTitle)
            }
        }
        .atlasCard(cornerRadius: 12)
    }

    private func authorRow(name: String, user: ObservationUser, license: String?) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RemoteImage(url: user.iconURL, symbolName: "person.fill")
                .frame(width: 36, height: 36)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("Photographed by")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                Text(name)
                    .font(Theme.display(.headline))
                    .foregroundStyle(Theme.primaryText)

                if let license {
                    Label(license, systemImage: "doc.text")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.accentSoft, in: Capsule())
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func additionalPhotos(for observation: WildlifeObservation) -> some View {
        let extra = max(0, observation.photos.count - 1)
        if extra > 0 {
            AdditionalPhotosCard(
                extraCount: extra,
                preview: observation.photos.dropFirst().first
            ) {
                galleryPresentation = GalleryPresentation(photos: observation.photos)
            }
        }
    }

    private var divider: some View {
        Divider().padding(.leading, 56)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Observation")
                .font(Theme.display(.headline))
                .foregroundStyle(Theme.accent)
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            if case .content(let observation) = viewModel.state {
                Button {
                    bookmarks.toggle(observation)
                } label: {
                    Image(systemName: bookmarks.contains(observation.id) ? "bookmark.fill" : "bookmark")
                }
                .tint(Theme.accent)
                .accessibilityLabel(bookmarks.contains(observation.id) ? "Remove from bookmarks" : "Add to bookmarks")

                if let url = observation.webURL {
                    ShareLink(item: url, subject: Text(observation.shareText), message: Text(observation.shareText))
                        .tint(Theme.accent)
                }
            }
        }
    }
}

private struct FactRow: View {
    let symbolName: String
    let title: String
    let value: String
    var note: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbolName)
                .font(.subheadline)
                .foregroundStyle(Theme.accent)
                .frame(width: 32, height: 32)
                .background(Theme.accentSoft, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.primaryText)
                if let note {
                    Text(note)
                        .font(.caption2)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .accessibilityElement(children: .combine)
    }
}

private struct GalleryPresentation: Identifiable {
    let id = UUID()
    let photos: [Photo]
}

private struct GallerySheet: View {
    let photos: [Photo]
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            PhotoGalleryView(photos: photos)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 12)
                .background(Theme.background.ignoresSafeArea())
                .navigationTitle("Photos")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done", action: onDismiss)
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }
}
