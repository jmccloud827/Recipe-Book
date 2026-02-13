import SwiftUI

public struct VFlow<Content: View>: View {
    private let layout: FlowLayout
    private let content: () -> Content
    
    public init(alignment: Alignment = .top,
                spacing: CGSize? = nil,
                justified: Bool = false,
                distributeItemsEvenly: Bool = false,
                content: @escaping () -> Content) {
        self.content = content
        self.layout = .init(axis: .vertical,
                            alignment: alignment,
                            spacing: spacing,
                            justified: justified,
                            distributeItemsEvenly: distributeItemsEvenly)
    }
    
    public var body: some View {
        layout {
            content()
        }
    }
}

#Preview {
    let colors: [Color] = [
        .blue,
        .orange,
        .green,
        .yellow,
        .brown,
        .mint,
        .indigo,
        .cyan,
        .gray,
        .pink,
        .blue,
        .orange,
        .green,
        .yellow,
        .brown,
        .mint,
        .indigo,
        .cyan,
        .gray,
        .pink,
        .blue,
        .orange,
        .green,
        .yellow,
        .brown,
        .mint,
        .indigo,
        .cyan,
        .gray,
        .pink,
        .blue,
        .orange,
        .green,
        .yellow,
        .brown,
        .mint,
        .indigo,
        .cyan,
        .gray,
        .pink,
        .blue,
        .orange,
        .green,
        .yellow,
        .brown,
        .mint,
        .indigo,
        .cyan,
        .gray,
        .pink
    ]
    
    VFlow {
        ForEach(colors.enumerated(), id: \.offset) { _, color in
            RoundedRectangle(cornerRadius: 10)
                .fill(color.gradient)
                .frame(width: .random(in: 30 ... 60), height: 30)
        }
    }
    .frame(maxWidth: 300)
}
