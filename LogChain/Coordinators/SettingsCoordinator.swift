//
//  SettingsCoordinator.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import SwiftUI
import Observation

@Observable
final class SettingsCoordinator {
    let viewModel: SettingsViewModel

    init(factory: ScreenFactory) {
        self.viewModel = factory.makeSettingsViewModel()
    }
}

struct SettingsCoordinatorView: View {
    let coordinator: SettingsCoordinator

    var body: some View {
        NavigationStack {
            SettingsView(viewModel: coordinator.viewModel)
        }
    }
}
