import SwiftUI

struct DevSettingsView: View {
    @AppStorage("mockDataSource") private var mockDataSource = "recipes_5"
    @State private var initialValue = ""

    private let mockDataOptions = ["recipes_5", "recipes_50", "recipes_empty", "recipes_corrupted"]

    private var needsRestart: Bool {
        mockDataSource != initialValue
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Mock Data Source") {
                    Picker("JSON File", selection: $mockDataSource) {
                        ForEach(mockDataOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Dev Settings")
            .onAppear {
                initialValue = mockDataSource
            }
            .safeAreaInset(edge: .bottom) {
                if needsRestart {
                    Text("Restart the app for this to take effect.")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                        .bold()
                        .padding()
                        .glassEffect()
                        .padding()
                }
            }
        }
    }
}

#Preview {
    DevSettingsView()
}
