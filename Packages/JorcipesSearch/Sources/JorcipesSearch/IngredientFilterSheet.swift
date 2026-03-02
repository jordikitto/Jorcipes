import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct IngredientFilterSheet: View {
    let title: String
    @Bindable var viewModel: SearchViewModel
    let isIncluded: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var isSearchFocused = false

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.filterOptions {
                case .loaded(let options):
                    List {
                        ForEach(filteredIngredients(from: options), id: \.self) { ingredient in
                            IngredientRow(
                                ingredient: ingredient,
                                isSelected: isSelected(ingredient),
                                isDisabled: isInOppositeList(ingredient),
                                oppositeLabel: isIncluded ? "Excluded" : "Included"
                            ) {
                                if isIncluded {
                                    viewModel.toggleIncludedIngredient(ingredient)
                                } else {
                                    viewModel.toggleExcludedIngredient(ingredient)
                                }
                            }
                        }
                    }
                    .searchable(text: $viewModel.ingredientSearchText, isPresented: $isSearchFocused, prompt: "Search ingredients...")

                case .failed(let message):
                    ContentUnavailableView {
                        Label("Failed to Load", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") { viewModel.loadFilterOptions() }
                    }

                default:
                    ProgressView()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isSearchFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Clear") {
                        if isIncluded {
                            viewModel.clearIncludedIngredients()
                        } else {
                            viewModel.clearExcludedIngredients()
                        }
                    }
                    .tint(.red)
                }
            }
        }
    }

    private func filteredIngredients(from options: FilterOptions) -> [String] {
        if viewModel.ingredientSearchText.isEmpty {
            return options.availableIngredients
        }
        return options.availableIngredients.filter {
            $0.localizedStandardContains(viewModel.ingredientSearchText)
        }
    }

    private func isSelected(_ ingredient: String) -> Bool {
        if isIncluded {
            viewModel.isIngredientIncluded(ingredient)
        } else {
            viewModel.isIngredientExcluded(ingredient)
        }
    }

    private func isInOppositeList(_ ingredient: String) -> Bool {
        if isIncluded {
            viewModel.isIngredientExcluded(ingredient)
        } else {
            viewModel.isIngredientIncluded(ingredient)
        }
    }
}

struct IngredientRow: View {
    let ingredient: String
    let isSelected: Bool
    let isDisabled: Bool
    let oppositeLabel: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(ingredient)
                    .foregroundStyle(isDisabled ? .tertiary : .primary)

                Spacer()

                if isDisabled {
                    Text(oppositeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, .space200)
                        .padding(.vertical, .space50)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(.capsule)
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
