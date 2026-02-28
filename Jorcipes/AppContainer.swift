import JorcipesCore
import JorcipesNetworking
import JorcipesRecipeList
import JorcipesSearch

@MainActor
final class AppContainer {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func makeRecipeListViewModel() -> RecipeListViewModel {
        RecipeListViewModel(apiClient: apiClient)
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(apiClient: apiClient)
    }
}
