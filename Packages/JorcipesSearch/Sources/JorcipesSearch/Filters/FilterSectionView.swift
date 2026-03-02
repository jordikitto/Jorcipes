import SwiftUI
import JorcipesCore
import JorcipesDesignSystem
import JorcipesNetworking

struct FilterSectionView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .space300) {
            FilterHeader(
                activeCount: viewModel.activeFilterCount,
                isExpanded: viewModel.filtersExpanded
            ) {
                withAnimation(.bouncy) {
                    viewModel.filtersExpanded.toggle()
                }
            }

            if viewModel.filtersExpanded {
                FilterRow(label: "Dietary", value: dietaryFormatted) {
                    viewModel.activeSheet = .dietary
                }

                if hasOptions(for: \.availableServings) {
                    FilterRow(label: "Servings", value: servingsFormatted) {
                        viewModel.activeSheet = .servings
                    }
                }

                if hasOptions(for: \.availableIngredients) {
                    FilterRow(label: "Included", value: includedFormatted) {
                        viewModel.activeSheet = .includedIngredients
                    }

                    FilterRow(label: "Excluded", value: excludedFormatted) {
                        viewModel.activeSheet = .excludedIngredients
                    }
                }

                FilterRow(label: "Instructions", value: instructionsFormatted) {
                    viewModel.activeSheet = .instructions
                }
            }
        }
        .padding(.space400)
    }

    private func hasOptions<C: Collection>(for keyPath: KeyPath<FilterOptions, C>) -> Bool {
        guard case .loaded(let options) = viewModel.filterOptions else { return false }
        return !options[keyPath: keyPath].isEmpty
    }

    private var dietaryFormatted: String? {
        let attributes = viewModel.query.dietaryAttributes
        guard !attributes.isEmpty else { return nil }
        return attributes.sorted(by: { $0.rawValue < $1.rawValue })
            .map(\.rawValue.capitalized)
            .joined(separator: ", ")
    }

    private var servingsFormatted: String? {
        guard let servings = viewModel.query.servings else { return nil }
        return "\(servings) servings"
    }

    private var includedFormatted: String? {
        guard !viewModel.query.includedIngredients.isEmpty else { return nil }
        return viewModel.query.includedIngredients.joined(separator: ", ")
    }

    private var excludedFormatted: String? {
        guard !viewModel.query.excludedIngredients.isEmpty else { return nil }
        return viewModel.query.excludedIngredients.joined(separator: ", ")
    }

    private var instructionsFormatted: String? {
        guard !viewModel.query.instructionText.isEmpty else { return nil }
        return viewModel.query.instructionText
    }
}

struct FilterHeader: View {
    let activeCount: Int
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(activeCount > 0 ? "Filters (\(activeCount))" : "Filters")
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .rotationEffect(isExpanded ? .degrees(90) : .degrees(0))

            }
            .padding()
            .contentShape(.rect)
            .glassEffect(
                .regular.interactive(),
                in: .rect(cornerRadius: .cornerRadiusLarge)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FilterRow: View {
    let label: String
    let value: String?
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .foregroundStyle(.primary)

                Spacer()

                if let value {
                    Text(value)
                        .font(.callout)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text("Select")
                        .font(.callout)
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .contentShape(.rect)
            .glassEffect(
                .regular.interactive(),
                in: .rect(cornerRadius: .cornerRadiusLarge)
            )
        }
        .buttonStyle(.plain)
        .padding(.leading, .space200)
    }
}

#Preview("Collapsed") {
    FilterSectionView(viewModel: SearchViewModel(apiClient: LocalAPIClient()))
}

#Preview("Expanded with Filters") {
    @Previewable @State var viewModel = {
        let viewModel = SearchViewModel(apiClient: LocalAPIClient())
        viewModel.filtersExpanded = true
        viewModel.query.dietaryAttributes = [.vegan, .vegetarian]
        viewModel.query.servings = 4
        viewModel.query.includedIngredients = ["Tomato", "Basil"]
        return viewModel
    }()
    FilterSectionView(viewModel: viewModel)
}


