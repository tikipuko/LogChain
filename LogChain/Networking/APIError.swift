//
//  APIError.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation

enum APIError: Error, LocalizedError, Equatable {
    case offline
    case rateLimited(retryAfter: TimeInterval?)
    case notFound
    case decoding
    case server(statusCode: Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .offline:
            return "No internet connection."
        case .rateLimited:
            return "Too many requests. Please try again shortly."
        case .notFound:
            return "Coin not found."
        case .decoding:
            return "Unexpected response from server."
        case .server(let statusCode):
            return "Server error (\(statusCode))."
        case .unknown:
            return "Something went wrong."
        }
    }
}
