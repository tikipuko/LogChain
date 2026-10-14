//
//  WatchlistCoordinator.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftUI
import Observation

@Observable
final class WatchlistCoordinator {
    var path: [Route] = []
    var sheet: WatchlistSheet?

    let viewModel: WatchlistViewModel
    @ObservationIgnored let factory: ScreenFactory

    init(factory: ScreenFactory) {
        self.factory = factory
        self.viewModel = factory.makeWatchlistViewModel()
    }

    func showCoinDetail(_ coin: CoinSummary) {
        path.append(.coinDetail(coin))
    }

    func presentAddCoin() {
        sheet = .addCoin
    }

    func dismissSheet() {
        sheet = nil
    }
}

struct WatchlistCoordinatorView: View {
    @Bindable var coordinator: WatchlistCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            WatchlistView(viewModel: coordinator.viewModel, onAddCoin: coordinator.presentAddCoin)
                .navigationDestination(for: Route.self) { route in
                    coordinator.factory.view(for: route)
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .addCoin:
                AddCoinView(viewModel: coordinator.factory.makeMarketsViewModel(), onClose: coordinator.dismissSheet)
            }
        }
    }
}
