import SwiftData
import SwiftUI

struct ViewRecipe: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.canEdit) private var canEdit
    
    @Bindable var recipe: Recipe
    
    @State private var showTagPopover = false
    
    var body: some View {
        FancyHeader(title: recipe.name) {
            details
        } label: {
            title
                .padding()
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
        } background: {
            image
                .frame(height: 350)
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
            .multilineTextAlignment(.center)
    }
    
    private var details: some View {
        VStack(alignment: .leading) {
            servingsAndCookTime
            
            ingredients
            
            steps
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(.background)
    }
    
    private var servingsAndCookTime: some View {
        Section {
            HStack {
                Group {
                    VStack {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(.gray)
                            
                            Text("\(recipe.servings)")
                        }
                        
                        Text("Servings")
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.gray)
                            
                            Text("\(recipe.cookTimeInMinutes)")
                        }
                        
                        Text("Minutes")
                    }
                    .frame(maxWidth: .infinity)
                       
                    VStack {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundStyle(.gray)
                            
                            Text("\(recipe.tags.count)")
                        }
                        
                        Text("Tags")
                    }
                    .onTapGesture {
                        showTagPopover = true
                    }
                    .popover(isPresented: $showTagPopover) {
                        tags
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }
                }
                .padding(20)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.bottom)
        }
    }
    
    private var tags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center) {
                ForEach(Array(recipe.tags).sorted { $0.rawValue < $1.rawValue }, id: \.self) { item in
                    Text(item.rawValue)
                        .foregroundStyle(.accent)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(.systemGray5))
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .safeAreaPadding(.horizontal, 20)
    }
    
    private var ingredients: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(recipe.sections, id: \.id) { section in
                    Text(section.name)
                        .bold()
                    
                    ForEach(section.ingredients, id: \.id) { ingredient in
                        makeIngredientLabel(ingredient)
                    }
                    .padding(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
            .padding(.bottom)
        } header: {
            makeSectionTitle("Ingredients")
        }
    }
    
    private var steps: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(recipe.sections, id: \.id) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(section.name)
                            .bold()
                        
                        ForEach(section.steps.enumerated(), id: \.element.id) { index, step in
                            makeStepLabel(step, ingredients: section.ingredients, index: index)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    .environment(section)
                }
            }
        } header: {
            makeSectionTitle("Steps")
        }
    }
    
    private func makeIngredientLabel(_ ingredient: Ingredient) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "square")
            
            Text(ingredient.makeAttributedString())
        }
    }
    
    private func makeStepLabel(_ step: Step, ingredients _: [Ingredient], index: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "\(index + 1).circle.fill")
                .foregroundStyle(.blue)
            
            HFlow(spacing: .init(width: 5, height: 0)) {
                ForEach(step.getWordsWithAttributes().enumerated(), id: \.offset) { _, value in
                    PopoverView(value: value)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 30))
    }
        
    private func makeSectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
            .padding(.bottom, 5)
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

private struct PopoverView: View {
    @Environment(Recipe.Section.self) private var section
    let value: (word: String, color: Color?)
    
    @State private var isShowingPopover = false
    
    var body: some View {
        if let color = value.color {
            let button =
                Button(value.word) {
                    isShowingPopover = true
                }
                .tint(color)
            
            if color == .accent {
                button
                    .popover(isPresented: $isShowingPopover) {
                        VStack {
                            ForEach(section.getIngredients(for: value.word), id: \.id) { ingredient in
                                Text(ingredient.makeAttributedString())
                            }
                        }
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }
            } else {
                button
            }
        } else {
            Text(value.word)
        }
    }
}

#Preview {
    NavigationStack {
        ViewRecipe(recipe: .palaminoSauce)
    }
}
