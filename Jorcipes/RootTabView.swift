import SwiftUI
import JorcipesRecipeList
import JorcipesSearch
import JorcipesNetworking
import JorcipesDesignSystem

struct RootTabView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            Tab("Recipes", systemImage: "book") {
                RecipeListView(viewModel: container.makeRecipeListViewModel())
                    .background(.recipeBackground)
            }

            Tab("Dev", systemImage: "hammer") {
                DevSettingsView()
                    .background(.recipeBackground)
            }

            Tab(role: .search) {
                SearchView(viewModel: container.makeSearchViewModel())
                    .background(.recipeBackground)
            }
        }
    }
}

#Preview {
    RootTabView(container: AppContainer(apiClient: LocalAPIClient(simulateDelay: false)))
}
