import PDFKit
import QuickLook
import SwiftData
import SwiftUI

/// Builds the flat, ordered list of content blocks that make up a recipe's PDF. Each block (the
/// header, a section title, one ingredient, one step) is measured and rendered as a single
/// unsplittable unit by `RecipePDFExporter`, so page breaks always fall between blocks — never
/// through the middle of an ingredient or step.
@MainActor enum RecipePDFContent {
    static func blocks(for recipe: Recipe) -> [AnyView] {
        var blocks: [AnyView] = [AnyView(label(for: recipe))]

        blocks.append(AnyView(sectionTitle("Ingredients")))
        for section in recipe.sections {
            blocks.append(AnyView(subSectionTitle(section.name)))

            for ingredient in section.ingredients {
                blocks.append(AnyView(ingredientRow(ingredient)))
            }
        }

        blocks.append(AnyView(sectionTitle("Steps")))
        for section in recipe.sections {
            blocks.append(AnyView(subSectionTitle(section.name)))

            for (index, step) in section.steps.enumerated() {
                blocks.append(AnyView(stepRow(step, index: index)))
            }
        }

        return blocks
    }

    private static func label(for recipe: Recipe) -> some View {
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

    private static func sectionTitle(_ title: String) -> some View {
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

    private static func subSectionTitle(_ title: String) -> some View {
        Text(title)
            .bold()
            .font(.title3)
            .foregroundStyle(.gray)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 5)
            .padding(.leading, 15)
    }

    private static func ingredientRow(_ ingredient: Ingredient) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "square")

            Text(ingredient.makeAttributedString())
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
        .padding(.leading, 30)
    }

    private static func stepRow(_ step: Step, index: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "\(index + 1).circle.fill")
                .foregroundStyle(.blue)

            Text(step.attributedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
        .padding(.leading, 30)
    }
}

/// Renders a recipe to PDF data on demand — nothing is cached to disk ahead of time, so this can be
/// called right when the user taps Share (or for a recipe, like a sample, that was never edited/saved).
@MainActor enum RecipePDFExporter {
    private static let pageSize = CGSize(width: 612, height: 792) // US Letter
    private static let margin: CGFloat = 40

    enum ExportError: Error {
        case renderingFailed
    }

    static func pdfData(for recipe: Recipe) throws -> Data {
        let contentWidth = pageSize.width - margin * 2
        let contentHeight = pageSize.height - margin * 2

        let blocks = RecipePDFContent.blocks(for: recipe)
        let heights = blocks.map { height(of: $0, width: contentWidth) }
        let pages = paginate(heights: heights, maxHeight: contentHeight)

        let data = NSMutableData()
        var mediaBox = CGRect(origin: .zero, size: pageSize)
        guard let consumer = CGDataConsumer(data: data as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ExportError.renderingFailed
        }

        for blockIndices in pages {
            let pageView = VStack(alignment: .leading, spacing: 0) {
                ForEach(blockIndices, id: \.self) { index in
                    blocks[index]
                }
            }
            .padding(.horizontal, margin)
            .padding(.top, margin)
            .frame(width: pageSize.width, height: pageSize.height, alignment: .top)
            .background(.white)
            .colorScheme(.light)

            let renderer = ImageRenderer(content: pageView)
            renderer.render { _, render in
                context.beginPDFPage(nil)
                render(context)
                context.endPDFPage()
            }
        }

        context.closePDF()
        return data as Data
    }

    /// The natural height a block wants at the given width, measured without rasterizing it — used to
    /// decide page breaks before any actual page drawing happens.
    private static func height(of view: some View, width: CGFloat) -> CGFloat {
        let controller = UIHostingController(rootView: view.frame(width: width))
        return controller.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude)).height
    }

    /// Greedily packs blocks onto pages: adds a block to the current page if it fits, otherwise starts
    /// a new page. A single block is never split across pages.
    private static func paginate(heights: [CGFloat], maxHeight: CGFloat) -> [[Int]] {
        var pages: [[Int]] = [[]]
        var currentHeight: CGFloat = 0

        for (index, height) in heights.enumerated() {
            if currentHeight + height > maxHeight, !pages[pages.count - 1].isEmpty {
                pages.append([])
                currentHeight = 0
            }

            pages[pages.count - 1].append(index)
            currentHeight += height
        }

        return pages
    }
}

#Preview {
    @Previewable @State var pdfURL: URL?

    return Group {
        if let pdfURL {
            PreviewController(pdfURL: pdfURL)
                .ignoresSafeArea()
        } else {
            ProgressView()
        }
    }
    .task {
        let data = try? RecipePDFExporter.pdfData(for: .palaminoSauce)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        try? data?.write(to: url)
        pdfURL = url
    }

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
