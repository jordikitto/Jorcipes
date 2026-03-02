import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct SearchFilterView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .space400) {
            // Dietary chips
            VStack(alignment: .leading, spacing: .space200) {
                Text("Dietary")
                    .font(.headline)

                WrappingHStack(spacing: .space200) {
                    ForEach(DietaryAttribute.allCases, id: \.self) { attribute in
                        DietaryChipView(
                            attribute: attribute,
                            isActive: viewModel.isDietaryAttributeActive(attribute)
                        ) {
                            viewModel.toggleDietaryAttribute(attribute)
                        }
                    }
                }
            }

            // Servings filter with toggle and stepper
            VStack(alignment: .leading, spacing: .space200) {
                Text("Servings")
                    .font(.headline)

                Toggle("Filter by servings", isOn: Binding(
                    get: { viewModel.query.servings != nil },
                    set: { enabled in
                        viewModel.setServings(enabled ? 1 : nil)
                    }
                ))

                if let servings = viewModel.query.servings {
                    Stepper(
                        "\(servings) servings",
                        value: Binding(
                            get: { servings },
                            set: { viewModel.setServings($0) }
                        ),
                        in: 1...20
                    )
                }
            }

            // Ingredient chips
            VStack(alignment: .leading, spacing: .space200) {
                Text("Ingredients")
                    .font(.headline)

                IngredientChipInputView(
                    text: $viewModel.ingredientSearchText,
                    includedIngredients: viewModel.query.includedIngredients,
                    excludedIngredients: viewModel.query.excludedIngredients,
                    onSubmit: {
                        let trimmed = viewModel.ingredientSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.toggleIncludedIngredient(trimmed)
                        viewModel.ingredientSearchText = ""
                    },
                    onToggleIncluded: { index in
                        guard viewModel.query.includedIngredients.indices.contains(index) else { return }
                        let name = viewModel.query.includedIngredients[index]
                        viewModel.toggleIncludedIngredient(name)
                        viewModel.toggleExcludedIngredient(name)
                    },
                    onToggleExcluded: { index in
                        guard viewModel.query.excludedIngredients.indices.contains(index) else { return }
                        let name = viewModel.query.excludedIngredients[index]
                        viewModel.toggleExcludedIngredient(name)
                        viewModel.toggleIncludedIngredient(name)
                    },
                    onRemoveIncluded: { index in
                        guard viewModel.query.includedIngredients.indices.contains(index) else { return }
                        let name = viewModel.query.includedIngredients[index]
                        viewModel.toggleIncludedIngredient(name)
                    },
                    onRemoveExcluded: { index in
                        guard viewModel.query.excludedIngredients.indices.contains(index) else { return }
                        let name = viewModel.query.excludedIngredients[index]
                        viewModel.toggleExcludedIngredient(name)
                    }
                )
            }
        }
        .padding(.space400)
    }
}
