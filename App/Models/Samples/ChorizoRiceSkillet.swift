import SwiftUI

extension Recipe {
    @MainActor static let chorizoRiceSkillet: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Chorizo Rice Skillet"
        recipe.servings = 6
        recipe.cookTimeInMinutes = 45
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(named: "chorizoRiceSkillet")?.pngData()
        
        let methodSection = Section(belongsTo: recipe)
        methodSection.name = "Method"
        methodSection.ingredients = [
            .init(belongsTo: methodSection, amount: "1", measurement: .cup, name: "rice (long grain)"),
            .init(belongsTo: methodSection, amount: "2", measurement: .tablespoon, name: "olive oil"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pound, name: "chorizo"),
            .init(belongsTo: methodSection, amount: "1", measurement: .item, name: "onion (diced)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .teaspoon, name: "chicken bouillon"),
            .init(belongsTo: methodSection, amount: "1", measurement: .can, name: "tomatoes (petite, diced)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .can, name: "green chiles (diced)"),
            .init(belongsTo: methodSection, amount: "2", measurement: .cup, name: "water"),
            .init(belongsTo: methodSection, amount: "1", measurement: .can, name: "black beans (rinsed and drained)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .teaspoon, name: "oregano"),
            .init(belongsTo: methodSection, amount: "1", measurement: .teaspoon, name: "garlic powder"),
            .init(belongsTo: methodSection, amount: "1", measurement: .teaspoon, name: "cumin"),
        ]
        methodSection.steps = [
            .init(belongsTo: methodSection, text: "Place rice in a strainer and run it under cool water, then place to the side to drain"),
            .init(belongsTo: methodSection, text: "Drain tomatoes and chiles into a measuring cup. Add water until the mixture reaches 2 cups"),
            .init(belongsTo: methodSection, text: "Add oil to a large pan and heat on medium. Add rice and cook until golden, about 5-7 minutes. Move the rice to a bowl and set aside"),
            .init(belongsTo: methodSection, text: "Add onion and chorizo to the pan and cook until browned breaking apart as it cooks"),
            .init(belongsTo: methodSection, text: "Add bouillon, water mixture, tomato, chiles, black beans, rice, oregano, garlic powder, and cumin. Stir well bring to a boil, then reduce to a simmer and cook for 20 minutes")
        ]
        
        return recipe
    }()
}
