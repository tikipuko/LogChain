//
//  MarketChartDTO.swift
//  LogChain
//

import Foundation

struct MarketChartDTO: Decodable {
    let prices: [[Double]]
}

struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

extension MarketChartDTO {
    func toPricePoints() -> [PricePoint] {
        prices.compactMap { pair in
            guard pair.count == 2 else { return nil }
            let date = Date(timeIntervalSince1970: pair[0] / 1000)
            return PricePoint(date: date, price: pair[1])
        }
    }
}
