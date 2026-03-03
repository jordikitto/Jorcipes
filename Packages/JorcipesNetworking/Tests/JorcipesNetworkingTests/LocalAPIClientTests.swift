import Testing
import Foundation
@testable import JorcipesNetworking
import JorcipesCore

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

    @Test func `search by description text returns matching recipes`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Searching for a term only found in a description
        let query = RecipeSearchQuery(text: "fragrant")
        let results = try await client.searchRecipes(query: query)

        // THEN: The Thai Green Curry is returned (its description contains "fragrant")
        #expect(results.count == 1)
        #expect(results.first?.title.localizedStandardContains("curry") == true)
    }

    @Test func `search by ingredient name returns matching recipes`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Searching for an ingredient name not in any title or description
        let query = RecipeSearchQuery(text: "arborio")
        let results = try await client.searchRecipes(query: query)

        // THEN: The Mushroom Risotto is returned (it has "Arborio Rice" as an ingredient)
        #expect(results.count == 1)
        #expect(results.first?.title.localizedStandardContains("risotto") == true)
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

    // MARK: - Search: Instructions

    @Test func `search by instruction text returns matching recipes`() async throws {
        // GIVEN: A client with recipe data
        let client = makeClient()

        // WHEN: Searching by instruction text
        let query = RecipeSearchQuery(instructionText: "preheat")
        let results = try await client.searchRecipes(query: query)

        // THEN: Only the pizza recipe is returned (its instructions mention "Preheat")
        #expect(results.count == 1)
        #expect(results.first?.title.localizedStandardContains("pizza") == true)
    }

    // MARK: - Filter Options

    @Test func `fetchFilterOptions returns sorted unique servings and ingredients`() async throws {
        // GIVEN: A client with 5 recipes
        let client = makeClient()

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
        let client = makeClient(jsonFileName: "recipes_empty")

        // WHEN: Fetching filter options
        let options = try await client.fetchFilterOptions()

        // THEN: Both lists are empty
        #expect(options.availableServings.isEmpty)
        #expect(options.availableIngredients.isEmpty)
    }

    @Test func `fetchFilterOptions throws for corrupted JSON`() async {
        // GIVEN: A client with corrupted JSON
        let client = makeClient(jsonFileName: "recipes_corrupted")

        // WHEN/THEN: Fetching throws an error
        await #expect(throws: (any Error).self) {
            try await client.fetchFilterOptions()
        }
    }
}
