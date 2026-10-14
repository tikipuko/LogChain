//
//  AppEnvironment.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 14/10/2026.
//

import Foundation

/// The environment the app was built for, selected by the build configuration
/// (Dev, SIT, UAT, Prod). Values come from `Config/<Env>.xcconfig` via Info.plist.
enum AppEnvironment: String {
    case dev = "Dev"
    case sit = "SIT"
    case uat = "UAT"
    case prod = "Prod"

    static let current: AppEnvironment = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "APP_ENV") as? String,
              let environment = AppEnvironment(rawValue: value) else {
            fatalError("APP_ENV missing or invalid in Info.plist; check Config/*.xcconfig")
        }
        return environment
    }()

    var apiBaseURL: URL {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: value) else {
            fatalError("API_BASE_URL missing or invalid in Info.plist; check Config/*.xcconfig")
        }
        return url
    }

    var isProduction: Bool { self == .prod }
}
