//
//  AppCoordinator.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftUI
import Observation

enum AppTab: Hashable {
    case watchlist
    case markets
    case settings
}

/// Root of the coordinator tree: owns the selected tab and one child coordinator per tab.
@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .watchlist

    let watchlist: WatchlistCoordinator
    let markets: MarketsCoordinator
    let settings: SettingsCoordinator

    init(dependencies: AppDependencies) {
        let factory = ScreenFactory(dependencies: dependencies)
        self.watchlist = WatchlistCoordinator(factory: factory)
        self.markets = MarketsCoordinator(factory: factory)
        self.settings = SettingsCoordinator(factory: factory)
    }
}

struct AppCoordinatorView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Tab("Watchlist", systemImage: "star", value: .watchlist) {
                WatchlistCoordinatorView(coordinator: coordinator.watchlist)
            }
            Tab("Markets", systemImage: "chart.line.uptrend.xyaxis", value: .markets) {
                MarketsCoordinatorView(coordinator: coordinator.markets)
            }
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsCoordinatorView(coordinator: coordinator.settings)
            }
        }
    }
}

#Preview {
    AppCoordinatorView(coordinator: AppCoordinator(dependencies: .preview))
}
