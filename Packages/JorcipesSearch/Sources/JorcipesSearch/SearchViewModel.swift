import Foundation
import JorcipesCore
import JorcipesNetworking

@MainActor
@Observable
public final class SearchViewModel {
    public private(set) var results: Loadable<[Recipe]> = .idle
    public var query = RecipeSearchQuery()
    public var navigationPath: [RecipeDestination] = []
    public var ingredientInput: String = ""

    private let apiClient: APIClient
    nonisolated(unsafe) private var searchTask: Task<Void, Never>?

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func search() {
        searchTask?.cancel()

        guard !query.isEmpty else {
            results = .idle
            return
        }

        results = .loading

        searchTask = Task {
            do {
                // Debounce: wait 300ms before executing search.
                // If the user types again, this task gets cancelled.
                try await Task.sleep(for: .milliseconds(300))

                let recipes = try await apiClient.searchRecipes(query: query)
                try Task.checkCancellation()
                results = .loaded(recipes)
            } catch is CancellationError {
                // Ignore cancellation
            } catch {
                results = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Dietary Attributes

    public func toggleDietaryAttribute(_ attribute: DietaryAttribute) {
        if query.dietaryAttributes.contains(attribute) {
            query.dietaryAttributes.remove(attribute)
        } else {
            query.dietaryAttributes.insert(attribute)
        }
        search()
    }

    public func isDietaryAttributeActive(_ attribute: DietaryAttribute) -> Bool {
        query.dietaryAttributes.contains(attribute)
    }

    // MARK: - Servings

    public func setServings(_ servings: Int?) {
        query.servings = servings
        search()
    }

    // MARK: - Ingredient Chips

    public func addIncludedIngredient() {
        let trimmed = ingredientInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        query.includedIngredients.append(trimmed)
        ingredientInput = ""
        search()
    }

    public func toggleIngredientChip(at index: Int) {
        guard index < query.includedIngredients.count else { return }
        let ingredient = query.includedIngredients.remove(at: index)
        query.excludedIngredients.append(ingredient)
        search()
    }

    public func toggleExcludedIngredientChip(at index: Int) {
        guard index < query.excludedIngredients.count else { return }
        let ingredient = query.excludedIngredients.remove(at: index)
        query.includedIngredients.append(ingredient)
        search()
    }

    public func removeIncludedIngredient(at index: Int) {
        guard index < query.includedIngredients.count else { return }
        query.includedIngredients.remove(at: index)
        search()
    }

    public func removeExcludedIngredient(at index: Int) {
        guard index < query.excludedIngredients.count else { return }
        query.excludedIngredients.remove(at: index)
        search()
    }

    // MARK: - Navigation

    public func didTapRecipe(_ recipe: Recipe) {
        navigationPath.append(.detail(recipe))
    }

    // MARK: - Text Search

    public func updateSearchText(_ text: String) {
        query.text = text
        search()
    }

    deinit {
        searchTask?.cancel()
    }
}
