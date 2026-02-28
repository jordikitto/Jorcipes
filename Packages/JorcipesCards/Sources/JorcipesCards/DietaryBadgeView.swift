import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct DietaryBadgeView: View {
    let attribute: DietaryAttribute

    public init(attribute: DietaryAttribute) {
        self.attribute = attribute
    }

    public var body: some View {
        Text(label)
            .font(.caption2)
            .bold()
            .padding(.horizontal, .space200)
            .padding(.vertical, .space50)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(.capsule)
    }

    private var label: String {
        switch attribute {
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        }
    }

    private var color: Color {
        switch attribute {
        case .vegetarian: .green
        case .vegan: .mint
        }
    }
}

#Preview {
    HStack {
        DietaryBadgeView(attribute: .vegetarian)
        DietaryBadgeView(attribute: .vegan)
    }
}
