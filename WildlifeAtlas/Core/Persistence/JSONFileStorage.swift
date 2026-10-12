//
//  JSONFileStorage.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import Foundation

actor JSONFileStorage {
    private let url: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileName: String) {
        let directory = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.init(url: directory.appendingPathComponent(fileName, isDirectory: false))
    }

    init(url: URL) {
        self.url = url
    }

    func load<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    func save<T: Encodable>(_ value: T) {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try encoder.encode(value).write(to: url, options: .atomic)
        } catch {
            assertionFailure("Failed to persist \(url.lastPathComponent): \(error)")
        }
    }
}
