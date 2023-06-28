import SwiftUI

struct TextFieldBackground: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.textFieldAppearance) private var appearance
    @Environment(\.textFieldFeedbackAppearance) private var feedbackAppearance

    @ScaledMetric private var backgroundCornerRadius = 10
    @ScaledMetric private var backgroundStrokeWidth = 1

    private let isFocused: Bool

    init(isFocused: Bool) {
        self.isFocused = isFocused
    }

    var body: some View {
        if appearance == .standalone {
            ZStack {
                RoundedRectangle(
                    cornerRadius: backgroundCornerRadius - (backgroundStrokeWidth / 2),
                    style: .continuous
                )
                .inset(by: -backgroundStrokeWidth / 2)
                .stroke(
                    Color.focusBorderColor(
                        isFocused: isFocused,
                        feedbackAppearance: feedbackAppearance
                    ),
                    lineWidth: backgroundStrokeWidth
                )
                .opacity(isEnabled ? 1 : 0)
                .animation(.easeInOut, value: isFocused)
                .animation(.easeInOut, value: isFocused)

                RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
                    .fill(Color.backgroundColor(isEnabled: isEnabled))
            }
        } else {
            Color.clear
        }
    }
}

private extension Color {
    static func focusBorderColor(
        isFocused: Bool,
        feedbackAppearance: TextFieldFeedbackAppearance?
    ) -> Color {
        if let feedbackAppearance, case .error = feedbackAppearance {
            return .ds.border.danger.quiet.idle
        }
        return isFocused ? .ds.border.brand.standard.active : .ds.border.neutral.quiet.idle
    }

    static func backgroundColor(isEnabled: Bool) -> Color {
        if isEnabled {
            return Color.ds.container.agnostic.neutral.supershy
        } else {
            return Color.ds.container.expressive.neutral.quiet.disabled
        }
    }
}

struct TextFieldBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            TextFieldBackground(isFocused: false)
                .frame(height: 44)
            TextFieldBackground(isFocused: true)
                .frame(height: 44)
            TextFieldBackground(isFocused: false)
                .frame(height: 44)
                .disabled(true)
            TextFieldBackground(isFocused: false)
                .frame(height: 44)
                .textFieldAppearance(.grouped)
            TextFieldBackground(isFocused: true)
                .frame(height: 44)
                .textFieldAppearance(.grouped)
        }
        .padding(.horizontal)
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }
}
