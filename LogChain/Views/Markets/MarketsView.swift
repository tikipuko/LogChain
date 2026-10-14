//
//  MarketsView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 09/10/2026.
//

import SwiftUI
import SwiftData
import TipKit

struct MarketsView: View {
    @Query(sort: \WatchedCoin.sortOrder) private var watchedCoins: [WatchedCoin]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddCoinViewModel()
    private let swipeToAddTip = SwipeToAddTip()

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
            // Attached to the Group (not the list) so the controls stay available while loading or after an error.
            .safeAreaInset(edge: .top, spacing: 0) {
                if !viewModel.isSearching {
                    MarketsCategoryChips(selection: $viewModel.selectedCategory)
                        .background(.bar)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !viewModel.isSearching {
                    sortFilterMenu {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.accentColor, in: Circle())
                            .shadow(radius: 4, y: 2)
                    }
                    .padding()
                    .accessibilityLabel("Sort and filter")
                }
            }
            .navigationTitle("Markets")
            .searchable(text: $viewModel.searchText, prompt: "Search coins")
            .toolbar {
                if !viewModel.isSearching {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortFilterMenu {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
            .navigationDestination(for: CoinSummary.self) { coin in
                CoinDetailView(coin: coin)
            }
            .task {
                await viewModel.loadBrowseList()
            }
        }
    }

    private var list: some View {
        List {
            TipView(swipeToAddTip)
                .listRowSeparator(.hidden)

            if viewModel.isSearching {
                ForEach(viewModel.searchResults) { result in
                    row(summary: CoinSummary(coinID: result.id, name: result.name, price: nil, change24h: nil)) {
                        CoinSearchResultRow(imageURL: result.thumb, name: result.name, symbol: result.symbol, price: nil, change24h: nil)
                    } onAdd: {
                        Task { _ = await viewModel.addFromSearchResult(result, modelContext: modelContext) }
                    }
                }
            } else {
                if viewModel.displayedBrowseResults.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView("No coins match", systemImage: "line.3.horizontal.decrease.circle", description: Text("Try a different filter."))
                        .listRowSeparator(.hidden)
                }
                ForEach(viewModel.displayedBrowseResults, id: \.id) { dto in
                    row(summary: CoinSummary(coinID: dto.id, name: dto.name, price: dto.currentPrice, change24h: dto.priceChangePercentage24h)) {
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

    private func sortFilterMenu<MenuLabel: View>(@ViewBuilder label: @escaping () -> MenuLabel) -> some View {
        MarketsSortFilterMenu(
            sort: $viewModel.sort,
            reverseOrder: $viewModel.reverseOrder,
            movers: $viewModel.movers,
            label: label
        )
    }

    /// Every coin links to its detail page; coins not yet watched can be added with a swipe.
    private func row<Content: View>(summary: CoinSummary, @ViewBuilder content: () -> Content, onAdd: @escaping () -> Void) -> some View {
        NavigationLink(value: summary) {
            content()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if !watchedCoins.contains(where: { $0.coinID == summary.coinID }) {
                Button {
                    onAdd()
                    swipeToAddTip.invalidate(reason: .actionPerformed)
                } label: {
                    Label("Add", systemImage: "plus.circle")
                        .labelStyle(.iconOnly)
                }
                .tint(.accentColor)
            }
        }
    }
}

#Preview {
    MarketsView()
        .modelContainer(for: WatchedCoin.self, inMemory: true)
}
