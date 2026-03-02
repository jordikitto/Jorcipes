import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct DietaryFilterSheet: View {
    @Bindable var viewModel: SearchViewModel

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
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.primary, .tint)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Dietary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { FilterSheetToolbar(onClear: { viewModel.clearDietaryAttributes() }) }
        }
        .presentationDetents([.medium])
    }
}
