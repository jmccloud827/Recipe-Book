import SwiftData
import SwiftUI

@Model class Step: Identifiable {
    var id = UUID()
    var text: String = ""
    var createdDate: Date = Date.now
    var order: Int = 0
    var belongsTo: Recipe.Section?
    @MainActor var attributedText: AttributedString {
        get {
            var result = AttributedString("")
            let flatWords = self.getWordsWithAttributes().flatMap { group in group.words.map { ($0, group.color) } }

            for (index, (word, color)) in flatWords.enumerated() {
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
        self.text = text
        self.belongsTo = belongsTo
    }

    init(belongsTo: Recipe.Section) {
        self.belongsTo = belongsTo
    }
    
    /// One run of consecutive words from a step, tagged with a display color and — for time phrases —
    /// the timer duration options a user could start for it. `durations` is computed once here rather
    /// than re-parsed from `words` by every view that renders the group.
    struct WordGroup {
        let words: [String]
        let color: Color?
        let durations: [ParsedDuration]?
    }

    /// Splits the step text into groups of one or more words, each tagged with a color. Words that
    /// spell out an ingredient's full name (e.g. "olive" + "oil" for the ingredient "olive oil") are
    /// grouped together so they render and behave as a single unit instead of one per word.
    @MainActor func getWordsWithAttributes() -> [WordGroup] {
        var result: [WordGroup] = []
        let words = self.text.split(separator: " ")
        // Tokenize each ingredient's name once per call instead of letting `matchLength`/`contains(word:)`
        // re-split it for every word position they're compared against.
        let ingredients = (self.belongsTo?.ingredients ?? []).map { ($0, $0.nameTokens) }

        var index = 0
        while index < words.count {
            let bestMatchLength = ingredients.reduce(0) { max($0, $1.0.matchLength(in: words, at: index, tokens: $1.1)) }

            if bestMatchLength > 0 {
                result.append(WordGroup(words: words[index ..< index + bestMatchLength].map(String.init), color: .accent, durations: nil))
                index += bestMatchLength
            } else if ingredients.contains(where: { $0.0.contains(word: String(words[index]), tokens: $0.1) }) {
                result.append(WordGroup(words: [String(words[index])], color: .accent, durations: nil))
                index += 1
            } else if Self.timeUnits.contains(where: { words[index].lowercased().trimmingCharacters(in: .punctuationCharacters).contains($0.name) }) {
                // Fold the number that comes right before the unit (e.g. "6-8" + "minutes") into one
                // group, so "6-8 minutes" renders and behaves as a single unit instead of two.
                if let lastGroup = result.last, lastGroup.color == nil {
                    let mergedWords = lastGroup.words + [String(words[index])]
                    result[result.count - 1] = WordGroup(words: mergedWords, color: .blue, durations: Self.parseDurations(from: mergedWords))
                } else {
                    let newWords = [String(words[index])]
                    result.append(WordGroup(words: newWords, color: .blue, durations: Self.parseDurations(from: newWords)))
                }

                index += 1
            } else {
                result.append(WordGroup(words: [String(words[index])], color: nil, durations: nil))
                index += 1
            }
        }

        return result
    }

    /// A single timer duration option parsed out of a step's time phrase (e.g. "6 minutes").
    struct ParsedDuration: Hashable {
        let timeInterval: TimeInterval
        let label: String
    }

    /// Parses the number(s) and unit out of a time-measurement word group (e.g. ["6-8", "minutes"])
    /// so a timer can be started for it. A range like "6-8 minutes" produces one option per endpoint.
    /// Returns nil if the group doesn't contain both a recognizable unit and at least one number.
    private static func parseDurations(from words: [String]) -> [ParsedDuration]? {
        guard let unit = Self.timeUnits.first(where: { unit in words.contains { $0.lowercased().contains(unit.name) } }) else {
            return nil
        }

        let numbers = words
            .filter { word in !Self.timeUnits.contains { word.lowercased().contains($0.name) } }
            .flatMap { word -> [Int] in
                word.trimmingCharacters(in: .punctuationCharacters)
                    .split(separator: "-")
                    .compactMap { Int($0) }
            }

        guard !numbers.isEmpty else { return nil }

        return Array(Set(numbers)).sorted().map { number in
            ParsedDuration(
                timeInterval: TimeInterval(number) * unit.seconds,
                label: "\(number) \(unit.name)\(number == 1 ? "" : "s")"
            )
        }
    }

    private static let timeUnits: [(name: String, seconds: TimeInterval)] = [
        ("second", 1),
        ("minute", 60),
        ("hour", 3600)
    ]
}
