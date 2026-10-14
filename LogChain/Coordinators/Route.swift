//
//  Route.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import Foundation

/// Screens pushed onto a tab's NavigationStack. Views only name the route; the coordinator builds the screen.
enum Route: Hashable {
    case coinDetail(CoinSummary)
}

/// Modal screens the Watchlist coordinator can present.
enum WatchlistSheet: String, Identifiable {
    case addCoin

    var id: String { rawValue }
}
