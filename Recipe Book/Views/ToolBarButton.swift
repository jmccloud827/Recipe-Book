import SwiftUI

public struct ToolbarButton<S: PrimitiveButtonStyle>: View {
    private let systemName: String?
    private let color: Color
    private let style: S
    private let offset: Double
    private let code: () -> Void
    
    public init(systemName: String?,
                color: Color,
                style: S,
                offset: Double = 0,
                code: @escaping () -> Void) {
        self.systemName = systemName
        self.color = color
        self.style = style
        self.offset = offset
        self.code = code
    }
    
    public var body: some View {
        Button {
            code()
        } label: {
            let symbol =
                Group {
                    if let systemName {
                        Image(systemName: systemName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .fontWeight(.heavy)
                            .frame(width: 15, height: 15)
                            .offset(x: offset)
                    } else {
                        Image(systemName: "chevron.up")
                            .frame(width: 15, height: 15)
                            .opacity(0)
                    }
                }
            if color == .white {
                symbol
                    .foregroundStyle(.foreground)
            } else {
                symbol
            }
        }
        .buttonStyle(style)
        .tint(color)
        .background(.ultraThickMaterial)
        .clipShape(Circle())
        .frame(width: 30, height: 30)
    }
}

public extension ToolbarButton where S == BorderedButtonStyle {
    init(systemName: String?, color: Color, offset: Double = 0, code: @escaping () -> Void) {
        self.init(systemName: systemName, color: color, style: .bordered, offset: offset, code: code)
    }
}

#Preview("Toolbar Button") {
    NavigationStack {
        List {
            Text("Test")
        }
        .toolbar {
            ToolbarButton(systemName: "line.3.horizontal.decrease", color: .blue, style: .borderedProminent) {}
        }
        .navigationTitle("Test")
        .navigationBarTitleDisplayMode(.inline)
    }
}
