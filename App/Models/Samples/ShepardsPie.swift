import SwiftUI

extension Recipe {
    @MainActor static let shepardsPie: Recipe = {
        let recipe = Recipe()
        recipe.sections = []
        recipe.name = "Shepards Pie"
        recipe.servings = 6
        recipe.cookTimeInMinutes = 60
        recipe.tags = [.dinner, .mainDish]
        recipe.photo = UIImage(named: "shepardsPie")?.pngData()
        
        let potatoesSection = Section(belongsTo: recipe)
        potatoesSection.name = "Potatoes"
        potatoesSection.ingredients = [
            .init(belongsTo: potatoesSection, amount: "2", measurement: .pound, name: "potatoes (russet and gold mix)"),
            .init(belongsTo: potatoesSection, amount: "1", measurement: .pinch, name: "salt"),
            .init(belongsTo: potatoesSection, amount: "8", measurement: .tablespoon, name: "butter"),
            .init(belongsTo: potatoesSection, amount: "2", measurement: .cup, name: "milk"),
            .init(belongsTo: potatoesSection, amount: "1", measurement: .pinch, name: "all purpose seasoning")
        ]
        potatoesSection.steps = [
            .init(belongsTo: potatoesSection, text: "Starting with the potatoes I like to cut them into 1/8ths so they cook evenly. Get a large pot add potatoes with some salt and fill with water until the potatoes are floating. Boil water and cook until potatoes are soft. While cooking move on to the meat section"),
            .init(belongsTo: potatoesSection, text: "Drain potatoes and add to a bowl. Add the butter, milk and seasoning. Mash until smooth")
        ]
        
        let meatSection = Section(belongsTo: recipe)
        meatSection.name = "Meat"
        meatSection.ingredients = [
            .init(belongsTo: meatSection, amount: "1", measurement: .pound, name: "beef (ground)"),
            .init(belongsTo: meatSection, amount: "1", measurement: .tablespoon, name: "A1 sauce"),
            .init(belongsTo: meatSection, amount: "1", measurement: .tablespoon, name: "worcestershire sauce"),
            .init(belongsTo: meatSection, amount: "1", measurement: .pinch, name: "lawry's seasoning")
        ]
        meatSection.steps = [
            .init(belongsTo: meatSection, text: "Get a medium sized pan and add the beef. Season with lawry's and cook on medium heat until browned. Drain grease"),
            .init(belongsTo: meatSection, text: "Add the worcestershire and A1 sauce and let it simmer for a few minutes. Sometimes I drain the excess sauce depends on how flavorful you want it")
        ]
        
        let ovenSection = Section(belongsTo: recipe)
        ovenSection.name = "Oven"
        ovenSection.ingredients = [
            .init(belongsTo: ovenSection, amount: "1", measurement: .can, name: "corn"),
            .init(belongsTo: ovenSection, amount: "1", measurement: .can, name: "green beans"),
            .init(belongsTo: ovenSection, amount: "1", measurement: .pinch, name: "lawry's seasoning"),
            .init(belongsTo: ovenSection, amount: "1", measurement: .pinch, name: "all purpose seasoning")
        ]
        ovenSection.steps = [
            .init(belongsTo: ovenSection, text: "Preheat the oven to 350 degrees and then drain the corn and green beans and spread on the bottom of an oven safe dish. Season with lawry's"),
            .init(belongsTo: ovenSection, text: "Now add the meat and spread evenly. Do the same with the mashed potatoes"),
            .init(belongsTo: ovenSection, text: "Put the dish in the oven and cook until the potatoes are golden and crispy on top. Served with the all purpose seasoning on top")
        ]
        
        return recipe
    }()
}
