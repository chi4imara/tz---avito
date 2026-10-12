//
//  HTTPClient.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

protocol HTTPClient: Sendable {
    func value<T: Decodable>(for request: URLRequest, as type: T.Type) async throws -> T
}

final class URLSessionHTTPClient: HTTPClient {
    static let shared = URLSessionHTTPClient()

    private static let sharedSession: URLSession = makeSession()

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = URLSessionHTTPClient.sharedSession) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.urlCache = URLCache(memoryCapacity: 8 * 1024 * 1024, diskCapacity: 32 * 1024 * 1024)
        configuration.httpAdditionalHeaders = ["Accept": "application/json"]
        return URLSession(configuration: configuration)
    }

    nonisolated func value<T: Decodable>(for request: URLRequest, as type: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw NetworkError(error)
        }

        guard let http = response as? HTTPURLResponse else { throw NetworkError.unknown }

        switch http.statusCode {
        case 200..<300:
            break
        case 429:
            throw NetworkError.rateLimited
        case 400..<500:
            throw NetworkError.badRequest(status: http.statusCode)
        default:
            throw NetworkError.server(status: http.statusCode)
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
}
