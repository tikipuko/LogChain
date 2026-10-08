//
//  TimeframePicker.swift
//  LogChain
//

import SwiftUI

struct TimeframePicker: View {
    @Binding var selection: Timeframe

    var body: some View {
        Picker("Timeframe", selection: $selection) {
            ForEach(Timeframe.allCases) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
    }
}
