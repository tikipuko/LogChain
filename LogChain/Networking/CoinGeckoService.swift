//
//  CoinGeckoService.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation

final class CoinGeckoService: CoinGeckoAPI {
    private let baseURL: URL
    private let httpClient: HTTPClient
    private let rateLimiter: RateLimiter
    private let cache = MarketsCache()

    init(
        baseURL: URL = AppEnvironment.current.apiBaseURL,
        httpClient: HTTPClient = HTTPClient(),
        rateLimiter: RateLimiter = RateLimiter()
    ) {
        self.baseURL = baseURL
        self.httpClient = httpClient
        self.rateLimiter = rateLimiter
    }

    func topMarkets(page: Int, perPage: Int, category: String?) async throws -> [CoinMarketDTO] {
        let cacheKey = "top|\(category ?? "all")|\(page)|\(perPage)"
        if let cached = await cache.value(for: cacheKey) {
            return cached
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("coins/markets"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sparkline", value: "false"),
        ]
        if let category {
            components.queryItems?.append(URLQueryItem(name: "category", value: category))
        }
        await rateLimiter.acquire()
        let result: [CoinMarketDTO] = try await httpClient.get(components.url!)
        await cache.store(result, for: cacheKey)
        return result
    }

    func markets(ids: [String]) async throws -> [CoinMarketDTO] {
        guard !ids.isEmpty else { return [] }

        let cacheKey = ids.sorted().joined(separator: ",")
        if let cached = await cache.value(for: cacheKey) {
            return cached
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("coins/markets"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
            URLQueryItem(name: "sparkline", value: "false"),
            URLQueryItem(name: "price_change_percentage", value: "24h"),
        ]
        await rateLimiter.acquire()
        let result: [CoinMarketDTO] = try await httpClient.get(components.url!)
        await cache.store(result, for: cacheKey)
        return result
    }

    func search(query: String) async throws -> [CoinSearchResultDTO] {
        var components = URLComponents(url: baseURL.appendingPathComponent("search"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "query", value: query)]
        await rateLimiter.acquire()
        let response: CoinSearchResponseDTO = try await httpClient.get(components.url!)
        return response.coins
    }

    func marketChart(id: String, days: Int) async throws -> MarketChartDTO {
        var components = URLComponents(url: baseURL.appendingPathComponent("coins/\(id)/market_chart"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "days", value: String(days)),
        ]
        await rateLimiter.acquire()
        return try await httpClient.get(components.url!)
    }
}

/// Short-TTL cache so bouncing between Watchlist/Detail within a few seconds
/// doesn't refire identical /coins/markets requests against the rate limit.
private actor MarketsCache {
    private let ttl: TimeInterval
    private var entries: [String: (value: [CoinMarketDTO], timestamp: Date)] = [:]

    init(ttl: TimeInterval = 20) {
        self.ttl = ttl
    }

    func value(for key: String) -> [CoinMarketDTO]? {
        guard let entry = entries[key], Date().timeIntervalSince(entry.timestamp) < ttl else {
            return nil
        }
        return entry.value
    }

    func store(_ value: [CoinMarketDTO], for key: String) {
        entries[key] = (value, Date())
    }
}
