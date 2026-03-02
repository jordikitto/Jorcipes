import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct RecipeGridView: View {
    @ScaledMetric private var minimumColumnWidth = 160

    let recipes: [Recipe]
    var heroNamespace: Namespace.ID

    public init(recipes: [Recipe], heroNamespace: Namespace.ID) {
        self.recipes = recipes
        self.heroNamespace = heroNamespace
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: minimumColumnWidth))],
                spacing: .space400
            ) {
                ForEach(recipes) { recipe in
                    NavigationLink(value: RecipeDestination.detail(recipe)) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: recipe.id, in: heroNamespace)
                }
            }
        }
    }
}
