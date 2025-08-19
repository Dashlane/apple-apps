import SwiftUI

public enum TextFieldColorHighlightingMode {
  case password
  case url
}

extension EnvironmentValues {
  @Entry var textFieldColorHighlightingMode: TextFieldColorHighlightingMode?
}

extension View {
  public func textFieldColorHighlightingMode(_ mode: TextFieldColorHighlightingMode?) -> some View {
    environment(\.textFieldColorHighlightingMode, mode)
  }
}
