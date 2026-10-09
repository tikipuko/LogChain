//
//  PriceHistoryChartView.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import SwiftUI
import Charts

struct PriceHistoryChartView: View {
    let points: [PricePoint]
    let timeframe: Timeframe

    var body: some View {
        Chart(points) { point in
            LineMark(
                x: .value("Time", point.date),
                y: .value("Price", point.price)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(.tint)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                AxisValueLabel(format: axisFormat)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 220)
    }

    private var axisFormat: Date.FormatStyle {
        switch timeframe {
        case .day24h:
            return .dateTime.hour()
        case .week7d, .month30d:
            return .dateTime.month(.abbreviated).day()
        }
    }
}
