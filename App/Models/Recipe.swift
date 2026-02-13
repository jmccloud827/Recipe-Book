import PDFKit
import SwiftData
import SwiftUI

@Model class Recipe: Hashable, Identifiable {
    var id = UUID()
    var name: String = ""
    var servings: Int = 0
    var cookTimeInMinutes: Int = 1
    private var persistedTags: [Tag] = []
    var photo: Data?
    @Relationship(deleteRule: .nullify, inverse: \Section.belongsTo) private var persistedSections: [Section]? = []
    var createdDate: Date = Date.now
    @Transient var sections: [Section] {
        get {
            self.persistedSections?.sorted { $0.createdDate < $1.createdDate } ?? []
        }
        set {
            self.persistedSections = newValue
        }
    }

    @Transient var uiImage: UIImage? {
        if let data = self.photo,
           let uiImage = UIImage(data: data) {
            return uiImage
        }
        
        return nil
    }
    
    var tags: Set<Tag> {
        get {
            Set(persistedTags)
        } set {
            persistedTags = Array(newValue)
        }
    }
    
    init() {
        self.name = "New Recipe"
        self.tags = []
        self._photo = nil
        self.sections = []
        self.createdDate = Date.now
        
        sections.append(.init(belongsTo: self))
    }
    
    var pdfURL: URL {
        getPDFURL()
    }
    
    func getPDFURL(overrideName: String? = nil) -> URL {
        URL.documentsDirectory.appending(path: overrideName ?? name + id.uuidString + ".pdf")
    }
    
    func getIngredientFromID(_ id: UUID) -> Ingredient? {
        for section in sections {
            for ingredient in section.ingredients {
                if ingredient.id == id {
                    return ingredient
                }
            }
        }
        
        return nil
    }
    
    @MainActor func saveToDocumentsDirectory() {
        let usLetterRect = CGRect(origin: .zero, size: .init(width: 612, height: 792))
            
        let view = RecipePDFView(recipe: self).frame(width: usLetterRect.width)
            
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
            
        if let uiImage = renderer.uiImage {
            let pdf = PDFDocument()
                
            let numberOfPages = Int(uiImage.size.height / usLetterRect.height)
            for page in 0 ... numberOfPages {
                let renderer = ImageRenderer(content: view.frame(height: usLetterRect.height, alignment: .top).offset(y: -usLetterRect.height * Double(page)))
                renderer.scale = 3
                    
                if let uiImage = renderer.uiImage,
                   let page = PDFPage(image: uiImage) {
                    pdf.insert(page, at: pdf.pageCount)
                }
            }
                
            pdf.write(to: pdfURL)
        }
    }
    
    @MainActor func deleteFromDocumentsDirectory(overrideURL: URL? = nil) {
        try? FileManager.default.removeItem(at: overrideURL ?? pdfURL)
    }
    
    @MainActor static let samples = [palaminoSauce, pizzaPasta]
}

enum Tag: String, Hashable, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case appetizer = "Appetizer"
    case salad = "Salad"
    case mainDish = "Main Dish"
    case sideDish = "Side Dish"
    case bakedGoods = "Baked Goods"
    case dessert = "Dessert"
    case snack = "Snack"
    case soup = "Soup"
    case holiday = "Holiday"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
}
