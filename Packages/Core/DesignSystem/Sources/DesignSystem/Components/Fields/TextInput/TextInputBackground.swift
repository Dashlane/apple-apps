import SwiftUI
import UIDelight

struct TextInputBackground: View {
  @Environment(\.style) private var style
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.fieldAppearance) private var appearance

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
            mood: style.mood
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

extension Color {
  fileprivate static func focusBorderColor(isFocused: Bool, mood: Mood) -> Color {
    if mood == .danger {
      return isFocused ? .ds.border.danger.standard.idle : .ds.border.danger.quiet.idle
    }
    return isFocused ? .ds.border.brand.standard.idle : .ds.border.neutral.quiet.idle
  }

  fileprivate static func backgroundColor(isEnabled: Bool) -> Color {
    if isEnabled {
      return Color.ds.container.agnostic.neutral.supershy
    } else {
      return Color.ds.container.expressive.neutral.quiet.disabled
    }
  }
}

#Preview("Brand") {
  VStack(spacing: 24) {
    TextInputBackground(isFocused: false)
      .frame(height: 44)
    TextInputBackground(isFocused: true)
      .frame(height: 44)
    TextInputBackground(isFocused: false)
      .frame(height: 44)
      .disabled(true)
    TextInputBackground(isFocused: false)
      .frame(height: 44)
      .fieldAppearance(.grouped)
    TextInputBackground(isFocused: true)
      .frame(height: 44)
      .fieldAppearance(.grouped)
  }
  .padding(.horizontal)
  .backgroundColorIgnoringSafeArea(.ds.background.alternate)
}

#Preview("Danger") {
  VStack(spacing: 24) {
    TextInputBackground(isFocused: false)
      .frame(height: 44)
    TextInputBackground(isFocused: true)
      .frame(height: 44)
    TextInputBackground(isFocused: false)
      .frame(height: 44)
      .disabled(true)
    TextInputBackground(isFocused: false)
      .frame(height: 44)
      .fieldAppearance(.grouped)
    TextInputBackground(isFocused: true)
      .frame(height: 44)
      .fieldAppearance(.grouped)
  }
  .padding(.horizontal)
  .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  .style(.error)
}
