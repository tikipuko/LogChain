//
//  CoinSearchDTO.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation

struct CoinSearchResponseDTO: Decodable {
    let coins: [CoinSearchResultDTO]
}

struct CoinSearchResultDTO: Decodable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int?
    let thumb: String

    enum CodingKeys: String, CodingKey {
        case id, name, symbol, thumb
        case marketCapRank = "market_cap_rank"
    }
}
