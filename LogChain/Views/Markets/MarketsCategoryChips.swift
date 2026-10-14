//
//  MarketsCategoryChips.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftUI

/// Multi-select category chips. An empty selection means "All".
struct MarketsCategoryChips: View {
    @Binding var selection: Set<MarketCategory>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: MarketCategory.all.title, isSelected: selection.isEmpty) {
                    selection = []
                }
                ForEach(MarketCategory.allCases.filter { $0 != .all }) { category in
                    chip(title: category.title, isSelected: selection.contains(category)) {
                        if selection.contains(category) {
                            selection.remove(category)
                        } else {
                            selection.insert(category)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
