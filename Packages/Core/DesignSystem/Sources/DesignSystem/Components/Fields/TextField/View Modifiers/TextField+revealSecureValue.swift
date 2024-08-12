import SwiftUI

enum TextFieldIsSecureValueRevealedKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var textFieldIsSecureValueRevealed: Bool {
    get { self[TextFieldIsSecureValueRevealedKey.self] }
    set { self[TextFieldIsSecureValueRevealedKey.self] = newValue }
  }
}

extension View {
  public func textFieldRevealSecureValue(_ reveal: Bool) -> some View {
    environment(\.textFieldIsSecureValueRevealed, reveal)
  }
}
