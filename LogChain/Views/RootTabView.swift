//
//  RootTabView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 09/10/2026.
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case watchlist
    case markets
    case settings
}

struct RootTabView: View {
    @State private var selection: AppTab = .watchlist

    var body: some View {
        TabView(selection: $selection) {
            Tab("Watchlist", systemImage: "star", value: .watchlist) {
                WatchlistView()
            }
            Tab("Markets", systemImage: "chart.line.uptrend.xyaxis", value: .markets) {
                MarketsView()
            }
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: WatchedCoin.self, inMemory: true)
}
