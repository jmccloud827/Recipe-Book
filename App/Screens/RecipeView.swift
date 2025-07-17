import PDFKit
import SwiftData
import SwiftUI

struct RecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var recipe: Recipe
    
    @State private var yOffset = 0.0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
            
            if isShowingNavBar {
                Color.accentColor.opacity(0.2)
                    .ignoresSafeArea()
            }
            
            image
            
            ScrollView {
                VStack(spacing: 0) {
                    title
                        .frame(height: 300, alignment: .bottom)
                    
                    RecipeDetails(recipe: recipe)
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
                    navigationTitle
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                
                ToolbarItem {
                    shareButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbarBackground(!isShowingNavBar ? .hidden : .visible, for: .navigationBar)
    }
    
    @ViewBuilder private var image: some View {
        if let uiImage = recipe.uiImage, !isShowingNavBar {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .scaleEffect(isShowingNavBar ? 1 : max(1, 1 + (-yOffset * 0.0005)))
                .animation(.none, value: UUID())
        }
    }
    
    private var title: some View {
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
    
    private var navigationTitle: some View {
        Text(recipe.name)
            .bold()
            .opacity(isShowingNavBar ? 1 : 0)
    }
    
    @ViewBuilder private var backButton: some View {
        Button("Close", systemImage: "xmark") {
            dismiss()
        }
    }
    
    @ViewBuilder private var shareButton: some View {
        let label = Image(systemName: "square.and.arrow.up")
            
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
    
    private var isShowingNavBar: Bool {
        yOffset > 200
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    return NavigationStack {
        RecipeView(recipe: Recipe.sample)
    }
    .modelContainer(container)
}
