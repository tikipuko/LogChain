//
//  SettingsView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 09/10/2026.
//

import SwiftUI

/// Hosted inside the Settings coordinator's NavigationStack.
struct SettingsView: View {
    let viewModel: SettingsViewModel
    @State private var showingClearConfirmation = false

    var body: some View {
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

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(watchlist: AppDependencies.preview.watchlistRepository))
    }
}
