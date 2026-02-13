import SwiftData
import SwiftUI

extension Recipe {
    @Model class Section: Identifiable {
        var id = UUID()
        var name: String = "Method"
        @Relationship(deleteRule: .nullify, inverse: \Ingredient.belongsTo) private var persistedIngredients: [Ingredient]? = []
        @Relationship(deleteRule: .nullify, inverse: \Step.belongsTo) private var persistedSteps: [Step]? = []
        var belongsTo: Recipe?
        var createdDate: Date = Date.now
        @Transient var ingredients: [Ingredient] {
            get {
                self.persistedIngredients?.sorted { $0.createdDate < $1.createdDate } ?? []
            }
            set {
                self.persistedIngredients = newValue
            }
        }

        @Transient var steps: [Step] {
            get {
                self.persistedSteps?.sorted { $0.createdDate < $1.createdDate } ?? []
            }
            set {
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
