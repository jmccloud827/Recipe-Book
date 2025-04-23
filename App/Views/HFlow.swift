import SwiftUI

struct HFlow: Layout {
    let lineAlignment: Alignment
    let spacing: CGSize
    
    init(spacing: CGSize = .init(width: 8, height: 8), lineAlignment alignment: Alignment = .topLeading) {
        self.lineAlignment = alignment
        self.spacing = spacing
    }

    typealias Cache = [[CGRect]]

    func makeCache(subviews _: Subviews) -> Cache {
        Cache()
    }

    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout Cache) -> CGSize {
        cache = []

        let width = proposal.width ?? subviews.reduce(0) { max($0, $1.sizeThatFits(proposal).width) }

        var offsetX = 0.0
        var offsetY = 0.0

        var currentLine: [PartialRect] = []

        for subview in subviews {
            let subviewWidth = min(width, subview.sizeThatFits(proposal).width)

            if offsetX + subviewWidth > width {
                offsetY += self.commit(proposal: proposal,
                                       line: currentLine,
                                       offsetY: offsetY,
                                       width: width,
                                       cache: &cache)

                offsetX = 0
                currentLine = []
            }

            let viewWidth = min(width, subview.sizeThatFits(proposal).width)
            let viewHeight = subview.sizeThatFits(proposal).height

            currentLine.append(
                PartialRect(subview: subview,
                            xValue: offsetX,
                            size: CGSize(width: viewWidth,
                                         height: viewHeight)))

            offsetX += viewWidth + self.spacing.width
        }

        if !currentLine.isEmpty {
            _ = self.commit(proposal: proposal,
                            line: currentLine,
                            offsetY: offsetY,
                            width: width,
                            cache: &cache)
        }
        
        let totalWidth = cache.flatMap(\.self).reduce(0) { width, line in
            max(width, line.maxX)
        }
        
        let totalHeight = cache.flatMap(\.self).reduce(0) { height, line in
            max(height, line.maxY)
        }

        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect,
                       proposal _: ProposedViewSize,
                       subviews: Subviews,
                       cache: inout Cache) {
        let allCache = cache.flatMap(\.self)

        for (index, subview) in Array(subviews.enumerated()) {
            let rect = allCache[index]

            subview.place(at: CGPoint(x: bounds.origin.x + rect.origin.x,
                                      y: bounds.origin.y + rect.origin.y),
                          proposal: .init(
                              rect.size))
        }
    }

    private func commit(proposal _: ProposedViewSize,
                        line: [PartialRect],
                        offsetY: Double,
                        width: Double,
                        cache: inout Cache) -> Double {
        let height = line.reduce(0) { max($0, $1.size.height) }

        let diffX = width - line.reduce(0) { max($0, $1.xValue + $1.size.width) }

        let offsetX: Double =
            switch self.lineAlignment.horizontal {
            case .listRowSeparatorTrailing,
                 .trailing:
                diffX
            
            case .center:
                diffX / 2.0
            
            default:
                0
            }

        var cacheLine: [CGRect] = []

        for partialRect in line {
            let lineDiffY = height - partialRect.size.height

            let lineOffsetY: Double =
                switch self.lineAlignment.vertical {
                case .bottom:
                    lineDiffY
                    
                case .center:
                    lineDiffY / 2.0
                    
                default:
                    0
                }

            cacheLine.append(
                CGRect(x: partialRect.xValue + offsetX,
                       y: offsetY + lineOffsetY,
                       width: partialRect.size.width,
                       height: partialRect.size.height))
        }

        cache.append(
            cacheLine)

        return height + self.spacing.height
    }
    
    private struct PartialRect {
        let subview: LayoutSubview
        let xValue: Double
        let size: CGSize
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
        .pink
    ]
    
    HFlow {
        ForEach(colors, id: \.description) { color in
            RoundedRectangle(cornerRadius: 10)
                .fill(color.gradient)
                .frame(width: .random(in: 40 ... 120), height: 50)
        }
    }
    .frame(maxWidth: 300)
}
