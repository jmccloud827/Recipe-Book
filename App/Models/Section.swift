import SwiftData
import SwiftUI

extension Recipe {
    @Model class Section: Identifiable {
        var id = UUID()
        var name: String = "Method"
        @Relationship(deleteRule: .cascade, inverse: \Ingredient.belongsTo) private var persistedIngredients: [Ingredient]? = []
        @Relationship(deleteRule: .cascade, inverse: \Step.belongsTo) private var persistedSteps: [Step]? = []
        var belongsTo: Recipe?
        var createdDate: Date = Date.now
        @Transient var ingredients: [Ingredient] {
            get {
                self.persistedIngredients?.sorted {
                    $0.order != $1.order ? $0.order < $1.order : $0.createdDate < $1.createdDate
                } ?? []
            }
            set {
                for (index, ingredient) in newValue.enumerated() {
                    ingredient.order = index
                }
                self.persistedIngredients = newValue
            }
        }

        @Transient var steps: [Step] {
            get {
                self.persistedSteps?.sorted {
                    $0.order != $1.order ? $0.order < $1.order : $0.createdDate < $1.createdDate
                } ?? []
            }
            set {
                for (index, step) in newValue.enumerated() {
                    step.order = index
                }
                self.persistedSteps = newValue
            }
        }
        
        init(belongsTo: Recipe) {
            self.belongsTo = belongsTo
        }
        
        func getIngredients(for word: String) -> [Ingredient] {
            ingredients.filter { $0.contains(word: word) }
        }
    }
}
