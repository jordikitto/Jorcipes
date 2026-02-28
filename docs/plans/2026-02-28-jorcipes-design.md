# Jorcipes App Design

## Overview

A native iOS recipe browsing and searching app built for the ReciMe iOS Coding Challenge. Users can browse a collection of recipes in an adaptive grid and search/filter them using dietary attributes, servings, ingredients, and free-text search.

## Data Model

### Recipe

```swift
struct Recipe: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let servings: Int
    let ingredients: [Ingredient]
    let instructions: [String]  // Raw markdown strings

    /// Computed: vegetarian if ALL ingredients are vegetarian, same for vegan
    var dietaryAttributes: Set<DietaryAttribute> { ... }
}
```

### Ingredient

```swift
struct Ingredient: Identifiable, Codable, Hashable, Sendable {
    let id: String              // Stable server-style ID, e.g. "chicken-breast"
    let name: String            // Display name: "Chicken Breast"
    let quantity: String        // e.g. "2 cups"
    let dietaryAttributes: Set<DietaryAttribute>
}
```

### DietaryAttribute

```swift
enum DietaryAttribute: String, Codable, CaseIterable, Sendable {
    case vegetarian
    case vegan
}
```

### Key decisions

- `instructions` stored as raw markdown `[String]` in the model — converted to `AttributedString` at the presentation layer. Keeps the model `Codable` and `Sendable`.
- Dietary attributes are computed: a recipe has an attribute only if ALL its ingredients have that attribute.
- `Ingredient.id` is `String` (not UUID) to mirror realistic server IDs and serve as a stable matching key.
- `Ingredient.quantity` is a plain `String` — avoids over-engineering measurement parsing.

## Package Structure

```
Jorcipes/
├── Packages/
│   ├── JorcipesCore/              # Recipe, Ingredient, DietaryAttribute, Loadable
│   ├── JorcipesDesignSystem/      # Colors, spacing, corner radii
│   ├── JorcipesNetworking/        # APIClient protocol, MockAPIClient, JSON loading
│   ├── JorcipesCards/             # Shared RecipeCardView component
│   ├── JorcipesRecipeList/        # Browse tab: grid, detail view, VM
│   └── JorcipesSearch/            # Search tab: search VM, filters, chip input
├── Jorcipes/                      # App target: AppContainer, JorcipesApp, ContentView
├── JorcipesTests/                 # Unit tests
└── Resources/                     # Mock JSON files
```

### Dependency graph

```
JorcipesApp
  ├── JorcipesRecipeList  → JorcipesCore, JorcipesDesignSystem, JorcipesCards, JorcipesNetworking
  ├── JorcipesSearch      → JorcipesCore, JorcipesDesignSystem, JorcipesCards, JorcipesNetworking
  ├── JorcipesCards       → JorcipesCore, JorcipesDesignSystem
  ├── JorcipesNetworking  → JorcipesCore
  ├── JorcipesDesignSystem → (none)
  └── JorcipesCore         → (none)
```

### Design System contents

- **Spacing**: `CGFloat` extension — `.space50` (2pt), `.space100` (4pt), `.space150` (6pt), `.space200` (8pt), `.space300` (12pt), `.space400` (16pt), through `.space1000`
- **Colors**: ReciMe-branded warm orange/amber palette with semantic colors (primary, background, surface, onSurface, error)
- **Corner radii**: Predefined set (`.small`, `.medium`, `.large`) as `CGFloat` extension

## Networking Layer

### APIClient protocol

```swift
protocol APIClient: Sendable {
    func fetchRecipes() async throws -> [Recipe]
    func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe]
}
```

### RecipeSearchQuery

```swift
struct RecipeSearchQuery: Equatable, Sendable {
    var text: String = ""
    var dietaryAttributes: Set<DietaryAttribute> = []
    var servings: Int?
    var includedIngredients: [String] = []
    var excludedIngredients: [String] = []
}
```

### MockAPIClient

- Two endpoints: `fetchRecipes` (browse) and `searchRecipes` (filtered search)
- Random delay via `Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))`
- Search filtering happens inside the mock client — simulates server-side filtering
- Ingredient matching uses `localizedStandardContains`
- Dietary filtering checks recipe's computed attributes are a superset of query's set

### Mock JSON files

- `recipes_empty.json` — empty array
- `recipes_5.json` — 5 recipes
- `recipes_50.json` — 50 recipes
- `recipes_corrupted.json` — malformed entry to trigger decoding error

## Views & Navigation

### Tab structure

```swift
TabView {
    Tab("Recipes", systemImage: "book") {
        RecipeListView(viewModel: container.makeRecipeListViewModel())
    }
    Tab(role: .search) {
        SearchView(viewModel: container.makeSearchViewModel())
    }
}
```

### Browse tab — RecipeListView

- States driven by `Loadable<[Recipe]>`: idle, loading (progress indicator), loaded (grid), failed (ContentUnavailableView with retry)
- Empty state: `ContentUnavailableView` when loaded but array is empty
- Adaptive grid: `LazyVGrid` with `adaptive(minimum:)` — adjusts for iPhone/iPad
- Recipe cards: shared `RecipeCardView` from `JorcipesCards` package
- Navigation: `NavigationStack` with ViewModel-owned path
- Detail transition: `.navigationTransition(.zoom)` with `matchedTransitionSource`
- Pull to refresh: `.refreshable { await viewModel.refresh() }`

### Recipe detail view

Scrollable view showing:
- Title (large, bold)
- Description
- Servings count
- Dietary attribute badges
- Ingredients list (name + quantity)
- Cooking instructions as numbered `AttributedString` steps (parsed from markdown)

### Search tab — SearchView

- `Tab(role: .search)` for native system search experience
- Search bar: free-text search on title, description, instruction content
- Dietary attribute chips: rendered from `DietaryAttribute.allCases`, tappable to toggle active state (highlighted when active). Auto-extensible when new cases are added.
- Servings picker (stepper or wheel)
- Ingredient chips: text field where typed ingredients become chips, tappable to toggle include (green) ↔ exclude (red)
- Results: same adaptive grid with shared `RecipeCardView`
- Empty/error/no results: `ContentUnavailableView`

### Navigation flow

```
TabView
├── Tab: Recipes
│   └── NavigationStack
│       ├── RecipeListView (grid)
│       └── RecipeDetailView (pushed, zoom transition)
└── Tab: Search (role: .search)
    └── NavigationStack
        ├── SearchView (filters + results grid)
        └── RecipeDetailView (pushed, zoom transition)
```

## State Management & DI

### Loadable

```swift
enum Loadable<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}
```

### RecipeListViewModel

```swift
@MainActor @Observable
final class RecipeListViewModel {
    private(set) var state: Loadable<[Recipe]> = .idle
    var navigationPath: [RecipeDestination] = []
    private var loadTask: Task<Void, Never>?

    func onAppear()           // fetch if idle (uses loadTask with cancellation)
    func load()               // cancel stale + re-fetch (loadTask), drives Loadable states
    func refresh() async      // awaitable by .refreshable, no task management needed
    func didTapRecipe(...)    // push to navigation path
}
```

- `load()` — fire-and-forget with `Task` cancellation, shows full-screen loading UI
- `refresh()` — `async`, awaited by SwiftUI's `.refreshable`, keeps existing data visible

### SearchViewModel

```swift
@MainActor @Observable
final class SearchViewModel {
    private(set) var results: Loadable<[Recipe]> = .idle
    var query: RecipeSearchQuery = .init()
    var navigationPath: [RecipeDestination] = []

    func search()                        // debounced search call (~300ms via Task.sleep + cancellation)
    func toggleDietaryAttribute(...)     // add/remove from query set
    func addIngredientChip(...)          // add to included
    func toggleIngredientChip(...)       // flip include ↔ exclude
    func removeIngredientChip(...)       // remove chip
    func didTapRecipe(...)               // push to navigation path
}
```

### AppContainer

```swift
@MainActor
final class AppContainer {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func makeRecipeListViewModel() -> RecipeListViewModel {
        RecipeListViewModel(apiClient: apiClient)
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(apiClient: apiClient)
    }
}
```

Created in `JorcipesApp` with `MockAPIClient()` — swap to a live client by changing one line.

## Testing Strategy

### Unit tests

- **ViewModel state transitions**: idle → loading → loaded / failed
- **Cancellation**: stale responses don't overwrite newer state
- **Search filtering**: verify `MockAPIClient` correctly filters by each query field
- **Dietary attribute computation**: all-vegetarian ingredients → vegetarian, mixed → not
- **Query manipulation**: toggle dietary chip, add/remove ingredient chips

### Approach

- Inject a `ControlledAPIClient` stub (actor with continuations) for deterministic async testing
- `@MainActor` test classes with `await Task.yield()` for state assertion
- No sleep-based tests

### Previews

- Every view has a working preview using mock data
- Preview helpers in each package providing sample `Recipe` / `Ingredient` data

## Not in scope (YAGNI)

- No persistence / favorites / bookmarking
- No image loading (recipes use placeholder/system images)
- No deep linking
- No analytics
- No localization beyond `localizedStandardContains` for search

## Deliverables

- Complete Xcode project
- README.md with setup instructions, architecture overview, design decisions, assumptions, limitations
