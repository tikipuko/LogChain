//
//  LogChainApp.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 08/10/2026.
//

import SwiftUI
import SwiftData

@main
struct LogChainApp: App {
    private let modelContainer = PersistenceController.makeContainer()

    var body: some Scene {
        WindowGroup {
            WatchlistView()
        }
        .modelContainer(modelContainer)
    }
}
