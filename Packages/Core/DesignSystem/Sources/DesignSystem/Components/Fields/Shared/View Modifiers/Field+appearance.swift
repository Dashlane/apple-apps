import SwiftUI

public enum FieldAppearance {
  case standalone
  case grouped
}

enum FieldAppearanceKey: EnvironmentKey {
  static let defaultValue = FieldAppearance.standalone
}

extension EnvironmentValues {
  var fieldAppearance: FieldAppearance {
    get { self[FieldAppearanceKey.self] }
    set { self[FieldAppearanceKey.self] = newValue }
  }
}

extension View {
  public func fieldAppearance(_ appearance: FieldAppearance) -> some View {
    environment(\.fieldAppearance, appearance)
  }
}
