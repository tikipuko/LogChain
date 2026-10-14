//
//  WatchlistView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI
import SwiftData
import TipKit

struct WatchlistView: View {
    @Query(sort: \WatchedCoin.sortOrder) private var watchedCoins: [WatchedCoin]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = WatchlistViewModel()
    @State private var showingAddCoin = false
    private let swipeToRemoveTip = SwipeToRemoveTip()

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
                    AddCoinView()
                }
                .task {
                    await viewModel.refresh(coins: watchedCoins, modelContext: modelContext)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    Task {
                        await viewModel.refreshIfNeeded(coins: watchedCoins, modelContext: modelContext)
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if watchedCoins.isEmpty {
            WatchlistEmptyStateView {
                showingAddCoin = true
            }
        } else {
            List {
                TipView(swipeToRemoveTip)
                    .listRowSeparator(.hidden)

                if let errorState = viewModel.errorState {
                    ErrorStateView(state: errorState) {
                        Task { await viewModel.refresh(coins: watchedCoins, modelContext: modelContext) }
                    }
                    .listRowSeparator(.hidden)
                }

                ForEach(watchedCoins) { coin in
                    NavigationLink(value: coin) {
                        WatchedCoinRow(coin: coin)
                    }
                }
                .onDelete(perform: delete)
            }
            .refreshable {
                await viewModel.refresh(coins: watchedCoins, modelContext: modelContext)
            }
            .navigationDestination(for: WatchedCoin.self) { coin in
                CoinDetailView(coin: coin)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(watchedCoins[index])
        }
        try? modelContext.save()
        swipeToRemoveTip.invalidate(reason: .actionPerformed)
    }
}

#Preview {
    WatchlistView()
        .modelContainer(for: WatchedCoin.self, inMemory: true)
}
