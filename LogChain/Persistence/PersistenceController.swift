//
//  PersistenceController.swift
//  LogChain
//

import SwiftData

enum PersistenceController {
    static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: WatchedCoin.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
