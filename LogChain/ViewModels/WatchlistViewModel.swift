//
//  WatchlistViewModel.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation
import SwiftData
import Observation

@Observable
final class WatchlistViewModel {
    private(set) var isRefreshing = false
    private(set) var errorState: ErrorState?
    private(set) var lastRefreshDate: Date?

    private let api: CoinGeckoAPI
    private let foregroundRefreshThreshold: TimeInterval = 60

    init(api: CoinGeckoAPI = CoinGeckoService()) {
        self.api = api
    }

    func refresh(coins: [WatchedCoin], modelContext: ModelContext) async {
        guard !coins.isEmpty else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let dtos = try await api.markets(ids: coins.map(\.coinID))
            let dtosByID = Dictionary(uniqueKeysWithValues: dtos.map { ($0.id, $0) })
            for coin in coins {
                if let dto = dtosByID[coin.coinID] {
                    coin.apply(dto)
                }
            }
            try modelContext.save()
            errorState = nil
            lastRefreshDate = .now
        } catch let error as APIError {
            // Keep previously cached values on screen; only surface the error banner.
            errorState = ErrorState(apiError: error)
        } catch {
            errorState = .generic
        }
    }

    func refreshIfNeeded(coins: [WatchedCoin], modelContext: ModelContext) async {
        if let lastRefreshDate, Date().timeIntervalSince(lastRefreshDate) < foregroundRefreshThreshold {
            return
        }
        await refresh(coins: coins, modelContext: modelContext)
    }
}
