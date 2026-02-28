import SwiftUI
import JorcipesDesignSystem

struct IngredientChipInputView: View {
    @Binding var text: String
    let includedIngredients: [String]
    let excludedIngredients: [String]
    let onSubmit: () -> Void
    let onToggleIncluded: (Int) -> Void
    let onToggleExcluded: (Int) -> Void
    let onRemoveIncluded: (Int) -> Void
    let onRemoveExcluded: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .space200) {
            TextField("Add ingredient...", text: $text)
                .textFieldStyle(.roundedBorder)
                .onSubmit(onSubmit)

            if !includedIngredients.isEmpty || !excludedIngredients.isEmpty {
                WrappingHStack(spacing: .space200) {
                    ForEach(includedIngredients.enumerated(), id: \.offset) { index, name in
                        IngredientChip(name: name, isIncluded: true) {
                            onToggleIncluded(index)
                        } onRemove: {
                            onRemoveIncluded(index)
                        }
                    }

                    ForEach(excludedIngredients.enumerated(), id: \.offset) { index, name in
                        IngredientChip(name: name, isIncluded: false) {
                            onToggleExcluded(index)
                        } onRemove: {
                            onRemoveExcluded(index)
                        }
                    }
                }
            }
        }
    }
}

/// Separate View struct for individual ingredient chip (per CLAUDE.md: no computed view property returning some View).
struct IngredientChip: View {
    let name: String
    let isIncluded: Bool
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: .space100) {
            Button(action: onTap) {
                Label(
                    name,
                    systemImage: isIncluded ? "checkmark" : "minus"
                )
                .font(.subheadline)
            }
            .accessibilityHint(isIncluded ? "Tap to exclude this ingredient" : "Tap to include this ingredient")
            Button("Remove ingredient", systemImage: "xmark", action: onRemove)
                .font(.caption)
                .labelStyle(.iconOnly)
        }
        .padding(.horizontal, .space300)
        .padding(.vertical, .space150)
        .background(isIncluded ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
        .foregroundStyle(isIncluded ? .green : .red)
        .clipShape(.capsule)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(isIncluded ? "included" : "excluded")")
    }
}

/// A simple wrapping horizontal stack using Layout protocol.
struct WrappingHStack: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}
