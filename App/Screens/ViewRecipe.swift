import SwiftData
import SwiftUI

struct ViewRecipe: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.canEdit) private var canEdit

    @Bindable var recipe: Recipe

    @State private var showTagPopover = false
    @State private var shareItem: ShareItem?
    @State private var isShowingShareError = false

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
        .sheet(item: $shareItem) { item in
            ShareSheet(url: item.url)
        }
        .alert("Couldn't Create PDF", isPresented: $isShowingShareError) {
            Button("OK", role: .cancel) {}
        }
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
            Button {
                shareRecipe()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
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

    /// Renders the recipe to a PDF right now (nothing is pre-generated or cached to disk) and hands
    /// the resulting file to the system share sheet.
    private func shareRecipe() {
        do {
            let data = try recipe.makePDFData()
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(sanitizedFileName)
                .appendingPathExtension("pdf")
            try data.write(to: url, options: .atomic)
            shareItem = ShareItem(url: url)
        } catch {
            isShowingShareError = true
        }
    }

    private var sanitizedFileName: String {
        let cleaned = recipe.name
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? "Recipe" : cleaned
    }
}

private struct ShareItem: Identifiable {
    let url: URL
    var id: URL { url }
}

/// Wraps the system share sheet so it can be triggered programmatically once the PDF is ready,
/// rather than requiring `ShareLink` to already hold a pre-rendered item.
private struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: url)
        }
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context: Context) {}
}

private struct PopoverView: View {
    @Environment(Recipe.Section.self) private var section
    let value: Step.WordGroup

    @State private var isShowingPopover = false

    var body: some View {
        let phrase = value.words.joined(separator: " ")

        if let color = value.color {
            let button =
                Button(phrase) {
                    isShowingPopover = true
                }
                .tint(color)

            if color == .accent {
                button
                    .popover(isPresented: $isShowingPopover) {
                        VStack {
                            ForEach(section.getIngredients(for: phrase), id: \.id) { ingredient in
                                Text(ingredient.makeAttributedString())
                            }
                        }
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }
            } else if color == .blue, let durations = value.durations {
                button
                    .popover(isPresented: $isShowingPopover) {
                        TimerPopoverContent(name: phrase, durations: durations)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
            } else {
                button
            }
        } else {
            Text(phrase)
        }
    }
}

private struct TimerPopoverContent: View {
    let name: String
    let durations: [Step.ParsedDuration]

    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(durations, id: \.self) { duration in
                Button("Start \(duration.label) Timer", systemImage: "timer") {
                    startTimer(for: duration)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func startTimer(for duration: Step.ParsedDuration) {
        Task {
            do {
                try await RecipeTimerManager.shared.startTimer(named: name, duration: duration.timeInterval)
                dismiss()
            } catch RecipeTimerManager.TimerError.authorizationDenied {
                errorMessage = "Allow alarms for Recipe Book in Settings to start timers."
            } catch {
                errorMessage = "Couldn't start the timer."
            }
        }
    }
}

#Preview {
    NavigationStack {
        ViewRecipe(recipe: .palaminoSauce)
    }
}
