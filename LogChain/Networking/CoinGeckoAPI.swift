//
//  CoinGeckoAPI.swift
//  LogChain
//

import Foundation

protocol CoinGeckoAPI {
    func topMarkets(page: Int, perPage: Int) async throws -> [CoinMarketDTO]
    func markets(ids: [String]) async throws -> [CoinMarketDTO]
    func search(query: String) async throws -> [CoinSearchResultDTO]
    func marketChart(id: String, days: Int) async throws -> MarketChartDTO
}
