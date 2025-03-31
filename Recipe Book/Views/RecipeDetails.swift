import PDFKit
import SwiftData
import SwiftUI

struct RecipeDetails: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                if !recipe.dishDescription.isEmpty {
                    descriptionSection
                }
                
                if !recipe.tags.isEmpty {
                    tagsSection
                }
                
                ingredientsSection
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            stepsSection
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(.background)
    }
    
    private var descriptionSection: some View {
        Section {
            GroupBox {
                Text(recipe.dishDescription)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } header: {
            makeSectionTitle("Description")
        }
    }
    
    private var tagsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 5) {
                ForEach(Array(recipe.tags), id: \.self) { item in
                    Button(item.rawValue) {}
                        .buttonStyle(.bordered)
                }
            }
        } header: {
            makeSectionTitle("Tags")
        }
    }
    
    private var ingredientsSection: some View {
        Section {
            ForEach(recipe.ingredients, id: \.id) { ingredient in
                Label(ingredient.name, systemImage: "square")
                    .padding(.horizontal)
                    .padding(.vertical, 2)
            }
        } header: {
            makeSectionTitle("Ingredients")
        }
    }
    
    private var stepsSection: some View {
        Section {
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                VStack(alignment: .leading) {
                    Text("\(index + 1). " + step.name)
                        .bold()
                        
                    Text(step.description)
                }
                .padding(.vertical, 2)
            }
        } header: {
            makeSectionTitle("Steps")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, minHeight: 300, alignment: .topLeading)
        .padding(.horizontal)
        .background {
            Color.accent.opacity(0.2)
                .clipShape(.rect(topLeadingRadius: 30,
                                 bottomLeadingRadius: 0,
                                 bottomTrailingRadius: 0,
                                 topTrailingRadius: 30))
        }
    }
    
    private func makeSectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title)
            .bold()
            .padding(.top)
            .padding(.bottom, 5)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    return NavigationStack {
        ScrollView {
            RecipeDetails(recipe: Recipe.exampleRecipe)
        }
    }
    .modelContainer(container)
}
