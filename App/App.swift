import SwiftUI
import SwiftData

@main
struct App: SwiftUI.App {
    let container: ModelContainer
    
    init() {
        let config = ModelConfiguration()

        let container = try! ModelContainer(for: Recipe.self,
                                            Recipe.Section.self,
                                            Ingredient.self,
                                            Step.self,
                                            configurations: config)
        container.mainContext.autosaveEnabled = false
        
        Recipe.samples.forEach { recipe in
            let hasLoadedBefore = UserDefaults.standard.bool(forKey: recipe.name)
            if !hasLoadedBefore {
                container.mainContext.insert(recipe)
                
                UserDefaults.standard.set(true, forKey: recipe.name)
            }
        }
        
        try! container.mainContext.save()
        self.container = container
    }
    
    var body: some Scene {
        WindowGroup {
            Dashboard()
        }
        .modelContainer(container)
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
