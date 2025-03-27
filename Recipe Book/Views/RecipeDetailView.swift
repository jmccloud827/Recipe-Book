import PDFKit
import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                if !recipe.dishDescription.isEmpty {
                    Section {
                        GroupBox {
                            Text(recipe.dishDescription)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } header: {
                        Text("Description")
                            .font(.title)
                            .bold()
                            .padding(.top)
                            .padding(.bottom, 5)
                    }
                }
                
                if !recipe.tags.isEmpty {
                    Section {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 5) {
                            ForEach(Array(recipe.tags), id: \.self) { item in
                                Button(item.rawValue) {}
                                    .buttonStyle(.bordered)
                            }
                        }
                    } header: {
                        Text("Tags")
                            .font(.title)
                            .bold()
                            .padding(.top)
                            .padding(.bottom, 5)
                    }
                }
                
                Section {
                    ForEach(recipe.ingredients, id: \.id) { ingredient in
                        Label(ingredient.name, systemImage: "square")
                            .padding(.horizontal)
                            .padding(.vertical, 2)
                    }
                } header: {
                    Text("Ingredients")
                        .font(.title)
                        .bold()
                        .padding(.top)
                        .padding(.bottom, 5)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            VStack {
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
                    Text("Steps")
                        .font(.title)
                        .bold()
                        .padding(.bottom)
                        .padding(.top, 5)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 300, alignment: .topLeading)
            .padding(.horizontal)
            .background {
                Color.accent.opacity(0.2)
                    .clipShape(
                        .rect(topLeadingRadius: 30,
                              bottomLeadingRadius: 0,
                              bottomTrailingRadius: 0,
                              topTrailingRadius: 30)
                    )
            }
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(.background)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    return NavigationStack {
        ScrollView {
            RecipeDetailView(recipe: Recipe.exampleRecipe)
        }
    }
    .modelContainer(container)
}
