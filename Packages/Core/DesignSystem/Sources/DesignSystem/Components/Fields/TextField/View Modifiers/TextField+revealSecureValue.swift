import SwiftUI

extension EnvironmentValues {
  @Entry var textFieldIsSecureValueRevealed: Bool = false
}

extension View {
  public func textFieldRevealSecureValue(_ reveal: Bool) -> some View {
    environment(\.textFieldIsSecureValueRevealed, reveal)
  }
}
