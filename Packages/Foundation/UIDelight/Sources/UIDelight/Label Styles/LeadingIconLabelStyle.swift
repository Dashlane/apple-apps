import SwiftUI

public struct LeadingIconLabelStyle: LabelStyle {
    @ScaledMetric private var spacing: Double

    public init(spacing: Double) {
        _spacing = .init(wrappedValue: spacing)
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: spacing) {
            configuration.icon
                .alignmentGuide(.firstTextBaseline) { context in
                    context[VerticalAlignment.center]
                }
            configuration.title
                .alignmentGuide(.firstTextBaseline) { context in
                    let remainingLineHeight = (context.height - context[.lastTextBaseline])
                    let lineHeight = context[.firstTextBaseline] + remainingLineHeight
                    let lineVerticalCenter = lineHeight / 2
                    return lineVerticalCenter
                }
        }
    }
}
