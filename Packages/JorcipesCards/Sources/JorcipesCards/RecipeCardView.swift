import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct RecipeCardView: View {
    let recipe: Recipe

    public init(recipe: Recipe) {
        self.recipe = recipe
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                .fill(Color.recipeSecondary.opacity(0.2))
                .aspectRatio(4 / 3, contentMode: .fill)
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundStyle(Color.recipeSecondary)
                }

            VStack(alignment: .leading, spacing: .space100) {
                DietaryBadgesView(attributes: Array(recipe.dietaryAttributes))

                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer(minLength: 0)

                Label("\(recipe.servings)", systemImage: "person.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, .space200)
            .padding(.bottom, .space300)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: .cornerRadiusLarge))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

#Preview {
    ScrollView {
        RecipeCardView(recipe: .preview)
            .padding()
    }
}
