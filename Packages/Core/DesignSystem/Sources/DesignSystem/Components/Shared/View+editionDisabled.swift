import SwiftUI

enum EditionDisabledKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var editionDisabled: Bool {
    get { self[EditionDisabledKey.self] }
    set { self[EditionDisabledKey.self] = newValue }
  }
}

extension View {
  public func editionDisabled(
    _ disabled: Bool = true,
    appearance: TextInputDisabledEditionAppearance = .emphasized
  ) -> some View {
    self
      .environment(\.editionDisabled, disabled)
      .environment(\.textInputDisabledEditionAppearance, appearance)
  }
}
