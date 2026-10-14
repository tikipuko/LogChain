//
//  MarketsView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 09/10/2026.
//

import SwiftUI
import TipKit

struct MarketsView: View {
    private let dependencies: AppDependencies
    @State private var viewModel: MarketsViewModel
    private let swipeToAddTip = SwipeToAddTip()

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(wrappedValue: MarketsViewModel(markets: dependencies.marketsRepository, watchlist: dependencies.watchlistRepository))
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
            // Attached to the Group (not the list) so the chips stay available while loading or after an error.
            .safeAreaInset(edge: .top, spacing: 0) {
                if !viewModel.isSearching {
                    MarketsCategoryChips(selection: $viewModel.selectedCategories)
                        .background(.bar)
                }
            }
            .navigationTitle("Markets")
            .searchable(text: $viewModel.searchText, prompt: "Search coins")
            .toolbar {
                if !viewModel.isSearching {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortFilterMenu {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .accessibilityLabel("Sort and filter")
                        }
                    }
                }
            }
            .navigationDestination(for: CoinSummary.self) { coin in
                CoinDetailView(coin: coin, markets: dependencies.marketsRepository)
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
                        Task { _ = await viewModel.addFromSearchResult(result) }
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
                        viewModel.add(dto)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.reloadBrowseList()
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
            if !viewModel.isWatched(coinID: summary.coinID) {
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
    MarketsView(dependencies: .preview)
}
