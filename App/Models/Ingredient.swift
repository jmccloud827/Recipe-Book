import SwiftData
import SwiftUI

@Model class Ingredient: Identifiable {
    var id = UUID()
    var amount: String = ""
    var measurement: Measurement = Measurement.item
    var persistedName: String = ""
    var subtext: String = ""
    var createdDate: Date = Date.now
    var order: Int = 0
    var belongsTo: Recipe.Section?
    
    var name: String {
        get {
            persistedName
        }
        set {
            let firstIndexOfParenthesis = newValue.firstIndex(of: "(")
            if let firstIndexOfParenthesis {
                persistedName = String(newValue[...newValue.index(before: firstIndexOfParenthesis)]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                subtext = String(newValue[firstIndexOfParenthesis...]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                persistedName = newValue
            }
        }
    }
    
    init(belongsTo: Recipe.Section, amount: String, measurement: Measurement, name: String) {
        self.amount = amount
        self.measurement = measurement
        self.name = name
        self.belongsTo = belongsTo
    }
    
    init(belongsTo: Recipe.Section) {
        self.belongsTo = belongsTo
    }
    
    func contains(word: String) -> Bool {
        let splits = self.name.split(separator: " ")
        return splits.contains { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) == word.lowercased().trimmingCharacters(in: .punctuationCharacters) }
    }
    
    @MainActor func makeAttributedString() -> AttributedString {
        var result = AttributedString("")
        let indexOnSlash = self.amount.firstIndex(of: "/")
        var isPlural = false
        if let indexOnSlash {
            let wholeNumber = self.amount[..<self.amount.index(before: indexOnSlash)].trimmingCharacters(in: .whitespacesAndNewlines)
            result += AttributedString(wholeNumber)

            let fraction = self.amount[self.amount.index(before: indexOnSlash)...].trimmingCharacters(in: .whitespacesAndNewlines)
            var fractionString = AttributedString(" " + fraction)
            fractionString.font = Font(UIFont.fractionFont(ofSize: UIFont.systemFontSize) as CTFont)
            result += fractionString
            
            if wholeNumber != "" {
                isPlural = true
            }
        } else {
            result += AttributedString(self.amount)
            
            if self.amount != "1" {
                isPlural = true
            }
        }
        
        result.foregroundColor = .accent
        
        if self.measurement != .item {
            var measurement = AttributedString(" " + (isPlural ? self.measurement.pluralValue : self.measurement.shortValue))
            measurement.foregroundColor = .accent
            result += measurement
        }
        
        result += AttributedString(" " + self.name)
        
        var subText = AttributedString(" " + self.subtext)
        subText.foregroundColor = .gray
        result += subText
        
        return result
    }
    
    enum Measurement: String, Codable, CaseIterable {
        case item = "Item"
        case tablespoon = "Tablespoon"
        case teaspoon = "Teaspoon"
        case cup = "Cup"
        case mill = "Mill"
        case gram = "Gram"
        case kilogram = "Kilogram"
        case pound = "Pound"
        case ounce = "Ounce"
        case fluidOunce = "Fluid Ounce"
        case litre = "Litre"
        case deciliter = "Deciliter"
        case centiliter = "Centiliter"
        case bottle = "Bottle"
        case pinch = "Pinch"
        case can = "Can"
        case bunch = "Bunch"
        case box = "Box"
        case packet = "Packet"
        
        var shortValue: String {
            switch self {
            case .item:
                ""
            case .tablespoon:
                "Tbsp"
            case .teaspoon:
                "tsp"
            case .cup:
                "cup"
            case .mill:
                "ml"
            case .gram:
                "g"
            case .kilogram:
                "kg"
            case .pound:
                "lb"
            case .ounce:
                "oz"
            case .fluidOunce:
                "fl oz"
            case .litre:
                "litre"
            case .deciliter:
                "dl"
            case .centiliter:
                "cl"
            case .bottle:
                "bottle"
            case .pinch:
                "pinch"
            case .can:
                "can"
            case .bunch:
                "bunch"
            case .box:
                "box"
            case .packet:
                "packet"
            }
        }
        
        var pluralValue: String {
            switch self {
            case .bottle,
                 .box,
                 .bunch,
                 .can,
                 .cup,
                 .litre,
                 .mill,
                 .packet,
                 .pinch:
                shortValue + "s"
            case .centiliter,
                 .deciliter,
                 .fluidOunce,
                 .gram,
                 .item,
                 .kilogram,
                 .ounce,
                 .pound,
                 .tablespoon,
                 .teaspoon:
                shortValue
            }
        }
    }
}
