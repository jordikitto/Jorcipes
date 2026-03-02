import Testing
import Foundation
@testable import JorcipesNetworking
import JorcipesCore

@Suite("MockAPIClient Tests")
struct MockAPIClientTests {

    private func makeClient(jsonFileName: String = "recipes_5") -> MockAPIClient {
        MockAPIClient(jsonFileName: jsonFileName, simulateDelay: false)
    }

    // MARK: - Fetch

    @Test("Fetching recipes loads all recipes from JSON")
    func fetchAll() async throws {
        let client = makeClient()
        let recipes = try await client.fetchRecipes()
        #expect(recipes.count == 5)
    }

    @Test("Fetching from empty JSON returns empty array")
    func fetchEmpty() async throws {
        let client = makeClient(jsonFileName: "recipes_empty")
        let recipes = try await client.fetchRecipes()
        #expect(recipes.isEmpty)
    }

    @Test("Fetching from corrupted JSON throws decoding error")
    func fetchCorrupted() async {
        let client = makeClient(jsonFileName: "recipes_corrupted")
        await #expect(throws: (any Error).self) {
            try await client.fetchRecipes()
        }
    }

    @Test("Fetching from missing file throws APIError.fileNotFound")
    func fetchMissing() async {
        let client = makeClient(jsonFileName: "nonexistent")
        await #expect(throws: APIError.self) {
            try await client.fetchRecipes()
        }
    }

    // MARK: - Search: Text

    @Test("Search by title text returns matching recipes")
    func searchByTitle() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(text: "pizza")
        let results = try await client.searchRecipes(query: query)
        #expect(results.count == 1)
        #expect(results.first?.title.localizedStandardContains("pizza") == true)
    }

    @Test("Search with empty query returns all recipes")
    func searchEmptyQuery() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery()
        let results = try await client.searchRecipes(query: query)
        #expect(results.count == 5)
    }

    // MARK: - Search: Dietary

    @Test("Search by vegetarian returns only vegetarian recipes")
    func searchVegetarian() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(dietaryAttributes: [.vegetarian])
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy { $0.dietaryAttributes.contains(.vegetarian) })
        #expect(results.count == 3) // Margherita, Thai Curry, Risotto
    }

    @Test("Search by vegan returns only vegan recipes")
    func searchVegan() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(dietaryAttributes: [.vegan])
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy { $0.dietaryAttributes.contains(.vegan) })
        #expect(results.count == 1) // Thai Curry only
    }

    // MARK: - Search: Servings

    @Test("Search by servings returns matching recipes")
    func searchByServings() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(servings: 4)
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy { $0.servings == 4 })
    }

    // MARK: - Search: Ingredients

    @Test("Search with included ingredient returns recipes containing it")
    func searchIncludedIngredient() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(includedIngredients: ["chicken"])
        let results = try await client.searchRecipes(query: query)
        #expect(results.count == 1) // Caesar only
    }

    @Test("Search with excluded ingredient filters out recipes containing it")
    func searchExcludedIngredient() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(excludedIngredients: ["cheese", "parmesan"])
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy { recipe in
            !recipe.ingredients.contains { $0.name.localizedStandardContains("cheese") || $0.name.localizedStandardContains("parmesan") }
        })
    }

    // MARK: - Search: Combined Filters

    @Test("Search with multiple filters combines them with AND logic")
    func searchCombinedFilters() async throws {
        let client = makeClient()
        let query = RecipeSearchQuery(
            dietaryAttributes: [.vegetarian],
            servings: 4
        )
        let results = try await client.searchRecipes(query: query)
        #expect(results.allSatisfy {
            $0.dietaryAttributes.contains(.vegetarian) && $0.servings == 4
        })
    }

    // MARK: - Filter Options

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
}
