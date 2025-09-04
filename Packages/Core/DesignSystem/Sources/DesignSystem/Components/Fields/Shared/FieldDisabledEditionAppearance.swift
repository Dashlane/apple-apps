import SwiftUI
import UIDelight

public enum FieldDisabledEditionAppearance {
  case discrete
  case emphasized
}

extension EnvironmentValues {
  @Entry var fieldDisabledEditionAppearance: FieldDisabledEditionAppearance?
}

extension View {
  func fieldDisabledEditionAppearance(_ mode: FieldDisabledEditionAppearance) -> some View {
    environment(\.fieldDisabledEditionAppearance, mode)
  }
}
