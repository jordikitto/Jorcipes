import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct DietaryFilterSheet: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(DietaryAttribute.allCases, id: \.self) { attribute in
                    Button {
                        viewModel.toggleDietaryAttribute(attribute)
                    } label: {
                        HStack {
                            Text(attribute.rawValue.capitalized)

                            Spacer()

                            if viewModel.isDietaryAttributeActive(attribute) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Dietary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Clear") { viewModel.clearDietaryAttributes() }
                        .tint(.red)
                }
            }
        }
    }
}
