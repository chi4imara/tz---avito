//
//  ImageLoader.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 07.09.2026.
//

import UIKit

final class ImageMemoryCache: @unchecked Sendable {
    static let shared = ImageMemoryCache()

    private let cache = NSCache<NSURL, UIImage>()

    init(byteLimit: Int = 96 * 1024 * 1024) {
        cache.totalCostLimit = byteLimit
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL, cost: image.approximateByteSize)
    }
}

actor ImageLoader {
    static let shared = ImageLoader()

    private let cache: ImageMemoryCache
    private let session: URLSession
    private var inFlight: [URL: Task<UIImage, Error>] = [:]

    init(cache: ImageMemoryCache = .shared) {
        self.cache = cache
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 128 * 1024 * 1024)
        self.session = URLSession(configuration: configuration)
    }

    nonisolated func cachedImage(for url: URL) -> UIImage? {
        cache.image(for: url)
    }

    func image(for url: URL) async throws -> UIImage {
        if let cached = cache.image(for: url) { return cached }

        if let existing = inFlight[url] {
            return try await existing.value
        }

        let task = Task<UIImage, Error> { [session, cache] in
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw NetworkError.server(status: http.statusCode)
            }
            guard let image = UIImage(data: data) else { throw NetworkError.decoding }
            cache.insert(image, for: url)
            return image
        }

        inFlight[url] = task
        defer { inFlight[url] = nil }
        return try await task.value
    }
}

private extension UIImage {
    var approximateByteSize: Int {
        guard let cgImage else { return 1 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
