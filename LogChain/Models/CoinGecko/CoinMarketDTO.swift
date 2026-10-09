//
//  CoinMarketDTO.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation

struct CoinMarketDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let priceChangePercentage24h: Double?
    let highPrice24h: Double?
    let lowPrice24h: Double?
    let marketCap: Double?
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case highPrice24h = "high_24h"
        case lowPrice24h = "low_24h"
        case marketCap = "market_cap"
        case lastUpdated = "last_updated"
    }
}
