//
//  RateLimiter.swift
//  LogChain
//

import Foundation

/// Simple sliding-window rate limiter to stay under CoinGecko's free-tier
/// call budget (~10-30 calls/min). `acquire()` suspends the caller if firing
/// now would exceed the configured budget.
actor RateLimiter {
    private let maxCallsPerWindow: Int
    private let window: TimeInterval
    private var callTimestamps: [Date] = []

    init(maxCallsPerWindow: Int = 25, window: TimeInterval = 60) {
        self.maxCallsPerWindow = maxCallsPerWindow
        self.window = window
    }

    func acquire() async {
        while true {
            let now = Date()
            callTimestamps.removeAll { now.timeIntervalSince($0) > window }

            if callTimestamps.count < maxCallsPerWindow {
                callTimestamps.append(now)
                return
            }

            let oldest = callTimestamps[0]
            let waitTime = window - now.timeIntervalSince(oldest)
            if waitTime > 0 {
                try? await Task.sleep(for: .seconds(waitTime))
            }
        }
    }
}
