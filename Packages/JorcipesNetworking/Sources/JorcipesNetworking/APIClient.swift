import JorcipesCore

public protocol APIClient: Sendable {
    func fetchRecipes() async throws -> [Recipe]
    func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe]
}
