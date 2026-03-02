import SwiftUI
import JorcipesCore
import JorcipesDesignSystem

struct ServingsFilterSheet: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.filterOptions {
                case .loaded(let options):
                    List {
                        ForEach(options.availableServings, id: \.self) { servings in
                            Button {
                                viewModel.setServings(servings)
                            } label: {
                                Text("\(servings) servings")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(
                                viewModel.query.servings == servings
                                    ? Color.accentColor.opacity(0.12)
                                    : nil
                            )
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
            .toolbar { FilterSheetToolbar(onClear: { viewModel.clearServings() }) }
        }
    }
}
