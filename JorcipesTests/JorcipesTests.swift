import Testing
import Foundation
@testable import JorcipesRecipeList
@testable import JorcipesSearch
import JorcipesCore
import JorcipesNetworking

@Suite("RecipeListViewModel Tests")
@MainActor
struct RecipeListViewModelTests {
    @Test("Initial state is idle")
    func initialState() {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        #expect(vm.state == .idle)
    }

    @Test("onAppear triggers loading state")
    func onAppearLoading() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        vm.onAppear()
        #expect(vm.state == .loading)
    }

    @Test("Successful load transitions to loaded")
    func loadSuccess() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let expected = Recipe.previewList

        vm.load()
        await client.waitForFetch()
        await client.resolveFetch(with: .success(expected))
        try? await Task.sleep(for: .milliseconds(10))

        #expect(vm.state == .loaded(expected))
    }

    @Test("Failed load transitions to failed")
    func loadFailure() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)

        vm.load()
        await client.waitForFetch()
        await client.resolveFetch(with: .failure(TestError.offline))
        try? await Task.sleep(for: .milliseconds(10))

        if case .failed = vm.state {
            // expected
        } else {
            Issue.record("Expected failed state, got \(vm.state)")
        }
    }

    @Test("onAppear does not reload if already loaded")
    func onAppearNoReload() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let recipes = Recipe.previewList

        vm.load()
        await client.waitForFetch()
        await client.resolveFetch(with: .success(recipes))
        try? await Task.sleep(for: .milliseconds(10))

        vm.onAppear()
        // State should still be loaded, not loading
        #expect(vm.state == .loaded(recipes))
    }

    @Test("didTapRecipe appends to navigation path")
    func didTapRecipe() {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let recipe = Recipe.preview

        vm.didTapRecipe(recipe)
        #expect(vm.navigationPath.count == 1)
    }

    @Test("Load cancellation prevents stale overwrite")
    func loadCancellationPreventsStaleOverwrite() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let stale = [Recipe.preview]
        let latest = Recipe.previewList

        vm.load() // request A
        await client.waitForFetch()
        vm.load() // request B cancels A

        // Wait for both continuations: A (stale, cancelled task) and B (new)
        await client.waitForFetch(count: 2)
        await client.resolveFetch(with: .success(stale))  // resolves A — cancelled, so ignored
        try? await Task.sleep(for: .milliseconds(10))
        await client.resolveFetch(with: .success(latest))  // resolves B
        try? await Task.sleep(for: .milliseconds(10))

        #expect(vm.state == .loaded(latest))
    }

    @Test("Refresh keeps existing data visible during fetch")
    func refreshKeepsData() async {
        let client = ControlledAPIClient()
        let vm = RecipeListViewModel(apiClient: client)
        let initial = Recipe.previewList

        // Load initial data
        vm.load()
        await client.waitForFetch()
        await client.resolveFetch(with: .success(initial))
        try? await Task.sleep(for: .milliseconds(10))
        #expect(vm.state == .loaded(initial))

        // Start refresh -- state should remain loaded (SwiftUI manages the spinner)
        let refreshed = [Recipe.preview]
        async let refreshTask: Void = vm.refresh()
        await client.waitForFetch()
        #expect(vm.state == .loaded(initial))

        await client.resolveFetch(with: .success(refreshed))
        await refreshTask
        #expect(vm.state == .loaded(refreshed))
    }
}

@Suite("SearchViewModel Tests")
@MainActor
struct SearchViewModelTests {
    @Test("Initial results state is idle")
    func initialState() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        #expect(vm.results == .idle)
    }

    @Test("Search with non-empty query triggers loading state")
    func searchLoading() async {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.text = "pizza"
        vm.search()
        #expect(vm.results == .loading)
    }

    @Test("Search with empty query still triggers loading")
    func searchEmpty() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query = RecipeSearchQuery()
        vm.search()
        #expect(vm.results == .loading)
    }

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

    @Test("Toggle dietary attribute adds and removes it")
    func toggleDietary() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)

        vm.toggleDietaryAttribute(.vegetarian)
        #expect(vm.query.dietaryAttributes.contains(.vegetarian))

        vm.toggleDietaryAttribute(.vegetarian)
        #expect(!vm.query.dietaryAttributes.contains(.vegetarian))
    }

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

    @Test("Search without debounce fires immediately")
    func searchNoDebounce() async {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.text = "pizza"
        vm.search()

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

        await client.waitForSearch()
        await client.resolveSearch(with: .success([Recipe.preview]))
        try? await Task.sleep(for: .milliseconds(10))

        #expect(vm.results == .loaded([Recipe.preview]))
        #expect(vm.ingredientSearchText.isEmpty)
    }
}

private enum TestError: Error {
    case offline
}
