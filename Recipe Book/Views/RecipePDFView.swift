import SwiftData
import SwiftUI

struct RecipePDFView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                if let data = recipe.photo,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                
                VStack {
                    Text(recipe.name)
                        .bold()
                        .font(.title)
                        .foregroundStyle(.foreground.opacity(0.7))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background {
                            ZStack(alignment: .top) {
                                Rectangle()
                                    .foregroundStyle(.thinMaterial)
                                    .mask(LinearGradient(gradient: Gradient(colors: [.white, .clear]), startPoint: .bottom, endPoint: .top))
                                
                                Rectangle()
                                    .foregroundStyle(Gradient(colors: [.clear, .white]))
                                    .opacity(0.5)
                            }
                        }
                }
            }
            .frame(height: 300, alignment: .bottom)
            
            RecipeDetailView(recipe: recipe)
        }
    }
}

#Preview {
    ScrollView {
        RecipePDFView(recipe: Recipe.exampleRecipe)
    }
}
