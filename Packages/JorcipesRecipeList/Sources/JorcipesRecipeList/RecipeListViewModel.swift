import Foundation
import JorcipesCore
import JorcipesNetworking

@MainActor
@Observable
public final class RecipeListViewModel {
    public private(set) var state: Loadable<[Recipe]> = .idle
    public var navigationPath: [RecipeDestination] = []

    private let apiClient: APIClient

    // nonisolated(unsafe) so deinit can cancel; Task.cancel() is thread-safe.
    @ObservationIgnored
    nonisolated(unsafe) private var loadTask: Task<Void, Never>?

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    /// Triggers an initial load if the state is idle. Called by the view on appear.
    public func onAppear() {
        guard case .idle = state else { return }
        load()
    }

    /// Cancels any in-flight fetch and starts a new one, driving the state through loading → loaded/failed.
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

    /// Awaitable refresh that keeps existing data visible while fetching. Used by SwiftUI's `.refreshable`.
    public func refresh() async {
        do {
            let recipes = try await apiClient.fetchRecipes()
            state = .loaded(recipes)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Pushes the given recipe onto the navigation path to show its detail view.
    public func didTapRecipe(_ recipe: Recipe) {
        navigationPath.append(.detail(recipe))
    }

    deinit {
        loadTask?.cancel()
    }
}
