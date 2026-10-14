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
                chip(isSelected: selection.isEmpty, action: { selection = [] }) {
                    Text(MarketCategory.all.title)
                }
                ForEach(MarketCategory.allCases.filter { $0 != .all }) { category in
                    chip(isSelected: selection.contains(category), action: {
                        if selection.contains(category) {
                            selection.remove(category)
                        } else {
                            selection.insert(category)
                        }
                    }) {
                        Text(category.title)
                    }
                }

                // Last chip: only shown while something is selected, and puts the list back to "All".
                if !selection.isEmpty {
                    chip(isSelected: false, action: { selection = [] }) {
                        Image(systemName: "xmark")
                            .accessibilityLabel("Clear categories")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func chip<Label: View>(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder label: () -> Label) -> some View {
        Button(action: action) {
            label()
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
