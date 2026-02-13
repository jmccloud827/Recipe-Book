import SwiftData
import SwiftUI

struct RecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.canEdit) private var canEdit
    
    @Bindable var recipe: Recipe
    
    var body: some View {
        FancyHeader(title: recipe.name) {
            RecipeDetails(recipe: recipe)
        } label: {
            title
                .padding()
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
        } background: {
            image
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
            
            ToolbarItem {
                optionsMenu
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder private var image: some View {
        if let uiImage = recipe.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Rectangle()
                .foregroundStyle(Color.accent.gradient)
        }
    }
    
    private var title: some View {
        Text(recipe.name)
            .bold()
            .font(.title)
    }
    
    @ViewBuilder private var backButton: some View {
        Button("Close", systemImage: "xmark") {
            dismiss()
        }
    }
    
    @ViewBuilder private var optionsMenu: some View {
        Menu {
            let label = Label("Share", systemImage: "square.and.arrow.up")
            
            if let previewImage = recipe.uiImage {
                ShareLink(item: recipe.pdfURL,
                          preview: SharePreview(recipe.name, image: Image(uiImage: previewImage))) {
                    label
                }
            } else {
                ShareLink(item: recipe.pdfURL,
                          preview: SharePreview(recipe.name)) {
                    label
                }
            }
            
            if canEdit {
                NavigationLink {
                    EditRecipe(recipe: recipe)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        } label: {
            Label("Options", systemImage: "ellipsis")
        }
    }
}

#Preview {
    NavigationStack {
        RecipeView(recipe: .palaminoSauce)
    }
}
