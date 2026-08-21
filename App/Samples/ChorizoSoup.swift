import SwiftUI

extension Recipe {
    @MainActor static let chorizoSoup: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Chorizo Soup"
        recipe.servings = 4
        recipe.cookTimeInMinutes = 35
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(resource: .chorizoSoup).pngData()
        
        let methodSection = Section(belongsTo: recipe)
        methodSection.name = ""
        methodSection.ingredients = [
            .init(belongsTo: methodSection, amount: "2", measurement: .tablespoon, name: "olive oil"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pound, name: "spicy sausage (chorizo or andouille)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .item, name: "onion (diced)"),
            .init(belongsTo: methodSection, amount: "1/2", measurement: .cup, name: "carrots (diced)"),
            .init(belongsTo: methodSection, amount: "1/2", measurement: .cup, name: "celery (diced)"),
            .init(belongsTo: methodSection, amount: "2", measurement: .teaspoon, name: "paprika (smoked)"),
            .init(belongsTo: methodSection, amount: "2", measurement: .item, name: "garlic cloves (minced)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pound, name: "potatoes (red or gold, diced)"),
            .init(belongsTo: methodSection, amount: "2", measurement: .cup, name: "kale (remove stems)"),
            .init(belongsTo: methodSection, amount: "32", measurement: .ounce, name: "chicken broth"),
            .init(belongsTo: methodSection, amount: "1", measurement: .cup, name: "water"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pinch, name: "salt (to taste)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pinch, name: "pepper (to taste)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .tablespoon, name: "parsley (chopped)")
        ]
        methodSection.steps = [
            .init(belongsTo: methodSection, text: "Heat olive oil in a large pot on medium-high heat, add sausage and cook until browned breaking apart as it cooks. Use a slotted spoon to remove sausage and set aside, keeping the grease in the pot"),
            .init(belongsTo: methodSection, text: "In the same pot ass the onion, carrots, celery, garlic, and paprika. Cook for 2-3 minutes"),
            .init(belongsTo: methodSection, text: "Now, add the potatoes, kale, chicken broth and water. Bring to a boil then reduce heat and let simmer for 15 minutes"),
            .init(belongsTo: methodSection, text: "Re-add the sausage to the pot and add salt and pepper to tase. Serve garnished with parsley")
        ]
        
        return recipe
    }()
}
