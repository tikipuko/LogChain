//
//  MarketsRepository.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import Foundation

/// Market data as the app needs it, independent of the CoinGecko endpoints behind it.
protocol MarketsRepository {
    /// Top coins for the given categories (empty means all). Several categories are merged,
    /// de-duplicated and ordered by market cap. `shouldContinue` is checked between requests
    /// so a superseded caller can stop early; the call then throws `CancellationError`.
    func browse(categoryIDs: [String], shouldContinue: () -> Bool) async throws -> [CoinMarketDTO]
    func search(query: String) async throws -> [CoinSearchResultDTO]
    func quotes(ids: [String]) async throws -> [CoinMarketDTO]
    func chart(id: String, days: Int) async throws -> MarketChartDTO
}

final class CoinGeckoMarketsRepository: MarketsRepository {
    private let api: CoinGeckoAPI
    private let perPage = 50

    init(api: CoinGeckoAPI = CoinGeckoService()) {
        self.api = api
    }

    func browse(categoryIDs: [String], shouldContinue: () -> Bool) async throws -> [CoinMarketDTO] {
        // CoinGecko takes one category per request, so several are fetched one after another.
        guard categoryIDs.count > 1 else {
            return try await api.topMarkets(page: 1, perPage: perPage, category: categoryIDs.first)
        }

        var seen = Set<String>()
        var merged: [CoinMarketDTO] = []
        for id in categoryIDs {
            guard shouldContinue() else { throw CancellationError() }
            for coin in try await api.topMarkets(page: 1, perPage: perPage, category: id) where seen.insert(coin.id).inserted {
                merged.append(coin)
            }
        }
        return merged.sorted { ($0.marketCap ?? 0) > ($1.marketCap ?? 0) }
    }

    func search(query: String) async throws -> [CoinSearchResultDTO] {
        try await api.search(query: query)
    }

    func quotes(ids: [String]) async throws -> [CoinMarketDTO] {
        try await api.markets(ids: ids)
    }

    func chart(id: String, days: Int) async throws -> MarketChartDTO {
        try await api.marketChart(id: id, days: days)
    }
}
