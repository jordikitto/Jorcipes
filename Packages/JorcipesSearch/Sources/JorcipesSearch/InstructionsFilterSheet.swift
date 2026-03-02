import SwiftUI

struct InstructionsFilterSheet: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField("Search instructions...", text: $viewModel.query.instructionText)
                    .focused($isTextFieldFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        dismiss()
                    }
            }
            .navigationTitle("Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isTextFieldFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Clear") { viewModel.clearInstructionText() }
                        .tint(.red)
                }
            }
        }
    }
}
