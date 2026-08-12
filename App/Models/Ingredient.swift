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
    
    private static func normalize(_ text: some StringProtocol) -> String {
        text.lowercased().trimmingCharacters(in: .punctuationCharacters)
    }

    /// This ingredient's name split into words. A caller matching against many word positions in a
    /// loop (e.g. scanning a whole step) should compute this once and pass it to `contains(word:tokens:)`
    /// / `matchLength(in:at:tokens:)` instead of letting each call re-split `name` from scratch.
    var nameTokens: [Substring] {
        self.name.split(separator: " ")
    }

    func contains(word: String, tokens: [Substring]? = nil) -> Bool {
        let target = Self.normalize(word)
        return (tokens ?? nameTokens).contains { Self.normalize($0) == target }
    }

    /// Returns how many consecutive words in `words`, starting at `index`, spell out this ingredient's
    /// full name (compared word by word, case-insensitive, ignoring surrounding punctuation).
    /// Returns 0 if the full name doesn't match starting there.
    func matchLength(in words: [Substring], at index: Int, tokens: [Substring]? = nil) -> Int {
        let tokens = tokens ?? nameTokens
        guard !tokens.isEmpty, index + tokens.count <= words.count else { return 0 }

        for (offset, token) in tokens.enumerated() {
            if Self.normalize(token) != Self.normalize(words[index + offset]) {
                return 0
            }
        }

        return tokens.count
    }

    /// Whether `phrase` (one or more space-separated words) spells out this ingredient's full name,
    /// with nothing left over.
    func isExactMatch(for phrase: String) -> Bool {
        let words = phrase.split(separator: " ")
        return !words.isEmpty && matchLength(in: words, at: 0) == words.count
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
