import SwiftUI
import JorcipesNetworking

@main
struct JorcipesApp: App {
    private let container: AppContainer

    init() {
        let jsonFileName = UserDefaults.standard.string(forKey: "mockDataSource") ?? "recipes_5"
        container = AppContainer(apiClient: MockAPIClient(jsonFileName: jsonFileName))
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(container: container)
        }
    }
}
