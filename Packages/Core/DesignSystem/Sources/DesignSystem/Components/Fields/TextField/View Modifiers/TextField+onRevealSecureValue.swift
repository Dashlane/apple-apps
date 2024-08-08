import SwiftUI

struct TextFieldOnRevealSecureValueAction {
  let action: () -> Void

  func callAsFunction() {
    action()
  }
}

enum TextFieldOnRevealSecureValueActionKey: EnvironmentKey {
  static let defaultValue: TextFieldOnRevealSecureValueAction? = nil
}

extension EnvironmentValues {
  var textFieldOnRevealSecureValueAction: TextFieldOnRevealSecureValueAction? {
    get { self[TextFieldOnRevealSecureValueActionKey.self] }
    set { self[TextFieldOnRevealSecureValueActionKey.self] = newValue }
  }
}

extension View {
  public func onRevealSecureValue(_ action: @escaping () -> Void) -> some View {
    environment(
      \.textFieldOnRevealSecureValueAction,
      TextFieldOnRevealSecureValueAction(action: action)
    )
  }
}
