# Update 2 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Code quality pass — fix naming, add doc comments, rename MockAPIClient → LocalAPIClient, and modernise tests with Swift Testing conventions.

**Architecture:** No architectural changes. This is a rename/restructure/documentation pass across production code (4 view models + 1 API client) and tests (3 files).

**Tech Stack:** Swift 6.2, Swift Testing framework, Xcode MCP for builds/tests.

---

### Task 1: Rename MockAPIClient → LocalAPIClient

**Files:**
- Rename: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/MockAPIClient.swift` → `LocalAPIClient.swift`
- Rename: `Packages/JorcipesNetworking/Tests/JorcipesNetworkingTests/MockAPIClientTests.swift` → `LocalAPIClientTests.swift`
- Modify: `Jorcipes/JorcipesApp.swift:10`
- Modify: `Jorcipes/RootTabView.swift:31`
- Modify: `Packages/JorcipesRecipeList/Sources/JorcipesRecipeList/RecipeListView.swift:73`
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/FilterSectionView.swift:142,147`
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchView.swift:112`

**Step 1: Rename class and file in networking package**

In `MockAPIClient.swift`, rename the class:

```swift
// Before:
public final class MockAPIClient: APIClient, @unchecked Sendable {

// After:
public final class LocalAPIClient: APIClient, @unchecked Sendable {
```

Then rename the file from `MockAPIClient.swift` to `LocalAPIClient.swift` using `git mv`.

**Step 2: Update all references in production code**

Replace `MockAPIClient` with `LocalAPIClient` in these files:
- `Jorcipes/JorcipesApp.swift` line 10: `MockAPIClient(jsonFileName: jsonFileName)` → `LocalAPIClient(jsonFileName: jsonFileName)`
- `Jorcipes/RootTabView.swift` line 31: `MockAPIClient(simulateDelay: false)` → `LocalAPIClient(simulateDelay: false)`
- `Packages/JorcipesRecipeList/Sources/JorcipesRecipeList/RecipeListView.swift` line 73: `MockAPIClient(simulateDelay: false)` → `LocalAPIClient(simulateDelay: false)`
- `Packages/JorcipesSearch/Sources/JorcipesSearch/FilterSectionView.swift` lines 142, 147: `MockAPIClient()` → `LocalAPIClient()`
- `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchView.swift` line 112: `MockAPIClient(simulateDelay: false)` → `LocalAPIClient(simulateDelay: false)`

**Step 3: Rename test file and update suite name**

Rename `MockAPIClientTests.swift` to `LocalAPIClientTests.swift` using `git mv`.

In the test file:
- Change suite name: `@Suite("MockAPIClient Tests")` → `@Suite("LocalAPIClient Tests")`
- Change struct name: `MockAPIClientTests` → `LocalAPIClientTests`
- Update `makeClient()` return type: `MockAPIClient` → `LocalAPIClient`
- Replace all `MockAPIClient(` with `LocalAPIClient(` in the file

**Step 4: Build to verify**

Build via Xcode MCP. Expected: clean build, no errors.

**Step 5: Run all tests**

Run all tests via Xcode MCP. Expected: all pass.

**Step 6: Commit**

```
Rename MockAPIClient to LocalAPIClient
```

---

### Task 2: Fix short variable names

**Files:**
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/FilterSectionView.swift:63,64`
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/FilterSectionView.swift:146-153` (preview)

**Step 1: Rename `s` in FilterSectionView**

```swift
// Before (line 63-64):
guard let s = viewModel.query.servings else { return nil }
return "\(s) servings"

// After:
guard let servings = viewModel.query.servings else { return nil }
return "\(servings) servings"
```

**Step 2: Rename `vm` in FilterSectionView preview**

```swift
// Before (lines 146-153):
@Previewable @State var viewModel = {
    let vm = SearchViewModel(apiClient: LocalAPIClient())
    vm.filtersExpanded = true
    vm.query.dietaryAttributes = [.vegan, .vegetarian]
    vm.query.servings = 4
    vm.query.includedIngredients = ["Tomato", "Basil"]
    return vm
}()

// After:
@Previewable @State var viewModel = {
    let viewModel = SearchViewModel(apiClient: LocalAPIClient())
    viewModel.filtersExpanded = true
    viewModel.query.dietaryAttributes = [.vegan, .vegetarian]
    viewModel.query.servings = 4
    viewModel.query.includedIngredients = ["Tomato", "Basil"]
    return viewModel
}()
```

Note: `vm` in tests will be renamed in Task 5 when rewriting tests.

**Step 3: Build to verify**

Build via Xcode MCP. Expected: clean build.

**Step 4: Commit**

```
Rename short variables for clarity
```

---

### Task 3: Add documentation comments to public functions

**Files:**
- Modify: `Packages/JorcipesRecipeList/Sources/JorcipesRecipeList/RecipeListViewModel.swift`
- Modify: `Packages/JorcipesSearch/Sources/JorcipesSearch/SearchViewModel.swift`
- Modify: `Packages/JorcipesCards/Sources/JorcipesCards/RecipeDetailViewModel.swift`
- Modify: `Packages/JorcipesNetworking/Sources/JorcipesNetworking/LocalAPIClient.swift`

**Step 1: Add doc comments to RecipeListViewModel (4 functions)**

```swift
/// Triggers an initial load if the state is idle. Called by the view on appear.
public func onAppear() {

/// Cancels any in-flight fetch and starts a new one, driving the state through loading → loaded/failed.
public func load() {

/// Awaitable refresh that keeps existing data visible while fetching. Used by SwiftUI's `.refreshable`.
public func refresh() async {

/// Pushes the given recipe onto the navigation path to show its detail view.
public func didTapRecipe(_ recipe: Recipe) {
```

**Step 2: Add doc comments to SearchViewModel (16 functions)**

```swift
/// Fetches available filter options from the API. Only runs from idle or failed state.
public func loadFilterOptions() {

/// Cancels any pending search and starts a new one immediately if the query has changed.
public func search() {

/// Schedules a search after a 300ms debounce. Cancels any previously scheduled debounced search.
public func debouncedSearch() {

/// Toggles the given dietary attribute in or out of the search query.
public func toggleDietaryAttribute(_ attribute: DietaryAttribute) {

/// Returns whether the given dietary attribute is currently active in the search query.
public func isDietaryAttributeActive(_ attribute: DietaryAttribute) -> Bool {

/// Sets the servings filter to the given value, or clears it if nil.
public func setServings(_ servings: Int?) {

/// Toggles the given ingredient in or out of the included ingredients list.
public func toggleIncludedIngredient(_ name: String) {

/// Toggles the given ingredient in or out of the excluded ingredients list.
public func toggleExcludedIngredient(_ name: String) {

/// Returns whether the given ingredient is in the included list.
public func isIngredientIncluded(_ name: String) -> Bool {

/// Returns whether the given ingredient is in the excluded list.
public func isIngredientExcluded(_ name: String) -> Bool {

/// Removes all dietary attribute filters from the search query.
public func clearDietaryAttributes() {

/// Removes the servings filter from the search query.
public func clearServings() {

/// Removes all included ingredient filters from the search query.
public func clearIncludedIngredients() {

/// Removes all excluded ingredient filters from the search query.
public func clearExcludedIngredients() {

/// Clears the instruction text filter from the search query.
public func clearInstructionText() {

/// Pushes the given recipe onto the navigation path to show its detail view.
public func didTapRecipe(_ recipe: Recipe) {
```

Note: `onFilterSheetDismiss()` already has a doc comment — leave it as-is.

**Step 3: Add doc comments to RecipeDetailViewModel (2 functions)**

```swift
/// Advances to the next instruction step, or finishes if on the last step.
public func advanceStep() {

/// Jumps directly to the given instruction step index.
public func selectStep(_ index: Int) {
```

**Step 4: Add doc comments to LocalAPIClient (3 functions)**

```swift
/// Fetches all recipes from the local JSON file, with an optional simulated network delay.
public func fetchRecipes() async throws -> [Recipe] {

/// Searches recipes by applying the query filters locally against the JSON data.
public func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe] {

/// Builds filter options (available servings and ingredients) from the local recipe data.
public func fetchFilterOptions() async throws -> FilterOptions {
```

**Step 5: Build to verify**

Build via Xcode MCP. Expected: clean build.

**Step 6: Commit**

```
Add documentation comments to public functions
```

---

### Task 4: Clean up RecipeTests and LocalAPIClientTests

**Files:**
- Modify: `Packages/JorcipesCore/Tests/JorcipesCoreTests/RecipeTests.swift`
- Modify: `Packages/JorcipesNetworking/Tests/JorcipesNetworkingTests/LocalAPIClientTests.swift`

**Step 1: Remove framework-testing tests from RecipeTests**

Delete these 3 tests (they test Apple's Codable synthesis or preview data, not our logic):
- `codableRoundTrip` (lines 71-80)
- `ingredientCodable` (lines 82-88)
- `previewDietaryDistribution` (lines 112-122)

Also remove the `// MARK: - Codable` and `// MARK: - Preview Data` section markers.

**Step 2: Rename remaining RecipeTests to backtick syntax and add GIVEN/WHEN/THEN**

The 7 remaining tests become:

```swift
@Suite("Recipe Model Tests")
struct RecipeTests {

    // MARK: - Dietary Attribute Computation

    @Test func `recipe with all vegetarian ingredients is vegetarian`() {
        // GIVEN: A recipe where all ingredients are vegetarian
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 2,
            ingredients: [
                Ingredient(id: "a", name: "A", quantity: "1", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "b", name: "B", quantity: "1", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: []
        )

        // THEN: Recipe is vegetarian but not vegan
        #expect(recipe.dietaryAttributes.contains(.vegetarian))
        #expect(!recipe.dietaryAttributes.contains(.vegan))
    }

    @Test func `recipe with all vegan ingredients is both vegan and vegetarian`() {
        // GIVEN: A recipe where all ingredients are vegan
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 2,
            ingredients: [
                Ingredient(id: "a", name: "A", quantity: "1", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "b", name: "B", quantity: "1", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: []
        )

        // THEN: Recipe is both vegetarian and vegan
        #expect(recipe.dietaryAttributes.contains(.vegetarian))
        #expect(recipe.dietaryAttributes.contains(.vegan))
    }

    @Test func `recipe with mixed ingredients has no dietary attributes`() {
        // GIVEN: A recipe with one non-vegetarian ingredient
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 2,
            ingredients: [
                Ingredient(id: "a", name: "Chicken", quantity: "1", dietaryAttributes: []),
                Ingredient(id: "b", name: "Lettuce", quantity: "1", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: []
        )

        // THEN: Recipe has no dietary attributes
        #expect(recipe.dietaryAttributes.isEmpty)
    }

    @Test func `recipe with no ingredients has no dietary attributes`() {
        // GIVEN: A recipe with an empty ingredients list
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 1,
            ingredients: [],
            instructions: []
        )

        // THEN: Recipe has no dietary attributes
        #expect(recipe.dietaryAttributes.isEmpty)
    }

    // MARK: - RecipeSearchQuery

    @Test func `empty query reports isEmpty as true`() {
        // GIVEN: A default search query
        let query = RecipeSearchQuery()

        // THEN: Query is empty
        #expect(query.isEmpty)
    }

    @Test func `query with text is not empty`() {
        // GIVEN: A query with search text
        let query = RecipeSearchQuery(text: "pizza")

        // THEN: Query is not empty
        #expect(!query.isEmpty)
    }

    @Test func `query with dietary attributes is not empty`() {
        // GIVEN: A query with a dietary filter
        let query = RecipeSearchQuery(dietaryAttributes: [.vegan])

        // THEN: Query is not empty
        #expect(!query.isEmpty)
    }
}
```

**Step 3: Rename LocalAPIClientTests to backtick syntax and add GIVEN/WHEN/THEN**

Update all test functions. The `makeClient` helper stays. Example pattern for each test:

```swift
@Suite("LocalAPIClient Tests")
struct LocalAPIClientTests {

    private func makeClient(jsonFileName: String = "recipes_5") -> LocalAPIClient {
        LocalAPIClient(jsonFileName: jsonFileName, simulateDelay: false)
    }

    // MARK: - Fetch

    @Test func `fetching recipes loads all recipes from JSON`() async throws {
        // GIVEN: A client with 5 recipes
        let client = makeClient()

        // WHEN: Fetching all recipes
        let recipes = try await client.fetchRecipes()

        // THEN: All 5 recipes are returned
        #expect(recipes.count == 5)
    }

    @Test func `fetching from empty JSON returns empty array`() async throws {
        // GIVEN: A client with empty recipe data
        let client = makeClient(jsonFileName: "recipes_empty")

        // WHEN: Fetching recipes
        let recipes = try await client.fetchRecipes()

        // THEN: No recipes are returned
        #expect(recipes.isEmpty)
    }

    @Test func `fetching from corrupted JSON throws decoding error`() async {
        // GIVEN: A client with corrupted JSON
        let client = makeClient(jsonFileName: "recipes_corrupted")

        // WHEN/THEN: Fetching throws an error
        await #expect(throws: (any Error).self) {
            try await client.fetchRecipes()
        }
    }

    @Test func `fetching from missing file throws fileNotFound`() async {
        // GIVEN: A client with a nonexistent file
        let client = makeClient(jsonFileName: "nonexistent")

        // WHEN/THEN: Fetching throws APIError
        await #expect(throws: APIError.self) {
            try await client.fetchRecipes()
        }
    }

    // MARK: - Search: Text

    @Test func `search by title text returns matching recipes`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Searching for "pizza"
        let query = RecipeSearchQuery(text: "pizza")
        let results = try await client.searchRecipes(query: query)

        // THEN: One matching recipe is returned
        #expect(results.count == 1)
        #expect(results.first?.title.localizedStandardContains("pizza") == true)
    }

    @Test func `search with empty query returns all recipes`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Searching with an empty query
        let query = RecipeSearchQuery()
        let results = try await client.searchRecipes(query: query)

        // THEN: All recipes are returned
        #expect(results.count == 5)
    }

    // MARK: - Search: Dietary

    @Test func `search by vegetarian returns only vegetarian recipes`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Filtering by vegetarian
        let query = RecipeSearchQuery(dietaryAttributes: [.vegetarian])
        let results = try await client.searchRecipes(query: query)

        // THEN: Only vegetarian recipes are returned
        #expect(results.allSatisfy { $0.dietaryAttributes.contains(.vegetarian) })
        #expect(results.count == 3)
    }

    @Test func `search by vegan returns only vegan recipes`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Filtering by vegan
        let query = RecipeSearchQuery(dietaryAttributes: [.vegan])
        let results = try await client.searchRecipes(query: query)

        // THEN: Only vegan recipes are returned
        #expect(results.allSatisfy { $0.dietaryAttributes.contains(.vegan) })
        #expect(results.count == 1)
    }

    // MARK: - Search: Servings

    @Test func `search by servings returns matching recipes`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Filtering by 4 servings
        let query = RecipeSearchQuery(servings: 4)
        let results = try await client.searchRecipes(query: query)

        // THEN: All results have 4 servings
        #expect(results.allSatisfy { $0.servings == 4 })
    }

    // MARK: - Search: Ingredients

    @Test func `search with included ingredient returns recipes containing it`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Including "chicken"
        let query = RecipeSearchQuery(includedIngredients: ["chicken"])
        let results = try await client.searchRecipes(query: query)

        // THEN: One recipe containing chicken is returned
        #expect(results.count == 1)
    }

    @Test func `search with excluded ingredient filters out recipes containing it`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Excluding "cheese" and "parmesan"
        let query = RecipeSearchQuery(excludedIngredients: ["cheese", "parmesan"])
        let results = try await client.searchRecipes(query: query)

        // THEN: No results contain cheese or parmesan
        #expect(results.allSatisfy { recipe in
            !recipe.ingredients.contains { $0.name.localizedStandardContains("cheese") || $0.name.localizedStandardContains("parmesan") }
        })
    }

    // MARK: - Search: Combined Filters

    @Test func `search with multiple filters combines them with AND logic`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Filtering by vegetarian AND 4 servings
        let query = RecipeSearchQuery(
            dietaryAttributes: [.vegetarian],
            servings: 4
        )
        let results = try await client.searchRecipes(query: query)

        // THEN: All results match both filters
        #expect(results.allSatisfy {
            $0.dietaryAttributes.contains(.vegetarian) && $0.servings == 4
        })
    }

    // MARK: - Filter Options

    @Test func `fetchFilterOptions returns sorted unique servings and ingredients`() async throws {
        // GIVEN: A client with 5 recipes
        let client = LocalAPIClient(jsonFileName: "recipes_5", simulateDelay: false)

        // WHEN: Fetching filter options
        let options = try await client.fetchFilterOptions()

        // THEN: Servings are sorted and unique, ingredients are sorted with no duplicates
        #expect(options.availableServings == [2, 3, 4, 6])
        #expect(!options.availableIngredients.isEmpty)
        #expect(options.availableIngredients == options.availableIngredients.sorted())
        #expect(Set(options.availableIngredients).count == options.availableIngredients.count)
    }

    @Test func `fetchFilterOptions returns empty options for empty recipes`() async throws {
        // GIVEN: A client with no recipes
        let client = LocalAPIClient(jsonFileName: "recipes_empty", simulateDelay: false)

        // WHEN: Fetching filter options
        let options = try await client.fetchFilterOptions()

        // THEN: Both lists are empty
        #expect(options.availableServings.isEmpty)
        #expect(options.availableIngredients.isEmpty)
    }

    @Test func `fetchFilterOptions throws for corrupted JSON`() async {
        // GIVEN: A client with corrupted JSON
        let client = LocalAPIClient(jsonFileName: "recipes_corrupted", simulateDelay: false)

        // WHEN/THEN: Fetching throws an error
        do {
            _ = try await client.fetchFilterOptions()
            Issue.record("Expected an error to be thrown")
        } catch {
            // Expected
        }
    }
}
```

**Step 4: Run all tests**

Run all tests via Xcode MCP. Expected: all pass (3 fewer tests in RecipeTests).

**Step 5: Commit**

```
Modernise RecipeTests and LocalAPIClientTests with Swift Testing conventions
```

---

### Task 5: Rewrite RecipeListViewModelTests as flow tests

**Files:**
- Create: `JorcipesTests/RecipeListViewModelTests.swift`

**Step 1: Create RecipeListViewModelTests.swift**

Write the file with 3 flow tests combining the original 8 individual tests:

```swift
import Testing
import Foundation
@testable import JorcipesRecipeList
import JorcipesCore
import JorcipesNetworking

@Suite("RecipeListViewModel Tests")
@MainActor
struct RecipeListViewModelTests {

    @Test func `happy path loads and refreshes recipes`() async {
        // GIVEN: View model initialised
        let client = ControlledAPIClient()
        let viewModel = RecipeListViewModel(apiClient: client)
        let recipes = Recipe.previewList

        // THEN: Initial state is idle
        #expect(viewModel.state == .idle)

        // WHEN: View appears
        viewModel.onAppear()

        // THEN: State transitions to loading
        #expect(viewModel.state == .loading)

        // WHEN: Fetch completes successfully
        await client.waitForFetch()
        await client.resolveFetch(with: .success(recipes))
        try? await Task.sleep(for: .milliseconds(10))

        // THEN: State is loaded with recipes
        #expect(viewModel.state == .loaded(recipes))

        // WHEN: View appears again
        viewModel.onAppear()

        // THEN: State remains loaded (no redundant reload)
        #expect(viewModel.state == .loaded(recipes))

        // WHEN: Pull-to-refresh starts
        let refreshed = [Recipe.preview]
        async let refreshTask: Void = viewModel.refresh()
        await client.waitForFetch()

        // THEN: Existing data stays visible during refresh
        #expect(viewModel.state == .loaded(recipes))

        // WHEN: Refresh completes
        await client.resolveFetch(with: .success(refreshed))
        await refreshTask

        // THEN: State updates to refreshed data
        #expect(viewModel.state == .loaded(refreshed))
    }

    @Test func `failed load and stale cancellation`() async {
        // GIVEN: View model initialised
        let client = ControlledAPIClient()
        let viewModel = RecipeListViewModel(apiClient: client)

        // WHEN: Load fails
        viewModel.load()
        await client.waitForFetch()
        await client.resolveFetch(with: .failure(TestError.offline))
        try? await Task.sleep(for: .milliseconds(10))

        // THEN: State is failed
        if case .failed = viewModel.state {
            // expected
        } else {
            Issue.record("Expected failed state, got \(viewModel.state)")
        }

        // GIVEN: A fresh view model for cancellation test
        let viewModel2 = RecipeListViewModel(apiClient: client)
        let stale = [Recipe.preview]
        let latest = Recipe.previewList

        // WHEN: Two loads fire in quick succession (B cancels A)
        viewModel2.load()
        await client.waitForFetch()
        viewModel2.load()
        await client.waitForFetch(count: 2)

        // WHEN: Stale response arrives (cancelled task ignores it)
        await client.resolveFetch(with: .success(stale))
        try? await Task.sleep(for: .milliseconds(10))

        // WHEN: Latest response arrives
        await client.resolveFetch(with: .success(latest))
        try? await Task.sleep(for: .milliseconds(10))

        // THEN: Only the latest response is used
        #expect(viewModel2.state == .loaded(latest))
    }

    @Test func `tapping recipe navigates to detail`() {
        // GIVEN: View model initialised
        let client = ControlledAPIClient()
        let viewModel = RecipeListViewModel(apiClient: client)
        let recipe = Recipe.preview

        // WHEN: User taps a recipe
        viewModel.didTapRecipe(recipe)

        // THEN: Recipe is pushed onto the navigation path
        #expect(viewModel.navigationPath.count == 1)
    }
}
```

**Step 2: Run tests to verify**

Run all tests via Xcode MCP. Expected: 3 tests in this suite, all pass.

**Step 3: Commit**

```
Rewrite RecipeListViewModelTests as flow tests
```

---

### Task 6: Rewrite SearchViewModelTests as flow tests

**Files:**
- Create: `JorcipesTests/SearchViewModelTests.swift`

**Step 1: Create SearchViewModelTests.swift**

Write the file with 4 flow tests combining the original 15 individual tests:

```swift
import Testing
import Foundation
@testable import JorcipesSearch
import JorcipesCore
import JorcipesNetworking

@Suite("SearchViewModel Tests")
@MainActor
struct SearchViewModelTests {

    @Test func `search flow from idle through loading to loaded`() async {
        // GIVEN: View model initialised
        let client = ControlledAPIClient()
        let viewModel = SearchViewModel(apiClient: client)

        // THEN: Initial state is idle
        #expect(viewModel.results == .idle)

        // WHEN: Search with non-empty query
        viewModel.query.text = "pizza"
        viewModel.search()

        // THEN: State transitions to loading
        #expect(viewModel.results == .loading)

        // WHEN: Search completes successfully
        let expected = [Recipe.preview]
        await client.waitForSearch()
        await client.resolveSearch(with: .success(expected))
        try? await Task.sleep(for: .milliseconds(10))

        // THEN: State is loaded with results
        #expect(viewModel.results == .loaded(expected))

        // GIVEN: A fresh view model for empty query test
        let viewModel2 = SearchViewModel(apiClient: client)

        // WHEN: Search with empty query
        viewModel2.query = RecipeSearchQuery()
        viewModel2.search()

        // THEN: Still triggers loading
        #expect(viewModel2.results == .loading)

        // GIVEN: A fresh view model for cancellation test
        let viewModel3 = SearchViewModel(apiClient: client)
        let stale = [Recipe.preview]
        let latest = Recipe.previewList

        // WHEN: Two searches fire in quick succession
        viewModel3.query.text = "old"
        viewModel3.search()
        viewModel3.query.text = "new"
        viewModel3.search()

        // WHEN: Stale response arrives (cancelled), then latest
        await client.waitForSearch(count: 2)
        await client.resolveSearch(with: .success(stale))
        try? await Task.sleep(for: .milliseconds(10))
        await client.resolveSearch(with: .success(latest))
        try? await Task.sleep(for: .milliseconds(10))

        // THEN: Only latest results are used
        #expect(viewModel3.results == .loaded(latest))
    }

    @Test func `filter manipulation updates query state`() {
        // GIVEN: View model initialised
        let client = ControlledAPIClient()
        let viewModel = SearchViewModel(apiClient: client)

        // THEN: No active filters initially
        #expect(viewModel.activeFilterCount == 0)

        // WHEN: Toggle dietary attribute on
        viewModel.toggleDietaryAttribute(.vegetarian)

        // THEN: Attribute is active, count is 1
        #expect(viewModel.query.dietaryAttributes.contains(.vegetarian))
        #expect(viewModel.activeFilterCount == 1)

        // WHEN: Toggle same attribute off
        viewModel.toggleDietaryAttribute(.vegetarian)

        // THEN: Attribute is removed
        #expect(!viewModel.query.dietaryAttributes.contains(.vegetarian))
        #expect(viewModel.activeFilterCount == 0)

        // WHEN: Multiple filter types are set
        viewModel.query.dietaryAttributes.insert(.vegan)
        viewModel.query.servings = 4
        viewModel.query.includedIngredients = ["chicken"]
        viewModel.query.excludedIngredients = ["tofu"]
        viewModel.query.instructionText = "boil"

        // THEN: Active filter count reflects all 5
        #expect(viewModel.activeFilterCount == 5)

        // WHEN: Clear instruction text
        viewModel.clearInstructionText()

        // THEN: Instruction text is empty
        #expect(viewModel.query.instructionText.isEmpty)

        // WHEN: Toggle included ingredient on then off
        let viewModel2 = SearchViewModel(apiClient: client)
        viewModel2.toggleIncludedIngredient("Chicken")

        // THEN: Ingredient is included
        #expect(viewModel2.query.includedIngredients == ["Chicken"])

        // WHEN: Toggle same ingredient off
        viewModel2.toggleIncludedIngredient("Chicken")

        // THEN: Ingredient is removed
        #expect(viewModel2.query.includedIngredients.isEmpty)

        // WHEN: Toggle excluded ingredient on then off
        viewModel2.toggleExcludedIngredient("Tofu")

        // THEN: Ingredient is excluded
        #expect(viewModel2.query.excludedIngredients == ["Tofu"])

        // WHEN: Toggle same ingredient off
        viewModel2.toggleExcludedIngredient("Tofu")

        // THEN: Ingredient is removed
        #expect(viewModel2.query.excludedIngredients.isEmpty)
    }

    @Test func `filter options load and retry from failure`() async {
        // GIVEN: View model initialised
        let client = ControlledAPIClient()
        let viewModel = SearchViewModel(apiClient: client)
        let expected = FilterOptions(availableServings: [2, 4], availableIngredients: ["Chicken", "Tofu"])

        // WHEN: Loading filter options succeeds
        viewModel.loadFilterOptions()
        await client.waitForFilterOptions()
        await client.resolveFilterOptions(with: .success(expected))
        try? await Task.sleep(for: .milliseconds(10))

        // THEN: Filter options are loaded
        #expect(viewModel.filterOptions == .loaded(expected))

        // GIVEN: A fresh view model for retry test
        let viewModel2 = SearchViewModel(apiClient: client)
        let retryExpected = FilterOptions(availableServings: [2, 4], availableIngredients: ["Chicken"])

        // WHEN: First attempt fails
        viewModel2.loadFilterOptions()
        await client.waitForFilterOptions()
        await client.resolveFilterOptions(with: .failure(TestError.offline))
        try? await Task.sleep(for: .milliseconds(10))

        // THEN: State is failed
        #expect(viewModel2.filterOptions.isFailed)

        // WHEN: Retry succeeds
        viewModel2.loadFilterOptions()
        await client.waitForFilterOptions()
        await client.resolveFilterOptions(with: .success(retryExpected))
        try? await Task.sleep(for: .milliseconds(10))

        // THEN: Filter options are loaded
        #expect(viewModel2.filterOptions == .loaded(retryExpected))
    }

    @Test func `sheet dismiss triggers search only when query changed`() async {
        // GIVEN: View model with an initial search completed
        let client = ControlledAPIClient()
        let viewModel = SearchViewModel(apiClient: client)
        viewModel.search()
        await client.waitForSearch()
        await client.resolveSearch(with: .success([]))
        try? await Task.sleep(for: .milliseconds(10))

        // WHEN: Filters change and sheet is dismissed
        viewModel.query.dietaryAttributes.insert(.vegan)
        viewModel.onFilterSheetDismiss()

        // THEN: A new search is triggered
        await client.waitForSearch()
        await client.resolveSearch(with: .success([Recipe.preview]))
        try? await Task.sleep(for: .milliseconds(10))
        #expect(viewModel.results == .loaded([Recipe.preview]))
        #expect(viewModel.ingredientSearchText.isEmpty)

        // WHEN: Sheet is dismissed without changing the query
        viewModel.onFilterSheetDismiss()

        // THEN: Results stay the same (no new search)
        #expect(viewModel.results == .loaded([Recipe.preview]))
        #expect(viewModel.ingredientSearchText.isEmpty)
    }
}
```

**Step 2: Run tests to verify**

Run all tests via Xcode MCP. Expected: 4 tests in this suite, all pass.

**Step 3: Commit**

```
Rewrite SearchViewModelTests as flow tests
```

---

### Task 7: Rewrite RecipeDetailViewModelTests as flow tests

**Files:**
- Create: `JorcipesTests/RecipeDetailViewModelTests.swift`

**Step 1: Create RecipeDetailViewModelTests.swift**

Write the file with 2 flow tests combining the original 7 individual tests:

```swift
import Testing
@testable import JorcipesCards

@Suite("RecipeDetailViewModel Tests")
@MainActor
struct RecipeDetailViewModelTests {

    @Test func `instruction step progression from start to finish`() {
        // GIVEN: View model with 4 instructions
        let viewModel = RecipeDetailViewModel(instructionCount: 4)

        // THEN: Initial state has no highlighted step
        #expect(viewModel.highlightedStep == nil)
        #expect(viewModel.showCongratulations == false)
        #expect(viewModel.instructionButtonLabel == "Start")

        // WHEN: Start is tapped
        viewModel.advanceStep()

        // THEN: First step is highlighted
        #expect(viewModel.highlightedStep == 0)
        #expect(viewModel.instructionButtonLabel == "Next")

        // WHEN: Next is tapped twice
        viewModel.advanceStep()
        #expect(viewModel.highlightedStep == 1)
        viewModel.advanceStep()
        #expect(viewModel.highlightedStep == 2)
        #expect(viewModel.instructionButtonLabel == "Next")

        // WHEN: Next advances to last step
        viewModel.advanceStep()

        // THEN: Last step shows Finish
        #expect(viewModel.highlightedStep == 3)
        #expect(viewModel.instructionButtonLabel == "Finish")

        // WHEN: Finish is tapped
        viewModel.advanceStep()

        // THEN: State resets with congratulations
        #expect(viewModel.highlightedStep == nil)
        #expect(viewModel.showCongratulations == true)
        #expect(viewModel.instructionButtonLabel == "Start")
    }

    @Test func `selecting a step directly sets highlight`() {
        // GIVEN: View model with 5 instructions
        let viewModel = RecipeDetailViewModel(instructionCount: 5)

        // WHEN: Selecting step 3 directly
        viewModel.selectStep(3)

        // THEN: Step 3 is highlighted with Next label
        #expect(viewModel.highlightedStep == 3)
        #expect(viewModel.instructionButtonLabel == "Next")

        // WHEN: Selecting the last step directly
        viewModel.selectStep(4)

        // THEN: Last step shows Finish
        #expect(viewModel.instructionButtonLabel == "Finish")
    }
}
```

**Step 2: Run tests to verify**

Run all tests via Xcode MCP. Expected: 2 tests in this suite, all pass.

**Step 3: Commit**

```
Rewrite RecipeDetailViewModelTests as flow tests
```

---

### Task 8: Delete old JorcipesTests.swift and verify

**Files:**
- Delete: `JorcipesTests/JorcipesTests.swift`

**Step 1: Delete the old monolith test file**

```bash
git rm JorcipesTests/JorcipesTests.swift
```

The `TestError` enum also needs to be accessible from the new files. It was `private` in the old file. Move it to a shared helper.

**Step 2: Create shared TestError helper**

Create `JorcipesTests/Helpers/TestError.swift`:

```swift
enum TestError: Error {
    case offline
}
```

**Step 3: Run all tests**

Run all tests via Xcode MCP. Expected: all pass. Total test count should be:
- RecipeListViewModelTests: 3
- SearchViewModelTests: 4
- RecipeDetailViewModelTests: 2
- RecipeTests: 7 (was 10, removed 3)
- LocalAPIClientTests: 15

**Step 4: Commit**

```
Remove old monolith test file and add shared TestError helper
```

---

### Task 9: Final verification

**Step 1: Full build**

Build via Xcode MCP. Expected: clean build, no warnings.

**Step 2: Run all tests**

Run all tests via Xcode MCP. Expected: all pass.

**Step 3: Verify no remaining MockAPIClient references**

Search the entire codebase for `MockAPIClient`. Expected: zero results.

**Step 4: Verify no remaining short variable names**

Search for `let vm ` and `let s ` patterns. Expected: zero results.

**Step 5: Verify one @Suite per file**

Check that no test file has more than one `@Suite`. Expected: each file has exactly one.
