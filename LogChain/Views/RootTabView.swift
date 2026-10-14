//
//  RootTabView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 09/10/2026.
//

import SwiftUI

enum AppTab: Hashable {
    case watchlist
    case markets
    case settings
}

struct RootTabView: View {
    let dependencies: AppDependencies
    @State private var selection: AppTab = .watchlist

    var body: some View {
        TabView(selection: $selection) {
            Tab("Watchlist", systemImage: "star", value: .watchlist) {
                WatchlistView(dependencies: dependencies)
            }
            Tab("Markets", systemImage: "chart.line.uptrend.xyaxis", value: .markets) {
                MarketsView(dependencies: dependencies)
            }
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsView(dependencies: dependencies)
            }
        }
    }
}

#Preview {
    RootTabView(dependencies: .preview)
}
