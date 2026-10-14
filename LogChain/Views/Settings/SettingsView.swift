//
//  SettingsView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 09/10/2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showingClearConfirmation = false

    init(dependencies: AppDependencies) {
        _viewModel = State(wrappedValue: SettingsViewModel(watchlist: dependencies.watchlistRepository))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Data") {
                    Button("Clear Watchlist", role: .destructive) {
                        showingClearConfirmation = true
                    }
                    .disabled(!viewModel.hasWatchedCoins)
                }

                Section("About") {
                    LabeledContent("Version", value: viewModel.appVersion)
                    if let environmentName = viewModel.environmentName {
                        LabeledContent("Environment", value: environmentName)
                    }
                    Link("Market data by CoinGecko", destination: URL(string: "https://www.coingecko.com")!)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Remove all coins from your watchlist?", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
                Button("Clear Watchlist", role: .destructive, action: viewModel.clearWatchlist)
            }
        }
    }
}

#Preview {
    SettingsView(dependencies: .preview)
}
