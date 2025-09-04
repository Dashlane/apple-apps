import SwiftUI

public enum IconAlignment {
  case leading
  case trailing
}

extension EnvironmentValues {
  @Entry var iconAlignment: IconAlignment = .leading
}

extension View {
  public func iconAlignment(_ alignment: IconAlignment) -> some View {
    environment(\.iconAlignment, alignment)
  }
}
