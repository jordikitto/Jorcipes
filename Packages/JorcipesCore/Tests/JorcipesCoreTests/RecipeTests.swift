import Foundation
import Testing
@testable import JorcipesCore

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
