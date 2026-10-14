//
//  CoinDetailViewModel.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation
import Observation

enum Timeframe: String, CaseIterable, Identifiable {
    case day24h = "24h"
    case week7d = "7d"
    case month30d = "30d"

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .day24h: return 1
        case .week7d: return 7
        case .month30d: return 30
        }
    }
}

@Observable
final class CoinDetailViewModel {
    var selectedTimeframe: Timeframe = .day24h {
        didSet {
            guard oldValue != selectedTimeframe else { return }
            Task { await loadChart() }
        }
    }

    private(set) var chartPoints: [PricePoint] = []
    private(set) var isLoading = false
    private(set) var errorState: ErrorState?

    @ObservationIgnored private let markets: MarketsRepository
    private let coinID: String

    init(coinID: String, markets: MarketsRepository) {
        self.coinID = coinID
        self.markets = markets
    }

    func loadChart() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let dto = try await markets.chart(id: coinID, days: selectedTimeframe.days)
            chartPoints = dto.toPricePoints()
            errorState = nil
        } catch let error as APIError {
            errorState = ErrorState(apiError: error)
        } catch {
            errorState = .generic
        }
    }
}
