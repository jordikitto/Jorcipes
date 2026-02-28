import Foundation

public struct Recipe: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String
    public let servings: Int
    public let ingredients: [Ingredient]
    public let instructions: [String]

    public var dietaryAttributes: Set<DietaryAttribute> {
        guard !ingredients.isEmpty else { return [] }
        return DietaryAttribute.allCases.reduce(into: Set<DietaryAttribute>()) { result, attribute in
            if ingredients.allSatisfy({ $0.dietaryAttributes.contains(attribute) }) {
                result.insert(attribute)
            }
        }
    }

    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        servings: Int,
        ingredients: [Ingredient],
        instructions: [String]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.servings = servings
        self.ingredients = ingredients
        self.instructions = instructions
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, servings, ingredients, instructions
    }
}
