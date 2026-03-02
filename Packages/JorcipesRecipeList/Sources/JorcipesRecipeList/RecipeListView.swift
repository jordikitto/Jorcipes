import SwiftUI
import JorcipesCore
import JorcipesDesignSystem
import JorcipesCards
import JorcipesNetworking

public struct RecipeListView: View {
    @State private var viewModel: RecipeListViewModel
    @Namespace private var heroNamespace

    public init(viewModel: RecipeListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $viewModel.navigationPath) {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear

                case .loading:
                    ProgressView("Loading recipes...")

                case .loaded(let recipes):
                    if recipes.isEmpty {
                        ContentUnavailableView(
                            "No Recipes",
                            systemImage: "fork.knife",
                            description: Text("There are no recipes available at the moment.")
                        )
                    } else {
                        RecipeGridView(recipes: recipes, heroNamespace: heroNamespace)
                            .padding(.space400)
                    }

                case .failed(let message):
                    ContentUnavailableView {
                        Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try Again") {
                            viewModel.load()
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: RecipeDestination.self) { destination in
                switch destination {
                case .detail(let recipe):
                    RecipeDetailView(recipe: recipe)
                        .navigationTransition(.zoom(sourceID: recipe.id, in: heroNamespace))
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                viewModel.onAppear()
            }
        }
    }
}


#Preview {
    RecipeListView(
        viewModel: RecipeListViewModel(
            apiClient: MockAPIClient(simulateDelay: false)
        )
    )
}
