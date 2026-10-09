//
//  MarketsView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 09/10/2026.
//

import SwiftUI
import SwiftData

struct MarketsView: View {
    @Query(sort: \WatchedCoin.sortOrder) private var watchedCoins: [WatchedCoin]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddCoinViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let errorState = viewModel.errorState {
                    ErrorStateView(state: errorState) {
                        Task { await viewModel.loadBrowseList() }
                    }
                } else if viewModel.isLoading && viewModel.browseResults.isEmpty && viewModel.searchResults.isEmpty {
                    LoadingView()
                } else {
                    list
                }
            }
            .navigationTitle("Markets")
            .searchable(text: $viewModel.searchText, prompt: "Search coins")
            .navigationDestination(for: WatchedCoin.self) { coin in
                CoinDetailView(coin: coin)
            }
            .task {
                await viewModel.loadBrowseList()
            }
        }
    }

    private var list: some View {
        List {
            if viewModel.isSearching {
                ForEach(viewModel.searchResults) { result in
                    row(coinID: result.id) {
                        CoinSearchResultRow(imageURL: result.thumb, name: result.name, symbol: result.symbol, price: nil, change24h: nil)
                    } onAdd: {
                        Task { _ = await viewModel.addFromSearchResult(result, modelContext: modelContext) }
                    }
                }
            } else {
                ForEach(viewModel.browseResults, id: \.id) { dto in
                    row(coinID: dto.id) {
                        CoinSearchResultRow(imageURL: dto.image, name: dto.name, symbol: dto.symbol, price: dto.currentPrice, change24h: dto.priceChangePercentage24h)
                    } onAdd: {
                        viewModel.add(coinID: dto.id, symbol: dto.symbol, name: dto.name, imageURL: dto.image, price: dto.currentPrice, change24h: dto.priceChangePercentage24h, modelContext: modelContext)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadBrowseList()
        }
    }

    /// Watched coins link to their detail page; others show an add button.
    @ViewBuilder
    private func row<Content: View>(coinID: String, @ViewBuilder content: () -> Content, onAdd: @escaping () -> Void) -> some View {
        if let watched = watchedCoins.first(where: { $0.coinID == coinID }) {
            NavigationLink(value: watched) {
                HStack {
                    content()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                        .accessibilityLabel("In watchlist")
                }
            }
        } else {
            HStack {
                content()
                Button(action: onAdd) {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Add to watchlist")
            }
        }
    }
}

#Preview {
    MarketsView()
        .modelContainer(for: WatchedCoin.self, inMemory: true)
}
