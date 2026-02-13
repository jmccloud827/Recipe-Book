import SwiftData
import SwiftUI

@Model class Step: Identifiable {
    var id = UUID()
    var text: String = ""
    var createdDate: Date = Date.now
    var belongsTo: Recipe.Section?
    @MainActor var attributedText: AttributedString {
        get {
            var result = AttributedString("")
            
            for (index, (word, color)) in self.getWordsWithAttributes().enumerated() {
                if index != 0 {
                    result += .init(" ")
                }
                var wordString = AttributedString(word)
                if let color {
                    wordString.foregroundColor = color
                }
                
                result += wordString
            }
            
            return result
        }
        set {
            text = String(newValue.characters)
        }
    }
    
    init(belongsTo: Recipe.Section, text: String) {
        self.id = id
        self.text = text
        self.belongsTo = belongsTo
    }
    
    init(belongsTo: Recipe.Section) {
        self.id = id
        self.text = text
        self.belongsTo = belongsTo
    }
    
    @MainActor func getWordsWithAttributes() -> [(word: String, color: Color?)] {
        var result: [(word: String, color: Color?)] = []
        
        for word in self.text.split(separator: " ") {
            if let belongsTo = self.belongsTo,
               belongsTo.ingredients.contains(where: { $0.contains(word: String(word)) }) {
                result.append((String(word), .accent))
            } else if Self.timeMeasurements.contains(where: { word.lowercased().trimmingCharacters(in: .punctuationCharacters).contains($0.lowercased()) }) {
                if let lastWord = result.last?.word {
                    result[result.count - 1] = (lastWord, .blue)
                }
                
                result.append((String(word), .blue))
            } else {
                result.append((String(word), nil))
            }
        }
        
        return result
    }
    
    private static let timeMeasurements = ["second", "minute", "hour"]
}
