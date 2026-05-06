import SwiftData
import SwiftUI

struct Dashboard: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Recipe.createdDate, order: .reverse) private var recipes: [Recipe]
    
    @State private var showAddRecipeSheet = false
    
    var body: some View {
        NavigationStack {
            RecipeList(recipes: recipes)
                .navigationTitle("Recipes")
                .toolbar {
                    bottomBar
                    
                    ToolbarItem {
                        Button("Add Samples") {
                            for sample in Recipe.samples {
                                modelContext.insert(sample)
                            }
                            
                            try? modelContext.save()
                        }
                    }
                }
                .fullScreenCover(isPresented: $showAddRecipeSheet) {
                    AddRecipe()
                }
        }
    }
    
    @ToolbarContentBuilder private var bottomBar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Text("\(recipes.count) recipe\(recipes.count == 1 ? "" : "s")")
                .font(.caption)
                .frame(maxWidth: .infinity)
        }
        
        ToolbarSpacer(.fixed, placement: .bottomBar)
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                showAddRecipeSheet = true
            } label: {
                Image(systemName: "square.and.pencil")
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
