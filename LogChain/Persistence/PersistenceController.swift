//
//  PersistenceController.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
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
