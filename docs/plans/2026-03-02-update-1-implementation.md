# Update 1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement Update 1 — general cleanup, dev tab, list view dietary badges, detail view card redesign, and search filter overhaul.

**Architecture:** Extends the existing MVVM + package architecture. New `FilterOptions` model in JorcipesCore, new `fetchFilterOptions()` endpoint on APIClient, extended SearchViewModel with filter UI state, and new views in JorcipesCards and JorcipesSearch. Dev tab lives in the main app target.

**Tech Stack:** Swift 6.2, SwiftUI (iOS 26+), local Swift packages, @Observable view models, MockAPIClient with JSON data.

---

## Task 1: Remove CLAUDE.md Comments

**Files:**
- Modify: `Packages/JorcipesRecipeList/Sources/JorcipesRecipeList/RecipeListView.swift:68`
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/IngredientChipInputView.swift:43`
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchView.swift:51`

**Step 1: Delete the three comments that reference CLAUDE.md entirely**

In `RecipeListView.swift:68`, delete this entire comment:
```swift
/// Extracted View struct for the recipe grid (per CLAUDE.md: no computed view properties).
```

In `IngredientChipInputView.swift:43`, delete this entire comment:
```swift
/// Separate View struct for individual ingredient chip (per CLAUDE.md: no computed view property returning some View).
```

In `SearchView.swift:51`, delete this entire comment:
```swift
/// Extracted View struct for search results (per CLAUDE.md: no computed view properties).
```

**Step 2: Build to verify no issues**

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add -A && git commit -m "Remove CLAUDE.md references from code comments"
```

---

## Task 2: Rename ContentView to RootTabView

**Files:**
- Rename: `Jorcipes/ContentView.swift` → `Jorcipes/RootTabView.swift`
- Modify: `Jorcipes/JorcipesApp.swift:10`

**Step 1: Rename the file and the struct**

Rename `Jorcipes/ContentView.swift` to `Jorcipes/RootTabView.swift`.

In the renamed file, change `struct ContentView: View` to `struct RootTabView: View`. Also update the preview:
```swift
#Preview {
    RootTabView(container: AppContainer(apiClient: MockAPIClient(simulateDelay: false)))
}
```

**Step 2: Update JorcipesApp.swift reference**

In `JorcipesApp.swift:10`, change:
```swift
ContentView(container: container)
```
to:
```swift
RootTabView(container: container)
```

**Step 3: Build to verify**

The project uses `PBXFileSystemSynchronizedRootGroup`, so Xcode auto-syncs file references from disk. No manual `project.pbxproj` edits are needed — just rename the file and build.

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add -A && git commit -m "Rename ContentView to RootTabView"
```

---

## Task 3: Add Background Colors to Tabs

**Files:**
- Modify: `Jorcipes/RootTabView.swift` (the renamed file from Task 2)

**Step 1: Add .background(.recipeBackground) to each tab's root view**

The `RootTabView` body should become:
```swift
var body: some View {
    TabView {
        Tab("Recipes", systemImage: "book") {
            RecipeListView(viewModel: container.makeRecipeListViewModel())
                .background(.recipeBackground)
        }

        Tab(role: .search) {
            SearchView(viewModel: container.makeSearchViewModel())
                .background(.recipeBackground)
        }
    }
}
```

Note: `import JorcipesDesignSystem` may need to be added to the file's imports.

**Step 2: Build to verify**

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add -A && git commit -m "Apply recipe background color to tab views"
```

---

## Task 4: MockAPIClient JSON Filename from UserDefaults + Dev Tab

**Files:**
- Modify: `Jorcipes/JorcipesApp.swift`
- Create: `Jorcipes/DevSettingsView.swift`
- Modify: `Jorcipes/RootTabView.swift`

**Step 1: Update JorcipesApp to read mock data source from UserDefaults**

In `JorcipesApp.swift`, update to read the stored JSON filename:

```swift
import SwiftUI
import JorcipesNetworking

@main
struct JorcipesApp: App {
    private let container: AppContainer

    init() {
        let jsonFileName = UserDefaults.standard.string(forKey: "mockDataSource") ?? "recipes_5"
        container = AppContainer(apiClient: MockAPIClient(jsonFileName: jsonFileName))
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(container: container)
        }
    }
}
```

**Step 2: Create DevSettingsView**

Create `Jorcipes/DevSettingsView.swift`:

```swift
import SwiftUI

struct DevSettingsView: View {
    @AppStorage("mockDataSource") private var mockDataSource = "recipes_5"
    @State private var initialValue = ""

    private let mockDataOptions = ["recipes_5", "recipes_50", "recipes_empty", "recipes_corrupted"]

    private var needsRestart: Bool {
        mockDataSource != initialValue
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Mock Data Source") {
                    Picker("JSON File", selection: $mockDataSource) {
                        ForEach(mockDataOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Dev Settings")
            .onAppear {
                initialValue = mockDataSource
            }
            .safeAreaInset(edge: .bottom) {
                if needsRestart {
                    Text("Restart the app for this to take effect.")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                }
            }
        }
    }
}

#Preview {
    DevSettingsView()
}
```

**Step 3: Add Dev tab to RootTabView**

In `RootTabView.swift`, add the Dev tab between Recipes and Search. Import `JorcipesDesignSystem` if not already imported:

```swift
var body: some View {
    TabView {
        Tab("Recipes", systemImage: "book") {
            RecipeListView(viewModel: container.makeRecipeListViewModel())
                .background(.recipeBackground)
        }

        Tab("Dev", systemImage: "hammer") {
            DevSettingsView()
                .background(.recipeBackground)
        }

        Tab(role: .search) {
            SearchView(viewModel: container.makeSearchViewModel())
                .background(.recipeBackground)
        }
    }
}
```

**Step 4: Build to verify**

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add -A && git commit -m "Add dev settings tab with mock data source picker"
```

---

## Task 5: Create DietaryBadgesView

**Files:**
- Create: `Packages/JorcipesCards/Sources/JorcipesCards/DietaryBadgesView.swift`

**Step 1: Create DietaryBadgesView**

Create `Packages/JorcipesCards/Sources/JorcipesCards/DietaryBadgesView.swift`:

```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct DietaryBadgesView: View {
    let sortedAttributes: [DietaryAttribute]

    public init(attributes: [DietaryAttribute]) {
        self.sortedAttributes = attributes.sorted(by: { $0.rawValue < $1.rawValue })
    }

    public var body: some View {
        if !sortedAttributes.isEmpty {
            ViewThatFits {
                HStack(spacing: .space200) {
                    ForEach(sortedAttributes, id: \.self) { attribute in
                        DietaryBadgeView(attribute: attribute)
                    }
                }

                VStack(alignment: .leading, spacing: .space100) {
                    ForEach(sortedAttributes, id: \.self) { attribute in
                        DietaryBadgeView(attribute: attribute)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        DietaryBadgesView(attributes: [.vegan, .vegetarian])
        DietaryBadgesView(attributes: [.vegetarian])
        DietaryBadgesView(attributes: [])
    }
}
```

**Step 2: Build to verify**

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add -A && git commit -m "Add DietaryBadgesView with ViewThatFits layout"
```

---

## Task 6: Update RecipeCardView to Use DietaryBadgesView

**Files:**
- Modify: `Packages/JorcipesCards/Sources/JorcipesCards/RecipeCardView.swift`

**Step 1: Move dietary badges above title and use DietaryBadgesView**

Replace the current card body with dietary badges moved above the title. The current layout is: image → title → description → spacer → servings+badges row. The new layout: image → badges → title → description → spacer → servings.

```swift
public var body: some View {
    VStack(alignment: .leading, spacing: .space200) {
        // Placeholder image area
        RoundedRectangle(cornerRadius: .cornerRadiusMedium)
            .fill(Color.recipeSecondary.opacity(0.2))
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.largeTitle)
                    .foregroundStyle(Color.recipeSecondary)
            }

        VStack(alignment: .leading, spacing: .space100) {
            DietaryBadgesView(attributes: Array(recipe.dietaryAttributes))

            Text(recipe.title)
                .font(.headline)
                .lineLimit(2)

            Text(recipe.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()

            Label("\(recipe.servings)", systemImage: "person.2")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, .space200)
        .padding(.bottom, .space300)
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: .cornerRadiusLarge))
    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
}
```

**Step 2: Build to verify**

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add -A && git commit -m "Move dietary badges above title in recipe card"
```

---

## Task 7: Redesign RecipeDetailView

**Files:**
- Modify: `Packages/JorcipesCards/Sources/JorcipesCards/RecipeDetailView.swift`

**Step 1: Rewrite RecipeDetailView with card-style layout**

Replace the entire content of `RecipeDetailView.swift` with the new card-based design. The view should have:

1. Placeholder image (not in card)
2. DietaryBadgesView (not in card)
3. Title as large Text (not in card) — also drives `.navigationTitle` for toolbar appearance
4. Description + Servings in a card
5. "Ingredients" header (not in card)
6. All ingredients in one card
7. "Instructions" header (not in card)
8. Each step in its own card, with accent border on the highlighted step

```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var highlightedStep = 0

    public init(recipe: Recipe) {
        self.recipe = recipe
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .space400) {
                DetailImageHeader()

                DietaryBadgesView(attributes: Array(recipe.dietaryAttributes))

                Text(recipe.title)
                    .font(.largeTitle)
                    .bold()

                DetailInfoCard(recipe: recipe)

                Text("Ingredients")
                    .font(.title2)
                    .bold()

                DetailIngredientsCard(ingredients: recipe.ingredients)

                Text("Instructions")
                    .font(.title2)
                    .bold()

                ForEach(recipe.instructions.enumerated(), id: \.offset) { index, instruction in
                    DetailInstructionCard(
                        index: index,
                        instruction: instruction,
                        isHighlighted: index == highlightedStep
                    ) {
                        highlightedStep = index
                    }
                }
            }
            .padding(.space400)
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sub-views

struct DetailImageHeader: View {
    var body: some View {
        RoundedRectangle(cornerRadius: .cornerRadiusMedium)
            .fill(Color.recipeSecondary.opacity(0.2))
            .aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.largeTitle)
                    .foregroundStyle(Color.recipeSecondary)
            }
    }
}

struct DetailInfoCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            Text(recipe.description)
                .font(.body)
                .foregroundStyle(.secondary)

            Label("\(recipe.servings) servings", systemImage: "person.2")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.space400)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: .cornerRadiusMedium))
    }
}

struct DetailIngredientsCard: View {
    let ingredients: [Ingredient]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ingredients.enumerated(), id: \.element.id) { index, ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.quantity)
                        .foregroundStyle(.secondary)
                }
                .padding(.space300)

                if index < ingredients.count - 1 {
                    Divider()
                        .padding(.horizontal, .space300)
                }
            }
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: .cornerRadiusMedium))
    }
}

struct DetailInstructionCard: View {
    let index: Int
    let instruction: String
    let isHighlighted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: .space300) {
                Text("\(index + 1)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.recipePrimary)
                    .frame(width: 30)

                if let attributed = try? AttributedString(markdown: instruction) {
                    Text(attributed)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(instruction)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.space400)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: .cornerRadiusMedium))
            .overlay {
                if isHighlighted {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                        .strokeBorder(.accent, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: .preview)
    }
}
```

**Step 2: Build to verify**

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add -A && git commit -m "Redesign detail view with card-style layout and highlighted steps"
```

---

## Task 8: Add FilterOptions Model and Loadable.isFailed

**Files:**
- Create: `Packages/JorcipesCore/Sources/JorcipesCore/FilterOptions.swift`
- Modify: `Packages/JorcipesCore/Sources/JorcipesCore/Loadable.swift`

**Step 1: Add `isFailed` helper to Loadable**

In `Packages/JorcipesCore/Sources/JorcipesCore/Loadable.swift`, add alongside the existing `isLoading`:

```swift
public var isFailed: Bool {
    if case .failed = self { return true }
    return false
}
```

**Step 2: Create FilterOptions model**

Create `Packages/JorcipesCore/Sources/JorcipesCore/FilterOptions.swift`:

```swift
public struct FilterOptions: Equatable, Sendable {
    public let availableServings: [Int]
    public let availableIngredients: [String]

    public init(availableServings: [Int], availableIngredients: [String]) {
        self.availableServings = availableServings
        self.availableIngredients = availableIngredients
    }
}
```

**Step 3: Build to verify**

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add -A && git commit -m "Add FilterOptions model and Loadable.isFailed to JorcipesCore"
```

---

## Task 9: Add fetchFilterOptions to APIClient and MockAPIClient

**Files:**
- Modify: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/APIClient.swift`
- Modify: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/MockAPIClient.swift`
- Modify: `JorcipesTests/Helpers/ControlledAPIClient.swift`

**Step 1: Write a failing test for fetchFilterOptions**

Add to `Packages/JorcipesNetworking/Tests/JorcipesNetworkingTests/MockAPIClientTests.swift`:

```swift
@Test("fetchFilterOptions returns sorted unique servings and ingredients")
func fetchFilterOptions() async throws {
    let client = MockAPIClient(jsonFileName: "recipes_5", simulateDelay: false)
    let options = try await client.fetchFilterOptions()

    // recipes_5.json has recipes with servings: 4, 2, 4, 6, 3
    #expect(options.availableServings == [2, 3, 4, 6])
    #expect(!options.availableIngredients.isEmpty)
    // Ingredients should be sorted alphabetically
    #expect(options.availableIngredients == options.availableIngredients.sorted())
    // Should contain no duplicates
    #expect(Set(options.availableIngredients).count == options.availableIngredients.count)
}
```

Also add edge case tests for empty and corrupted JSON:

```swift
@Test("fetchFilterOptions returns empty options for empty recipes")
func fetchFilterOptionsEmpty() async throws {
    let client = MockAPIClient(jsonFileName: "recipes_empty", simulateDelay: false)
    let options = try await client.fetchFilterOptions()

    #expect(options.availableServings.isEmpty)
    #expect(options.availableIngredients.isEmpty)
}

@Test("fetchFilterOptions throws for corrupted JSON")
func fetchFilterOptionsCorrupted() async {
    let client = MockAPIClient(jsonFileName: "recipes_corrupted", simulateDelay: false)
    do {
        _ = try await client.fetchFilterOptions()
        Issue.record("Expected an error to be thrown")
    } catch {
        // Expected
    }
}
```

**Step 2: Run tests to verify they fail**

Use Xcode MCP `RunAllTests` to run the JorcipesNetworking tests.
Expected: FAIL — `fetchFilterOptions` does not exist on APIClient.

**Step 3: Add fetchFilterOptions to APIClient protocol**

In `APIClient.swift`, add the new method:

```swift
public protocol APIClient: Sendable {
    func fetchRecipes() async throws -> [Recipe]
    func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe]
    func fetchFilterOptions() async throws -> FilterOptions
}
```

**Step 4: Implement in MockAPIClient**

In `MockAPIClient.swift`, add:

```swift
public func fetchFilterOptions() async throws -> FilterOptions {
    if simulateDelay {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))
    }

    let recipes = try await loadRecipes()

    let servings = Array(Set(recipes.map(\.servings))).sorted()
    let ingredients = Array(Set(recipes.flatMap { $0.ingredients.map(\.name) })).sorted()

    return FilterOptions(availableServings: servings, availableIngredients: ingredients)
}
```

**Step 5: Update ControlledAPIClient**

In `JorcipesTests/Helpers/ControlledAPIClient.swift`, add support for the new method:

```swift
private var filterOptionsContinuations: [CheckedContinuation<FilterOptions, Error>] = []

var filterOptionsContinuationCount: Int { filterOptionsContinuations.count }

func fetchFilterOptions() async throws -> FilterOptions {
    try await withCheckedThrowingContinuation { continuation in
        filterOptionsContinuations.append(continuation)
    }
}

func waitForFilterOptions(count: Int = 1) async {
    while filterOptionsContinuations.count < count {
        await Task.yield()
    }
}

func resolveFilterOptions(with result: Result<FilterOptions, Error>) {
    guard !filterOptionsContinuations.isEmpty else { return }
    let continuation = filterOptionsContinuations.removeFirst()
    continuation.resume(with: result)
}
```

**Step 6: Run test to verify it passes**

Use Xcode MCP `RunAllTests` to run the JorcipesNetworking tests.
Expected: PASS

**Step 7: Run all tests**

Use Xcode MCP `RunAllTests` to run the Jorcipes test suite.
Expected: ALL PASS

**Step 8: Commit**

```bash
git add -A && git commit -m "Add fetchFilterOptions endpoint to APIClient"
```

---

## Task 10: Overhaul SearchViewModel

**Files:**
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchViewModel.swift`
- Modify: `JorcipesTests/JorcipesTests.swift`

**Step 1: Write failing tests for new search behavior**

Add these tests to the `SearchViewModelTests` suite in `JorcipesTests/JorcipesTests.swift`:

```swift
@Test("Search without debounce fires immediately")
func searchNoDebounce() async {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)
    vm.query.text = "pizza"
    vm.search()

    // Should immediately call API — no debounce delay
    await client.waitForSearch()
    await client.resolveSearch(with: .success([Recipe.preview]))
    try? await Task.sleep(for: .milliseconds(10))

    #expect(vm.results == .loaded([Recipe.preview]))
}

@Test("Active filter count reflects selected filters")
func activeFilterCount() {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)

    #expect(vm.activeFilterCount == 0)

    vm.query.dietaryAttributes.insert(.vegan)
    #expect(vm.activeFilterCount == 1)

    vm.query.servings = 4
    #expect(vm.activeFilterCount == 2)

    vm.query.includedIngredients = ["chicken"]
    #expect(vm.activeFilterCount == 3)

    vm.query.excludedIngredients = ["tofu"]
    #expect(vm.activeFilterCount == 4)
}

@Test("loadFilterOptions populates filter options")
func loadFilterOptions() async {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)
    let expected = FilterOptions(availableServings: [2, 4], availableIngredients: ["Chicken", "Tofu"])

    vm.loadFilterOptions()
    await client.waitForFilterOptions()
    await client.resolveFilterOptions(with: .success(expected))
    try? await Task.sleep(for: .milliseconds(10))

    #expect(vm.filterOptions == .loaded(expected))
}
```

**Step 2: Run tests to verify they fail**

Use Xcode MCP `RunSomeTests` to run JorcipesTests.
Expected: FAIL — `activeFilterCount`, `loadFilterOptions`, `filterOptions` don't exist yet.

**Step 3: Rewrite SearchViewModel**

Replace the contents of `SearchViewModel.swift` with the new implementation. Key changes:
- Remove debounce from `search()` — searches execute immediately
- Add `filterOptions: Loadable<FilterOptions>` state
- Add `filtersExpanded: Bool` state
- Add `activeFilterCount: Int` computed property
- Add `activeSheet: FilterSheet?` enum for tracking which sheet is open
- Add `loadFilterOptions()` method
- Remove `ingredientInput` (no longer needed — ingredients picked from a list)
- Remove `updateSearchText()` (no longer searching on text change)
- Simplify ingredient management — now uses full ingredient names from FilterOptions

```swift
import Foundation
import JorcipesCore
import JorcipesNetworking

public enum FilterSheet: Identifiable {
    case dietary
    case servings
    case includedIngredients
    case excludedIngredients

    public var id: Self { self }
}

@MainActor
@Observable
public final class SearchViewModel {
    public private(set) var results: Loadable<[Recipe]> = .idle
    public private(set) var filterOptions: Loadable<FilterOptions> = .idle
    public var query = RecipeSearchQuery()
    public var navigationPath: [RecipeDestination] = []
    public var filtersExpanded = false
    public var activeSheet: FilterSheet?
    public var ingredientSearchText = ""

    private let apiClient: APIClient

    @ObservationIgnored
    nonisolated(unsafe) private var searchTask: Task<Void, Never>?

    @ObservationIgnored
    nonisolated(unsafe) private var filterOptionsTask: Task<Void, Never>?

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Filter Options

    public func loadFilterOptions() {
        guard filterOptions == .idle || filterOptions.isFailed else { return }
        filterOptions = .loading

        filterOptionsTask = Task {
            do {
                let options = try await apiClient.fetchFilterOptions()
                try Task.checkCancellation()
                filterOptions = .loaded(options)
            } catch is CancellationError {
                // Ignore
            } catch {
                filterOptions = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Search

    public func search() {
        searchTask?.cancel()

        guard !query.isEmpty else {
            results = .idle
            return
        }

        results = .loading

        searchTask = Task {
            do {
                let recipes = try await apiClient.searchRecipes(query: query)
                try Task.checkCancellation()
                results = .loaded(recipes)
            } catch is CancellationError {
                // Ignore
            } catch {
                results = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Filter State

    public var activeFilterCount: Int {
        var count = 0
        if !query.dietaryAttributes.isEmpty { count += 1 }
        if query.servings != nil { count += 1 }
        if !query.includedIngredients.isEmpty { count += 1 }
        if !query.excludedIngredients.isEmpty { count += 1 }
        return count
    }

    // MARK: - Dietary Attributes

    public func toggleDietaryAttribute(_ attribute: DietaryAttribute) {
        if query.dietaryAttributes.contains(attribute) {
            query.dietaryAttributes.remove(attribute)
        } else {
            query.dietaryAttributes.insert(attribute)
        }
    }

    public func isDietaryAttributeActive(_ attribute: DietaryAttribute) -> Bool {
        query.dietaryAttributes.contains(attribute)
    }

    // MARK: - Servings

    public func setServings(_ servings: Int?) {
        query.servings = servings
    }

    // MARK: - Ingredients

    public func toggleIncludedIngredient(_ name: String) {
        if let index = query.includedIngredients.firstIndex(of: name) {
            query.includedIngredients.remove(at: index)
        } else {
            query.includedIngredients.append(name)
        }
    }

    public func toggleExcludedIngredient(_ name: String) {
        if let index = query.excludedIngredients.firstIndex(of: name) {
            query.excludedIngredients.remove(at: index)
        } else {
            query.excludedIngredients.append(name)
        }
    }

    public func isIngredientIncluded(_ name: String) -> Bool {
        query.includedIngredients.contains(name)
    }

    public func isIngredientExcluded(_ name: String) -> Bool {
        query.excludedIngredients.contains(name)
    }

    // MARK: - Sheet Dismissal

    /// Called when any filter sheet is dismissed. Clears ingredient search text
    /// and triggers a new search so filter changes take effect on results.
    public func onFilterSheetDismiss() {
        ingredientSearchText = ""
        search()
    }

    // MARK: - Navigation

    public func didTapRecipe(_ recipe: Recipe) {
        navigationPath.append(.detail(recipe))
    }

    deinit {
        searchTask?.cancel()
        filterOptionsTask?.cancel()
    }
}
```

**Step 4: Run tests to verify they pass**

Use Xcode MCP `RunSomeTests` to run JorcipesTests.
Expected: PASS (some existing tests may need minor adjustments — see Step 5)

**Step 5: Fix existing SearchViewModel tests**

Existing tests that call `search()` may need adjustment since debounce is removed. The `searchSuccess` test was waiting for a debounce — now it should resolve immediately:

```swift
@Test("Successful search transitions to loaded")
func searchSuccess() async {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)
    vm.query.text = "test"
    let expected = [Recipe.preview]

    vm.search()

    await client.waitForSearch()
    await client.resolveSearch(with: .success(expected))
    try? await Task.sleep(for: .milliseconds(10))

    #expect(vm.results == .loaded(expected))
}
```

The `searchCancellationPreventsStaleOverwrite` test also needs updating — without debounce, both search calls will immediately hit the API, so both may produce continuations. We need to wait for two continuations and resolve both, verifying only the latest result is kept:

```swift
@Test("Search cancellation prevents stale overwrite")
func searchCancellationPreventsStaleOverwrite() async {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)
    let stale = [Recipe.preview]
    let latest = Recipe.previewList

    vm.query.text = "old"
    vm.search() // request A
    vm.query.text = "new"
    vm.search() // request B cancels A

    // Wait for both continuations to be captured
    await client.waitForSearch(count: 2)
    await client.resolveSearch(with: .success(stale))  // resolves A — cancelled, so ignored
    try? await Task.sleep(for: .milliseconds(10))
    await client.resolveSearch(with: .success(latest))  // resolves B
    try? await Task.sleep(for: .milliseconds(10))

    #expect(vm.results == .loaded(latest))
}
```

Remove tests for removed methods: `addIncludedIngredient`, `toggleIngredientChip`, `toggleExcludedIngredientChip`, `removeIncludedIngredient`, `removeExcludedIngredient`, and `addWhitespaceIngredient`.

Add new tests for `toggleIncludedIngredient` and `toggleExcludedIngredient`:

```swift
@Test("Toggle included ingredient adds and removes")
func toggleIncludedIngredient() {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)

    vm.toggleIncludedIngredient("Chicken")
    #expect(vm.query.includedIngredients == ["Chicken"])

    vm.toggleIncludedIngredient("Chicken")
    #expect(vm.query.includedIngredients.isEmpty)
}

@Test("Toggle excluded ingredient adds and removes")
func toggleExcludedIngredient() {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)

    vm.toggleExcludedIngredient("Tofu")
    #expect(vm.query.excludedIngredients == ["Tofu"])

    vm.toggleExcludedIngredient("Tofu")
    #expect(vm.query.excludedIngredients.isEmpty)
}

@Test("loadFilterOptions retries from failed state")
func loadFilterOptionsRetry() async {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)
    let expected = FilterOptions(availableServings: [2, 4], availableIngredients: ["Chicken"])

    // First attempt fails
    vm.loadFilterOptions()
    await client.waitForFilterOptions()
    await client.resolveFilterOptions(with: .failure(TestError.offline))
    try? await Task.sleep(for: .milliseconds(10))
    #expect(vm.filterOptions.isFailed)

    // Retry should work from failed state
    vm.loadFilterOptions()
    await client.waitForFilterOptions()
    await client.resolveFilterOptions(with: .success(expected))
    try? await Task.sleep(for: .milliseconds(10))
    #expect(vm.filterOptions == .loaded(expected))
}

@Test("Sheet dismiss triggers search with updated query")
func sheetDismissTriggersSearch() async {
    let client = ControlledAPIClient()
    let vm = SearchViewModel(apiClient: client)
    vm.query.dietaryAttributes.insert(.vegan)
    vm.query.text = "curry"

    vm.onFilterSheetDismiss()

    // search() should have been called — wait for API call
    await client.waitForSearch()
    await client.resolveSearch(with: .success([Recipe.preview]))
    try? await Task.sleep(for: .milliseconds(10))

    #expect(vm.results == .loaded([Recipe.preview]))
    #expect(vm.ingredientSearchText.isEmpty)
}
```

**Step 6: Run all tests**

Use Xcode MCP `RunAllTests` to run the Jorcipes test suite.
Expected: ALL PASS

**Step 7: Commit**

```bash
git add -A && git commit -m "Overhaul SearchViewModel: remove debounce, add filter state"
```

---

## Task 11: Rewrite Search UI

**Files:**
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchView.swift`
- Delete: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchFilterView.swift`
- Delete: `Packages/JorcipesSearch/Sources/JorcipesSearch/DietaryChipView.swift`
- Delete: `Packages/JorcipesSearch/Sources/JorcipesSearch/IngredientChipInputView.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/FilterSectionView.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/DietaryFilterSheet.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/ServingsFilterSheet.swift`
- Create: `Packages/JorcipesSearch/Sources/JorcipesSearch/IngredientFilterSheet.swift`

**Step 1: Update SearchView**

Rewrite `SearchView.swift`:
- Switch to `.navigationBarTitleDisplayMode(.inline)`
- Remove `.onChange(of: viewModel.query.text)` — search on submit only
- Replace `SearchFilterView` with new `FilterSectionView`
- Add `.task { viewModel.loadFilterOptions() }`
- Add `.sheet(item: $viewModel.activeSheet)` for filter sheets
- On sheet dismiss, call `viewModel.onFilterSheetDismiss()`

```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem
import JorcipesCards
import JorcipesNetworking

public struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @Namespace private var heroNamespace

    public init(viewModel: SearchViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $viewModel.navigationPath) {
            ScrollView {
                VStack(spacing: .space400) {
                    FilterSectionView(viewModel: viewModel)

                    Divider()

                    SearchResultsContent(
                        results: viewModel.results,
                        heroNamespace: heroNamespace,
                        onRetry: { viewModel.search() }
                    )
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query.text, prompt: "Search recipes...")
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .task {
                viewModel.loadFilterOptions()
            }
            .sheet(item: $viewModel.activeSheet, onDismiss: {
                viewModel.onFilterSheetDismiss()
            }) { sheet in
                switch sheet {
                case .dietary:
                    DietaryFilterSheet(viewModel: viewModel)
                        .presentationDetents([.medium])
                case .servings:
                    ServingsFilterSheet(viewModel: viewModel)
                        .presentationDetents([.medium])
                case .includedIngredients:
                    IngredientFilterSheet(
                        title: "Included Ingredients",
                        viewModel: viewModel,
                        isIncluded: true
                    )
                    .presentationDetents([.medium])
                case .excludedIngredients:
                    IngredientFilterSheet(
                        title: "Excluded Ingredients",
                        viewModel: viewModel,
                        isIncluded: false
                    )
                    .presentationDetents([.medium])
                }
            }
            .navigationDestination(for: RecipeDestination.self) { destination in
                switch destination {
                case .detail(let recipe):
                    RecipeDetailView(recipe: recipe)
                        .navigationTransition(.zoom(sourceID: recipe.id, in: heroNamespace))
                }
            }
        }
    }
}

/// Extracted View struct for search results.
struct SearchResultsContent: View {
    let results: Loadable<[Recipe]>
    var heroNamespace: Namespace.ID
    let onRetry: () -> Void

    var body: some View {
        switch results {
        case .idle:
            ContentUnavailableView(
                "Search Recipes",
                systemImage: "magnifyingglass",
                description: Text("Use the filters above or type a search term to find recipes.")
            )

        case .loading:
            ProgressView("Searching...")
                .padding()

        case .loaded(let recipes):
            if recipes.isEmpty {
                ContentUnavailableView.search
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: .space400) {
                    ForEach(recipes) { recipe in
                        NavigationLink(value: RecipeDestination.detail(recipe)) {
                            RecipeCardView(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: recipe.id, in: heroNamespace)
                    }
                }
                .padding(.horizontal, .space400)
            }

        case .failed(let message):
            ContentUnavailableView {
                Label("Search Failed", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again", action: onRetry)
            }
        }
    }
}

#Preview {
    SearchView(
        viewModel: SearchViewModel(
            apiClient: MockAPIClient(simulateDelay: false)
        )
    )
}
```

**Step 2: Create FilterSectionView**

Create `Packages/JorcipesSearch/Sources/JorcipesSearch/FilterSectionView.swift`:

```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct FilterSectionView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .space300) {
            FilterHeader(
                activeCount: viewModel.activeFilterCount,
                isExpanded: viewModel.filtersExpanded
            ) {
                viewModel.filtersExpanded.toggle()
            }

            if viewModel.filtersExpanded {
                FilterRow(label: "Dietary", value: dietaryValue) {
                    viewModel.activeSheet = .dietary
                }

                FilterRow(label: "Servings", value: servingsValue) {
                    viewModel.activeSheet = .servings
                }

                FilterChipRow(label: "Included ingredients", items: viewModel.query.includedIngredients) {
                    viewModel.activeSheet = .includedIngredients
                }

                FilterChipRow(label: "Excluded ingredients", items: viewModel.query.excludedIngredients) {
                    viewModel.activeSheet = .excludedIngredients
                }
            }
        }
        .padding(.space400)
    }

    private var dietaryValue: String? {
        let attrs = viewModel.query.dietaryAttributes
        guard !attrs.isEmpty else { return nil }
        return attrs.sorted(by: { $0.rawValue < $1.rawValue })
            .map(\.rawValue.capitalized)
            .joined(separator: ", ")
    }

    private var servingsValue: String? {
        guard let s = viewModel.query.servings else { return nil }
        return "\(s) servings"
    }
}

struct FilterHeader: View {
    let activeCount: Int
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(activeCount > 0 ? "Filters (\(activeCount))" : "Filters")
                    .font(.headline)

                Spacer()

                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct FilterRow: View {
    let label: String
    let value: String?
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Button(value ?? "Select", action: onTap)
                .buttonStyle(.bordered)
        }
    }
}

struct FilterChipRow: View {
    let label: String
    let items: [String]
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            if items.isEmpty {
                Button("Select", action: onTap)
                    .buttonStyle(.bordered)
            } else {
                Button(action: onTap) {
                    HStack(spacing: .space100) {
                        ForEach(items, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .padding(.horizontal, .space200)
                                .padding(.vertical, .space50)
                                .background(Color.recipePrimary.opacity(0.15))
                                .foregroundStyle(Color.recipePrimary)
                                .clipShape(.capsule)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
```

**Step 3: Create DietaryFilterSheet**

Create `Packages/JorcipesSearch/Sources/JorcipesSearch/DietaryFilterSheet.swift`:

```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct DietaryFilterSheet: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(DietaryAttribute.allCases, id: \.self) { attribute in
                    Button {
                        viewModel.toggleDietaryAttribute(attribute)
                    } label: {
                        HStack {
                            Text(attribute.rawValue.capitalized)

                            Spacer()

                            if viewModel.isDietaryAttributeActive(attribute) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Dietary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
```

**Step 4: Create ServingsFilterSheet**

Create `Packages/JorcipesSearch/Sources/JorcipesSearch/ServingsFilterSheet.swift`:

```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct ServingsFilterSheet: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.filterOptions {
                case .loaded(let options):
                    List {
                        Button {
                            viewModel.setServings(nil)
                        } label: {
                            HStack {
                                Text("Any")

                                Spacer()

                                if viewModel.query.servings == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accent)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        ForEach(options.availableServings, id: \.self) { servings in
                            Button {
                                viewModel.setServings(servings)
                            } label: {
                                HStack {
                                    Text("\(servings) servings")

                                    Spacer()

                                    if viewModel.query.servings == servings {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.accent)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                case .failed(let message):
                    ContentUnavailableView {
                        Label("Failed to Load", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") { viewModel.loadFilterOptions() }
                    }

                default:
                    ProgressView()
                }
            }
            .navigationTitle("Servings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
```

**Step 5: Create IngredientFilterSheet**

Create `Packages/JorcipesSearch/Sources/JorcipesSearch/IngredientFilterSheet.swift`:

```swift
import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct IngredientFilterSheet: View {
    let title: String
    @Bindable var viewModel: SearchViewModel
    let isIncluded: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.filterOptions {
                case .loaded(let options):
                    List {
                        ForEach(filteredIngredients(from: options), id: \.self) { ingredient in
                            IngredientRow(
                                ingredient: ingredient,
                                isSelected: isSelected(ingredient),
                                isDisabled: isInOppositeList(ingredient),
                                oppositeLabel: isIncluded ? "Excluded" : "Included"
                            ) {
                                if isIncluded {
                                    viewModel.toggleIncludedIngredient(ingredient)
                                } else {
                                    viewModel.toggleExcludedIngredient(ingredient)
                                }
                            }
                        }
                    }
                    .searchable(text: $viewModel.ingredientSearchText, prompt: "Search ingredients...")

                case .failed(let message):
                    ContentUnavailableView {
                        Label("Failed to Load", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") { viewModel.loadFilterOptions() }
                    }

                default:
                    ProgressView()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func filteredIngredients(from options: FilterOptions) -> [String] {
        if viewModel.ingredientSearchText.isEmpty {
            return options.availableIngredients
        }
        return options.availableIngredients.filter {
            $0.localizedStandardContains(viewModel.ingredientSearchText)
        }
    }

    private func isSelected(_ ingredient: String) -> Bool {
        if isIncluded {
            viewModel.isIngredientIncluded(ingredient)
        } else {
            viewModel.isIngredientExcluded(ingredient)
        }
    }

    private func isInOppositeList(_ ingredient: String) -> Bool {
        if isIncluded {
            viewModel.isIngredientExcluded(ingredient)
        } else {
            viewModel.isIngredientIncluded(ingredient)
        }
    }
}

struct IngredientRow: View {
    let ingredient: String
    let isSelected: Bool
    let isDisabled: Bool
    let oppositeLabel: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(ingredient)
                    .foregroundStyle(isDisabled ? .tertiary : .primary)

                Spacer()

                if isDisabled {
                    Text(oppositeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, .space200)
                        .padding(.vertical, .space50)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(.capsule)
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
```

**Step 6: Delete old filter files**

Delete these files:
- `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchFilterView.swift`
- `Packages/JorcipesSearch/Sources/JorcipesSearch/DietaryChipView.swift`
- `Packages/JorcipesSearch/Sources/JorcipesSearch/IngredientChipInputView.swift`

Note: `WrappingHStack` in `IngredientChipInputView.swift` may still be used elsewhere. Check if `FilterChipRow` or any other view still needs it. If not, it can be deleted along with the file. If it's needed, move it to its own file or to JorcipesDesignSystem first.

**Step 7: Build to verify**

Use Xcode MCP `BuildProject` to build the Jorcipes scheme.
Expected: BUILD SUCCEEDED

**Step 8: Run all tests**

Use Xcode MCP `RunAllTests` to run the Jorcipes test suite.
Expected: ALL PASS

**Step 9: Commit**

```bash
git add -A && git commit -m "Rewrite search UI with collapsible filters and half-sheet selection"
```

---

## Task 12: Final Cleanup and Verification

**Step 1: Remove unused functions and properties**

After the refactors above, audit the codebase for any now-unused code. Key candidates:
- `SearchViewModel.updateSearchText()` — removed, verify no callers remain
- `SearchViewModel.ingredientInput` — replaced by `ingredientSearchText`, verify old property is gone
- `SearchViewModel.addIncludedIngredient()`, `toggleIngredientChip()`, `toggleExcludedIngredientChip()`, `removeIncludedIngredient()`, `removeExcludedIngredient()` — replaced by `toggleIncludedIngredient(_:)` and `toggleExcludedIngredient(_:)`, verify old methods are gone
- `RecipeDietarySection`, `RecipeHeaderSection`, `RecipeIngredientsSection`, `RecipeInstructionsSection` — replaced by new Detail sub-views, verify old structs are gone
- `DietaryChipView`, `IngredientChipInputView`, `IngredientChip`, `WrappingHStack` — deleted with old files, verify no remaining references
- Any other dead code discovered during audit

**Step 2: Verify filter options flow end-to-end**

Confirm that:
- `SearchView.task` calls `viewModel.loadFilterOptions()` on appear
- Filter sheets read from `viewModel.filterOptions`
- Selecting filters updates `viewModel.query` (dietary, servings, included/excluded ingredients)
- Dismissing a filter sheet calls `viewModel.onFilterSheetDismiss()` which calls `search()`
- `search()` passes the full `query` (including filter selections) to `apiClient.searchRecipes(query:)`
- `MockAPIClient.searchRecipes(query:)` already filters by dietary, servings, included/excluded ingredients

**Step 3: Run full test suite**

Use Xcode MCP `RunAllTests` to run the Jorcipes test suite.
Expected: ALL PASS

**Step 4: Check for any remaining CLAUDE.md references**

Search all `.swift` files for `CLAUDE.md` — should find zero results.

**Step 5: Check for any remaining ContentView references**

Search all files for `ContentView` — should find zero results (in non-build directories).

**Step 6: Verify no SwiftLint warnings (if installed)**

Run: `swiftlint lint` if available.

**Step 7: Commit any final fixes if needed**
