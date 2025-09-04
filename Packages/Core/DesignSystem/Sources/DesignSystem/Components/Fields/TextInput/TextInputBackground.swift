import SwiftUI
import UIDelight

package struct TextInputBackground: View {
  @Environment(\.style) private var style
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.container) private var container

  @ScaledMetric private var backgroundCornerRadius = 10
  @ScaledMetric private var backgroundStrokeWidth = 1

  private let isFocused: Bool

  package init(isFocused: Bool) {
    self.isFocused = isFocused
  }

  package var body: some View {
    switch container {
    case .list(.plain), .root:
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

        RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
          .fill(Color.backgroundColor(isEnabled: isEnabled))
      }

    case .list(.insetGrouped):
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
      .containerContext(.list(.insetGrouped))
    TextInputBackground(isFocused: true)
      .frame(height: 44)
      .containerContext(.list(.insetGrouped))
  }
  .padding(.horizontal)
  .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
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
      .containerContext(.list(.insetGrouped))
    TextInputBackground(isFocused: true)
      .frame(height: 44)
      .containerContext(.list(.insetGrouped))
  }
  .padding(.horizontal)
  .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  .style(.error)
}
