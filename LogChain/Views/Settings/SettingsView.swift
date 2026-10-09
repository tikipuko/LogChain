//
//  SettingsView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 09/10/2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var watchedCoins: [WatchedCoin]
    @Environment(\.modelContext) private var modelContext
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Data") {
                    Button("Clear Watchlist", role: .destructive) {
                        showingClearConfirmation = true
                    }
                    .disabled(watchedCoins.isEmpty)
                }

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                    Link("Market data by CoinGecko", destination: URL(string: "https://www.coingecko.com")!)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Remove all coins from your watchlist?", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
                Button("Clear Watchlist", role: .destructive, action: clearWatchlist)
            }
        }
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "–"
        let build = info?["CFBundleVersion"] as? String ?? "–"
        return "\(version) (\(build))"
    }

    private func clearWatchlist() {
        for coin in watchedCoins {
            modelContext.delete(coin)
        }
        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: WatchedCoin.self, inMemory: true)
}
