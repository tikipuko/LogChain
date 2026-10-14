//
//  AddCoinViewModel.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation
import SwiftData
import Observation

@Observable
final class AddCoinViewModel {
    var searchText: String = "" {
        didSet { scheduleSearch() }
    }

    var selectedCategory: MarketCategory = .all {
        didSet {
            guard oldValue != selectedCategory else { return }
            browseResults = []
            Task { await reloadBrowseList() }
        }
    }
    var sort: MarketSort = .marketCap
    var reverseOrder = false
    var movers: MarketMovers = .all

    private(set) var browseResults: [CoinMarketDTO] = []
    private(set) var searchResults: [CoinSearchResultDTO] = []
    private(set) var isLoading = false
    private(set) var errorState: ErrorState?
    private(set) var duplicateMessage: String?

    private let api: CoinGeckoAPI
    private var searchTask: Task<Void, Never>?
    private var browseRequestID = 0

    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespaces).isEmpty }

    init(api: CoinGeckoAPI = CoinGeckoService()) {
        self.api = api
    }

    /// Browse results after applying the gainers/losers filter and the chosen sort.
    /// Sorting works on the loaded page only; the API returns market-cap order.
    var displayedBrowseResults: [CoinMarketDTO] {
        var results = browseResults
        switch movers {
        case .all: break
        case .gainers: results = results.filter { ($0.priceChangePercentage24h ?? 0) > 0 }
        case .losers: results = results.filter { ($0.priceChangePercentage24h ?? 0) < 0 }
        }

        switch sort {
        case .marketCap: break
        case .price: results.sort { $0.currentPrice > $1.currentPrice }
        case .change24h: results.sort { ($0.priceChangePercentage24h ?? -.infinity) > ($1.priceChangePercentage24h ?? -.infinity) }
        case .name: results.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }

        return reverseOrder ? results.reversed() : results
    }

    /// Initial load: does nothing if results are already on screen.
    func loadBrowseList() async {
        guard browseResults.isEmpty else { return }
        await reloadBrowseList()
    }

    /// Always refetches for the selected category (used by pull-to-refresh and chip changes).
    /// Only the most recent request may update state, so a slow earlier response can't overwrite it.
    func reloadBrowseList() async {
        browseRequestID += 1
        let requestID = browseRequestID
        let category = selectedCategory.apiID
        isLoading = true

        // Unstructured (inherits the main actor) so SwiftUI cancelling the refresh gesture doesn't abort the request.
        await Task {
            let outcome: Result<[CoinMarketDTO], Error>
            do {
                outcome = .success(try await api.topMarkets(page: 1, perPage: 50, category: category))
            } catch {
                outcome = .failure(error)
            }
            finishBrowseLoad(outcome, requestID: requestID)
        }.value
    }

    private func finishBrowseLoad(_ outcome: Result<[CoinMarketDTO], Error>, requestID: Int) {
        guard requestID == browseRequestID else { return }
        isLoading = false
        switch outcome {
        case .success(let results):
            browseResults = results
            errorState = nil
        case .failure(let error as APIError):
            errorState = ErrorState(apiError: error)
        case .failure:
            errorState = .generic
        }
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await self?.performSearch(query: query)
        }
    }

    private func performSearch(query: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let results = try await api.search(query: query)
            guard !Task.isCancelled else { return }
            searchResults = results
            errorState = nil
        } catch let error as APIError {
            errorState = ErrorState(apiError: error)
        } catch {
            errorState = .generic
        }
    }

    func clearDuplicateMessage() {
        duplicateMessage = nil
    }

    @discardableResult
    func add(coinID: String, symbol: String, name: String, imageURL: String, price: Double, change24h: Double?, modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<WatchedCoin>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []

        if existing.contains(where: { $0.coinID == coinID }) {
            duplicateMessage = "\(name) is already in your watchlist."
            return false
        }

        let coin = WatchedCoin(
            coinID: coinID,
            symbol: symbol,
            name: name,
            imageURL: imageURL,
            lastKnownPrice: price,
            lastKnownChange24h: change24h,
            sortOrder: existing.count
        )
        modelContext.insert(coin)
        try? modelContext.save()
        return true
    }

    /// For results that came from /search (no price yet), fetch a one-off price before adding.
    func addFromSearchResult(_ result: CoinSearchResultDTO, modelContext: ModelContext) async -> Bool {
        if let dto = try? await api.markets(ids: [result.id]).first {
            return add(coinID: dto.id, symbol: dto.symbol, name: dto.name, imageURL: dto.image, price: dto.currentPrice, change24h: dto.priceChangePercentage24h, modelContext: modelContext)
        }
        return add(coinID: result.id, symbol: result.symbol, name: result.name, imageURL: result.thumb, price: 0, change24h: nil, modelContext: modelContext)
    }
}
