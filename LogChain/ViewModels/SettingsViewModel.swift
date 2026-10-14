//
//  SettingsViewModel.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import Foundation
import Observation

@Observable
final class SettingsViewModel {
    @ObservationIgnored private let watchlist: WatchlistRepository

    var hasWatchedCoins: Bool { !watchlist.coins.isEmpty }

    var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "–"
        let build = info?["CFBundleVersion"] as? String ?? "–"
        return "\(version) (\(build))"
    }

    var environmentName: String? {
        AppEnvironment.current.isProduction ? nil : AppEnvironment.current.rawValue
    }

    init(watchlist: WatchlistRepository) {
        self.watchlist = watchlist
    }

    func clearWatchlist() {
        watchlist.clearAll()
    }
}
