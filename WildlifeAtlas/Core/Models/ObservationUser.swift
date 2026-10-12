//
//  ObservationUser.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

struct ObservationUser: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let login: String?
    let name: String?
    let iconURL: URL?

    private enum CodingKeys: String, CodingKey {
        case id, login, name
        case iconURL = "icon_url"
    }

    var displayName: String? {
        if let name, !name.isEmpty { return name }
        if let login, !login.isEmpty { return login }
        return nil
    }

    var handle: String? {
        guard let login, !login.isEmpty, login != displayName else { return nil }
        return "@\(login)"
    }
}
