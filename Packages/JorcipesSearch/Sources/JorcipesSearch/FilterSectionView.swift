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
                FilterRow(label: "Dietary", value: dietaryValue) {
                    viewModel.activeSheet = .dietary
                }

                if hasOptions(for: \.availableServings) {
                    FilterRow(label: "Servings", value: servingsValue) {
                        viewModel.activeSheet = .servings
                    }
                }

                if hasOptions(for: \.availableIngredients) {
                    FilterRow(label: "Included", value: includedValue) {
                        viewModel.activeSheet = .includedIngredients
                    }

                    FilterRow(label: "Excluded", value: excludedValue) {
                        viewModel.activeSheet = .excludedIngredients
                    }
                }

                FilterRow(label: "Instructions", value: instructionsValue) {
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

    private var dietaryValue: String? {
        let attrs = viewModel.query.dietaryAttributes
        guard !attrs.isEmpty else { return nil }
        return attrs.sorted(by: { $0.rawValue < $1.rawValue })
            .map(\.rawValue.capitalized)
            .joined(separator: ", ")
    }

    private var servingsValue: String? {
        guard let s = viewModel.query.servings else { return nil }
        return "\(s) servings"
    }

    private var includedValue: String? {
        guard !viewModel.query.includedIngredients.isEmpty else { return nil }
        return viewModel.query.includedIngredients.joined(separator: ", ")
    }

    private var excludedValue: String? {
        guard !viewModel.query.excludedIngredients.isEmpty else { return nil }
        return viewModel.query.excludedIngredients.joined(separator: ", ")
    }

    private var instructionsValue: String? {
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
            .padding(.space200)
            .contentShape(.rect)
        }
        .buttonStyle(.glass)
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
                } else {
                    Text("Select")
                        .font(.callout)
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.space200)
            .contentShape(.rect)
        }
        .buttonStyle(.glass)
        .padding(.leading, .space200)
    }
}

#Preview("Collapsed") {
    FilterSectionView(viewModel: SearchViewModel(apiClient: MockAPIClient()))
}

#Preview("Expanded with Filters") {
    @Previewable @State var viewModel = {
        let vm = SearchViewModel(apiClient: MockAPIClient())
        vm.filtersExpanded = true
        vm.query.dietaryAttributes = [.vegan, .vegetarian]
        vm.query.servings = 4
        vm.query.includedIngredients = ["Tomato", "Basil"]
        return vm
    }()
    FilterSectionView(viewModel: viewModel)
}


