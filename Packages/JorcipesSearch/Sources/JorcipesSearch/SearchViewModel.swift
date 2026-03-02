import Foundation
import JorcipesCore
import JorcipesNetworking

public enum FilterSheet: Identifiable {
    case dietary
    case servings
    case includedIngredients
    case excludedIngredients
    case instructions

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
    nonisolated(unsafe) private var debouncedSearchTask: Task<Void, Never>?

    @ObservationIgnored
    nonisolated(unsafe) private var filterOptionsTask: Task<Void, Never>?

    private var lastSearchedQuery: RecipeSearchQuery?

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Filter Options

    /// Fetches available filter options from the API. Only runs from idle or failed state.
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

    /// Cancels any pending search and starts a new one immediately if the query has changed.
    public func search() {
        guard query != lastSearchedQuery else { return }

        debouncedSearchTask?.cancel()
        searchTask?.cancel()
        results = .loading

        searchTask = Task {
            do {
                let recipes = try await apiClient.searchRecipes(query: query)
                try Task.checkCancellation()
                results = .loaded(recipes)
                lastSearchedQuery = query
            } catch is CancellationError {
                // Ignore
            } catch {
                results = .failed(error.localizedDescription)
            }
        }
    }

    /// Schedules a search after a 300ms debounce. Cancels any previously scheduled debounced search.
    public func debouncedSearch() {
        debouncedSearchTask?.cancel()
        debouncedSearchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            search()
        }
    }

    // MARK: - Filter State

    public var activeFilterCount: Int {
        var count = 0
        if !query.dietaryAttributes.isEmpty { count += 1 }
        if query.servings != nil { count += 1 }
        if !query.includedIngredients.isEmpty { count += 1 }
        if !query.excludedIngredients.isEmpty { count += 1 }
        if !query.instructionText.isEmpty { count += 1 }
        return count
    }

    // MARK: - Dietary Attributes

    /// Toggles the given dietary attribute in or out of the search query.
    public func toggleDietaryAttribute(_ attribute: DietaryAttribute) {
        if query.dietaryAttributes.contains(attribute) {
            query.dietaryAttributes.remove(attribute)
        } else {
            query.dietaryAttributes.insert(attribute)
        }
    }

    /// Returns whether the given dietary attribute is currently active in the search query.
    public func isDietaryAttributeActive(_ attribute: DietaryAttribute) -> Bool {
        query.dietaryAttributes.contains(attribute)
    }

    // MARK: - Servings

    /// Sets the servings filter to the given value, or clears it if nil.
    public func setServings(_ servings: Int?) {
        query.servings = servings
    }

    // MARK: - Ingredients

    /// Toggles the given ingredient in or out of the included ingredients list.
    public func toggleIncludedIngredient(_ name: String) {
        if let index = query.includedIngredients.firstIndex(of: name) {
            query.includedIngredients.remove(at: index)
        } else {
            query.includedIngredients.append(name)
        }
    }

    /// Toggles the given ingredient in or out of the excluded ingredients list.
    public func toggleExcludedIngredient(_ name: String) {
        if let index = query.excludedIngredients.firstIndex(of: name) {
            query.excludedIngredients.remove(at: index)
        } else {
            query.excludedIngredients.append(name)
        }
    }

    /// Returns whether the given ingredient is in the included list.
    public func isIngredientIncluded(_ name: String) -> Bool {
        query.includedIngredients.contains(name)
    }

    /// Returns whether the given ingredient is in the excluded list.
    public func isIngredientExcluded(_ name: String) -> Bool {
        query.excludedIngredients.contains(name)
    }

    // MARK: - Clear Filters

    /// Removes all dietary attribute filters from the search query.
    public func clearDietaryAttributes() {
        query.dietaryAttributes.removeAll()
    }

    /// Removes the servings filter from the search query.
    public func clearServings() {
        query.servings = nil
    }

    /// Removes all included ingredient filters from the search query.
    public func clearIncludedIngredients() {
        query.includedIngredients.removeAll()
    }

    /// Removes all excluded ingredient filters from the search query.
    public func clearExcludedIngredients() {
        query.excludedIngredients.removeAll()
    }

    /// Clears the instruction text filter from the search query.
    public func clearInstructionText() {
        query.instructionText = ""
    }

    // MARK: - Sheet Dismissal

    /// Called when any filter sheet is dismissed. Clears ingredient search text
    /// and triggers a new search so filter changes take effect on results.
    public func onFilterSheetDismiss() {
        ingredientSearchText = ""
        search()
    }

    // MARK: - Navigation

    /// Pushes the given recipe onto the navigation path to show its detail view.
    public func didTapRecipe(_ recipe: Recipe) {
        navigationPath.append(.detail(recipe))
    }

    deinit {
        searchTask?.cancel()
        debouncedSearchTask?.cancel()
        filterOptionsTask?.cancel()
    }
}
