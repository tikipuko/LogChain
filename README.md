# LogChain

A native iOS watchlist app for tracking cryptocurrency prices, built with SwiftUI and SwiftData.

## Features

- **Tab bar** — Watchlist, Markets and Settings tabs.
- **Watchlist** — add coins and track live prices, with price history charts per coin.
- **Markets** — browse top coins by category (multi-select chips), sort and filter gainers/losers, search by name or symbol, open any coin's detail page and swipe to add it to your watchlist.
- **Settings** — clear the watchlist, app version and CoinGecko attribution.
- **Detail view** — per-coin price history chart with a timeframe picker (e.g. 24h / 7d / 30d).
- **Offline-friendly** — prices are persisted locally with SwiftData, so the watchlist still shows last-known values without a connection.
- **Smart refresh** — refreshes on launch and on returning to the foreground, throttled to avoid redundant calls.

## Architecture

- **SwiftUI + SwiftData** for the UI and local persistence (`WatchedCoin` model).
- **MVVM-C** (Model–View–ViewModel–Coordinator):
  - **Views** are passive: they render a view model and name the `Route` to push; they contain no `NavigationStack`, `@Query` or `ModelContext`.
  - **View models** (`WatchlistViewModel`, `MarketsViewModel`, `CoinDetailViewModel`, `SettingsViewModel`) are `@Observable`, own screen state and depend only on repositories.
  - **Coordinators** own navigation: `AppCoordinator` holds the selected tab and one child coordinator per tab (`WatchlistCoordinator`, `MarketsCoordinator`, `SettingsCoordinator`), each with a typed `[Route]` path. `ScreenFactory` builds view models and resolves routes into screens.
  - **Repositories** sit between view models and data: `WatchlistRepository` is the single owner of the persisted watchlist (SwiftData), and `MarketsRepository` wraps the CoinGecko API (including merging several categories).
  - **`AppDependencies`** is the composition root that builds the container and repositories once; `AppDependencies.preview` gives previews in-memory storage.
- **Networking** — a small `CoinGeckoAPI` protocol backed by `CoinGeckoService`, with:
  - `HTTPClient` for requests and decoding,
  - `RateLimiter`, a sliding-window limiter that keeps calls under CoinGecko's free-tier budget,
  - typed `APIError` handling surfaced to the UI via an error banner.
- **Data source** — [CoinGecko](https://www.coingecko.com/en/api) public API for market data, search, and price history.

## Project structure

```
LogChain/
├── App/               # AppDependencies (composition root)
├── Coordinators/       # AppCoordinator, per-tab coordinators, Route, ScreenFactory
├── Models/            # SwiftData model, CoinGecko DTOs, Markets filter/sort types
├── Networking/         # API protocol, HTTP client, rate limiter, errors
├── Persistence/        # SwiftData container setup
├── Repositories/       # WatchlistRepository, MarketsRepository
├── Tips/               # TipKit tips
├── ViewModels/          # Observable view models
├── Views/
│   ├── Watchlist/       # Main list + empty state
│   ├── Markets/         # Browse & search top coins
│   ├── Settings/        # Watchlist reset + about
│   ├── AddCoin/         # Search & add flow
│   ├── Detail/          # Coin detail + price chart
│   └── Shared/          # Loading/error/percent-change components
└── Formatting/          # Currency formatting helpers
Config/                  # Per-environment .xcconfig files + Info.plist keys
```

## Requirements

- Xcode (latest)
- iOS device or simulator

## Getting started

```bash
open LogChain.xcodeproj
```

Pick a scheme for the environment you want and run it on a simulator or device.

## Environments

Each environment has its own build configuration, scheme and `.xcconfig` file in `Config/`:

| Scheme          | Configuration | Bundle ID                   | Home screen name | Optimised |
|-----------------|---------------|-----------------------------|------------------|-----------|
| `LogChain Dev`  | Dev           | `josebcorreia.LogChain.dev` | LogChain Dev     | No        |
| `LogChain SIT`  | SIT           | `josebcorreia.LogChain.sit` | LogChain SIT     | Yes       |
| `LogChain UAT`  | UAT           | `josebcorreia.LogChain.uat` | LogChain UAT     | Yes       |
| `LogChain Prod` | Prod          | `josebcorreia.LogChain`     | LogChain         | Yes       |

- Different bundle IDs let all four builds sit side by side on one device.
- Settings shows the current environment in every build except Prod.
- In code, read `AppEnvironment.current`, or use the `DEV` / `SIT` / `UAT` / `PROD` compilation conditions (`#if DEV`).
- Per-environment values (such as `API_BASE_URL`) live in `Config/<Env>.xcconfig`; shared defaults are in `Config/Base.xcconfig`. To expose a new value to Swift, add it to the `.xcconfig` files and to `Config/Info.plist`.
