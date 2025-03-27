import PDFKit
import SwiftData
import SwiftUI

struct RecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var recipe: Recipe
    
    @State private var yOffset = 0.0
    @State private var isEditing = false
    @State private var changedTitle: String? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
            
            if isShowingNavBar {
                Color.accentColor.opacity(0.2)
                    .ignoresSafeArea()
            }
            
            if let uiImage = recipe.uiImage, !isShowingNavBar {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .scaleEffect(isShowingNavBar ? 1 : max(1, 1 + (-yOffset * 0.0005)))
                    .animation(.none, value: UUID())
            }
            
            ScrollView {
                VStack(spacing: 0) {
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
                                        .mask(LinearGradient(gradient: Gradient(colors: [colorScheme == .light ? .white : .black, .clear]), startPoint: .bottom, endPoint: .top))
                                    
                                    Rectangle()
                                        .foregroundStyle(Gradient(colors: [.clear, colorScheme == .light ? .white : .black]))
                                        .opacity(0.5)
                                }
                            }
                    }
                    .frame(height: 300, alignment: .bottom)
                    
                    RecipeDetailView(recipe: recipe)
                }
            }
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentOffset.y
            } action: { _, newValue in
                withAnimation {
                    yOffset = newValue
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(recipe.name)
                        .bold()
                        .opacity(isShowingNavBar ? 1 : 0)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    let color: Color = isShowingNavBar ? .accentColor : .white
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(isShowingNavBar ? .semibold : .heavy)
                            .font(isShowingNavBar ? .body : .system(size: 13))
                            .foregroundStyle(color == .white ? colorScheme == .light ? .black : .white : color)
                    }
                    .buttonStyle(.borderless)
                    .tint(isShowingNavBar ? .accentColor : .white)
                    .padding(isShowingNavBar ? 0 : 8)
                    .background {
                        ToolbarButton(systemName: nil, color: isShowingNavBar ? .accentColor : .white) {
                            dismiss()
                        }
                        .opacity(!isShowingNavBar ? 1 : 0)
                    }
                    .offset(x: isShowingNavBar ? -8 : 0)
                }
                
                ToolbarItem {
                    let color: Color = isShowingNavBar ? .accentColor : .white
                    let label =
                        Group {
                            let symbol =
                                Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.heavy)
                                .frame(width: 15, height: 15)
                                .scaleEffect(1.3)
                            Group {
                                if color == .white {
                                    symbol
                                        .foregroundStyle(.foreground)
                                } else {
                                    symbol
                                }
                            }
                        }
                        
                    Group {
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
                    }
                    .buttonStyle(.bordered)
                    .tint(color)
                    .background(.ultraThickMaterial)
                    .clipShape(Circle())
                    .frame(width: 30, height: 30)
                }
                    
                ToolbarItem {
                    ToolbarButton(systemName: "pencil", color: isShowingNavBar ? .accentColor : .white) {
                        isEditing = true
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbarBackground(!isShowingNavBar ? .hidden : .visible, for: .navigationBar)
        .navigationDestination(isPresented: $isEditing) {
            EditRecipe(recipe: recipe)
                .navigationTitle("Edit \(recipe.name)")
                .navigationBarBackButtonHidden()
                .onChange(of: recipe.name) { oldValue, newValue in
                    if oldValue != newValue {
                        changedTitle = oldValue
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Save") {
                            try? modelContext.save()
                            isEditing = false
                            
                            if let changedTitle {
                                Task {
                                    recipe.deleteFromDocumentsDirectory(overrideURL: recipe.getPDFURL(overrideName: changedTitle))
                                }
                            }
                            
                            recipe.saveToDocumentsDirectory()
                        }
                    }
                    
                    ToolbarItem(placement: .navigation) {
                        Button("Cancel") {
                            modelContext.rollback()
                            isEditing = false
                        }
                    }
                }
        }
    }
    
    private var isShowingNavBar: Bool {
        yOffset > 200
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    return NavigationStack {
        RecipeView(recipe: Recipe.exampleRecipe)
    }
    .modelContainer(container)
}
