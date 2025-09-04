import SwiftUI

struct TextFieldOnRevealSecureValueAction {
  let action: () -> Void

  func callAsFunction() {
    action()
  }
}

extension EnvironmentValues {
  @Entry var textFieldOnRevealSecureValueAction: TextFieldOnRevealSecureValueAction?
}

extension View {
  public func onRevealSecureValue(_ action: @escaping () -> Void) -> some View {
    environment(
      \.textFieldOnRevealSecureValueAction,
      TextFieldOnRevealSecureValueAction(action: action)
    )
  }
}
