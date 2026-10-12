//
//  NetworkError.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 06.09.2026.
//

import Foundation

enum NetworkError: Error, Equatable {
    case offline
    case timedOut
    case rateLimited
    case notFound
    case server(status: Int)
    case badRequest(status: Int)
    case decoding
    case unknown

    init(_ error: Error) {
        switch error {
        case let networkError as NetworkError:
            self = networkError
        case is DecodingError:
            self = .decoding
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet, .dataNotAllowed, .cannotFindHost, .cannotConnectToHost,
                 .networkConnectionLost, .dnsLookupFailed:
                self = .offline
            case .timedOut:
                self = .timedOut
            default:
                self = .unknown
            }
        default:
            self = .unknown
        }
    }

    var title: String {
        switch self {
        case .offline: "No internet connection"
        case .timedOut: "The request timed out"
        case .rateLimited: "Too many requests"
        case .notFound: "WildlifeObservation not found"
        case .server: "iNaturalist is unavailable"
        case .badRequest: "Request failed"
        case .decoding: "Unexpected response"
        case .unknown: "Something went wrong"
        }
    }

    var message: String {
        switch self {
        case .offline: "Check your connection and try again."
        case .timedOut: "The server took too long to respond."
        case .rateLimited: "iNaturalist limits how often data can be requested. Please wait a moment."
        case .notFound: "It may have been deleted or made private on iNaturalist."
        case .server: "The service is having trouble right now. Please try again later."
        case .badRequest: "The observation service rejected the request."
        case .decoding: "The data returned by iNaturalist could not be read."
        case .unknown: "Please try again."
        }
    }
}
