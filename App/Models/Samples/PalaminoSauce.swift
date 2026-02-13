import SwiftUI

extension Recipe {
    @MainActor static let palaminoSauce: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Palamino Sauce"
        recipe.servings = 4
        recipe.cookTimeInMinutes = 25
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(resource: .palaminoSauce).pngData()
        
        let sauceSection = Section(belongsTo: recipe)
        sauceSection.name = "Sauce"
        sauceSection.ingredients = [
            .init(belongsTo: sauceSection, amount: "2", measurement: .tablespoon, name: "olive oil"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .item, name: "onion (diced)"),
            .init(belongsTo: sauceSection, amount: "3", measurement: .item, name: "garlic cloves (minced)"),
            .init(belongsTo: sauceSection, amount: "14 1/2", measurement: .ounce, name: "tomatoes (diced)"),
            .init(belongsTo: sauceSection, amount: "18", measurement: .ounce, name: "marinara"),
            .init(belongsTo: sauceSection, amount: "1/2", measurement: .cup, name: "whipping cream")
        ]
        sauceSection.steps = [
            .init(belongsTo: sauceSection, text: "Heat olive oil in a large saucepan and fry the onion on a medium heat until softened - about 5 minutes"),
            .init(belongsTo: sauceSection, text: "Add the garlic and sauté for 1-2 minutes"),
            .init(belongsTo: sauceSection, text: "Stir in the marinara, diced tomatoes, and cream. Bring to a boil then reduce heat and simmer for 15 minutes")
        ]
        
        let pastaSection = Section(belongsTo: recipe)
        pastaSection.name = "Pasta"
        pastaSection.ingredients = [
            .init(belongsTo: pastaSection, amount: "16", measurement: .ounce, name: "rigatoni pasta")
        ]
        pastaSection.steps = [
            .init(belongsTo: pastaSection, text: "While the sauce is simmering go ahead and cook the rigatoni and remember to add salt to the pot"),
            .init(belongsTo: pastaSection, text: "When the pasta becomes al dente strain it and add some sauce to keep it from drying out")
        ]
        
        let servingSection = Section(belongsTo: recipe)
        servingSection.name = "Serving"
        servingSection.ingredients = [
            .init(belongsTo: servingSection, amount: "1", measurement: .cup, name: "parmesan cheese (grated or shaved)"),
            .init(belongsTo: sauceSection, amount: "1/2", measurement: .cup, name: "parsley")
        ]
        servingSection.steps = [
            .init(belongsTo: servingSection, text: "Whisk half the parmesan into the sauce until melted"),
            .init(belongsTo: servingSection, text: "Serve the sauce over the noodles and garnish with parsley and more parmesan")
        ]
        
        return recipe
    }()
}
