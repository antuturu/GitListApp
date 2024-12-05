import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    var body: some View {
        VStack {
            RepositoryListView(context: context)
        }
    }
}

#Preview {
    ContentView()
}
