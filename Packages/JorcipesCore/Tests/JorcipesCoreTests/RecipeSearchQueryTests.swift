import Foundation
import Testing
@testable import JorcipesCore

@Suite("RecipeSearchQuery Tests")
struct RecipeSearchQueryTests {

    // MARK: - isEmpty

    @Test func `default query is empty`() {
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

    @Test func `query with servings is not empty`() {
        // GIVEN: A query with a servings filter
        let query = RecipeSearchQuery(servings: 4)

        // THEN: Query is not empty
        #expect(!query.isEmpty)
    }

    @Test func `query with included ingredients is not empty`() {
        // GIVEN: A query with included ingredients
        let query = RecipeSearchQuery(includedIngredients: ["tomato"])

        // THEN: Query is not empty
        #expect(!query.isEmpty)
    }

    @Test func `query with excluded ingredients is not empty`() {
        // GIVEN: A query with excluded ingredients
        let query = RecipeSearchQuery(excludedIngredients: ["peanuts"])

        // THEN: Query is not empty
        #expect(!query.isEmpty)
    }

    @Test func `query with instruction text is not empty`() {
        // GIVEN: A query with instruction text
        let query = RecipeSearchQuery(instructionText: "bake")

        // THEN: Query is not empty
        #expect(!query.isEmpty)
    }
}
