import SwiftUI

struct FilterSheetToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    let onClear: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Clear", systemImage: "trash") {
                onClear()
                dismiss()
            }
            .labelStyle(.iconOnly)
            .tint(.red)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", systemImage: "checkmark") { dismiss() }
                .labelStyle(.iconOnly)
        }
    }
}
