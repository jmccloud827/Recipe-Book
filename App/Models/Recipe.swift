import PDFKit
import SwiftData
import SwiftUI

@Model class Recipe: Hashable, Identifiable {
    var id = UUID()
    var name: String = ""
    private var tagsBackingData: [Category] = []
    var dishDescription: String = ""
    var photo: Data?
    var ingredients: [Ingredient] = []
    var steps: [Step] = []
    var createdDate: Date = Date.now
    @Transient var uiImage: UIImage?
    
    var tags: Set<Category> {
        get {
            Set(tagsBackingData)
        } set {
            tagsBackingData = Array(newValue)
        }
    }
    
    var pdfURL: URL {
        getPDFURL()
    }
    
    func getPDFURL(overrideName: String? = nil) -> URL {
        URL.documentsDirectory.appending(path: overrideName ?? name + id.uuidString + ".pdf")
    }
    
    init(name: String, tags: Set<Category>, dishDescription: String, photo: Data?, ingredients: [Ingredient], steps: [Step]) {
        self.name = name
        self.tags = tags
        self.dishDescription = dishDescription
        self.photo = photo
        self.ingredients = ingredients
        self.steps = steps
        self.createdDate = Date.now
        if let photo {
            self.uiImage = UIImage(data: photo)
        } else {
            self.uiImage = nil
        }
    }
    
    init() {
        self.name = "New Recipe"
        self.tags = []
        self.dishDescription = ""
        self._photo = nil
        self.ingredients = []
        self.steps = []
        self.createdDate = Date.now
        self.uiImage = nil
    }
    
    @MainActor func saveToDocumentsDirectory() {
        Task {
            let view = {
                RecipePDFView(recipe: self)
                    .frame(width: 400)
            }
            
            let renderer = ImageRenderer(content: view())
            renderer.scale = 3
            
            if let uiImage = renderer.uiImage {
                let data = uiImage.pngData()
                if let image = UIImage(data: data ?? Data()) {
                    let pdf = PDFDocument()
                    if let page = PDFPage(image: image) {
                        pdf.insert(page, at: 0)
                    }
                    
                    pdf.write(to: pdfURL)
                }
            }
        }
    }
    
    @MainActor func deleteFromDocumentsDirectory(overrideURL: URL? = nil) {
        Task {
            try? FileManager.default.removeItem(at: overrideURL ?? pdfURL)
        }
    }
    
    @MainActor static let sample = Recipe(name: "Garlic Parm Chicken Pasta",
                                                 tags: Set(Category.allCases),
                                                 dishDescription: "Indulge in a plate of creamy garlic parmesan fettuccine, where al dente ribbons of fettuccine pasta are enveloped in a luscious sauce that strikes the perfect balance between rich and savory. This dish begins with sautéed garlic, which releases its fragrant aroma, then melds with heavy cream, creating a velvety base that's irresistible.\n\nGrated aged Parmesan cheese is gently stirred in, melting into the sauce and lending a nutty depth that perfectly complements the garlic. A hint of freshly cracked black pepper adds a subtle kick, while a sprinkle of fresh parsley provides a pop of color and freshness.\n\nServed with a generous topping of more grated Parmesan and a drizzle of high-quality olive oil, this pasta dish is a comforting classic that invites you to savor each bite. Pair it with a crisp green salad and a glass of white wine for a delightful dining experience that will transport your taste buds to the heart of Italy.",
                                                 photo: UIImage(named: "mock")?.pngData(),
                                                 ingredients: [
                                                     .init(name: "8 oz (about 225 g) spaghetti or linguine"),
                                                     .init(name: "1 lb (450 g) shrimp, peeled and deveined"),
                                                     .init(name: "4 tablespoons unsalted butter"),
                                                     .init(name: "4 cloves garlic, minced"),
                                                     .init(name: "1/2 teaspoon red pepper flakes (optional, adjust to taste)"),
                                                     .init(name: "1/2 cup chicken or vegetable broth"),
                                                     .init(name: "1 lemon (juice and zest)"),
                                                     .init(name: "Salt and pepper to taste"),
                                                     .init(name: "1/4 cup fresh parsley, chopped (for garnish)"),
                                                     .init(name: "Grated Parmesan cheese (optional)")
                                                 ],
                                                 steps: [
                                                     .init(name: "Cook the Pasta", description: "Bring a large pot of salted water to a boil. Add the spaghetti or linguine and cook according to package instructions until al dente. Reserve about 1 cup of pasta water, then drain the rest."),
                                                     .init(name: "Prepare the Shrimp", description: "While the pasta is cooking, heat 2 tablespoons of butter in a large skillet over medium heat. Add the shrimp and season with salt and pepper. Cook for about 2-3 minutes on each side, or until they turn pink and opaque. Remove the shrimp from the skillet and set aside."),
                                                     .init(name: "Make the Sauce", description: "In the same skillet, add the remaining 2 tablespoons of butter. Once melted, add the minced garlic and red pepper flakes (if using). Sauté for about 1 minute, or until the garlic is fragrant but not browned. Pour in the chicken or vegetable broth and stir to combine. Let it simmer for 2-3 minutes."),
                                                     .init(name: "Combine Everything", description: "Add the cooked pasta to the skillet along with the shrimp. Toss everything together, adding the lemon juice and zest. If the pasta seems dry, add a bit of the reserved pasta water until you reach the desired consistency."),
                                                     .init(name: "Serve", description: "Taste and adjust seasoning with salt and pepper as needed. Remove from heat and garnish with fresh parsley and grated Parmesan cheese, if desired.")
                                                 ])
}

struct Ingredient: Codable, Identifiable {
    var id = UUID()
    var name: String
}

struct Step: Codable, Identifiable {
    var id = UUID()
    var name: String
    var description: String
}

enum Category: String, Hashable, CaseIterable, Codable {
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
