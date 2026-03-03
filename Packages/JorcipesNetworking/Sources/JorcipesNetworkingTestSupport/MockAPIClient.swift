import JorcipesCore
import JorcipesNetworking

public actor MockAPIClient: APIClient {
    private var fetchContinuations: [CheckedContinuation<[Recipe], Error>] = []
    private var searchContinuations: [CheckedContinuation<[Recipe], Error>] = []
    private var filterOptionsContinuations: [CheckedContinuation<FilterOptions, Error>] = []

    public var fetchContinuationCount: Int { fetchContinuations.count }
    public var searchContinuationCount: Int { searchContinuations.count }
    public var filterOptionsContinuationCount: Int { filterOptionsContinuations.count }

    public init() {}

    public func fetchRecipes() async throws -> [Recipe] {
        try await withCheckedThrowingContinuation { continuation in
            fetchContinuations.append(continuation)
        }
    }

    public func searchRecipes(query: RecipeSearchQuery) async throws -> [Recipe] {
        try await withCheckedThrowingContinuation { continuation in
            searchContinuations.append(continuation)
        }
    }

    public func fetchFilterOptions() async throws -> FilterOptions {
        try await withCheckedThrowingContinuation { continuation in
            filterOptionsContinuations.append(continuation)
        }
    }

    /// Waits until at least `count` fetch continuations have been captured.
    public func waitForFetch(count: Int = 1) async {
        while fetchContinuations.count < count {
            await Task.yield()
        }
    }

    /// Waits until at least `count` search continuations have been captured.
    public func waitForSearch(count: Int = 1) async {
        while searchContinuations.count < count {
            await Task.yield()
        }
    }

    /// Waits until at least `count` filter options continuations have been captured.
    public func waitForFilterOptions(count: Int = 1) async {
        while filterOptionsContinuations.count < count {
            await Task.yield()
        }
    }

    public func resolveFetch(with result: Result<[Recipe], Error>) {
        guard !fetchContinuations.isEmpty else { return }
        let continuation = fetchContinuations.removeFirst()
        continuation.resume(with: result)
    }

    public func resolveSearch(with result: Result<[Recipe], Error>) {
        guard !searchContinuations.isEmpty else { return }
        let continuation = searchContinuations.removeFirst()
        continuation.resume(with: result)
    }

    public func resolveFilterOptions(with result: Result<FilterOptions, Error>) {
        guard !filterOptionsContinuations.isEmpty else { return }
        let continuation = filterOptionsContinuations.removeFirst()
        continuation.resume(with: result)
    }

    /// Waits for a fetch continuation, resolves it, then sleeps briefly for the caller to observe the result.
    public func completeFetch(with result: Result<[Recipe], Error>) async throws {
        await waitForFetch()
        resolveFetch(with: result)
        try await Task.sleep(for: .milliseconds(10))
    }

    /// Waits for a search continuation, resolves it, then sleeps briefly for the caller to observe the result.
    public func completeSearch(with result: Result<[Recipe], Error>) async throws {
        await waitForSearch()
        resolveSearch(with: result)
        try await Task.sleep(for: .milliseconds(10))
    }

    /// Waits for a filter-options continuation, resolves it, then sleeps briefly for the caller to observe the result.
    public func completeFilterOptions(with result: Result<FilterOptions, Error>) async throws {
        await waitForFilterOptions()
        resolveFilterOptions(with: result)
        try await Task.sleep(for: .milliseconds(10))
    }
}
