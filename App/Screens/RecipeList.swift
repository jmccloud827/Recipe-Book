import SwiftData
import SwiftUI

struct RecipeList: View {
    @Environment(\.modelContext) private var modelContext
    
    let recipes: [Recipe]

    @State private var recipeToView: RecipeSelection?
    @Namespace private var namespace

    private let samples = Recipe.samples

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if recipes.isEmpty {
                    emptyState
                } else {
                    Text("My Recipes")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    recipeGrid(recipes, canEdit: true)
                }

                if !samples.isEmpty {
                    Text("Samples")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    recipeGrid(samples, canEdit: false)
                }
            }
            .padding(.vertical)
        }
        .fullScreenCover(item: $recipeToView) { selection in
            NavigationStack {
                ViewRecipe(recipe: selection.recipe)
            }
            .environment(\.canEdit, selection.canEdit)
            .navigationTransition(.zoom(sourceID: selection.recipe.id, in: namespace))
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Recipes Yet", systemImage: "fork.knife")
        } description: {
            Text("Recipes you add will show up here. Tap the pencil icon below to create your first one.")
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }

    private func recipeGrid(_ recipes: [Recipe], canEdit: Bool) -> some View {
        HFlow(spacing: .init(width: 20, height: 20)) {
            ForEach(recipes, id: \.id) { recipe in
                RecipeLink(recipe: recipe, namespace: namespace) { recipe in
                    recipeToView = RecipeSelection(recipe: recipe, canEdit: canEdit)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .environment(\.canEdit, canEdit)
    }
}

/// A recipe selected for full-screen viewing, paired with whether it came from a list the user is
/// allowed to edit — carried alongside the recipe so the presented screen doesn't have to re-derive it.
private struct RecipeSelection: Identifiable {
    let recipe: Recipe
    let canEdit: Bool
    var id: Recipe.ID { recipe.id }
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
    
    private var contextMenuButtons: some View {
        Button(role: .destructive) {
            modelContext.delete(recipe)
            try? modelContext.save()
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
