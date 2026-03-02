import Foundation
import JorcipesCore

public final class MockAPIClient: APIClient, @unchecked Sendable {
    private let jsonFileName: String
    private let bundle: Bundle
    private let simulateDelay: Bool

    public init(jsonFileName: String = "recipes_5", bundle: Bundle? = nil, simulateDelay: Bool = true) {
        self.jsonFileName = jsonFileName
        self.bundle = bundle ?? .module
        self.simulateDelay = simulateDelay
    }

    public func fetchRecipes() async throws -> [Recipe] {
        if simulateDelay {
            try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))
        }
        return try await loadRecipes()
    }

    public func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe] {
        if simulateDelay {
            try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))
        }

        let allRecipes = try await loadRecipes()

        guard !query.isEmpty else { return allRecipes }

        return allRecipes.filter { recipe in
            matchesText(recipe: recipe, text: query.text)
                && matchesDietary(recipe: recipe, attributes: query.dietaryAttributes)
                && matchesServings(recipe: recipe, servings: query.servings)
                && matchesIncludedIngredients(recipe: recipe, included: query.includedIngredients)
                && matchesExcludedIngredients(recipe: recipe, excluded: query.excludedIngredients)
        }
    }

    public func fetchFilterOptions() async throws -> FilterOptions {
        if simulateDelay {
            try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))
        }

        let recipes = try await loadRecipes()

        let servings = Array(Set(recipes.map(\.servings))).sorted()
        let ingredients = Array(Set(recipes.flatMap { $0.ingredients.map(\.name) })).sorted()

        return FilterOptions(availableServings: servings, availableIngredients: ingredients)
    }

    // MARK: - Private

    /// Loads and decodes recipes off the main actor to avoid UI hitching.
    private nonisolated func loadRecipes() async throws -> [Recipe] {
        let jsonFileName = self.jsonFileName
        let bundle = self.bundle
        guard let url = bundle.url(forResource: jsonFileName, withExtension: "json") else {
            throw APIError.fileNotFound(jsonFileName)
        }
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(RecipesResponse.self, from: data)
        return response.recipes.sorted(using: SortDescriptor(\.title))
    }

    private func matchesText(recipe: Recipe, text: String) -> Bool {
        guard !text.isEmpty else { return true }
        return recipe.title.localizedStandardContains(text)
            || recipe.description.localizedStandardContains(text)
            || recipe.ingredients.contains { $0.name.localizedStandardContains(text) }
    }

    private func matchesDietary(recipe: Recipe, attributes: Set<DietaryAttribute>) -> Bool {
        guard !attributes.isEmpty else { return true }
        return attributes.isSubset(of: recipe.dietaryAttributes)
    }

    private func matchesServings(recipe: Recipe, servings: Int?) -> Bool {
        guard let servings else { return true }
        return recipe.servings == servings
    }

    private func matchesIncludedIngredients(recipe: Recipe, included: [String]) -> Bool {
        guard !included.isEmpty else { return true }
        return included.allSatisfy { term in
            recipe.ingredients.contains { $0.name.localizedStandardContains(term) }
        }
    }

    private func matchesExcludedIngredients(recipe: Recipe, excluded: [String]) -> Bool {
        guard !excluded.isEmpty else { return true }
        return !excluded.contains { term in
            recipe.ingredients.contains { $0.name.localizedStandardContains(term) }
        }
    }
}

public enum APIError: LocalizedError, Sendable {
    case fileNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            "Could not find resource file: \(name).json"
        }
    }
}
