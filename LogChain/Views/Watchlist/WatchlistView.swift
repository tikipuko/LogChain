//
//  WatchlistView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI
import TipKit

struct WatchlistView: View {
    @Environment(\.scenePhase) private var scenePhase
    private let dependencies: AppDependencies
    @State private var viewModel: WatchlistViewModel
    @State private var showingAddCoin = false
    private let swipeToRemoveTip = SwipeToRemoveTip()

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(wrappedValue: WatchlistViewModel(markets: dependencies.marketsRepository, watchlist: dependencies.watchlistRepository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Watchlist")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddCoin = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddCoin) {
                    AddCoinView(dependencies: dependencies)
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
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.coins.isEmpty {
            WatchlistEmptyStateView {
                showingAddCoin = true
            }
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
                    NavigationLink(value: CoinSummary(coin)) {
                        WatchedCoinRow(coin: coin)
                    }
                }
                .onDelete(perform: delete)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(for: CoinSummary.self) { coin in
                CoinDetailView(coin: coin, markets: dependencies.marketsRepository)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        viewModel.remove(at: offsets)
        swipeToRemoveTip.invalidate(reason: .actionPerformed)
    }
}

#Preview {
    WatchlistView(dependencies: .preview)
}
