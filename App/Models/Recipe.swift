import SwiftData
import SwiftUI

@Model class Recipe: Hashable, Identifiable {
    var id = UUID()
    var name: String = ""
    var servings: Int = 0
    var cookTimeInMinutes: Int = 1
    private var persistedTags: [Tag] = []
    var photo: Data?
    @Relationship(deleteRule: .cascade, inverse: \Section.belongsTo) private var persistedSections: [Section]? = []
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

    /// Renders this recipe to PDF data on demand (nothing is cached to disk ahead of time).
    @MainActor func makePDFData() throws -> Data {
        try RecipePDFExporter.pdfData(for: self)
    }
    
    @MainActor static let samples = [
        palaminoSauce,
        pizzaPasta,
        chorizoSoup,
        creamyItalianSausageDitalini,
        chorizoRiceSkillet,
        shepardsPie,
        calabrianPasta,
        mozzarellaHerbChickenAndCouscous,
        sweetSoySalmonBowl
    ]
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
