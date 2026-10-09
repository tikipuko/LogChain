//
//  TimeframePicker.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
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
