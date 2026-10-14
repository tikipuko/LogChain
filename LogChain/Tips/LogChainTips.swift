//
//  LogChainTips.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftUI
import TipKit

/// Markets: explains that coins are added with a swipe.
struct SwipeToAddTip: Tip {
    var title: Text { Text("Add coins with a swipe") }
    var message: Text? { Text("Swipe left on any coin to add it to your watchlist.") }
    var image: Image? { Image(systemName: "hand.draw") }
}

/// Coin detail: points out the timeframe picker above the chart.
struct TimeframeTip: Tip {
    var title: Text { Text("Change the timeframe") }
    var message: Text? { Text("Switch between 24h, 7d and 30d to see how the price moved.") }
    var image: Image? { Image(systemName: "chart.xyaxis.line") }
}

/// Watchlist: explains how to remove a coin.
struct SwipeToRemoveTip: Tip {
    var title: Text { Text("Remove with a swipe") }
    var message: Text? { Text("Swipe left on a coin to remove it from your watchlist.") }
    var image: Image? { Image(systemName: "trash") }
}
