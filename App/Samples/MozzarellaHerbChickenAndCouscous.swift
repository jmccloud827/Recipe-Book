import SwiftUI

extension Recipe {
    @MainActor static let mozzarellaHerbChickenAndCouscous: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Mozzarella Herb Chicken & Couscous"
        recipe.servings = 4
        recipe.cookTimeInMinutes = 40
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(resource: .mozzarellaHerbChickenAndCouscous).pngData()
        
        let methodSection = Section(belongsTo: recipe)
        methodSection.name = ""
        methodSection.ingredients = [
            .init(belongsTo: methodSection, amount: "1", measurement: .item, name: "lemon (juiced)"),
            .init(belongsTo: methodSection, amount: "16", measurement: .ounce, name: "broccoli"),
            .init(belongsTo: methodSection, amount: "2", measurement: .teaspoon, name: "Italian seasoning"),
            .init(belongsTo: methodSection, amount: "2", measurement: .tablespoon, name: "olive oil"),
            .init(belongsTo: methodSection, amount: "3", measurement: .tablespoon, name: "sour cream"),
            .init(belongsTo: methodSection, amount: "24", measurement: .ounce, name: "chicken"),
            .init(belongsTo: methodSection, amount: "1/2", measurement: .cup, name: "panko breadcrumbs"),
            .init(belongsTo: methodSection, amount: "1", measurement: .cup, name: "mozzarella cheese"),
            .init(belongsTo: methodSection, amount: "1 1/2", measurement: .cup, name: "chicken stock"),
            .init(belongsTo: methodSection, amount: "1 1/2", measurement: .cup, name: "couscous"),
            .init(belongsTo: methodSection, amount: "1 1/2", measurement: .cup, name: "water"),
            .init(belongsTo: methodSection, amount: "4", measurement: .tablespoon, name: "butter"),
            .init(belongsTo: methodSection, amount: "2", measurement: .pinch, name: "salt (to taste)"),
            .init(belongsTo: methodSection, amount: "2", measurement: .pinch, name: "pepper (to taste)")
        ]
        methodSection.steps = [
            .init(belongsTo: methodSection, text: "Preheat oven to 425 degrees and in a bowl mix the breadcrumbs, mozzarella, olive oil, Italian seasoning, salt, and pepper"),
            .init(belongsTo: methodSection, text: "Get out a baking sheet and give it a drizzle of olive oil. Place the chicken on on half of the sheet and with salt and pepper. Next, spread sour cream on top of the chicken and cover with the breadcrumb mixture"),
            .init(belongsTo: methodSection, text: "On the other half of the baking sheet add the broccoli and season with salt and pepper. Put the sheet in the oven and cook or 18-22 minutes"),
            .init(belongsTo: methodSection, text: "While that is in the oven get out a small pot and melt the butter in it. Add couscous and a pinch of salt. Cook on medium heat while stirring for 2-3 minutes. Now, add the water, chicken stock, and lemon juice then bring to a boil. Reduce heat and cook until tender, about 6-8 minutes")
        ]
        
        return recipe
    }()
}
