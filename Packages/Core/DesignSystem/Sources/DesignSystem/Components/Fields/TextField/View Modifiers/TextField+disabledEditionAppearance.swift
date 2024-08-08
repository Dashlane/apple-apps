import SwiftUI

public enum TextInputDisabledEditionAppearance {
  case discrete
  case emphasized
}

enum TextInputDisabledEditionAppearanceKey: EnvironmentKey {
  static let defaultValue = TextInputDisabledEditionAppearance.emphasized
}

extension EnvironmentValues {
  var textInputDisabledEditionAppearance: TextInputDisabledEditionAppearance {
    get { self[TextInputDisabledEditionAppearanceKey.self] }
    set { self[TextInputDisabledEditionAppearanceKey.self] = newValue }
  }
}

extension View {
  func textInputDisabledEditionAppearance(_ mode: TextInputDisabledEditionAppearance) -> some View {
    environment(\.textInputDisabledEditionAppearance, mode)
  }
}
