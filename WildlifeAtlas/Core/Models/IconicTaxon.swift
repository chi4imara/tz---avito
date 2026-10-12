//
//  IconicTaxon.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import SwiftUI

enum IconicTaxon: String, Sendable {
    case mammals = "Mammalia"
    case birds = "Aves"
    case reptiles = "Reptilia"
    case amphibians = "Amphibia"
    case fish = "Actinopterygii"
    case insects = "Insecta"
    case arachnids = "Arachnida"
    case molluscs = "Mollusca"
    case plants = "Plantae"
    case fungi = "Fungi"
    case protozoans = "Protozoa"
    case chromista = "Chromista"
    case animals = "Animalia"

    init?(apiName: String?) {
        guard let apiName, let value = IconicTaxon(rawValue: apiName) else { return nil }
        self = value
    }

    var title: String {
        switch self {
        case .mammals: "Mammals"
        case .birds: "Birds"
        case .reptiles: "Reptiles"
        case .amphibians: "Amphibians"
        case .fish: "Fish"
        case .insects: "Insects"
        case .arachnids: "Arachnids"
        case .molluscs: "Molluscs"
        case .plants: "Plants"
        case .fungi: "Fungi"
        case .protozoans: "Protozoans"
        case .chromista: "Chromista"
        case .animals: "Animals"
        }
    }

    var symbolName: String {
        switch self {
        case .mammals: "hare.fill"
        case .birds: "bird.fill"
        case .reptiles: "lizard.fill"
        case .amphibians: "lizard"
        case .fish: "fish.fill"
        case .insects: "ant.fill"
        case .arachnids: "ant"
        case .molluscs: "fossil.shell.fill"
        case .plants: "leaf.fill"
        case .fungi: "camera.macro"
        case .protozoans, .chromista: "circle.hexagongrid.fill"
        case .animals: "pawprint.fill"
        }
    }

    var tint: Color {
        switch self {
        case .mammals: .brown
        case .birds: .teal
        case .reptiles, .amphibians: .green
        case .fish: .blue
        case .insects, .arachnids: .orange
        case .molluscs: .purple
        case .plants: Theme.accent
        case .fungi: .red
        case .protozoans, .chromista: .indigo
        case .animals: .gray
        }
    }
}
