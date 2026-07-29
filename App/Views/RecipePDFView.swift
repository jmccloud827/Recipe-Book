import PDFKit
import QuickLook
import SwiftData
import SwiftUI

struct RecipePDFView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                label
                
                makeSectionTitle("Ingredients")
                
                ingredients
                
                makeSectionTitle("Steps")
                
                steps
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 40)
        .background(.white)
        .colorScheme(.light)
    }
    
    private var label: some View {
        HStack {
            if let data = recipe.photo,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .bold()
                    .font(.title)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Text("Serves: \(recipe.servings)")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Cook time: \(recipe.cookTimeInMinutes) min")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private var ingredients: some View {
        ForEach(recipe.sections, id: \.id) { section in
            makeSubSectionTitle(section.name)
                        
            ForEach(section.ingredients, id: \.id) { ingredient in
                makeRow {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "square")
                            
                        Text(ingredient.makeAttributedString())
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
    
    private var steps: some View {
        ForEach(recipe.sections, id: \.id) { section in
            makeSubSectionTitle(section.name)
                        
            ForEach(section.steps.enumerated(), id: \.element.id) { index, step in
                makeRow {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "\(index + 1).circle.fill")
                            .foregroundStyle(.blue)
                            
                        Text(step.attributedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .environment(section)
        }
    }
    
    @ViewBuilder private func makeSectionTitle(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title2)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
            
            Rectangle()
                .fill(.black)
                .frame(height: 2)
                .padding(.bottom, 5)
        }
    }
    
    @ViewBuilder private func makeSubSectionTitle(_ title: String) -> some View {
        Text(title)
            .bold()
            .font(.title3)
            .foregroundStyle(.gray)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 5)
            .padding(.leading, 15)
    }
    
    private func makeRow(label: () -> some View) -> some View {
        label()
            .padding(.vertical, 5)
            .padding(.leading, 30)
    }
}

@MainActor enum RecipePDFExporter {
    private static let usLetterRect = CGRect(origin: .zero, size: .init(width: 612, height: 792))

    nonisolated static func url(for recipe: Recipe, overrideName: String? = nil) -> URL {
        URL.documentsDirectory.appending(path: (overrideName ?? recipe.name) + recipe.id.uuidString + ".pdf")
    }

    static func save(_ recipe: Recipe) {
        let view = RecipePDFView(recipe: recipe).frame(width: usLetterRect.width)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3

        guard let uiImage = renderer.uiImage else {
            return
        }

        let pdf = PDFDocument()

        let numberOfPages = Int(ceil(uiImage.size.height / usLetterRect.height))
        for page in 0 ..< numberOfPages {
            let pageRenderer = ImageRenderer(content: view.frame(height: usLetterRect.height, alignment: .top).offset(y: -usLetterRect.height * Double(page)))
            pageRenderer.scale = 3

            if let pageImage = pageRenderer.uiImage,
               let pdfPage = PDFPage(image: pageImage) {
                pdf.insert(pdfPage, at: pdf.pageCount)
            }
        }

        pdf.write(to: url(for: recipe))
    }

    static func delete(_ recipe: Recipe, overrideURL: URL? = nil) {
        try? FileManager.default.removeItem(at: overrideURL ?? url(for: recipe))
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    let recipe = Recipe.palaminoSauce
    recipe.saveToDocumentsDirectory()
    
    return PreviewController(pdfURL: recipe.pdfURL)
        .ignoresSafeArea()
    
    struct PreviewController: UIViewControllerRepresentable {
        let pdfURL: URL
        
        func makeUIViewController(context: Context) -> QLPreviewController {
            let controller = QLPreviewController()
            controller.dataSource = context.coordinator
            return controller
        }
        
        func updateUIViewController(_: QLPreviewController, context _: Context) {}
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }
        
        class Coordinator: QLPreviewControllerDataSource {
            let parent: PreviewController
            
            init(parent: PreviewController) {
                self.parent = parent
            }
            
            func numberOfPreviewItems(in _: QLPreviewController) -> Int {
                return 1
            }
            
            func previewController(_: QLPreviewController,
                                   previewItemAt _: Int) -> QLPreviewItem {
                return parent.pdfURL as NSURL
            }
        }
    }
}
