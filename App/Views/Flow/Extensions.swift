import SwiftUI

public struct LineBreak: View {
    public init() {}

    public var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .layoutValue(key: IsLineBreakLayoutValueKey.self, value: true)
    }
}

extension View {
    public func startInNewLine(_ enabled: Bool = true) -> some View {
        layoutValue(key: ShouldStartInNewLineLayoutValueKey.self, value: enabled)
    }
}

nonisolated struct ShouldStartInNewLineLayoutValueKey: LayoutValueKey {
    static let defaultValue = false
}

nonisolated struct IsLineBreakLayoutValueKey: LayoutValueKey {
    static let defaultValue = false
}

nonisolated extension Sequence {
    func sum<Result: Numeric>(of block: (Element) -> Result) -> Result {
        reduce(into: .zero) { $0 += block($1) }
    }
}
