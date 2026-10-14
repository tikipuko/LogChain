//
//  LogChainApp.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 08/10/2026.
//

import SwiftUI
import TipKit

@main
struct LogChainApp: App {
    private let dependencies = AppDependencies()

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--reset-tips") {
            try? Tips.resetDatastore()
        }
        #endif
        try? Tips.configure([
            .displayFrequency(.immediate)
        ])
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(dependencies: dependencies)
        }
    }
}
