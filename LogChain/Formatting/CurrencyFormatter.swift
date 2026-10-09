//
//  CurrencyFormatter.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation

enum CurrencyFormatter {
    private static let usd: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private static let usdPrecise: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }()

    /// Coins under $1 (e.g. many altcoins) need more decimal places to be meaningful.
    static func price(_ value: Double) -> String {
        let formatter = abs(value) < 1 ? usdPrecise : usd
        return formatter.string(from: value as NSNumber) ?? "$\(value)"
    }

    static func percent(_ value: Double) -> String {
        String(format: "%+.2f%%", value)
    }
}
