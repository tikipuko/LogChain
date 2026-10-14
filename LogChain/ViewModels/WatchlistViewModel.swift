//
//  WatchlistViewModel.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation
import Observation

@Observable
final class WatchlistViewModel {
    private(set) var errorState: ErrorState?
    private(set) var lastRefreshDate: Date?

    @ObservationIgnored private let markets: MarketsRepository
    @ObservationIgnored private let watchlist: WatchlistRepository
    private let foregroundRefreshThreshold: TimeInterval = 60

    var coins: [WatchedCoin] { watchlist.coins }

    init(markets: MarketsRepository, watchlist: WatchlistRepository) {
        self.markets = markets
        self.watchlist = watchlist
    }

    func remove(at offsets: IndexSet) {
        watchlist.remove(at: offsets)
    }

    func refresh() async {
        let coins = watchlist.coins
        guard !coins.isEmpty else { return }
        do {
            let dtos = try await markets.quotes(ids: coins.map(\.coinID))
            watchlist.apply(dtos)
            errorState = nil
            lastRefreshDate = .now
        } catch let error as APIError {
            // Keep previously cached values on screen; only surface the error banner.
            errorState = ErrorState(apiError: error)
        } catch {
            errorState = .generic
        }
    }

    func refreshIfNeeded() async {
        if let lastRefreshDate, Date().timeIntervalSince(lastRefreshDate) < foregroundRefreshThreshold {
            return
        }
        await refresh()
    }
}
