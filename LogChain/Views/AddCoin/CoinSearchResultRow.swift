//
//  CoinSearchResultRow.swift
//  LogChain
//

import SwiftUI

struct CoinSearchResultRow: View {
    let imageURL: String
    let name: String
    let symbol: String
    let price: Double?
    let change24h: Double?

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(.quaternary)
            }
            .frame(width: 28, height: 28)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                Text(symbol.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let price {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyFormatter.price(price))
                        .font(.callout)
                    PercentChangeLabel(value: change24h)
                }
            }
        }
    }
}
