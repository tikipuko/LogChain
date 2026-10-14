//
//  AddCoinView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI

/// Presented as a sheet by the Watchlist coordinator, which also decides how it is closed.
struct AddCoinView: View {
    @State private var viewModel: MarketsViewModel
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
                        Task { await viewModel.loadBrowseList() }
                    }
                } else if viewModel.isLoading && viewModel.browseResults.isEmpty && viewModel.searchResults.isEmpty {
                    LoadingView()
                } else {
                    list
                }
            }
            .navigationTitle("Add Coin")
            .searchable(text: $viewModel.searchText, prompt: "Search coins")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onClose)
                }
            }
            .task {
                await viewModel.loadBrowseList()
            }
            .alert("Already Added", isPresented: duplicateAlertBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.duplicateMessage ?? "")
            }
        }
    }

    private var list: some View {
        List {
            if viewModel.isSearching {
                ForEach(viewModel.searchResults) { result in
                    Button {
                        Task {
                            if await viewModel.addFromSearchResult(result) {
                                onClose()
                            }
                        }
                    } label: {
                        CoinSearchResultRow(imageURL: result.thumb, name: result.name, symbol: result.symbol, price: nil, change24h: nil)
                    }
                    .tint(.primary)
                }
            } else {
                ForEach(viewModel.browseResults, id: \.id) { dto in
                    Button {
                        if viewModel.add(dto) {
                            onClose()
                        }
                    } label: {
                        CoinSearchResultRow(imageURL: dto.image, name: dto.name, symbol: dto.symbol, price: dto.currentPrice, change24h: dto.priceChangePercentage24h)
                    }
                    .tint(.primary)
                }
            }
        }
    }

    private var duplicateAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.duplicateMessage != nil },
            set: { isPresented in
                if !isPresented { viewModel.clearDuplicateMessage() }
            }
        )
    }
}
