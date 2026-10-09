//
//  WatchedCoin.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation
import SwiftData

@Model
final class WatchedCoin {
    @Attribute(.unique) var coinID: String
    var symbol: String
    var name: String
    var imageURL: String
    var lastKnownPrice: Double
    var lastKnownChange24h: Double?
    var lastUpdated: Date
    var sortOrder: Int
    var dateAdded: Date

    init(
        coinID: String,
        symbol: String,
        name: String,
        imageURL: String,
        lastKnownPrice: Double,
        lastKnownChange24h: Double?,
        lastUpdated: Date = .now,
        sortOrder: Int,
        dateAdded: Date = .now
    ) {
        self.coinID = coinID
        self.symbol = symbol
        self.name = name
        self.imageURL = imageURL
        self.lastKnownPrice = lastKnownPrice
        self.lastKnownChange24h = lastKnownChange24h
        self.lastUpdated = lastUpdated
        self.sortOrder = sortOrder
        self.dateAdded = dateAdded
    }
}

extension WatchedCoin {
    func apply(_ dto: CoinMarketDTO) {
        name = dto.name
        symbol = dto.symbol
        imageURL = dto.image
        lastKnownPrice = dto.currentPrice
        lastKnownChange24h = dto.priceChangePercentage24h
        lastUpdated = .now
    }
}
