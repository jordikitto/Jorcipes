public struct FilterOptions: Equatable, Sendable {
    public let availableServings: [Int]
    public let availableIngredients: [String]

    public init(availableServings: [Int], availableIngredients: [String]) {
        self.availableServings = availableServings
        self.availableIngredients = availableIngredients
    }
}
