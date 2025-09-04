import SwiftUI

extension EnvironmentValues {
  @Entry var isInputSecure: Bool = false
}

extension View {
  public func secureInput(_ secure: Bool = true) -> some View {
    environment(\.isInputSecure, secure)
  }
}
