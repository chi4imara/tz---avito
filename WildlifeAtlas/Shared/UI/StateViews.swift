//
//  StateViews.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import SwiftUI

struct LoadingStateView: View {
    var title: String = "Loading observations…"

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(title)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    var symbolName: String = "binoculars"
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        UnavailableStateLayout(
            title: title,
            message: message,
            symbolName: symbolName,
            actionTitle: actionTitle,
            action: action
        )
    }
}

struct ErrorStateView: View {
    let error: NetworkError
    let retry: () -> Void

    var body: some View {
        UnavailableStateLayout(
            title: error.title,
            message: error.message,
            symbolName: "exclamationmark.triangle",
            actionTitle: "Try again",
            action: retry
        )
    }
}

private struct UnavailableStateLayout: View {
    let title: String
    let message: String
    let symbolName: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbolName)
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(Theme.secondaryText)

            VStack(spacing: 6) {
                Text(title)
                    .font(Theme.display(.title3))
                    .foregroundStyle(Theme.primaryText)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct PageLoadingFooter: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text("Loading more observations…")
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

struct PageErrorFooter: View {
    let error: NetworkError
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(error.title)
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
            Button("Retry", action: retry)
                .font(.footnote.weight(.semibold))
                .tint(Theme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}
