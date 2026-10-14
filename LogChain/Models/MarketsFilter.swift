//
//  MarketsFilter.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import Foundation

/// CoinGecko category used to narrow the Markets list (server-side filter).
enum MarketCategory: String, CaseIterable, Identifiable {
    case all
    case meme
    case stablecoins
    case privacy
    case rwa
    case payments
    case defi
    case layer1
    case ai
    case gaming

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .meme: return "Meme"
        case .stablecoins: return "Stablecoins"
        case .privacy: return "Privacy"
        case .rwa: return "RWA"
        case .payments: return "Payments"
        case .defi: return "DeFi"
        case .layer1: return "Layer 1"
        case .ai: return "AI"
        case .gaming: return "Gaming"
        }
    }

    /// Value for the `category` query parameter; nil means no category filter.
    var apiID: String? {
        switch self {
        case .all: return nil
        case .meme: return "meme-token"
        case .stablecoins: return "stablecoins"
        case .privacy: return "privacy-coins"
        case .rwa: return "real-world-assets-rwa"
        case .payments: return "payment-solutions"
        case .defi: return "decentralized-finance-defi"
        case .layer1: return "layer-1"
        case .ai: return "artificial-intelligence"
        case .gaming: return "gaming"
        }
    }
}

enum MarketSort: String, CaseIterable, Identifiable {
    case marketCap = "Market cap"
    case price = "Price"
    case change24h = "24h change"
    case name = "Name"

    var id: String { rawValue }
}

enum MarketMovers: String, CaseIterable, Identifiable {
    case all = "All"
    case gainers = "Gainers"
    case losers = "Losers"

    var id: String { rawValue }
}
