//
//  PercentChangeLabel.swift
//  LogChain
//

import SwiftUI

struct PercentChangeLabel: View {
    let value: Double?

    var body: some View {
        if let value {
            Text(CurrencyFormatter.percent(value))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(value >= 0 ? .green : .red)
        } else {
            Text("—")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}
