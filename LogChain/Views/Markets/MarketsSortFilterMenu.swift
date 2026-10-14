//
//  MarketsSortFilterMenu.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftUI

/// Sort and gainers/losers options. Callers supply the label so the same menu
/// can back both the toolbar button and the floating button.
struct MarketsSortFilterMenu<MenuLabel: View>: View {
    @Binding var sort: MarketSort
    @Binding var reverseOrder: Bool
    @Binding var movers: MarketMovers
    @ViewBuilder let label: () -> MenuLabel

    var body: some View {
        Menu {
            Picker("Sort by", selection: $sort) {
                ForEach(MarketSort.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            Toggle("Reverse order", isOn: $reverseOrder)

            Picker("Show", selection: $movers) {
                ForEach(MarketMovers.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
        } label: {
            label()
        }
    }
}
