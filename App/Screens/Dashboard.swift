import SwiftData
import SwiftUI

struct Dashboard: View {
    @Query(sort: \Recipe.createdDate, order: .reverse) private var recipes: [Recipe]

    @State private var showAddRecipeSheet = false

    var body: some View {
        NavigationStack {
            RecipeList(recipes: recipes)
                .navigationTitle("Recipes")
                .toolbar {
                    Button {
                        showAddRecipeSheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                .fullScreenCover(isPresented: $showAddRecipeSheet) {
                    AddRecipe()
                }
                .navigationDestination(for: Recipe.self) { recipe in
                    EditRecipe(recipe: recipe)
                }
        }
    }
}

private struct AddRecipe: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var recipe = Recipe()
    
    @State private var isFirstAppear = true
    
    var body: some View {
        NavigationStack {
            EditRecipe(recipe: recipe)
        }
        .onAppear {
            if isFirstAppear {
                isFirstAppear = false
                modelContext.insert(recipe)
            }
        }
    }
}

#Preview {
    let container = ModelContainer.previewContainer
    
    return NavigationStack {
        Dashboard()
    }
    .modelContainer(container)
}
