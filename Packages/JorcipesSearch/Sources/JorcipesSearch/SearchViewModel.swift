import Foundation
import JorcipesCore
import JorcipesNetworking

public enum FilterSheet: Identifiable {
    case dietary
    case servings
    case includedIngredients
    case excludedIngredients

    public var id: Self { self }
}

@MainActor
@Observable
public final class SearchViewModel {
    public private(set) var results: Loadable<[Recipe]> = .idle
    public private(set) var filterOptions: Loadable<FilterOptions> = .idle
    public var query = RecipeSearchQuery()
    public var navigationPath: [RecipeDestination] = []
    public var filtersExpanded = false
    public var activeSheet: FilterSheet?
    public var ingredientSearchText = ""

    private let apiClient: APIClient

    @ObservationIgnored
    nonisolated(unsafe) private var searchTask: Task<Void, Never>?

    @ObservationIgnored
    nonisolated(unsafe) private var filterOptionsTask: Task<Void, Never>?

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Filter Options

    public func loadFilterOptions() {
        guard filterOptions == .idle || filterOptions.isFailed else { return }
        filterOptions = .loading

        filterOptionsTask = Task {
            do {
                let options = try await apiClient.fetchFilterOptions()
                try Task.checkCancellation()
                filterOptions = .loaded(options)
            } catch is CancellationError {
                // Ignore
            } catch {
                filterOptions = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Search

    public func search() {
        searchTask?.cancel()

        results = .loading

        searchTask = Task {
            do {
                let recipes = try await apiClient.searchRecipes(query: query)
                try Task.checkCancellation()
                results = .loaded(recipes)
            } catch is CancellationError {
                // Ignore
            } catch {
                results = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Filter State

    public var activeFilterCount: Int {
        var count = 0
        if !query.dietaryAttributes.isEmpty { count += 1 }
        if query.servings != nil { count += 1 }
        if !query.includedIngredients.isEmpty { count += 1 }
        if !query.excludedIngredients.isEmpty { count += 1 }
        return count
    }

    // MARK: - Dietary Attributes

    public func toggleDietaryAttribute(_ attribute: DietaryAttribute) {
        if query.dietaryAttributes.contains(attribute) {
            query.dietaryAttributes.remove(attribute)
        } else {
            query.dietaryAttributes.insert(attribute)
        }
    }

    public func isDietaryAttributeActive(_ attribute: DietaryAttribute) -> Bool {
        query.dietaryAttributes.contains(attribute)
    }

    // MARK: - Servings

    public func setServings(_ servings: Int?) {
        query.servings = servings
    }

    // MARK: - Ingredients

    public func toggleIncludedIngredient(_ name: String) {
        if let index = query.includedIngredients.firstIndex(of: name) {
            query.includedIngredients.remove(at: index)
        } else {
            query.includedIngredients.append(name)
        }
    }

    public func toggleExcludedIngredient(_ name: String) {
        if let index = query.excludedIngredients.firstIndex(of: name) {
            query.excludedIngredients.remove(at: index)
        } else {
            query.excludedIngredients.append(name)
        }
    }

    public func isIngredientIncluded(_ name: String) -> Bool {
        query.includedIngredients.contains(name)
    }

    public func isIngredientExcluded(_ name: String) -> Bool {
        query.excludedIngredients.contains(name)
    }

    // MARK: - Sheet Dismissal

    /// Called when any filter sheet is dismissed. Clears ingredient search text
    /// and triggers a new search so filter changes take effect on results.
    public func onFilterSheetDismiss() {
        ingredientSearchText = ""
        search()
    }

    // MARK: - Navigation

    public func didTapRecipe(_ recipe: Recipe) {
        navigationPath.append(.detail(recipe))
    }

    deinit {
        searchTask?.cancel()
        filterOptionsTask?.cancel()
    }
}
