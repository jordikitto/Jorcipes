import Testing
import Foundation
@testable import JorcipesSearch
import JorcipesCore
import JorcipesNetworkingTestSupport

@Suite("SearchViewModel Tests")
@MainActor
struct SearchViewModelTests {

    @Test func `search flow from idle through loading to loaded`() async throws {
        // GIVEN: View model initialised
        let client = MockAPIClient()
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
        try await Task.sleep(for: .milliseconds(10))

        // THEN: State is loaded with results
        #expect(viewModel.results == .loaded(expected))

        // GIVEN: A fresh view model for empty query test
        let viewModel2 = SearchViewModel(apiClient: client)

        // WHEN: Search with empty query
        viewModel2.query = RecipeSearchQuery()
        viewModel2.search()

        // THEN: Still triggers loading
        #expect(viewModel2.results == .loading)

        // Resolve viewModel2's search so it doesn't pollute later assertions
        await client.waitForSearch()
        await client.resolveSearch(with: .success([]))
        try await Task.sleep(for: .milliseconds(10))

        // GIVEN: A fresh view model for cancellation test
        let viewModel3 = SearchViewModel(apiClient: client)
        let stale = [Recipe.preview]
        let latest = Recipe.previewList

        // WHEN: Two searches fire in quick succession (B cancels A)
        viewModel3.query.text = "old"
        viewModel3.search()
        await client.waitForSearch()
        viewModel3.query.text = "new"
        viewModel3.search()

        // WHEN: Stale response arrives (cancelled), then latest
        await client.waitForSearch(count: 2)
        await client.resolveSearch(with: .success(stale))
        try await Task.sleep(for: .milliseconds(10))
        await client.resolveSearch(with: .success(latest))
        try await Task.sleep(for: .milliseconds(10))

        // THEN: Only latest results are used
        #expect(viewModel3.results == .loaded(latest))
    }

    @Test func `filter manipulation updates query state`() {
        // GIVEN: View model initialised
        let client = MockAPIClient()
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

    @Test func `filter options load and retry from failure`() async throws {
        // GIVEN: View model initialised
        let client = MockAPIClient()
        let viewModel = SearchViewModel(apiClient: client)
        let expected = FilterOptions(availableServings: [2, 4], availableIngredients: ["Chicken", "Tofu"])

        // WHEN: Loading filter options succeeds
        viewModel.loadFilterOptions()
        await client.waitForFilterOptions()
        await client.resolveFilterOptions(with: .success(expected))
        try await Task.sleep(for: .milliseconds(10))

        // THEN: Filter options are loaded
        #expect(viewModel.filterOptions == .loaded(expected))

        // GIVEN: A fresh view model for retry test
        let viewModel2 = SearchViewModel(apiClient: client)
        let retryExpected = FilterOptions(availableServings: [2, 4], availableIngredients: ["Chicken"])

        // WHEN: First attempt fails
        viewModel2.loadFilterOptions()
        await client.waitForFilterOptions()
        await client.resolveFilterOptions(with: .failure(TestError.offline))
        try await Task.sleep(for: .milliseconds(10))

        // THEN: State is failed
        #expect(viewModel2.filterOptions.isFailed)

        // WHEN: Retry succeeds
        viewModel2.loadFilterOptions()
        await client.waitForFilterOptions()
        await client.resolveFilterOptions(with: .success(retryExpected))
        try await Task.sleep(for: .milliseconds(10))

        // THEN: Filter options are loaded
        #expect(viewModel2.filterOptions == .loaded(retryExpected))
    }

    @Test func `sheet dismiss triggers search only when query changed`() async throws {
        // GIVEN: View model with an initial search completed
        let client = MockAPIClient()
        let viewModel = SearchViewModel(apiClient: client)
        viewModel.search()
        await client.waitForSearch()
        await client.resolveSearch(with: .success([]))
        try await Task.sleep(for: .milliseconds(10))

        // WHEN: Filters change and sheet is dismissed
        viewModel.query.dietaryAttributes.insert(.vegan)
        viewModel.onFilterSheetDismiss()

        // THEN: A new search is triggered
        await client.waitForSearch()
        await client.resolveSearch(with: .success([Recipe.preview]))
        try await Task.sleep(for: .milliseconds(10))
        #expect(viewModel.results == .loaded([Recipe.preview]))
        #expect(viewModel.ingredientSearchText.isEmpty)

        // WHEN: Sheet is dismissed without changing the query
        viewModel.onFilterSheetDismiss()

        // THEN: Results stay the same (no new search)
        #expect(viewModel.results == .loaded([Recipe.preview]))
        #expect(viewModel.ingredientSearchText.isEmpty)
    }
}
