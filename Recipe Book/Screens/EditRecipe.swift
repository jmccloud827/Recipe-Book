import SwiftData
import SwiftUI

struct EditRecipe: View {
    @Bindable var recipe: Recipe
    
    var body: some View {
        Form {
            Section {
                TextInputField(text: $recipe.name, label: "Name")
                
                NavigationLink {
                    List {
                        ForEach(Category.allCases, id: \.self) { category in
                            Button {
                                withAnimation {
                                    if recipe.tags.contains(category) {
                                        _ = recipe.tags.remove(category)
                                    } else {
                                        _ = recipe.tags.insert(category)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(category.rawValue)
                                    
                                    if recipe.tags.contains(category) {
                                        Spacer()
                                        
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.accent)
                                    }
                                }
                                .foregroundStyle(.foreground)
                            }
                        }
                    }
                    .animation(.default, value: UUID())
                    .navigationTitle("Tags")
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
                    LabeledContent("Tags") {
                        Text("\(recipe.tags.count) added")
                    }
                }
            }
             
            Section {
                VStack(alignment: .leading) {
                    Text("Description")
                        .padding(.vertical, 5)
                    
                    Divider()
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $recipe.dishDescription)
                            .scrollBounceBehavior(.basedOnSize)
                            .scrollDismissesKeyboard(.interactively)
                        
                        if recipe.dishDescription.isEmpty {
                            Text("Type here")
                                .foregroundStyle(Color(.systemGray3))
                                .font(.system(size: 17))
                                .offset(x: 5, y: 8)
                        }
                    }
                    .frame(idealHeight: 100)
                }
            }
                
            Section {
                VStack(alignment: .leading) {
                    Text("Image")
                        .padding(.vertical, 5)
                    
                    Divider()
                    
                    ImagePicker(data: $recipe.photo) { show in
                        if let uiImage = recipe.uiImage {
                            VStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        } else {
                            Button("Tap to add") {
                                show.wrappedValue = true
                            }
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .controlSize(.large)
                        }
                    }
                }
            }
                
            NavigationLink {
                List {
                    ForEach($recipe.ingredients, id: \.id) { $ingredient in
                        HStack {
                            Image(systemName: "circle")
                            
                            TextField(ingredient.name, text: $ingredient.name)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            recipe.ingredients.remove(at: index)
                        }
                    }
                    .onMove { source, destination in
                        recipe.ingredients.move(fromOffsets: source, toOffset: destination)
                    }
                        
                    Button("Add Ingredient") {
                        recipe.ingredients.append(.init(name: ""))
                    }
                }
                .toolbar {
                    EditButton()
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle("Ingredients")
            } label: {
                LabeledContent("Ingredients") {
                    Text("\(recipe.ingredients.count)")
                }
            }
            
            NavigationLink {
                List {
                    ForEach(Array($recipe.steps.enumerated()), id: \.element.id) { index, $step in
                        Section {
                            VStack {
                                HStack {
                                    Text("\(index + 1).")
                                    
                                    TextField("Name", text: $step.name)
                                }
                                    .padding(.top, 4)
                                
                                Divider()
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $step.description)
                                        .scrollBounceBehavior(.basedOnSize)
                                        .scrollDismissesKeyboard(.interactively)
                                    
                                    if $step.description.wrappedValue.isEmpty {
                                        Text("Description")
                                            .foregroundStyle(Color(.systemGray3))
                                            .font(.system(size: 17))
                                            .offset(x: 5, y: 8)
                                    }
                                }
                                .frame(idealHeight: 100)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            recipe.steps.remove(at: index)
                        }
                    }
                    .onMove { source, destination in
                        recipe.steps.move(fromOffsets: source, toOffset: destination)
                    }
                        
                    Button("Add Step") {
                        recipe.steps.append(.init(name: "", description: ""))
                    }
                }
                .toolbar {
                    EditButton()
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle("Steps")
            } label: {
                LabeledContent("Steps") {
                    Text("\(recipe.steps.count)")
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    return NavigationStack {
        EditRecipe(recipe: Recipe())
    }
    .modelContainer(container)
}
