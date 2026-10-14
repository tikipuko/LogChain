//
//  MarketsViewModel.swift
//  LogChain
//
//  Created by Correia, Jose Bastos on 03/10/2026.
//

import Foundation
import Observation

/// A coin picked in the Add Coin sheet, waiting to be added when the user taps Done.
/// Search results carry no price yet, so they are priced when added.
enum PendingCoin {
    case market(CoinMarketDTO)
    case search(CoinSearchResultDTO)

    var id: String {
        switch self {
        case .market(let dto): return dto.id
        case .search(let result): return result.id
        }
    }
}

@Observable
final class MarketsViewModel {
    var searchText: String = "" {
        didSet { scheduleSearch() }
    }

    /// Selected category chips; empty means "All". Several categories show their combined coins.
    var selectedCategories: Set<MarketCategory> = [] {
        didSet {
            guard oldValue != selectedCategories else { return }
            scheduleCategoryReload()
        }
    }
    var sort: MarketSort = .marketCap
    var reverseOrder = false
    var movers: MarketMovers = .all

    private(set) var browseResults: [CoinMarketDTO] = []
    private(set) var searchResults: [CoinSearchResultDTO] = []
    private(set) var isLoading = false
    private(set) var errorState: ErrorState?
    private(set) var pendingCoins: [PendingCoin] = []

    @ObservationIgnored private let markets: MarketsRepository
    @ObservationIgnored private let watchlist: WatchlistRepository
    private var searchTask: Task<Void, Never>?
    private var categoryTask: Task<Void, Never>?
    private var browseRequestID = 0

    var isSearching: Bool { !searchText.trimmingCharacters(in: .whitespaces).isEmpty }

    init(markets: MarketsRepository, watchlist: WatchlistRepository) {
        self.markets = markets
        self.watchlist = watchlist
    }

    /// Reads the observable watchlist, so views using it update when coins are added or removed.
    func isWatched(coinID: String) -> Bool {
        watchlist.contains(coinID: coinID)
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

    /// Waits briefly so a burst of chip taps results in a single reload.
    private func scheduleCategoryReload() {
        categoryTask?.cancel()
        // Drop any in-flight response for the old selection and show the loading state right away.
        browseRequestID += 1
        browseResults = []
        isLoading = true
        categoryTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await self?.reloadBrowseList()
        }
    }

    /// Always refetches for the selected category (used by pull-to-refresh and chip changes).
    /// Only the most recent request may update state, so a slow earlier response can't overwrite it.
    func reloadBrowseList() async {
        browseRequestID += 1
        let requestID = browseRequestID
        let categoryIDs = selectedCategories.compactMap(\.apiID).sorted()
        isLoading = true

        // Unstructured (inherits the main actor) so SwiftUI cancelling the refresh gesture doesn't abort the request.
        await Task {
            let outcome: Result<[CoinMarketDTO], Error>
            do {
                // The repository stops between requests once a newer reload has superseded this one.
                outcome = .success(try await markets.browse(categoryIDs: categoryIDs, shouldContinue: { requestID == browseRequestID }))
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
            let results = try await markets.search(query: query)
            guard !Task.isCancelled else { return }
            searchResults = results
            errorState = nil
        } catch let error as APIError {
            errorState = ErrorState(apiError: error)
        } catch {
            errorState = .generic
        }
    }

    /// Returns false if the coin was already in the watchlist.
    @discardableResult
    func add(coinID: String, symbol: String, name: String, imageURL: String, price: Double, change24h: Double?) -> Bool {
        watchlist.add(coinID: coinID, symbol: symbol, name: name, imageURL: imageURL, price: price, change24h: change24h) == .added
    }

    /// Adds a coin shown in the browse list.
    @discardableResult
    func add(_ dto: CoinMarketDTO) -> Bool {
        add(coinID: dto.id, symbol: dto.symbol, name: dto.name, imageURL: dto.image, price: dto.currentPrice, change24h: dto.priceChangePercentage24h)
    }

    func isPending(coinID: String) -> Bool {
        pendingCoins.contains { $0.id == coinID }
    }

    /// Selects or deselects a coin in the Add Coin sheet. Coins already watched can't be selected.
    func togglePending(_ coin: PendingCoin) {
        guard !isWatched(coinID: coin.id) else { return }
        if let index = pendingCoins.firstIndex(where: { $0.id == coin.id }) {
            pendingCoins.remove(at: index)
        } else {
            pendingCoins.append(coin)
        }
    }

    /// Adds every selected coin in the order it was picked, then clears the selection.
    func addPendingCoins() async {
        let coins = pendingCoins
        for coin in coins {
            switch coin {
            case .market(let dto): add(dto)
            case .search(let result): _ = await addFromSearchResult(result)
            }
        }
        pendingCoins = []
    }

    /// For results that came from /search (no price yet), fetch a one-off price before adding.
    func addFromSearchResult(_ result: CoinSearchResultDTO) async -> Bool {
        if let dto = try? await markets.quotes(ids: [result.id]).first {
            return add(dto)
        }
        return add(coinID: result.id, symbol: result.symbol, name: result.name, imageURL: result.thumb, price: 0, change24h: nil)
    }
}
