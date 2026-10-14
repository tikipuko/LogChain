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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip(isSelected: selection.isEmpty, action: { clear(scrollingWith: proxy) }) {
                        Text(MarketCategory.all.title)
                    }
                    .id(MarketCategory.all)

                    ForEach(MarketCategory.allCases.filter { $0 != .all }) { category in
                        chip(isSelected: selection.contains(category), action: { toggle(category) }) {
                            Text(category.title)
                        }
                    }

                    // Last chip: only shown while something is selected, and puts the list back to "All".
                    if !selection.isEmpty {
                        chip(isSelected: false, foreground: .red, action: { clear(scrollingWith: proxy) }) {
                            Image(systemName: "xmark")
                                .accessibilityLabel("Clear categories")
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }

    private func toggle(_ category: MarketCategory) {
        withAnimation(.snappy) {
            if selection.contains(category) {
                selection.remove(category)
            } else {
                selection.insert(category)
            }
        }
    }

    /// Resets to "All": the clear chip shrinks away while the row scrolls back to the start.
    private func clear(scrollingWith proxy: ScrollViewProxy) {
        withAnimation(.snappy) {
            selection = []
            proxy.scrollTo(MarketCategory.all, anchor: .leading)
        }
    }

    private func chip<Label: View>(isSelected: Bool, foreground: Color? = nil, action: @escaping () -> Void, @ViewBuilder label: () -> Label) -> some View {
        Button(action: action) {
            label()
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(foreground ?? (isSelected ? Color.white : Color.primary))
                .background(isSelected ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
