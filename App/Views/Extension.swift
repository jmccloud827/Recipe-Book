import SwiftData
import SwiftUI

extension EnvironmentValues {
    @Entry var canEdit = true
}

extension UIFont {
    static func fractionFont(ofSize pointSize: CGFloat) -> UIFont {
        let systemFontDesc = UIFont.systemFont(ofSize: pointSize).fontDescriptor
        let fractionFontDesc = systemFontDesc.addingAttributes(
            [
                UIFontDescriptor.AttributeName.featureSettings: [
                    [
                        UIFontDescriptor.FeatureKey.type: kFractionsType,
                        UIFontDescriptor.FeatureKey.selector: kDiagonalFractionsSelector
                    ]
                ]
            ])
        return UIFont(descriptor: fractionFontDesc, size: pointSize)
    }
}

extension ModelContainer {
    static var previewContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Recipe.self,
                                            Recipe.Section.self,
                                            Ingredient.self,
                                            Step.self,
                                            configurations: config)
    
        Recipe.samples.forEach { container.mainContext.insert($0) }
    
        try? container.mainContext.save()
    
        return container
    }
}

#if DEBUG
    extension Color {
        static func random() -> Color {
            return Color(red: Double.random(in: 0 ... 1),
                         green: Double.random(in: 0 ... 1),
                         blue: Double.random(in: 0 ... 1))
        }
    }
#endif
