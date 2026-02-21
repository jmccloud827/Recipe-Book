import SwiftUI

extension Recipe {
    @MainActor static let sweetSoySalmonBowl: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Sweet Soy Salmon Bowl"
        recipe.servings = 4
        recipe.cookTimeInMinutes = 40
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(named: "sweetSoySalmonBowl")?.pngData()
        
        let glazeSection = Section(belongsTo: recipe)
        glazeSection.name = "Glaze"
        glazeSection.ingredients = [
            .init(belongsTo: glazeSection, amount: "1/2", measurement: .cup, name: "soy sauce"),
            .init(belongsTo: glazeSection, amount: "1/2", measurement: .cup, name: "mirin"),
            .init(belongsTo: glazeSection, amount: "1/4", measurement: .cup, name: "sugar"),
            .init(belongsTo: glazeSection, amount: "3", measurement: .tablespoon, name: "brown rice vinegar (or rice wine vinegar)"),
            .init(belongsTo: glazeSection, amount: "1", measurement: .tablespoon, name: "water"),
            .init(belongsTo: glazeSection, amount: "2", measurement: .teaspoon, name: "cornstarch"),
            .init(belongsTo: glazeSection, amount: "", measurement: .item, name: ""),
            .init(belongsTo: glazeSection, amount: "", measurement: .item, name: ""),
            .init(belongsTo: glazeSection, amount: "", measurement: .item, name: ""),
            .init(belongsTo: glazeSection, amount: "", measurement: .item, name: ""),
            .init(belongsTo: glazeSection, amount: "", measurement: .item, name: ""),
            .init(belongsTo: glazeSection, amount: "", measurement: .item, name: ""),
            .init(belongsTo: glazeSection, amount: "", measurement: .item, name: "")
        ]
        glazeSection.steps = [
            .init(belongsTo: glazeSection, text: "In a small saucepan over medium heat, whisk the soy sauce, mirin, sugar, and vinegar. Bring to a simmer and cook for 2 to 3 minutes, stirring until the sugar is dissolved."),
            .init(belongsTo: glazeSection, text: "As the glaze simmers, in a small bowl or liquid measuring cup, whisk the water and cornstarch."),
            .init(belongsTo: glazeSection, text: "Whisk the cornstarch mixture into the glaze and continue to simmer for about 5 minutes, until slightly thickened."),
            .init(belongsTo: glazeSection, text: "Transfer the glaze to a heatproof jar and let cool completely."),
            .init(belongsTo: glazeSection, text: "The glaze can be good for 2 weeks. Store in the jar in the refrigerator.")
        ]
        
        let methodSection = Section(belongsTo: recipe)
        methodSection.name = "Method"
        methodSection.ingredients = [
            .init(belongsTo: methodSection, amount: "16", measurement: .ounce, name: "broccoli"),
            .init(belongsTo: methodSection, amount: "1 1/2", measurement: .cup, name: "jasmine rice"),
            .init(belongsTo: methodSection, amount: "2", measurement: .teaspoon, name: "korean chili flakes"),
            .init(belongsTo: methodSection, amount: "8", measurement: .tablespoon, name: "sweet soy glaze (made in previous section)"),
            .init(belongsTo: methodSection, amount: "2", measurement: .teaspoon, name: "honey"),
            .init(belongsTo: methodSection, amount: "2", measurement: .tablespoon, name: "sesame seeds"),
            .init(belongsTo: methodSection, amount: "4", measurement: .tablespoon, name: "mayonnaise"),
            .init(belongsTo: methodSection, amount: "4", measurement: .item, name: "scallions"),
            .init(belongsTo: methodSection, amount: "2", measurement: .tablespoon, name: "sriracha"),
            .init(belongsTo: methodSection, amount: "4", measurement: .tablespoon, name: "garlic powder"),
            .init(belongsTo: methodSection, amount: "20", measurement: .ounce, name: "salmon"),
            .init(belongsTo: methodSection, amount: "2 1/4", measurement: .cup, name: "water"),
            .init(belongsTo: methodSection, amount: "2", measurement: .tablespoon, name: "olive oil"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pinch, name: "salt (to taste)"),
            .init(belongsTo: methodSection, amount: "1", measurement: .pinch, name: "pepper (to taste)")
        ]
        methodSection.steps = [
            .init(belongsTo: methodSection, text: "In a small pot combine rice, water, and salt and bring to a boil then reduce heat to low cooking for 15-20 minutes"),
            .init(belongsTo: methodSection, text: "In a medium bowl combine broccoli, olive oil, garlic powder, salt, and pepper"),
            .init(belongsTo: methodSection, text: "Take put the salmon and cut the skin off then cut into 1/2 inch chunks"),
            .init(belongsTo: methodSection, text: "In another small bowl add salmon and half the glaze. Mix until evenly coated"),
            .init(belongsTo: methodSection, text: "Get your air fryer basket and add a drizzle of olive oil. Now add the broccoli and salmon then fry at 390 degrees for 4-6 minutes. Pull basket out and coat salmon with the remaining glaze then cook for another 1-2 minutes. Remove salmon and cook broccoli for another 5 minutes"),
            .init(belongsTo: methodSection, text: "While that is cooking in a small bowl combine mayonnaise, sriracha, honey, and chili flakes. Add 1 teaspoon of water at a time until the mixture reaches a drizzling consistency. Season with salt and pepper"),
            .init(belongsTo: methodSection, text: "Fluff rice with a fork and serve rice, broccoli, and salmon in bowls drizzled with the sauce and garnished with scallions and sesame seeds")
        ]
        
        return recipe
    }()
}
