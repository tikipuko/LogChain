//
//  CoinDetailView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI
import TipKit

struct CoinDetailView: View {
    let coin: WatchedCoin
    @State private var viewModel: CoinDetailViewModel
    private let timeframeTip = TimeframeTip()

    init(coin: WatchedCoin) {
        self.coin = coin
        _viewModel = State(wrappedValue: CoinDetailViewModel(coinID: coin.coinID))
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
            Text(CurrencyFormatter.price(coin.lastKnownPrice))
                .font(.largeTitle.weight(.bold))
            PercentChangeLabel(value: coin.lastKnownChange24h)
        }
    }
}
