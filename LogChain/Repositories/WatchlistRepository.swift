//
//  WatchlistRepository.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import Foundation
import SwiftData
import Observation

enum AddCoinResult {
    case added
    case duplicate
}

/// Single owner of the persisted watchlist. Every mutation goes through here and
/// refreshes `coins`, so observers (view models, views) always see a consistent list.
@Observable
final class WatchlistRepository {
    private(set) var coins: [WatchedCoin] = []

    @ObservationIgnored private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        reload()
    }

    func contains(coinID: String) -> Bool {
        coins.contains { $0.coinID == coinID }
    }

    @discardableResult
    func add(coinID: String, symbol: String, name: String, imageURL: String, price: Double, change24h: Double?) -> AddCoinResult {
        guard !contains(coinID: coinID) else { return .duplicate }

        let coin = WatchedCoin(
            coinID: coinID,
            symbol: symbol,
            name: name,
            imageURL: imageURL,
            lastKnownPrice: price,
            lastKnownChange24h: change24h,
            sortOrder: coins.count
        )
        context.insert(coin)
        save()
        return .added
    }

    func remove(at offsets: IndexSet) {
        for index in offsets {
            context.delete(coins[index])
        }
        save()
    }

    func clearAll() {
        for coin in coins {
            context.delete(coin)
        }
        save()
    }

    /// Updates stored quotes for watched coins from fresh market data.
    func apply(_ dtos: [CoinMarketDTO]) {
        let dtosByID = Dictionary(dtos.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for coin in coins {
            if let dto = dtosByID[coin.coinID] {
                coin.apply(dto)
            }
        }
        save()
    }

    private func save() {
        try? context.save()
        reload()
    }

    private func reload() {
        let descriptor = FetchDescriptor<WatchedCoin>(sortBy: [SortDescriptor(\.sortOrder)])
        coins = (try? context.fetch(descriptor)) ?? []
    }
}
