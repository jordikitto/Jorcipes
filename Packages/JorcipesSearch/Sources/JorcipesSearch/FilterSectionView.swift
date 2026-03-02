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

                FilterRow(label: "Servings", value: servingsValue) {
                    viewModel.activeSheet = .servings
                }

                FilterRow(
                    label: "Included",
                    value: viewModel.query.includedIngredients.joined(separator: ", ")
                ) {
                    viewModel.activeSheet = .includedIngredients
                }

                FilterRow(
                    label: "Excluded",
                    value: viewModel.query.excludedIngredients.joined(separator: ", ")
                ) {
                    viewModel.activeSheet = .excludedIngredients
                }
            }
        }
        .padding(.space400)
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


