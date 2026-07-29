import SwiftData
import SwiftUI

struct RecipeList: View {
    @Environment(\.modelContext) private var modelContext
    
    let recipes: [Recipe]
    
    @State private var showAddRecipeSheet = false
    @State private var showInfoSheet = false
    @State private var recipeToView: Recipe?
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HFlow(spacing: .init(width: 20, height: 20), distributeItemsEvenly: true) {
                    ForEach(recipes, id: \.id) { recipe in
                        RecipeLink(recipe: recipe, namespace: namespace) { recipe in
                            recipeToView = recipe
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .fullScreenCover(item: $recipeToView) { recipe in
                NavigationStack {
                    ViewRecipe(recipe: recipe)
                }
                .navigationTransition(.zoom(sourceID: recipe.id, in: namespace))
            }
            .navigationDestination(for: Recipe.self) { recipe in
                EditRecipe(recipe: recipe)
            }
        }
    }
}

private struct RecipeLink: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.canEdit) private var canEdit
    
    let recipe: Recipe
    let namespace: Namespace.ID
    let onSelect: (Recipe) -> Void
    
    var body: some View {
        Button {
            onSelect(recipe)
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.accent.gradient.opacity(0.5))
                .overlay {
                    recipeImage
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    Text(recipe.name)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 10))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .matchedTransitionSource(id: recipe.id, in: namespace)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                .containerRelativeFrame(.horizontal) { length, _ in
                    length / 2 - 40
                }
                .containerRelativeFrame(.vertical) { _, _ in
                    200
                }
                .contextMenu {
                    if canEdit {
                        contextMenuButtons
                    }
                }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder private var recipeImage: some View {
        if let uiImage = recipe.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fill)
        } else {
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
    
    @ViewBuilder private var contextMenuButtons: some View {
        Button(role: .destructive) {
            modelContext.delete(recipe)
            try? modelContext.save()
            recipe.deleteFromDocumentsDirectory()
        } label: {
            Label("Delete", systemImage: "trash")
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
