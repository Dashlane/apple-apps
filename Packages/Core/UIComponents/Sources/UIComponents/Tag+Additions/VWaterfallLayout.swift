import SwiftUI

struct VWaterfallLayout<Content: View>: View {

    let alignment: Alignment

    let content: () -> Content

    let size: CGSize
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    var body: some View {
        var alignments: [CGSize] = []
        var isLastLineAdjusted: Bool = false

                var top: CGFloat = 0
                var leading: CGFloat = 0

        var maxValue: CGFloat = 0
        var maxLineValue: CGFloat = 0

        var currentIndex: Int = 0
        var lineFirstIndex: Int = 0
        var maximumIndex: Int?

        ZStack(alignment: .topLeading) {
                        content()
                .fixedSize()
                .alignmentGuide(.top) { _ in
                    if let maximumIndex, currentIndex > maximumIndex {
                        currentIndex %= maximumIndex
                    }

                    let top: CGFloat
                                        if alignments.indices.contains(currentIndex) {
                        top = alignments[currentIndex].height
                    } else {
                        top = 0
                    }

                    currentIndex += 1

                    return top
                }
                .alignmentGuide(.leading) { dimensions in
                    if let maximumIndex, currentIndex > maximumIndex {
                        currentIndex %= maximumIndex
                    }

                    if alignments.indices.contains(currentIndex) {
                        return alignments[currentIndex].width
                    }

                                        if leading + dimensions.width < size.width {
                        maxValue = max(dimensions.height, maxValue)
                    } else {
                                                if leading > maxLineValue {
                            let adjustment = adjustment(
                                maxLineValue: maxLineValue,
                                leading: leading,
                                dimensions: dimensions
                            )

                            for index in 0..<lineFirstIndex {
                                alignments[index].width += adjustment
                            }
                        }

                        maxLineValue = max(leading, maxLineValue)

                        let adjustment = adjustment(
                            maxLineValue: maxLineValue,
                            leading: leading,
                            dimensions: dimensions
                        )

                                                for index in lineFirstIndex..<currentIndex {
                            alignments[index].width -= adjustment
                        }

                        top += verticalSpacing + (leading == 0 ? dimensions.height : maxValue)
                        leading = 0
                        lineFirstIndex = currentIndex
                        maxValue = dimensions.height
                    }

                    alignments.append(.init(width: -leading, height: -top))
                    leading += horizontalSpacing + dimensions.width

                    return alignments[currentIndex].width
                }

                                    Color.clear
                .frame(width: 1, height: 1)
                .hidden()
                .alignmentGuide(.leading) { dimensions in
                    if maximumIndex == nil {
                        maximumIndex = currentIndex
                    }

                    if !isLastLineAdjusted, let lastIndex = alignments.indices.last {
                        let adjustment = adjustment(
                            maxLineValue: maxLineValue,
                            leading: leading,
                            dimensions: dimensions
                        )

                        for index in lineFirstIndex...lastIndex {
                            alignments[index].width -= adjustment
                        }

                        isLastLineAdjusted = true
                    }

                    top = 0
                    leading = 0
                    maxValue = 0
                    maxLineValue = 0
                    currentIndex = 0
                    lineFirstIndex = 0

                    return 0
                }
        }
        .frame(alignment: alignment)
    }

    private func adjustment(
        maxLineValue: CGFloat,
        leading: CGFloat,
        dimensions: ViewDimensions
    ) -> CGFloat {
        let currentMaxLineValue = maxLineValue - leading
        let adjustmentRatio = dimensions[alignment.horizontal] / dimensions[.trailing]

        return adjustmentRatio * currentMaxLineValue
    }
}
