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

    @Test("Search with empty query resets to idle")
    func searchEmpty() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query = RecipeSearchQuery()
        vm.search()
        #expect(vm.results == .idle)
    }

    @Test("Successful search transitions to loaded")
    func searchSuccess() async {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.text = "test"
        let expected = [Recipe.preview]

        vm.search()

        // Wait for the debounce to pass and the API call to be made
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

    @Test("Adding included ingredient clears input and adds to query")
    func addIngredient() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.ingredientInput = "  chicken  "

        vm.addIncludedIngredient()
        #expect(vm.query.includedIngredients == ["chicken"])
        #expect(vm.ingredientInput.isEmpty)
    }

    @Test("Toggle included ingredient moves it to excluded")
    func toggleIncludedToExcluded() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.includedIngredients = ["chicken"]

        vm.toggleIngredientChip(at: 0)
        #expect(vm.query.includedIngredients.isEmpty)
        #expect(vm.query.excludedIngredients == ["chicken"])
    }

    @Test("Toggle excluded ingredient moves it to included")
    func toggleExcludedToIncluded() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.excludedIngredients = ["chicken"]

        vm.toggleExcludedIngredientChip(at: 0)
        #expect(vm.query.excludedIngredients.isEmpty)
        #expect(vm.query.includedIngredients == ["chicken"])
    }

    @Test("Adding whitespace-only ingredient is ignored")
    func addWhitespaceIngredient() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.ingredientInput = "   "

        vm.addIncludedIngredient()
        #expect(vm.query.includedIngredients.isEmpty)
    }

    @Test("Toggle ingredient at out-of-bounds index is safe")
    func toggleOutOfBounds() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.includedIngredients = ["chicken"]

        vm.toggleIngredientChip(at: 5)
        #expect(vm.query.includedIngredients == ["chicken"])
    }

    @Test("Remove ingredient at valid index removes it")
    func removeIngredient() {
        let client = ControlledAPIClient()
        let vm = SearchViewModel(apiClient: client)
        vm.query.includedIngredients = ["chicken", "beef"]

        vm.removeIncludedIngredient(at: 0)
        #expect(vm.query.includedIngredients == ["beef"])
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

        // Wait for the debounce to pass and the API call to be made
        await client.waitForSearch()

        // The first search task was cancelled, so only one continuation should be pending
        await client.resolveSearch(with: .success(latest))
        try? await Task.sleep(for: .milliseconds(10))

        #expect(vm.results == .loaded(latest))
    }
}

private enum TestError: Error {
    case offline
}
