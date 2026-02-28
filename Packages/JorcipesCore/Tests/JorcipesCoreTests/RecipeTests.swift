import Foundation
import Testing
@testable import JorcipesCore

@Suite("Recipe Model Tests")
struct RecipeTests {

    // MARK: - Dietary Attribute Computation

    @Test("Recipe with all vegetarian ingredients is vegetarian")
    func allVegetarianIngredients() {
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
        #expect(recipe.dietaryAttributes.contains(.vegetarian))
        #expect(!recipe.dietaryAttributes.contains(.vegan))
    }

    @Test("Recipe with all vegan ingredients is both vegan and vegetarian")
    func allVeganIngredients() {
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
        #expect(recipe.dietaryAttributes.contains(.vegetarian))
        #expect(recipe.dietaryAttributes.contains(.vegan))
    }

    @Test("Recipe with mixed ingredients has no dietary attributes")
    func mixedIngredients() {
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
        #expect(recipe.dietaryAttributes.isEmpty)
    }

    @Test("Recipe with no ingredients has no dietary attributes")
    func emptyIngredients() {
        let recipe = Recipe(
            title: "Test",
            description: "Test",
            servings: 1,
            ingredients: [],
            instructions: []
        )
        #expect(recipe.dietaryAttributes.isEmpty)
    }

    // MARK: - Codable

    @Test("Recipe round-trips through JSON encoding and decoding")
    func codableRoundTrip() throws {
        let original = Recipe.preview
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Recipe.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.title == original.title)
        #expect(decoded.ingredients.count == original.ingredients.count)
        #expect(decoded.dietaryAttributes == original.dietaryAttributes)
    }

    @Test("Ingredient round-trips through JSON")
    func ingredientCodable() throws {
        let original = Ingredient(id: "test", name: "Test", quantity: "1 cup", dietaryAttributes: [.vegetarian, .vegan])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Ingredient.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - RecipeSearchQuery

    @Test("Empty query reports isEmpty as true")
    func emptyQuery() {
        let query = RecipeSearchQuery()
        #expect(query.isEmpty)
    }

    @Test("Query with text is not empty")
    func queryWithText() {
        let query = RecipeSearchQuery(text: "pizza")
        #expect(!query.isEmpty)
    }

    @Test("Query with dietary attributes is not empty")
    func queryWithDietary() {
        let query = RecipeSearchQuery(dietaryAttributes: [.vegan])
        #expect(!query.isEmpty)
    }

    // MARK: - Preview Data

    @Test("Preview list contains expected dietary distribution")
    func previewDietaryDistribution() {
        let recipes = Recipe.previewList
        let vegetarian = recipes.filter { $0.dietaryAttributes.contains(.vegetarian) }
        let vegan = recipes.filter { $0.dietaryAttributes.contains(.vegan) }
        let neither = recipes.filter { $0.dietaryAttributes.isEmpty }

        #expect(vegetarian.count == 3) // Margherita, Thai Curry, Risotto
        #expect(vegan.count == 1)      // Thai Curry only
        #expect(neither.count == 2)    // Caesar, Beef Tacos
    }
}
