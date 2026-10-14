//
//  CoinDetailView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI
import TipKit

/// What the detail page needs to show a coin, whether or not it is in the watchlist.
struct CoinSummary: Hashable {
    let coinID: String
    let name: String
    let price: Double?
    let change24h: Double?

    init(coinID: String, name: String, price: Double?, change24h: Double?) {
        self.coinID = coinID
        self.name = name
        self.price = price
        self.change24h = change24h
    }

    init(_ coin: WatchedCoin) {
        self.init(coinID: coin.coinID, name: coin.name, price: coin.lastKnownPrice, change24h: coin.lastKnownChange24h)
    }
}

struct CoinDetailView: View {
    let coin: CoinSummary
    @State private var viewModel: CoinDetailViewModel
    private let timeframeTip = TimeframeTip()

    init(coin: CoinSummary) {
        self.coin = coin
        _viewModel = State(wrappedValue: CoinDetailViewModel(coinID: coin.coinID))
    }

    init(coin: WatchedCoin) {
        self.init(coin: CoinSummary(coin))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                TimeframePicker(selection: $viewModel.selectedTimeframe)
                    .popoverTip(timeframeTip, arrowEdge: .top)
                    .onChange(of: viewModel.selectedTimeframe) {
                        timeframeTip.invalidate(reason: .actionPerformed)
                    }

                if let errorState = viewModel.errorState {
                    ErrorStateView(state: errorState) {
                        Task { await viewModel.loadChart() }
                    }
                    .frame(height: 220)
                } else if viewModel.isLoading && viewModel.chartPoints.isEmpty {
                    LoadingView()
                        .frame(height: 220)
                } else {
                    PriceHistoryChartView(points: viewModel.chartPoints, timeframe: viewModel.selectedTimeframe)
                }
            }
            .padding()
        }
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadChart()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Search results have no price yet; fall back to the latest chart point.
            if let price = coin.price ?? viewModel.chartPoints.last?.price {
                Text(CurrencyFormatter.price(price))
                    .font(.largeTitle.weight(.bold))
            } else {
                Text("—")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            PercentChangeLabel(value: coin.change24h)
        }
    }
}
