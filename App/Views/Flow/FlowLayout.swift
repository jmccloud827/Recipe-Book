import CoreFoundation
import SwiftUI

nonisolated struct FlowLayout: Sendable, Layout {
    let axis: Axis
    let alignment: Alignment
    let spacing: CGSize?
    let justified: Bool
    let distributeItemsEvenly: Bool

    private typealias Item = (subview: LayoutSubview, cache: FlowLayoutCache.SubviewCache)
    private typealias Line = [ItemWithSpacing<Item>]
    private typealias Lines = [ItemWithSpacing<Line>]

    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: LayoutSubviews,
                      cache: inout FlowLayoutCache) -> CGSize {
        guard !subviews.isEmpty else {
            return .zero
        }

        let lines = calculateLayout(in: proposal, of: subviews, cache: cache)
        var size = lines
            .map(\.size)
            .reduce(.zero, breadth: max, depth: +)
        size.depth += lines.sum(of: \.leadingSpace)
        if justified {
            size.breadth = proposal.value(on: axis)
        }
        return CGSize(size: size, axis: axis)
    }

    func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: LayoutSubviews,
                       cache: inout FlowLayoutCache) {
        guard !subviews.isEmpty else {
            return
        }

        var bounds = bounds
        bounds.origin.replaceNaN(with: 0)
        var target = bounds.origin.size(on: axis)

        let lines = calculateLayout(in: proposal, of: subviews, cache: cache)

        for line in lines {
            adjust(&target, for: line, on: .vertical) { target in
                let minimumValue =
                    switch axis {
                    case .horizontal: bounds.minX
                    case .vertical: bounds.minY
                    }
                target.breadth = minimumValue

                for item in line.item {
                    adjust(&target, for: item, on: .horizontal) { target in
                        alignAndPlace(item, in: line, at: target)
                    }
                }
            }
        }
    }

    func makeCache(subviews: LayoutSubviews) -> FlowLayoutCache {
        FlowLayoutCache(subviews, axis: axis)
    }

    private func adjust<T>(_ target: inout Size,
                           for item: ItemWithSpacing<T>,
                           on axis: Axis,
                           body: (inout Size) -> Void) {
        let leadingSpace = item.leadingSpace
        let size = item.size[axis]
        target[axis] += leadingSpace
        body(&target)
        target[axis] += size
    }

    private func alignAndPlace(_ item: Line.Element,
                               in line: Lines.Element,
                               at target: Size) {
        var position = target
        let lineDepth = line.size.depth
        let size = Size(breadth: item.size.breadth, depth: lineDepth)
        let proposedSize = ProposedViewSize(size: size, axis: axis)
        let itemDepth = item.size.depth
        if itemDepth > 0 {
            let dimensions = item.item.subview.dimensions(in: proposedSize)
            let alignedPosition = dimensions[alignment.vertical]
            position.depth += (alignedPosition / itemDepth) * (lineDepth - itemDepth)
            if position.depth.isNaN {
                position.depth = .infinity
            }
        }
        let point = CGPoint(size: position, axis: axis)
        item.item.subview.place(at: point, anchor: .topLeading, proposal: proposedSize)
    }

    private func calculateLayout(in proposedSize: ProposedViewSize,
                                 of subviews: Subviews,
                                 cache: FlowLayoutCache) -> Lines {
        let items: LineBreakingInput = subviews.enumerated().map { offset, subview in
            let minValue: CGFloat
            let subviewCache = cache.subviewsCache[offset]
            if subviewCache.ideal.breadth <= proposedSize.value(on: axis) {
                minValue = subviewCache.ideal.breadth
            } else {
                minValue = subview.sizeThatFits(proposedSize).value(on: axis)
            }
            let maxValue = subviewCache.max.breadth
            let size = min(minValue, maxValue) ... max(minValue, maxValue)
            let spacing = spacing?.width ?? (
                offset > cache.subviewsCache.startIndex
                    ? cache.subviewsCache[offset - 1].spacing.distance(to: subviewCache.spacing, along: axis)
                    : 0
            )
            return .init(size: size,
                         spacing: spacing,
                         priority: subviewCache.priority,
                         isLineBreakView: subviewCache.layoutValues.isLineBreak,
                         shouldStartInNewLine: subviewCache.layoutValues.shouldStartInNewLine)
        }

        let lineBreaker: any LineBreaking =
            if distributeItemsEvenly {
                KnuthPlassLineBreaker()
            } else {
                FlowLineBreaker()
            }

        let wrapped = lineBreaker.wrapItemsToLines(items: items,
                                                   in: proposedSize.replacingUnspecifiedDimensions(by: .infinity).value(on: axis))

        var lines: Lines = wrapped.map { line in
            let items = line.map { item in
                Line.Element(item: (subview: subviews[item.index], cache: cache.subviewsCache[item.index]),
                             size: subviews[item.index]
                                 .sizeThatFits(ProposedViewSize(size: Size(breadth: item.size, depth: .infinity), axis: axis))
                                 .size(on: axis),
                             leadingSpace: item.leadingSpace)
            }
            var size = items
                .map(\.size)
                .reduce(.zero, breadth: +, depth: max)
            size.breadth += items.sum(of: \.leadingSpace)
            return Lines.Element(item: items,
                                 size: size,
                                 leadingSpace: 0)
        }

        if justified {
            for (lineIndex, line) in lines.enumerated() {
                let items = line.item
                let remainingSpace = proposedSize.value(on: axis) - items.sum { $0.size[axis] + $0.leadingSpace }
                for (itemIndex, item) in items.enumerated().dropFirst() {
                    let distributedSpace = remainingSpace / Double(items.count - 1)
                    lines[lineIndex].item[itemIndex].leadingSpace = item.leadingSpace + distributedSpace
                }
            }
        }
        
        if let spacing {
            for index in lines.indices.dropFirst() {
                lines[index].leadingSpace = spacing.height
            }
        } else {
            let lineSpacings = lines.map { line in
                line.item.reduce(into: ViewSpacing()) { $0.formUnion($1.item.cache.spacing) }
            }
            for (previous, index) in lines.indices.adjacentPairs() {
                let spacing = lineSpacings[index].distance(to: lineSpacings[previous], along: axis.perpendicular)
                lines[index].leadingSpace = spacing
            }
        }
        for index in lines.indices where lines[index].item.count == 1 && lines[index].item[0].item.cache.layoutValues.isLineBreak {
            lines[index].leadingSpace = 0
        }
        
        let breadth = lines.map { $0.item.sum { $0.leadingSpace + $0.size.breadth } }.max() ?? 0
        for index in lines.indices where !lines[index].item.isEmpty {
            lines[index].item[0].leadingSpace += determineLeadingSpace(in: lines[index], breadth: breadth)
        }
        
        return lines
    }

    private func determineLeadingSpace(in line: Lines.Element, breadth: CGFloat) -> CGFloat {
        guard let item = line.item.first(where: { $0.item.cache.ideal.breadth > 0 })?.item else {
            return 0
        }
        let lineSize = line.item.sum { $0.leadingSpace + $0.size.breadth }
        let value = item.subview.dimensions(in: .unspecified)[alignment.horizontal] / item.cache.ideal.breadth
        let remainingSpace = breadth - lineSize
        return value * remainingSpace
    }
}

private nonisolated extension Array where Element == Size {
    func reduce(_ initial: Size,
                breadth: (CGFloat, CGFloat) -> CGFloat,
                depth: (CGFloat, CGFloat) -> CGFloat) -> Size {
        reduce(initial) { result, size in
            Size(breadth: breadth(result.breadth, size.breadth),
                 depth: depth(result.depth, size.depth))
        }
    }
}

nonisolated struct FlowLayoutCache {
    let subviewsCache: [SubviewCache]

    init(_ subviews: LayoutSubviews, axis: Axis) {
        subviewsCache = subviews.map {
            SubviewCache($0, axis: axis)
        }
    }
    
    struct SubviewCache {
        var priority: Double
        var spacing: ViewSpacing
        var min: Size
        var ideal: Size
        var max: Size
        var layoutValues: LayoutValues

        init(_ subview: LayoutSubview, axis: Axis) {
            priority = subview.priority
            spacing = subview.spacing
            min = subview.dimensions(in: .zero).size(on: axis)
            ideal = subview.dimensions(in: .unspecified).size(on: axis)
            max = subview.dimensions(in: .infinity).size(on: axis)
            layoutValues = LayoutValues(shouldStartInNewLine: subview[ShouldStartInNewLineLayoutValueKey.self],
                                        isLineBreak: subview[IsLineBreakLayoutValueKey.self])
        }
        
        struct LayoutValues {
            var shouldStartInNewLine: Bool
            var isLineBreak: Bool

            init(shouldStartInNewLine: Bool, isLineBreak: Bool) {
                self.shouldStartInNewLine = shouldStartInNewLine
                self.isLineBreak = isLineBreak
            }
        }
    }
}

private nonisolated struct ItemWithSpacing<T> {
    var item: T
    var size: Size
    var leadingSpace: CGFloat = 0
}

private nonisolated extension CGPoint {
    mutating func replaceNaN(with value: CGFloat) {
        x.replaceNaN(with: value)
        y.replaceNaN(with: value)
    }
}

private nonisolated extension CGFloat {
    mutating func replaceNaN(with value: CGFloat) {
        if isNaN {
            self = value
        }
    }
}

private nonisolated extension ViewDimensions {
    func size(on axis: Axis) -> Size {
        Size(breadth: value(on: axis),
             depth: value(on: axis.perpendicular))
    }

    func value(on axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal: width
        case .vertical: height
        }
    }
}

private nonisolated extension Sequence {
    func adjacentPairs() -> some Sequence<(Element, Element)> {
        zip(self, self.dropFirst())
    }
}
