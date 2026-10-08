//
//  ErrorStateView.swift
//  LogChain
//

import SwiftUI

enum ErrorState: Equatable {
    case offline
    case rateLimited
    case notFound
    case generic

    init(apiError: APIError) {
        switch apiError {
        case .offline:
            self = .offline
        case .rateLimited:
            self = .rateLimited
        case .notFound:
            self = .notFound
        case .decoding, .server, .unknown:
            self = .generic
        }
    }

    var icon: String {
        switch self {
        case .offline: return "wifi.slash"
        case .rateLimited: return "clock"
        case .notFound: return "magnifyingglass"
        case .generic: return "exclamationmark.triangle"
        }
    }

    var message: String {
        switch self {
        case .offline: return "No internet connection"
        case .rateLimited: return "Too many requests, try again shortly"
        case .notFound: return "Coin not found"
        case .generic: return "Something went wrong"
        }
    }
}

struct ErrorStateView: View {
    let state: ErrorState
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: state.icon)
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text(state.message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let retry {
                Button("Retry", action: retry)
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
