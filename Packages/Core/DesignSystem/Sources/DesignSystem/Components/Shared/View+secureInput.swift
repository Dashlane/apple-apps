import SwiftUI

enum SecureInputKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var isInputSecure: Bool {
    get { self[SecureInputKey.self] }
    set { self[SecureInputKey.self] = newValue }
  }
}

extension View {

  public func secureInput(_ secure: Bool = true) -> some View {
    environment(\.isInputSecure, secure)
  }
}
