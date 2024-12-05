import SwiftUI
import SwiftData

@main
struct GitListAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [RepositoryEntity.self])
        }
    }
}
