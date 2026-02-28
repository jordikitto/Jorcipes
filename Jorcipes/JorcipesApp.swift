import SwiftUI
import JorcipesNetworking

@main
struct JorcipesApp: App {
    private let container = AppContainer(apiClient: MockAPIClient())

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
