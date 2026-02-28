import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct DietaryChipView: View {
    let attribute: DietaryAttribute
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, .space300)
                .padding(.vertical, .space200)
                .background(isActive ? Color.recipePrimary : Color(.secondarySystemBackground))
                .foregroundStyle(isActive ? .white : .primary)
                .clipShape(.capsule)
        }
        .accessibilityLabel("\(label) filter")
        .accessibilityHint(isActive ? "Double tap to remove \(label) filter" : "Double tap to add \(label) filter")
    }

    private var label: String {
        switch attribute {
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        }
    }
}

#Preview {
    HStack {
        DietaryChipView(attribute: .vegetarian, isActive: true, action: {})
        DietaryChipView(attribute: .vegan, isActive: false, action: {})
    }
}
