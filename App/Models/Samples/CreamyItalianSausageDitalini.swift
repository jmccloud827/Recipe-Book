import SwiftUI

extension Recipe {
    @MainActor static let creamyItalianSausageDitalini: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Creamy Italian Sausage Ditalini"
        recipe.servings = 6
        recipe.cookTimeInMinutes = 25
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(resource: .creamyItalianSausageDitalini).pngData()
        
        let methodSection = Section(belongsTo: recipe)
        methodSection.name = ""
        methodSection.ingredients = [
            .init(belongsTo: methodSection, amount: "1", measurement: .pound, name: "Italian sausage"),
            .init(belongsTo: methodSection, amount: "1", measurement: .item, name: "onion (diced)"),
            .init(belongsTo: methodSection, amount: "2", measurement: .item, name: "garlic cloves (minced)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .teaspoon, name: "fennel (ground, optional)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .teaspoon, name: "red pepper flaskes (optional)"),
            .init(belongsTo: methodSection, amount: "4", measurement: .cup, name: "chicken broth"),
            .init(belongsTo: methodSection, amount: "1", measurement: .can, name: "tomatoes (petite, diced)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .box, name: "ditalini pasta"),
            .init(belongsTo: methodSection, amount: "1", measurement: .teaspoon, name: "Italian seasoning"),
            .init(belongsTo: methodSection, amount: "1/2", measurement: .cup, name: "parmesan cheese (grated)"),
            .init(belongsTo: methodSection, amount: "4", measurement: .ounce, name: "cream cheese"),
            .init(belongsTo: methodSection, amount: "1/4", measurement: .cup, name: "heavy cream"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pinch, name: "salt (to taste)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pinch, name: "pepper (to taste)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .tablespoon, name: "parsley (chopped)")
        ]
        methodSection.steps = [
            .init(belongsTo: methodSection, text: "Cook the sausage and onion in a large pan until the sausage is browned breaking it apart as it cooks. Drain excess grease"),
            .init(belongsTo: methodSection, text: "Add the garlic, fennel, and red pepper, mix, and cook until fragrant, about a minute"),
            .init(belongsTo: methodSection, text: "Add the broth, tomatoes, pasta, and Italian seasoning, bring to a boil, reduce heat, and let simmer until the pasta is al dente, about 6-8 minutes"),
            .init(belongsTo: methodSection, text: "Add the parmesan, cream cheese, and heavy cream. Let the cheeses melt for about 3-5 minutes"),
            .init(belongsTo: methodSection, text: "Season with salt and pepper to taste and serve garnished with parsley")
        ]
        
        return recipe
    }()
}
