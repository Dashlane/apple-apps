import SwiftUI

public enum TextColorHighlightingMode {
  case password
  case url
}

enum TextColorHighlightingModeKey: EnvironmentKey {
  static let defaultValue: TextColorHighlightingMode? = nil
}

extension EnvironmentValues {
  var textColorHighlightingMode: TextColorHighlightingMode? {
    get { self[TextColorHighlightingModeKey.self] }
    set { self[TextColorHighlightingModeKey.self] = newValue }
  }
}

extension View {
  public func textColorHighlightingMode(_ mode: TextColorHighlightingMode?) -> some View {
    environment(\.textColorHighlightingMode, mode)
  }
}
