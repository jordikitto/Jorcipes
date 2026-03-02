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
            ScrollView {
                VStack(spacing: .space400) {
                    FilterSectionView(viewModel: viewModel)

                    Divider()

                    SearchResultsContent(
                        results: viewModel.results,
                        heroNamespace: heroNamespace,
                        onRetry: { viewModel.search() }
                    )
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query.text, prompt: "Search recipes...")
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .task {
                viewModel.loadFilterOptions()
            }
            .sheet(item: $viewModel.activeSheet, onDismiss: {
                viewModel.onFilterSheetDismiss()
            }) { sheet in
                switch sheet {
                case .dietary:
                    DietaryFilterSheet(viewModel: viewModel)
                        .presentationDetents([.medium])
                case .servings:
                    ServingsFilterSheet(viewModel: viewModel)
                        .presentationDetents([.medium])
                case .includedIngredients:
                    IngredientFilterSheet(
                        title: "Included Ingredients",
                        viewModel: viewModel,
                        isIncluded: true
                    )
                    .presentationDetents([.medium])
                case .excludedIngredients:
                    IngredientFilterSheet(
                        title: "Excluded Ingredients",
                        viewModel: viewModel,
                        isIncluded: false
                    )
                    .presentationDetents([.medium])
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
        case .idle:
            ContentUnavailableView(
                "Search Recipes",
                systemImage: "magnifyingglass",
                description: Text("Use the filters above or type a search term to find recipes.")
            )

        case .loading:
            ProgressView("Searching...")
                .padding()

        case .loaded(let recipes):
            if recipes.isEmpty {
                ContentUnavailableView.search
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: .space400) {
                    ForEach(recipes) { recipe in
                        NavigationLink(value: RecipeDestination.detail(recipe)) {
                            RecipeCardView(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: recipe.id, in: heroNamespace)
                    }
                }
                .padding(.horizontal, .space400)
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
            apiClient: MockAPIClient(simulateDelay: false)
        )
    )
}
