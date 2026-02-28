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
                    text: $viewModel.ingredientInput,
                    includedIngredients: viewModel.query.includedIngredients,
                    excludedIngredients: viewModel.query.excludedIngredients,
                    onSubmit: { viewModel.addIncludedIngredient() },
                    onToggleIncluded: { viewModel.toggleIngredientChip(at: $0) },
                    onToggleExcluded: { viewModel.toggleExcludedIngredientChip(at: $0) },
                    onRemoveIncluded: { viewModel.removeIncludedIngredient(at: $0) },
                    onRemoveExcluded: { viewModel.removeExcludedIngredient(at: $0) }
                )
            }
        }
        .padding(.space400)
    }
}
