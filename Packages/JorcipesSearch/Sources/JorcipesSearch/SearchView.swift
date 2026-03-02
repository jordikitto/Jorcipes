import SwiftUI
import JorcipesCore
import JorcipesDesignSystem
import JorcipesCards
import JorcipesNetworking

public struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @Namespace private var heroNamespace

    public init(viewModel: SearchViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $viewModel.navigationPath) {
            VStack(spacing: 0) {
                SearchResultsContent(
                    results: viewModel.results,
                    heroNamespace: heroNamespace,
                    onRetry: { viewModel.search() }
                )
                .frame(maxHeight: .infinity)
                .safeAreaBar(edge: .top) {
                    FilterSectionView(viewModel: viewModel)
                        .frame(maxWidth: 660, alignment: .center) // For iPad reading
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query.text, prompt: "Search recipes...")
            .onChange(of: viewModel.query.text) {
                viewModel.debouncedSearch()
            }
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .task {
                viewModel.loadFilterOptions()
                viewModel.search()
            }
            .sheet(item: $viewModel.activeSheet, onDismiss: {
                viewModel.onFilterSheetDismiss()
            }) { sheet in
                switch sheet {
                case .dietary:
                    DietaryFilterSheet(viewModel: viewModel)
                case .servings:
                    ServingsFilterSheet(viewModel: viewModel)
                case .includedIngredients:
                    IngredientFilterSheet(
                        title: "Included Ingredients",
                        viewModel: viewModel,
                        isIncluded: true
                    )
                case .excludedIngredients:
                    IngredientFilterSheet(
                        title: "Excluded Ingredients",
                        viewModel: viewModel,
                        isIncluded: false
                    )
                case .instructions:
                    InstructionsFilterSheet(viewModel: viewModel)
                }
            }
            .navigationDestination(for: RecipeDestination.self) { destination in
                switch destination {
                case .detail(let recipe):
                    RecipeDetailView(recipe: recipe)
                        .navigationTransition(.zoom(sourceID: recipe.id, in: heroNamespace))
                }
            }
        }
    }
}

struct SearchResultsContent: View {
    let results: Loadable<[Recipe]>
    var heroNamespace: Namespace.ID
    let onRetry: () -> Void

    var body: some View {
        switch results {
        case .idle, .loading:
            ProgressView("Loading recipes...")

        case .loaded(let recipes):
            if recipes.isEmpty {
                ContentUnavailableView.search
            } else {
                RecipeGridView(recipes: recipes, heroNamespace: heroNamespace)
            }

        case .failed(let message):
            ContentUnavailableView {
                Label("Search Failed", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again", action: onRetry)
            }
        }
    }
}

#Preview {
    SearchView(
        viewModel: SearchViewModel(
            apiClient: LocalAPIClient(simulateDelay: false)
        )
    )
}
