# LogChain

A native iOS watchlist app for tracking cryptocurrency prices, built with SwiftUI and SwiftData.

## Features

- **Watchlist** — add coins and track live prices, with price history charts per coin.
- **Search** — find coins by name or symbol to add to your watchlist.
- **Detail view** — per-coin price history chart with a timeframe picker (e.g. 24h / 7d / 30d).
- **Offline-friendly** — prices are persisted locally with SwiftData, so the watchlist still shows last-known values without a connection.
- **Smart refresh** — refreshes on launch and on returning to the foreground, throttled to avoid redundant calls.

## Architecture

- **SwiftUI + SwiftData** for the UI and local persistence (`WatchedCoin` model).
- **MVVM**: `@Observable` view models (`WatchlistViewModel`, `CoinDetailViewModel`, `AddCoinViewModel`) drive the views and own refresh/error state.
- **Networking** — a small `CoinGeckoAPI` protocol backed by `CoinGeckoService`, with:
  - `HTTPClient` for requests and decoding,
  - `RateLimiter`, a sliding-window limiter that keeps calls under CoinGecko's free-tier budget,
  - typed `APIError` handling surfaced to the UI via an error banner.
- **Data source** — [CoinGecko](https://www.coingecko.com/en/api) public API for market data, search, and price history.

## Project structure

```
LogChain/
├── Models/            # SwiftData model + CoinGecko DTOs
├── Networking/         # API protocol, HTTP client, rate limiter, errors
├── Persistence/        # SwiftData container setup
├── ViewModels/          # Observable view models
├── Views/
│   ├── Watchlist/       # Main list + empty state
│   ├── AddCoin/         # Search & add flow
│   ├── Detail/          # Coin detail + price chart
│   └── Shared/          # Loading/error/percent-change components
└── Formatting/          # Currency formatting helpers
```

## Requirements

- Xcode (latest)
- iOS device or simulator

## Getting started

```bash
open LogChain.xcodeproj
```

Build and run the `LogChain` scheme on a simulator or device.
