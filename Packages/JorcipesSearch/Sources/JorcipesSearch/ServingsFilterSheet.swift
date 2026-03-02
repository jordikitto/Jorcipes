import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct ServingsFilterSheet: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.filterOptions {
                case .loaded(let options):
                    List {
                        Button {
                            viewModel.setServings(nil)
                        } label: {
                            HStack {
                                Text("Any")

                                Spacer()

                                if viewModel.query.servings == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        ForEach(options.availableServings, id: \.self) { servings in
                            Button {
                                viewModel.setServings(servings)
                            } label: {
                                HStack {
                                    Text("\(servings) servings")

                                    Spacer()

                                    if viewModel.query.servings == servings {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                case .failed(let message):
                    ContentUnavailableView {
                        Label("Failed to Load", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") { viewModel.loadFilterOptions() }
                    }

                default:
                    ProgressView()
                }
            }
            .navigationTitle("Servings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .labelStyle(.iconOnly)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Clear") { viewModel.clearServings() }
                        .tint(.red)
                }
            }
        }
    }
}
