import SwiftUI
import JorcipesCore
import JorcipesDesignSystem
import JorcipesNetworking

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
                                HStack {
                                    Text("^[\(servings) serving](inflect: true)")

                                    Spacer()

                                    if viewModel.query.servings == servings {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.primary, .tint)
                                    }
                                }
                                .contentShape(.rect)
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
            .toolbar { FilterSheetToolbar(onClear: { viewModel.clearServings() }) }
        }
        .presentationDetents([UIDevice.current.userInterfaceIdiom == .pad ? .large : .medium])
    }
}

