import JorcipesCore
import JorcipesNetworking

actor ControlledAPIClient: APIClient {
    private var fetchContinuations: [CheckedContinuation<[Recipe], Error>] = []
    private var searchContinuations: [CheckedContinuation<[Recipe], Error>] = []

    var fetchContinuationCount: Int { fetchContinuations.count }
    var searchContinuationCount: Int { searchContinuations.count }

    func fetchRecipes() async throws -> [Recipe] {
        try await withCheckedThrowingContinuation { continuation in
            fetchContinuations.append(continuation)
        }
    }

    func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe] {
        try await withCheckedThrowingContinuation { continuation in
            searchContinuations.append(continuation)
        }
    }

    /// Waits until at least `count` fetch continuations have been captured.
    func waitForFetch(count: Int = 1) async {
        while fetchContinuations.count < count {
            await Task.yield()
        }
    }

    /// Waits until at least `count` search continuations have been captured.
    func waitForSearch(count: Int = 1) async {
        while searchContinuations.count < count {
            await Task.yield()
        }
    }

    func resolveFetch(with result: Result<[Recipe], Error>) {
        guard !fetchContinuations.isEmpty else { return }
        let continuation = fetchContinuations.removeFirst()
        continuation.resume(with: result)
    }

    func resolveSearch(with result: Result<[Recipe], Error>) {
        guard !searchContinuations.isEmpty else { return }
        let continuation = searchContinuations.removeFirst()
        continuation.resume(with: result)
    }
}
