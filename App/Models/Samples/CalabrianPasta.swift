import SwiftUI

extension Recipe {
    @MainActor static let calabrianPasta: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Calabrian Pasta"
        recipe.servings = 6
        recipe.cookTimeInMinutes = 60
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(resource: .calabrianPasta).pngData()
        
        
        let pastaSection = Section(belongsTo: recipe)
        pastaSection.name = "Pasta"
        pastaSection.ingredients = [
            .init(belongsTo: pastaSection, amount: "1", measurement: .box, name: "bucatini pasta"),
            .init(belongsTo: pastaSection, amount: "1", measurement: .pinch, name: "salt"),
        ]
        pastaSection.steps = [
            .init(belongsTo: pastaSection, text: "Get a pot and add the bucatini and some water. Bring to a boil and cook until al dente. You can start the sauce while this is happening"),
            .init(belongsTo: pastaSection, text: "When the pasta becomes al dente strain it keeping a cup of the pasta water and mix it with the sauce")
        ]
        
        let sauceSection = Section(belongsTo: recipe)
        sauceSection.name = "Sauce"
        sauceSection.ingredients = [
            .init(belongsTo: sauceSection, amount: "8", measurement: .ounce, name: "beef (steak or beef bits)"),
            .init(belongsTo: sauceSection, amount: "8", measurement: .ounce, name: "shrimp (peeled)"),
            .init(belongsTo: sauceSection, amount: "4", measurement: .item, name: "garlic cloves (minced)"),
            .init(belongsTo: sauceSection, amount: "1", measurement: .teaspoon, name: "lemon juice"),
            .init(belongsTo: sauceSection, amount: "2", measurement: .tablespoon, name: "olive oil"),
            .init(belongsTo: sauceSection, amount: "3", measurement: .tablespoon, name: "butter"),
            .init(belongsTo: sauceSection, amount: "1/4", measurement: .cup, name: "tomato paste"),
            .init(belongsTo: sauceSection, amount: "1/3", measurement: .cup, name: "heavy cream"),
            .init(belongsTo: sauceSection, amount: "2", measurement: .tablespoon, name: "calabrian chili paste"),
            .init(belongsTo: sauceSection, amount: "1/2", measurement: .cup, name: "parmesan cheese (grated)"),
            .init(belongsTo: sauceSection, amount: "1/2", measurement: .cup, name: "basil"),
        ]
        sauceSection.steps = [
            .init(belongsTo: sauceSection, text: "Get a large saucepan, add olive oil, and heat on a medium setting. Sear the beef until browned"),
            .init(belongsTo: sauceSection, text: "Add butter, garlic, and shrimp until pink and opaque"),
            .init(belongsTo: sauceSection, text: "Add calabrian paste, lemon juice, heavy cream, pasta water, and tomato paste. Bring to a boil, reduce heat and let it simmer for 5 minutes"),
            .init(belongsTo: sauceSection, text: "Add the parmesan and wait for it to melt then add the basil"),
            .init(belongsTo: sauceSection, text: "Add the pasta and stir to coat. Serve topping with a little more parmesan")
        ]
        
        return recipe
    }()
}
