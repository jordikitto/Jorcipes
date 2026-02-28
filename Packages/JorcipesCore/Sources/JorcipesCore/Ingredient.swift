public struct Ingredient: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let quantity: String
    public let dietaryAttributes: Set<DietaryAttribute>

    public init(id: String, name: String, quantity: String, dietaryAttributes: Set<DietaryAttribute>) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.dietaryAttributes = dietaryAttributes
    }
}
