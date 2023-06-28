import SwiftUI

public struct TrailingIconLabelStyle: LabelStyle {
    @ScaledMetric private var spacing: Double

    public init(spacing: Double) {
        _spacing = .init(wrappedValue: spacing)
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: spacing) {
            configuration.title
                .alignmentGuide(.firstTextBaseline) { context in
                    let remainingLineHeight = (context.height - context[.lastTextBaseline])
                    let lineHeight = context[.firstTextBaseline] + remainingLineHeight
                    let lineVerticalCenter = lineHeight / 2
                    return lineVerticalCenter
                }
            configuration.icon
                .alignmentGuide(.firstTextBaseline) { context in
                    context[VerticalAlignment.center]
                }
        }
    }
}

struct TrailingIconLabelStyle_Previews: PreviewProvider {
    struct Preview: View {
        @Environment(\.layoutDirection) private var layoutDirection

        var body: some View {
            VStack(alignment: .trailing) {
                Label("Title 1", systemImage: "star")
                Label("Title 2", systemImage: "square")
                Label("Title 3", systemImage: "circle")
                Label("Title 4\n Multiline", systemImage: arrowImageName)
                    .multilineTextAlignment(.trailing)
            }
            .labelStyle(TrailingIconLabelStyle(spacing: 8))
        }

        private var arrowImageName: String {
            if layoutDirection == .leftToRight {
                return "arrow.right"
            }
            return "arrow.left"
        }
    }
    static var previews: some View {
        Preview()
            .previewDisplayName("Left to Right")

        Preview()
            .environment(\.layoutDirection, .rightToLeft)
            .previewDisplayName("Right to Left")
    }
}
