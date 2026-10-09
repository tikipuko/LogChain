//
//  WatchedCoinRow.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI

struct WatchedCoinRow: View {
    let coin: WatchedCoin

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.imageURL)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(.quaternary)
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name)
                    .font(.body.weight(.medium))
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.price(coin.lastKnownPrice))
                    .font(.body.weight(.medium))
                PercentChangeLabel(value: coin.lastKnownChange24h)
            }
        }
        .padding(.vertical, 4)
    }
}
