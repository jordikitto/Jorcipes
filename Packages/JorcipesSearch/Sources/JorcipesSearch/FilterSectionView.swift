import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct FilterSectionView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .space300) {
            FilterHeader(
                activeCount: viewModel.activeFilterCount,
                isExpanded: viewModel.filtersExpanded
            ) {
                viewModel.filtersExpanded.toggle()
            }

            if viewModel.filtersExpanded {
                FilterRow(label: "Dietary", value: dietaryValue) {
                    viewModel.activeSheet = .dietary
                }

                FilterRow(label: "Servings", value: servingsValue) {
                    viewModel.activeSheet = .servings
                }

                FilterChipRow(label: "Included ingredients", items: viewModel.query.includedIngredients) {
                    viewModel.activeSheet = .includedIngredients
                }

                FilterChipRow(label: "Excluded ingredients", items: viewModel.query.excludedIngredients) {
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

                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct FilterRow: View {
    let label: String
    let value: String?
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Button(value ?? "Select", action: onTap)
                .buttonStyle(.bordered)
        }
    }
}

struct FilterChipRow: View {
    let label: String
    let items: [String]
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            if items.isEmpty {
                Button("Select", action: onTap)
                    .buttonStyle(.bordered)
            } else {
                Button(action: onTap) {
                    HStack(spacing: .space100) {
                        ForEach(items, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .padding(.horizontal, .space200)
                                .padding(.vertical, .space50)
                                .background(Color.recipePrimary.opacity(0.15))
                                .foregroundStyle(Color.recipePrimary)
                                .clipShape(.capsule)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
