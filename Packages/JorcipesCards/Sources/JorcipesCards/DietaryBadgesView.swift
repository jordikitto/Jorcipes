import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

public struct DietaryBadgesView: View {
    let sortedAttributes: [DietaryAttribute]

    public init(attributes: [DietaryAttribute]) {
        self.sortedAttributes = attributes.sorted(by: { $0.rawValue < $1.rawValue })
    }

    public var body: some View {
        if !sortedAttributes.isEmpty {
            ViewThatFits {
                HStack(spacing: .space200) {
                    ForEach(sortedAttributes, id: \.self) { attribute in
                        DietaryBadgeView(attribute: attribute)
                    }
                }

                VStack(alignment: .leading, spacing: .space100) {
                    ForEach(sortedAttributes, id: \.self) { attribute in
                        DietaryBadgeView(attribute: attribute)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        DietaryBadgesView(attributes: [.vegan, .vegetarian])
        DietaryBadgesView(attributes: [.vegetarian])
        DietaryBadgesView(attributes: [])
    }
}
