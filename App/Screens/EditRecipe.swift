import SwiftData
import SwiftUI

struct EditRecipe: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var recipe: Recipe
    
    @State private var showConfirmationDialog = false
    @State private var originalName: String
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.originalName = recipe.name
    }
    
    var body: some View {
        Form {
            nameAndTagsSection
            
            servingsAndCookTimeSection
                
            imageSection
                
            ForEach(recipe.sections, id: \.id) { section in
                EditableSection(recipe: recipe, section: section)
            }

            Section {
                Button("Add Section", systemImage: "plus") {
                    recipe.sections.append(.init(belongsTo: recipe))
                }
            }
        }
        .toolbar {
            EditButton()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Done", systemImage: "checkmark", role: .confirm) {
                    try? modelContext.save()
                    
                    recipe.deleteFromDocumentsDirectory(overrideURL: recipe.getPDFURL(overrideName: originalName))
                        
                    recipe.saveToDocumentsDirectory()
                    
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigation) {
                Button("Cancel", systemImage: "xmark") {
                    showConfirmationDialog = true
                }
                .confirmationDialog("Are you sure you want leave without saving?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                    Button("Discard Changes?", role: .destructive) {
                        modelContext.rollback()
                        dismiss()
                    }
                        
                    Button("Keep Editing", role: .cancel) {}
                }
            }
        }
        .interactiveDismissDisabled()
        .navigationBarBackButtonHidden()
        .navigationTitle(recipe.name)
    }
    
    private var nameAndTagsSection: some View {
        Section {
            TextInputField(text: recipe.name, label: "Name") { recipe.name = $0 }
            
            NavigationLink {
                List {
                    ForEach(Tag.allCases, id: \.self) { tag in
                        makeTagButton(tag)
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
    }
    
    private var servingsAndCookTimeSection: some View {
        Section {
            Picker("Servings", selection: $recipe.servings) {
                ForEach(1 ... 100, id: \.self) { number in
                    Text("\(number)")
                }
            }
            
            Picker("Cook Time", selection: $recipe.cookTimeInMinutes) {
                ForEach(0 ... 200, id: \.self) { number in
                    Text("\(number) min")
                }
            }
        }
    }
    
    private func makeTagButton(_ tag: Tag) -> some View {
        Button {
            withAnimation {
                if recipe.tags.contains(tag) {
                    _ = recipe.tags.remove(tag)
                } else {
                    _ = recipe.tags.insert(tag)
                }
            }
        } label: {
            HStack {
                Text(tag.rawValue)
                
                if recipe.tags.contains(tag) {
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
            }
            .foregroundStyle(.foreground)
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                Text("Photo")
                    .padding(.vertical, 5)
                
                Spacer()
                
                imagePicker
                
                if recipe.photo != nil {
                    Button(role: .destructive) {
                        withAnimation {
                            recipe.photo = nil
                        }
                    } label: {
                        Label("Remove", systemImage: "xmark")
                    }
                    .buttonStyle(.plain)
                    .labelStyle(.iconOnly)
                }
            }
        }
    }
       
    private var imagePicker: some View {
        ImagePicker(data: $recipe.photo) { show in
            if let uiImage = recipe.uiImage {
                HStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 50)
                }
            } else {
                Button("Tap to add") {
                    show.wrappedValue = true
                }
                .padding(.vertical, 5)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

private struct EditableSection: View {
    let recipe: Recipe
    @Bindable var section: Recipe.Section
    
    @State private var isEditingIngredients = false
    @State private var editingIngredientIndex: Int? = nil
    
    var body: some View {
        Section {} footer: {
            let sectionNameTextField = TextField("Section name", text: $section.name)
            if let editingIngredientIndex {
                sectionNameTextField
                    .sheet(isPresented: .constant(true), onDismiss: { self.editingIngredientIndex = nil }) {
                        NavigationStack {
                            EditEditingIngredientView(ingredient: section.ingredients[editingIngredientIndex], editingIngredientIndex: self.$editingIngredientIndex)
                            .toolbar {
                                ToolbarItem {
                                    Button("Previous", systemImage: "chevron.left") {
                                        self.editingIngredientIndex! -= 1
                                    }
                                    .disabled(editingIngredientIndex <= 0)
                                }
                                
                                ToolbarItem {
                                    Button("Next", systemImage: "chevron.right") {
                                        self.editingIngredientIndex! += 1
                                    }
                                    .disabled(editingIngredientIndex >= section.ingredients.count - 1)
                                }
                                
                                ToolbarSpacer()
                                
                                ToolbarItem {
                                    Button("Add", systemImage: "plus") {
                                        section.ingredients.append(.init(belongsTo: section))
                                        self.editingIngredientIndex = section.ingredients.count - 1
                                    }
                                }
                            }
                        }
                        .presentationDetents([.height(300)])
                    }
            } else {
                sectionNameTextField
            }
        }
        .listSectionMargins(.all, 0)
        .font(.title2)
        .listSectionSpacing(.default)
        
        ingredients
            .listSectionSpacing(5)
                
        steps
    }
    
    @ViewBuilder private var ingredients: some View {
        Section {
            ForEach(section.ingredients, id: \.id) { ingredient in
                makeIngredientRow(ingredient)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    section.ingredients.remove(at: index)
                }
            }
            .onMove { source, destination in
                section.ingredients.move(fromOffsets: source, toOffset: destination)
            }
            
            addIngredientButton
                .scrollDismissesKeyboard(.immediately)
        } header: {
            Text("Ingredients")
        }
    }
    
    private func makeIngredientRow(_ ingredient: Ingredient) -> some View {
        HStack {
            Image(systemName: "square")
            
            Button {
                editingIngredientIndex = section.ingredients.firstIndex { $0.id == ingredient.id }
                isEditingIngredients = true
            } label: {
                Text(ingredient.makeAttributedString())
            }
            .foregroundStyle(.foreground)
        }
    }
    
    private var addIngredientButton: some View {
        Button("Add Ingredient", systemImage: "plus") {
            section.ingredients.append(.init(belongsTo: section))
        }
    }
    
    @ViewBuilder private var steps: some View {
        Section {
            ForEach(section.steps.enumerated(), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 0) {
                    Image(systemName: "\(index + 1).circle.fill")
                        .foregroundStyle(.blue)
                        .padding(.top, 9)
                    
                    @Bindable var step = step
                        TextEditor(text: $step.attributedText)
                            .scrollBounceBehavior(.basedOnSize)
                            .scrollDismissesKeyboard(.interactively)
                    .frame(height: 100)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    section.steps.remove(at: index)
                }
            }
            .onMove { source, destination in
                section.steps.move(fromOffsets: source, toOffset: destination)
            }
                        
            addStepButton
        } header: {
            Text("Steps")
        }
    }
    
    private var addStepButton: some View {
        Button("Add Step", systemImage: "plus") {
            section.steps.append(.init(belongsTo: section))
        }
    }
}

private struct EditEditingIngredientView: View {
    @Bindable var ingredient: Ingredient
    @Binding var editingIngredientIndex: Int?
    
    var body: some View {
            Form {
                TextInputField(text: ingredient.amount, label: "Amount") { ingredient.amount = $0 }
                    
                Picker("Measurement", selection: $ingredient.measurement) {
                    ForEach(Ingredient.Measurement.allCases, id: \.hashValue) { measurement in
                        Text(measurement.rawValue)
                            .tag(measurement)
                    }
                }
                    
                TextInputField(text: ingredient.name, label: "Name") { ingredient.name = $0 }
            }
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(ingredient.makeAttributedString())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EditRecipe(recipe: .palaminoSauce)
    }
}
