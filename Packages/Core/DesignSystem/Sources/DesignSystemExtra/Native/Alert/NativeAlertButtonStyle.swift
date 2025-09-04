import DesignSystem
import SwiftUI
import UIDelight

struct NativeAlertButtonStyle: ButtonStyle {

  static let buttonHeight: CGFloat = 44

  @Environment(\.isEnabled) var isEnabled

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(
        .system(
          size: 17, weight: configuration.role == .cancel ? .regular : .semibold, design: .default)
      )
      .foregroundStyle(textColor(for: configuration))
      .padding(12)
      .frame(maxWidth: .infinity, maxHeight: Self.buttonHeight)
      .contentShape(Rectangle())
      .background(configuration.isPressed ? Color.primary.opacity(0.1) : Color.clear)
      .hoverEffect(isEnabled: isEnabled)
  }

  private func textColor(for configuration: Configuration) -> Color {
    guard isEnabled else {
      return .ds.text.oddity.disabled
    }

    let baseColor: Color =
      configuration.role == .destructive ? .ds.text.danger.standard : .ds.text.brand.standard

    if configuration.isPressed {
      return baseColor.opacity(0.8)
    } else {
      return baseColor
    }
  }
}

extension ButtonStyle where Self == NativeAlertButtonStyle {
  static var nativeAlert: NativeAlertButtonStyle { .init() }
}

#Preview("Button variants") {
  NativeAlert {
    Text("Variants")
      .padding()
      .foregroundStyle(.secondary)
  } buttons: {
    Button("Default") {}
    Button("Default disabled") {}
      .disabled(true)
    Button("Cancel", role: .cancel) {}
    Button("Delete", role: .destructive) {}
  }
  .alertButtonsLayout(.vertical)

}

#Preview("Buttons Horizontal") {
  NativeAlert {
    Text("Horizontal")
      .padding()
      .foregroundStyle(.secondary)
  } buttons: {
    Button("Cancel", role: .cancel) {}
    Button("Do") {}
  }
  .alertButtonsLayout(.horizontal)
}
