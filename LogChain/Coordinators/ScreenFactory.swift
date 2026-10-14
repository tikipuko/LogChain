//
//  ScreenFactory.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftUI

/// Builds view models and screens from the app's dependencies, so coordinators never wire things by hand.
struct ScreenFactory {
    let dependencies: AppDependencies

    func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(markets: dependencies.marketsRepository, watchlist: dependencies.watchlistRepository)
    }

    func makeMarketsViewModel() -> MarketsViewModel {
        MarketsViewModel(markets: dependencies.marketsRepository, watchlist: dependencies.watchlistRepository)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(watchlist: dependencies.watchlistRepository)
    }

    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .coinDetail(let coin):
            CoinDetailView(coin: coin, markets: dependencies.marketsRepository)
        }
    }
}
