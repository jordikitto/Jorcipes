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
                        Text(attribute.rawValue.capitalized)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        viewModel.isDietaryAttributeActive(attribute)
                            ? Color.accentColor.opacity(0.12)
                            : nil
                    )
                }
            }
            .navigationTitle("Dietary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { FilterSheetToolbar(onClear: { viewModel.clearDietaryAttributes() }) }
        }
    }
}
