//
//  WatchlistView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI
import TipKit

/// Hosted inside the Watchlist coordinator's NavigationStack. Rows push `Route`s and the
/// "add" actions ask the coordinator to present the Add Coin sheet.
struct WatchlistView: View {
    let viewModel: WatchlistViewModel
    let onAddCoin: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    private let swipeToRemoveTip = SwipeToRemoveTip()

    var body: some View {
        content
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onAddCoin) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.refresh()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                Task {
                    await viewModel.refreshIfNeeded()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.coins.isEmpty {
            WatchlistEmptyStateView(onAdd: onAddCoin)
        } else {
            List {
                TipView(swipeToRemoveTip)
                    .listRowSeparator(.hidden)

                if let errorState = viewModel.errorState {
                    ErrorStateView(state: errorState) {
                        Task { await viewModel.refresh() }
                    }
                    .listRowSeparator(.hidden)
                }

                ForEach(viewModel.coins) { coin in
                    NavigationLink(value: Route.coinDetail(CoinSummary(coin))) {
                        WatchedCoinRow(coin: coin)
                    }
                }
                .onDelete(perform: delete)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        viewModel.remove(at: offsets)
        swipeToRemoveTip.invalidate(reason: .actionPerformed)
    }
}

#Preview {
    let dependencies = AppDependencies.preview
    NavigationStack {
        WatchlistView(
            viewModel: WatchlistViewModel(markets: dependencies.marketsRepository, watchlist: dependencies.watchlistRepository),
            onAddCoin: {}
        )
    }
}
