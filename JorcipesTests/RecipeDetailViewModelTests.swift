import Testing
@testable import JorcipesCards

@Suite("RecipeDetailViewModel Tests")
@MainActor
struct RecipeDetailViewModelTests {

    @Test func `instruction step progression from start to finish`() {
        // GIVEN: View model with 4 instructions
        let viewModel = RecipeDetailViewModel(instructionCount: 4)

        // THEN: Initial state has no highlighted step
        #expect(viewModel.highlightedStep == nil)
        #expect(viewModel.showCongratulations == false)
        #expect(viewModel.instructionButtonLabel == "Start")

        // WHEN: Start is tapped
        viewModel.advanceStep()

        // THEN: First step is highlighted
        #expect(viewModel.highlightedStep == 0)
        #expect(viewModel.instructionButtonLabel == "Next")

        // WHEN: Next is tapped twice
        viewModel.advanceStep()
        #expect(viewModel.highlightedStep == 1)
        viewModel.advanceStep()
        #expect(viewModel.highlightedStep == 2)
        #expect(viewModel.instructionButtonLabel == "Next")

        // WHEN: Next advances to last step
        viewModel.advanceStep()

        // THEN: Last step shows Finish
        #expect(viewModel.highlightedStep == 3)
        #expect(viewModel.instructionButtonLabel == "Finish")

        // WHEN: Finish is tapped
        viewModel.advanceStep()

        // THEN: State resets with congratulations
        #expect(viewModel.highlightedStep == nil)
        #expect(viewModel.showCongratulations == true)
        #expect(viewModel.instructionButtonLabel == "Start")
    }

    @Test func `selecting a step directly sets highlight`() {
        // GIVEN: View model with 5 instructions
        let viewModel = RecipeDetailViewModel(instructionCount: 5)

        // WHEN: Selecting step 3 directly
        viewModel.selectStep(3)

        // THEN: Step 3 is highlighted with Next label
        #expect(viewModel.highlightedStep == 3)
        #expect(viewModel.instructionButtonLabel == "Next")

        // WHEN: Selecting the last step directly
        viewModel.selectStep(4)

        // THEN: Last step shows Finish
        #expect(viewModel.instructionButtonLabel == "Finish")
    }
}
