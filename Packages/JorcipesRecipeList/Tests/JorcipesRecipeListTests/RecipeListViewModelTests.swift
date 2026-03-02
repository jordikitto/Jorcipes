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
