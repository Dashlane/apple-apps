import DesignSystem
import SwiftUI

public struct Chip: View {

    @ScaledMetric(relativeTo: .body) private var textSize = 13
    @ScaledMetric private var backgroundCornerRadius = 4
    @ScaledMetric private var textHorizontalPadding = 4
    @ScaledMetric private var containerPadding = 6

    private let title: String
    private let foregroundColor: Color = .ds.text.neutral.standard
    private let backgroundColor: Color = .ds.container.expressive.neutral.quiet.idle

                    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.system(size: textSize))
            .lineLimit(1)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, textHorizontalPadding)
            .padding(containerPadding)
            .background(backgroundView)
            .accessibilityElement()
            .accessibilityLabel(Text(title))
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
            .foregroundColor(backgroundColor)
    }
}

struct Chip_Previews: PreviewProvider {
    static var previews: some View {
        ChipPreview()
    }
}
