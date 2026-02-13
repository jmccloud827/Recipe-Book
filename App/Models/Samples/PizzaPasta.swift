import SwiftUI

extension Recipe {
    @MainActor static let pizzaPasta: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Pizza Pasta"
        recipe.servings = 4
        recipe.cookTimeInMinutes = 25
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(named: "mock")?.pngData()
        
        let sauceSection = Section(belongsTo: recipe)
        sauceSection.name = "Sauce"
        sauceSection.ingredients = [
            .init(belongsTo: sauceSection, amount: "2", measurement: .tablespoon, name: "olive oil"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .pound, name: "italian sausage"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .item, name: "onion (diced)"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .cup, name: "mushrooms (diced)"),
            .init(belongsTo: sauceSection, amount: "2", measurement: .can, name: "tomatoes (petite, diced)"),
            .init(belongsTo: sauceSection, amount: "2", measurement: .can, name: "tomato paste"),
            .init(belongsTo: sauceSection, amount: "1 1/4", measurement: .item, name: "garlic cloves (minced)"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .tablespoon, name: "italian seasoning"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .tablespoon, name: "basil"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .tablespoon, name: "oregano")
        ]
        sauceSection.steps = [
            .init(belongsTo: sauceSection, text: "Get a large pan, add the olive oil and heat on a medium setting. Once warmed add the onions and garlic and sauté for 1-2 minutes"),
            .init(belongsTo: sauceSection, text: "Next, add the mushrooms and italian sausage and cook until the sausage is browned"),
            .init(belongsTo: sauceSection, text: "After that add the tomatoes and tomato paste. Then add the itialian seasoning, basil, and oregano. Cover and let it simmer on low heat for 10 minutes"),
        ]
        
        let pastaSection = Section(belongsTo: recipe)
        pastaSection.name = "Pasta"
        pastaSection.ingredients = [
            .init(belongsTo: pastaSection, amount: "1", measurement: .box, name: "penne pasta")
        ]
        pastaSection.steps = [
            .init(belongsTo: pastaSection, text: "While the sauce is simmering go ahead and cook the penne and remember to add salt to the pot"),
            .init(belongsTo: pastaSection, text: "When the pasta becomes al dente strain it and mix it with the sauce")
        ]
        
        let servingSection = Section(belongsTo: recipe)
        servingSection.name = "Cooke in the Oven"
        servingSection.ingredients = [
            .init(belongsTo: servingSection, amount: "1", measurement: .packet, name: "mozzarella cheese"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .packet, name: "pepperoni")
        ]
        servingSection.steps = [
            .init(belongsTo: servingSection, text: "Preheat oven to 350 degrees and get an oven safe dish"),
            .init(belongsTo: servingSection, text: "Add about half the pasta and sauce to the dish. Then put half of the mozzarella on top. Repeat with the other half of pasta, sauce, and mozzarella"),
            .init(belongsTo: servingSection, text: "Top the dish with pepperoni and bake in the oven until the cheese is melted. Usally about 5 minute.")
        ]
        
        return recipe
    }()
}
