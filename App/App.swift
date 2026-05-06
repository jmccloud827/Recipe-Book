import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            Dashboard()
        }
        .modelContainer(for: Recipe.self, isAutosaveEnabled: false)
    }
}

/// App Icon
#Preview {
    Image(systemName: "text.book.closed.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(.white)
        .frame(width: 250, height: 250)
        .padding()
        .padding()
        .padding(44)
        .background(.accent.gradient)
}
