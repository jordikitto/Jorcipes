import Foundation

@MainActor
@Observable
public final class RecipeDetailViewModel {
    public var highlightedStep: Int?
    public var showCongratulations = false
    public var isTitleVisible = true

    private let instructionCount: Int

    public init(instructionCount: Int) {
        self.instructionCount = instructionCount
    }

    public var instructionButtonLabel: String {
        if highlightedStep == nil {
            "Start"
        } else if isOnLastStep {
            "Finish"
        } else {
            "Next"
        }
    }

    private var isOnLastStep: Bool {
        highlightedStep == instructionCount - 1
    }

    /// Advances to the next instruction step, or finishes if on the last step.
    public func advanceStep() {
        if highlightedStep == nil {
            highlightedStep = 0
        } else if isOnLastStep {
            highlightedStep = nil
            showCongratulations = true
        } else {
            highlightedStep = (highlightedStep ?? 0) + 1
        }
    }

    /// Jumps directly to the given instruction step index.
    public func selectStep(_ index: Int) {
        highlightedStep = index
    }
}
