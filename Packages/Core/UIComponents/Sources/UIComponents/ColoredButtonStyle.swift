import SwiftUI
import DesignSystem

public struct ColoredButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let color: SwiftUI.Color

    public init(color: SwiftUI.Color = .ds.text.brand.standard) {
        self.color = color
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(color)
            .opacity(configuration.isPressed || !isEnabled ? 0.5 : 1)
    }
}

public extension ButtonStyle where Self == ColoredButtonStyle {
    static func colored(_ color: Color) -> ColoredButtonStyle {
        return ColoredButtonStyle(color: color)
    }
}
