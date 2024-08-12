import SwiftUI

enum TextInputIsRequiredKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var isRequired: Bool {
    get { self[TextInputIsRequiredKey.self] }
    set { self[TextInputIsRequiredKey.self] = newValue }
  }
}

extension View {
  public func required(_ required: Bool = true) -> some View {
    environment(\.isRequired, required)
  }
}
