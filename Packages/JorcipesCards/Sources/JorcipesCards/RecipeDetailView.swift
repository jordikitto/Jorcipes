import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct RecipeDetailView: View {
    let recipe: Recipe

    public init(recipe: Recipe) {
        self.recipe = recipe
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .space400) {
                RecipeHeaderSection(recipe: recipe)
                RecipeDietarySection(attributes: recipe.dietaryAttributes)
                RecipeIngredientsSection(ingredients: recipe.ingredients)
                RecipeInstructionsSection(instructions: recipe.instructions)
            }
            .padding(.space400)
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Sections

struct RecipeHeaderSection: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            Text(recipe.description)
                .font(.body)
                .foregroundStyle(.secondary)

            Label("\(recipe.servings) servings", systemImage: "person.2")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct RecipeDietarySection: View {
    let attributes: Set<DietaryAttribute>

    var body: some View {
        if !attributes.isEmpty {
            HStack(spacing: .space200) {
                ForEach(Array(attributes).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { attribute in
                    DietaryBadgeView(attribute: attribute)
                }
            }
        }
    }
}

struct RecipeIngredientsSection: View {
    let ingredients: [Ingredient]

    var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            Text("Ingredients")
                .font(.title2)
                .bold()

            ForEach(ingredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.quantity)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, .space100)
                Divider()
            }
        }
    }
}

struct RecipeInstructionsSection: View {
    let instructions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: .space300) {
            Text("Instructions")
                .font(.title2)
                .bold()

            ForEach(instructions.enumerated(), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: .space300) {
                    Text("\(index + 1)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.recipePrimary)
                        .frame(width: 30)

                    if let attributed = try? AttributedString(markdown: instruction) {
                        Text(attributed)
                            .font(.body)
                    } else {
                        Text(instruction)
                            .font(.body)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: .preview)
    }
}
