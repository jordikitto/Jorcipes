public struct RecipeSearchQuery: Equatable, Sendable {
    public var text: String
    public var dietaryAttributes: Set<DietaryAttribute>
    public var servings: Int?
    public var includedIngredients: [String]
    public var excludedIngredients: [String]

    public init(
        text: String = "",
        dietaryAttributes: Set<DietaryAttribute> = [],
        servings: Int? = nil,
        includedIngredients: [String] = [],
        excludedIngredients: [String] = []
    ) {
        self.text = text
        self.dietaryAttributes = dietaryAttributes
        self.servings = servings
        self.includedIngredients = includedIngredients
        self.excludedIngredients = excludedIngredients
    }

    public var isEmpty: Bool {
        text.isEmpty && dietaryAttributes.isEmpty && servings == nil
            && includedIngredients.isEmpty && excludedIngredients.isEmpty
    }
}
