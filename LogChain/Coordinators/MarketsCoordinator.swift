//
//  MarketsCoordinator.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftUI
import Observation

@Observable
final class MarketsCoordinator {
    var path: [Route] = []

    let viewModel: MarketsViewModel
    @ObservationIgnored let factory: ScreenFactory

    init(factory: ScreenFactory) {
        self.factory = factory
        self.viewModel = factory.makeMarketsViewModel()
    }

    func showCoinDetail(_ coin: CoinSummary) {
        path.append(.coinDetail(coin))
    }
}

struct MarketsCoordinatorView: View {
    @Bindable var coordinator: MarketsCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MarketsView(viewModel: coordinator.viewModel)
                .navigationDestination(for: Route.self) { route in
                    coordinator.factory.view(for: route)
                }
        }
    }
}
