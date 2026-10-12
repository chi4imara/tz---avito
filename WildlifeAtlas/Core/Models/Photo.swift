//
//  Photo.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

struct Photo: Identifiable, Codable, Hashable, Sendable {
    enum Size: String {
        case square, medium, large
    }

    let id: Int
    let url: URL?
    let attribution: String?
    let licenseCode: String?

    private enum CodingKeys: String, CodingKey {
        case id, url, attribution
        case licenseCode = "license_code"
    }

    func url(_ size: Size) -> URL? {
        url?.replacingImageSize(with: size)
    }

    var licenseTitle: String? {
        guard let licenseCode, !licenseCode.isEmpty else { return nil }
        let suffix = licenseCode
            .replacingOccurrences(of: "cc-", with: "")
            .replacingOccurrences(of: "cc0", with: "0")
            .uppercased()
        return licenseCode.hasPrefix("cc") ? "CC \(suffix)" : licenseCode.uppercased()
    }
}

extension URL {
    func replacingImageSize(with size: Photo.Size) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        guard var path = components?.path, let slash = path.lastIndex(of: "/") else { return self }
        let fileName = String(path[path.index(after: slash)...])
        guard let dot = fileName.lastIndex(of: ".") else { return self }

        let currentSize = String(fileName[fileName.startIndex..<dot])
        let knownSizes: Set<String> = ["square", "small", "medium", "large", "original"]
        guard knownSizes.contains(currentSize) else { return self }

        let ext = String(fileName[dot...])
        path.replaceSubrange(path.index(after: slash)..., with: size.rawValue + ext)
        components?.path = path
        return components?.url ?? self
    }
}
