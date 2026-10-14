//
//  AddCoinView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI

/// Presented as a sheet by the Watchlist coordinator, which also decides how it is closed.
/// Tap coins to select them, then Done adds all of them at once.
struct AddCoinView: View {
    @State private var viewModel: MarketsViewModel
    @State private var isAdding = false
    private let onClose: () -> Void

    init(viewModel: MarketsViewModel, onClose: @escaping () -> Void) {
        _viewModel = State(wrappedValue: viewModel)
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            Group {
                if let errorState = viewModel.errorState {
                    ErrorStateView(state: errorState) {
                        Task { await viewModel.reloadBrowseList() }
                    }
                } else if viewModel.isLoading && viewModel.browseResults.isEmpty && viewModel.searchResults.isEmpty {
                    LoadingView()
                } else {
                    list
                }
            }
            .navigationTitle(title)
            .searchable(text: $viewModel.searchText, prompt: "Search coins")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onClose)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: confirm)
                        .tint(.green)
                        .disabled(viewModel.pendingCoins.isEmpty || isAdding)
                }
            }
            .task {
                await viewModel.loadBrowseList()
            }
        }
    }

    private var title: String {
        let count = viewModel.pendingCoins.count
        return count == 0 ? "Add Coins" : "\(count) Selected"
    }

    private var list: some View {
        List {
            if viewModel.isSearching {
                ForEach(viewModel.searchResults) { result in
                    selectableRow(coin: .search(result)) {
                        CoinSearchResultRow(imageURL: result.thumb, name: result.name, symbol: result.symbol, price: nil, change24h: nil)
                    }
                }
            } else {
                ForEach(viewModel.browseResults, id: \.id) { dto in
                    selectableRow(coin: .market(dto)) {
                        CoinSearchResultRow(imageURL: dto.image, name: dto.name, symbol: dto.symbol, price: dto.currentPrice, change24h: dto.priceChangePercentage24h)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    /// Coins already in the watchlist show a dimmed filled check and can't be selected again.
    private func selectableRow<Content: View>(coin: PendingCoin, @ViewBuilder content: () -> Content) -> some View {
        let isWatched = viewModel.isWatched(coinID: coin.id)
        let isSelected = viewModel.isPending(coinID: coin.id)

        return Button {
            viewModel.togglePending(coin)
        } label: {
            HStack {
                content()
                Image(systemName: isWatched || isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
            }
        }
        .tint(.primary)
        .disabled(isWatched)
        .opacity(isWatched ? 0.5 : 1)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isWatched ? "Already in your watchlist" : "")
    }

    private func confirm() {
        isAdding = true
        Task {
            await viewModel.addPendingCoins()
            onClose()
        }
    }
}
