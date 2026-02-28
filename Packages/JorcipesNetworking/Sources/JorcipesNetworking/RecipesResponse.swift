import JorcipesCore

struct RecipesResponse: Codable, Sendable {
    let recipes: [Recipe]
}
