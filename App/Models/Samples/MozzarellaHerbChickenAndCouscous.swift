import SwiftUI

extension Recipe {
    @MainActor static let mozzarellaHerbChickenAndCouscous: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Mozzarella Herb Chicken & Couscous"
        recipe.servings = 4
        recipe.cookTimeInMinutes = 40
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(named: "mozzarellaHerbChickenAndCouscous")?.pngData()
        
        
        let methodSection = Section(belongsTo: recipe)
        methodSection.name = "Method"
        methodSection.ingredients = [
            .init(belongsTo: methodSection, amount: "1", measurement: .item, name: "lemon (juiced, zested)"),
            .init(belongsTo: methodSection, amount: "16", measurement: .ounce, name: "broccoli"),
            .init(belongsTo: methodSection, amount: "1", measurement: .tablespoon, name: "Italian seasoning"),
            .init(belongsTo: methodSection, amount: "3", measurement: .tablespoon, name: "sour cream"),
            .init(belongsTo: methodSection, amount: "24", measurement: .ounce, name: "chicken"),
            .init(belongsTo: methodSection, amount: "1/2", measurement: .cup, name: "panko breadcrumbs"),
            .init(belongsTo: methodSection, amount: "1", measurement: .cup, name: "mozzarella cheese"),
            .init(belongsTo: methodSection, amount: "1 1/2", measurement: .cup, name: "chicken stock"),
            .init(belongsTo: methodSection, amount: "1 1/2", measurement: .cup, name: "couscous"),
            .init(belongsTo: methodSection, amount: "2", measurement: .tablespoon, name: "butter"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pinch, name: "salt (to taste)"),
            ]
        methodSection.steps = [
            .init(belongsTo: methodSection, text: "I a "),
            .init(belongsTo: methodSection, text: ""),
            .init(belongsTo: methodSection, text: ""),
            .init(belongsTo: methodSection, text: ""),
            .init(belongsTo: methodSection, text: ""),
            .init(belongsTo: methodSection, text: ""),
            .init(belongsTo: methodSection, text: ""),
            .init(belongsTo: methodSection, text: ""),
        ]
        
        return recipe
    }()
}
