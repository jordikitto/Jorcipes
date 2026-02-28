import Foundation
import JorcipesCore
import JorcipesNetworking

@MainActor
@Observable
public final class RecipeListViewModel {
    public private(set) var state: Loadable<[Recipe]> = .idle
    public var navigationPath: [RecipeDestination] = []

    private let apiClient: APIClient
    private var loadTask: Task<Void, Never>?

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func onAppear() {
        guard case .idle = state else { return }
        load()
    }

    public func load() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let recipes = try await apiClient.fetchRecipes()
                try Task.checkCancellation()
                state = .loaded(recipes)
            } catch is CancellationError {
                // Ignore cancellation
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    public func refresh() async {
        do {
            let recipes = try await apiClient.fetchRecipes()
            state = .loaded(recipes)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    public func didTapRecipe(_ recipe: Recipe) {
        navigationPath.append(.detail(recipe))
    }

    deinit {
        loadTask?.cancel()
    }
}
