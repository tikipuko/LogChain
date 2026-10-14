//
//  CoinGeckoAPI.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation

protocol CoinGeckoAPI {
    func topMarkets(page: Int, perPage: Int, category: String?) async throws -> [CoinMarketDTO]
    func markets(ids: [String]) async throws -> [CoinMarketDTO]
    func search(query: String) async throws -> [CoinSearchResultDTO]
    func marketChart(id: String, days: Int) async throws -> MarketChartDTO
}

extension CoinGeckoAPI {
    func topMarkets(page: Int, perPage: Int) async throws -> [CoinMarketDTO] {
        try await topMarkets(page: page, perPage: perPage, category: nil)
    }
}
