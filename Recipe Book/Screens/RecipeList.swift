import SwiftData
import SwiftUI

struct RecipeList: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Recipe.createdDate, order: .reverse) private var recipes: [Recipe]
    
    @State private var recipeToAdd: Recipe?
    @State private var selectedRecipe: Recipe?
    @Namespace private var namespace
    
    @State private var showConfirmationDialog = false
    @State private var currentDetent = Self.startingDetent
    
    static let startingDetent = PresentationDetent.fraction(1.0)
    static let dismissDetent = PresentationDetent.fraction(0.95)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                    ForEach(recipes, id: \.id) { recipe in
                        RecipeLink(recipe: recipe, namespace: namespace) { recipe in
                            selectedRecipe = recipe
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    bottomBar
                }
                
                ToolbarItem(placement: .automatic) {
                    #if DEBUG
                    addExampleButton
                    #endif
                }
            }
            .sheet(item: $selectedRecipe) { recipe in
                viewRecipeSheet(recipe: recipe)
            }
            .sheet(item: $recipeToAdd) { recipe in
                addRecipeSheet(recipe: recipe)
            }
        }
    }
    
    private var bottomBar: some View {
        HStack {
            Button {
                recipeToAdd = Recipe()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .opacity(0)
            
            Text("\(recipes.count) recipe\(recipes.count == 1 ? "" : "s")")
                .font(.caption)
                .frame(maxWidth: .infinity)
            
            Button {
                recipeToAdd = Recipe()
            } label: {
                Image(systemName: "square.and.pencil")
            }
        }
    }
    
    private var addExampleButton: some View {
        Button("Add Example") {
            modelContext.insert(Recipe.exampleRecipe)
            try? modelContext.save()
            Recipe.exampleRecipe.saveToDocumentsDirectory()
        }
    }
    
    private func viewRecipeSheet(recipe: Recipe) -> some View {
        NavigationStack {
            RecipeView(recipe: recipe)
        }
        .navigationTransition(.zoom(sourceID: recipe.id, in: namespace))
    }
    
    private func addRecipeSheet(recipe: Recipe) -> some View {
        let hasChanges = recipe.name != "New Recipe"
            || !recipe.tags.isEmpty
            || !recipe.dishDescription.isEmpty
            || recipe.photo != nil
            || !recipe.ingredients.isEmpty
            || !recipe.steps.isEmpty
        
        return NavigationStack {
            EditRecipe(recipe: recipe)
                .navigationTitle(recipe.name)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Done") { saveNewRecipe(recipe: recipe) }
                    }
                    
                    ToolbarItem(placement: .navigation) {
                        Button("Cancel") { cancelNewRecipe(hasChanges: hasChanges) }
                    }
                }
                .confirmationDialog("Are you sure you want to this task?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                    Button("Discard Changes?", role: .destructive) {
                        recipeToAdd = nil
                    }
                    
                    Button("Keep Editing", role: .cancel) {}
                }
        }
        .interactiveDismissDisabled(hasChanges)
        .presentationDetents(newRecipeSheetDetents(hasChanges: hasChanges), selection: $currentDetent)
        .presentationDragIndicator(.hidden)
        .onChange(of: currentDetent) {
            onChangeOfNewRecipeSheetDetent(hasChanges: hasChanges)
        }
    }
    
    private func saveNewRecipe(recipe: Recipe) {
        modelContext.insert(recipe)
        try? modelContext.save()
        recipe.saveToDocumentsDirectory()
        
        recipeToAdd = nil
    }
    
    private func cancelNewRecipe(hasChanges: Bool) {
        if hasChanges {
            showConfirmationDialog = true
        } else {
            recipeToAdd = nil
        }
    }
    
    private func newRecipeSheetDetents(hasChanges: Bool) -> Set<PresentationDetent> {
        if hasChanges {
            [Self.dismissDetent, Self.startingDetent]
        } else {
            [Self.startingDetent]
        }
    }
    
    private func onChangeOfNewRecipeSheetDetent(hasChanges: Bool) {
        if currentDetent == Self.dismissDetent {
            if hasChanges {
                currentDetent = Self.startingDetent
                showConfirmationDialog = true
            } else {
                recipeToAdd = nil
            }
        }
    }
}

private struct RecipeLink: View {
    @Environment(\.modelContext) private var modelContext
    
    let recipe: Recipe
    let namespace: Namespace.ID
    let onSelect: (Recipe) -> Void
    
    @State private var isEditing = false
    @State private var changedTitle: String? = nil
    
    var body: some View {
        VStack {
            Button {
                onSelect(recipe)
            } label: {
                recipeImage
                    .matchedTransitionSource(id: recipe.id, in: namespace)
                    .background {
                        RoundedRectangle(cornerSize: .init(width: 5, height: 5), style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    }
                    .overlay {
                        RoundedRectangle(cornerSize: .init(width: 5, height: 5), style: .continuous)
                            .stroke(lineWidth: 0.5)
                            .fill(.black.opacity(0.5))
                    }
                    .contextMenu {
                        contextMenuButtons
                    }
                    .frame(maxWidth: 150, maxHeight: 200, alignment: .bottom)
            }
            .frame(width: 150, height: 200)
            
            recipeDetails
            
            Spacer()
        }
        .onAppear(perform: onAppear)
        .navigationDestination(isPresented: $isEditing) {
            editRecipeDestination
        }
    }
    
    @ViewBuilder private var recipeImage: some View {
        if let uiImage = recipe.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 5, height: 5), style: .continuous))
        } else {
            Image(systemName: "list.bullet.clipboard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
                .padding()
                .padding()
                .foregroundStyle(.gray)
                .frame(width: 150, height: 200)
        }
    }
    
    @ViewBuilder private var contextMenuButtons: some View {
        Button {
            isEditing = true
        } label: {
            Label("Edit", systemImage: "pencil")
        }
    
        Button(role: .destructive) {
            modelContext.delete(recipe)
            try? modelContext.save()
            recipe.deleteFromDocumentsDirectory()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder private var recipeDetails: some View {
        Text(recipe.name)
            .multilineTextAlignment(.center)
    }
    
    private var editRecipeDestination: some View {
        EditRecipe(recipe: recipe)
            .navigationTitle("Edit \(recipe.name)")
            .navigationBarBackButtonHidden()
            .onChange(of: recipe.name, onChangeOfRecipeTitle)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Save", action: saveRecipe)
                }
                
                ToolbarItem(placement: .navigation) {
                    Button("Cancel", action: cancelEditingRecipe)
                }
            }
    }
    
    private func onChangeOfRecipeTitle(oldValue: String, newValue: String) {
        if oldValue != newValue {
            changedTitle = oldValue
        }
    }
    
    private func saveRecipe() {
        try? modelContext.save()
        isEditing = false
        
        if let changedTitle {
            Task {
                recipe.deleteFromDocumentsDirectory(overrideURL: recipe.getPDFURL(overrideName: changedTitle))
            }
        }
        
        recipe.saveToDocumentsDirectory()
    }
    
    private func cancelEditingRecipe() {
        modelContext.rollback()
        isEditing = false
    }
    
    private func onAppear() {
        if let photo = recipe.photo {
            recipe.uiImage = UIImage(data: photo)
            recipe.createdDate = recipe.createdDate
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    container.mainContext.insert(Recipe())
    container.mainContext.insert(Recipe())
    container.mainContext.insert(Recipe.exampleRecipe)
    
    return NavigationStack {
        RecipeList()
    }
    .modelContainer(container)
}
