//
//  AppDependencies.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftData

/// Composition root: builds the long-lived objects once and hands them to coordinators and view models.
struct AppDependencies {
    let modelContainer: ModelContainer
    let marketsRepository: MarketsRepository
    let watchlistRepository: WatchlistRepository

    init(
        modelContainer: ModelContainer = PersistenceController.makeContainer(),
        marketsRepository: MarketsRepository = CoinGeckoMarketsRepository()
    ) {
        self.modelContainer = modelContainer
        self.marketsRepository = marketsRepository
        self.watchlistRepository = WatchlistRepository(context: modelContainer.mainContext)
    }

    /// In-memory storage for previews and tests.
    static var preview: AppDependencies {
        let container = try! ModelContainer(
            for: WatchedCoin.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return AppDependencies(modelContainer: container)
    }
}
