import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var viewModel: RecipeDetailViewModel

    public init(recipe: Recipe) {
        self.recipe = recipe
        _viewModel = State(
            initialValue: RecipeDetailViewModel(
                instructionCount: recipe.instructions.count
            )
        )
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .space400) {
                DetailImageHeader()

                DietaryBadgesView(attributes: Array(recipe.dietaryAttributes))

                Text(recipe.title)
                    .font(.largeTitle)
                    .bold()

                DetailInfoCard(recipe: recipe)

                Text("Ingredients")
                    .font(.title2)
                    .bold()

                DetailIngredientsCard(ingredients: recipe.ingredients)

                HStack {
                    Text("Instructions")
                        .font(.title2)
                        .bold()

                    Spacer()

                    Button(viewModel.instructionButtonLabel) {
                        viewModel.advanceStep()
                    }
                    .buttonStyle(.borderedProminent)
                }

                ForEach(recipe.instructions.enumerated(), id: \.offset) { index, instruction in
                    DetailInstructionCard(
                        index: index,
                        instruction: instruction,
                        isHighlighted: index == viewModel.highlightedStep
                    ) {
                        viewModel.selectStep(index)
                    }
                }
            }
            .padding(.space400)
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Congratulations 🎉", isPresented: $viewModel.showCongratulations) {
            Button("OK") { }
        } message: {
            Text("Another Jorcipe cooked! Keep up the great work, chef.")
        }
    }
}

// MARK: - Sub-views

struct DetailImageHeader: View {
    var body: some View {
        RoundedRectangle(cornerRadius: .cornerRadiusMedium)
            .fill(Color.recipeSecondary.opacity(0.2))
            .aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.largeTitle)
                    .foregroundStyle(Color.recipeSecondary)
            }
    }
}

struct DetailInfoCard: View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.space400)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: .cornerRadiusMedium))
    }
}

struct DetailIngredientsCard: View {
    let ingredients: [Ingredient]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ingredients.enumerated(), id: \.element.id) { index, ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.quantity)
                        .foregroundStyle(.secondary)
                }
                .padding(.space300)

                if index < ingredients.count - 1 {
                    Divider()
                        .padding(.horizontal, .space300)
                }
            }
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: .cornerRadiusMedium))
    }
}

struct DetailInstructionCard: View {
    let index: Int
    let instruction: String
    let isHighlighted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: .space300) {
                Text("\(index + 1)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.recipePrimary)
                    .frame(width: 30)

                if let attributed = try? AttributedString(markdown: instruction) {
                    Text(attributed)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(instruction)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.space400)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: .cornerRadiusMedium))
            .overlay {
                if isHighlighted {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium)
                        .strokeBorder(Color.accentColor, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: .preview)
    }
}
