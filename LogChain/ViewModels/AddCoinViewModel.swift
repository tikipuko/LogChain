//
//  AddCoinViewModel.swift
//  LogChain
//

import Foundation
import SwiftData
import Observation

@Observable
final class AddCoinViewModel {
    var searchText: String = "" {
        didSet { scheduleSearch() }
    }

    private(set) var browseResults: [CoinMarketDTO] = []
    private(set) var searchResults: [CoinSearchResultDTO] = []
    private(set) var isLoading = false
    private(set) var errorState: ErrorState?
    private(set) var duplicateMessage: String?

    private let api: CoinGeckoAPI
    private var searchTask: Task<Void, Never>?

    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespaces).isEmpty }

    init(api: CoinGeckoAPI = CoinGeckoService()) {
        self.api = api
    }

    func loadBrowseList() async {
        guard browseResults.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            browseResults = try await api.topMarkets(page: 1, perPage: 50)
            errorState = nil
        } catch let error as APIError {
            errorState = ErrorState(apiError: error)
        } catch {
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
