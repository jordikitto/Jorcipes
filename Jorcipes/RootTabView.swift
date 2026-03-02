import SwiftUI
import JorcipesRecipeList
import JorcipesSearch
import JorcipesNetworking

struct RootTabView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            Tab("Recipes", systemImage: "book") {
                RecipeListView(viewModel: container.makeRecipeListViewModel())
            }

            Tab(role: .search) {
                SearchView(viewModel: container.makeSearchViewModel())
            }
        }
    }
}

#Preview {
    RootTabView(container: AppContainer(apiClient: MockAPIClient(simulateDelay: false)))
}
