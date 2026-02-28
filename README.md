# Jorcipes

A native iOS recipe browsing and searching app built for the ReciMe iOS Coding Challenge.

## Setup Instructions

1. Clone the repository
2. Open `Jorcipes.xcodeproj` in Xcode 26+
3. Select an iOS 26 simulator as the run destination
4. Build and run (Cmd+R)

No third-party dependencies — all packages are local.

## Architecture Overview

MVVM with container-based dependency injection, structured across 6 local Swift packages:

```
Jorcipes (App)
├── JorcipesRecipeList  ─┬─ JorcipesCards ── JorcipesCore
│                        │                   JorcipesDesignSystem
│                        └─ JorcipesNetworking ── JorcipesCore
│
├── JorcipesSearch ──────┬─ JorcipesCards
│                        └─ JorcipesNetworking
│
└── AppContainer (DI wiring)
```

- **JorcipesCore** — Shared models (`Recipe`, `Ingredient`, `DietaryAttribute`, `Loadable<T>`)
- **JorcipesDesignSystem** — Spacing, corner radii, and color assets
- **JorcipesNetworking** — `APIClient` protocol and `MockAPIClient` with bundled JSON
- **JorcipesCards** — `RecipeCardView` and `RecipeDetailView` shared across features
- **JorcipesRecipeList** — Browse tab with adaptive grid, pull-to-refresh, hero zoom transitions
- **JorcipesSearch** — Search tab with text search, dietary chips, ingredient include/exclude, servings filter

## Key Design Decisions

- **Dietary attributes computed from ingredients** — A recipe is vegetarian/vegan only if all its ingredients are. No stored flags to get out of sync.
- **Mock API simulates real network behavior** — Random delay, JSON decoding, and filtering replicate what a real server would do.
- **`Tab(role: .search)`** — Uses the system search experience for a native feel.
- **Hero zoom transitions** — `navigationTransition(.zoom)` with `matchedTransitionSource` animates from grid card to detail view.
- **`ContentUnavailableView`** — Used consistently for empty, error, and no-results states.
- **Container-based DI** — `AppContainer` centralizes dependency wiring, making it easy to swap implementations (e.g., real API client).
- **`Set<DietaryAttribute>` for search filtering** — Extensible if more dietary attributes are added later.
- **`WrappingHStack` custom Layout** — Dietary and ingredient chips wrap naturally across lines.

## Assumptions and Tradeoffs

- No real API — mock data loaded from bundled JSON (50 recipes)
- No image loading — SF Symbol placeholder icons used
- Ingredient quantity stored as plain string (no measurement parsing)
- No persistence or favorites

## Known Limitations

- No offline support
- No localization (strings are localization-ready but no `.lproj` translations provided)
- No real image assets (placeholder icons only)

## Testing

20 unit tests covering both ViewModels using a `ControlledAPIClient` actor with continuation-based async control:

```bash
xcodebuild test -scheme Jorcipes \
  -destination 'platform=iOS Simulator,name=iPhone 17 - Jordi Manager' \
  -only-testing:JorcipesTests
```

Additionally, 10 tests in `JorcipesCoreTests` cover model encoding/decoding and dietary attribute computation.
