//
//  HTTPClient.swift
//  LogChain
//

import Foundation

/// Thin generic GET + decode wrapper shared by all CoinGecko calls.
/// Centralizes HTTP status -> APIError mapping and JSON decoding.
struct HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch let urlError as URLError {
            throw Self.map(urlError)
        } catch {
            throw APIError.unknown
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 404:
            throw APIError.notFound
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
            throw APIError.rateLimited(retryAfter: retryAfter)
        case 500..<600:
            throw APIError.server(statusCode: httpResponse.statusCode)
        default:
            throw APIError.server(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    private static func map(_ error: URLError) -> APIError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .cannotConnectToHost, .timedOut:
            return .offline
        default:
            return .unknown
        }
    }
}
