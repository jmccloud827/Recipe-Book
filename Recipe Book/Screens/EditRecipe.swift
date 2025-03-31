import SwiftData
import SwiftUI

struct EditRecipe: View {
    @Bindable var recipe: Recipe
    
    var body: some View {
        Form {
            tagsSection
             
            descriptionsSection
                
            imageSection
                
            ingredientsNavigationLink
            
            stepsNavigationLink
        }
    }
    
    private var tagsSection: some View {
        Section {
            TextInputField(text: $recipe.name, label: "Name")
            
            NavigationLink {
                List {
                    ForEach(Category.allCases, id: \.self) { category in
                        makeCategoryButton(category)
                    }
                }
                .animation(.default, value: UUID())
                .navigationTitle("Tags")
                .navigationBarTitleDisplayMode(.inline)
            } label: {
                tagsLabel
            }
        }
    }
    
    private func makeCategoryButton(_ category: Category) -> some View {
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
    
    private var tagsLabel: some View {
        LabeledContent("Tags") {
            Text("\(recipe.tags.count) added")
        }
    }
    
    private var descriptionsSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Description")
                    .padding(.vertical, 5)
                
                Divider()
                
                descriptionTextEditor
            }
        }
    }
    
    private var descriptionTextEditor: some View {
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
    
    private var imageSection: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Image")
                    .padding(.vertical, 5)
                
                Divider()
                
                imagePicker
            }
        }
    }
       
    private var imagePicker: some View {
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
    
    private var ingredientsNavigationLink: some View {
        NavigationLink {
            List {
                ForEach($recipe.ingredients, id: \.id) { $ingredient in
                    makeIngredientRow($ingredient)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        recipe.ingredients.remove(at: index)
                    }
                }
                .onMove { source, destination in
                    recipe.ingredients.move(fromOffsets: source, toOffset: destination)
                }
                    
                addIngredientButton
            }
            .toolbar {
                EditButton()
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Ingredients")
        } label: {
            ingredientsLabel
        }
    }
    
    private func makeIngredientRow(_ ingredient: Binding<Ingredient>) -> some View {
        HStack {
            Image(systemName: "circle")
            
            TextField(ingredient.wrappedValue.name, text: ingredient.name)
        }
    }
    
    private var addIngredientButton: some View {
        Button("Add Ingredient") {
            recipe.ingredients.append(.init(name: ""))
        }
    }
    
    private var ingredientsLabel: some View {
        LabeledContent("Ingredients") {
            Text("\(recipe.ingredients.count)")
        }
    }
    
    private var stepsNavigationLink: some View {
        NavigationLink {
            List {
                ForEach(Array($recipe.steps.enumerated()), id: \.element.id) { index, $step in
                    makeStepRow($step, index: index)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        recipe.steps.remove(at: index)
                    }
                }
                .onMove { source, destination in
                    recipe.steps.move(fromOffsets: source, toOffset: destination)
                }
                    
                addStepButton
            }
            .toolbar {
                EditButton()
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Steps")
        } label: {
            stepsLabel
        }
    }
    
    private func makeStepRow(_ step: Binding<Step>, index: Int) -> some View {
        Section {
            VStack {
                HStack {
                    Text("\(index + 1).")
                    
                    TextField("Name", text: step.name)
                }
                    .padding(.top, 4)
                
                Divider()
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: step.description)
                        .scrollBounceBehavior(.basedOnSize)
                        .scrollDismissesKeyboard(.interactively)
                    
                    if step.description.wrappedValue.isEmpty {
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
    
    private var addStepButton: some View {
        Button("Add Step") {
            recipe.steps.append(.init(name: "", description: ""))
        }
    }
    
    private var stepsLabel: some View {
        LabeledContent("Steps") {
            Text("\(recipe.steps.count)")
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
