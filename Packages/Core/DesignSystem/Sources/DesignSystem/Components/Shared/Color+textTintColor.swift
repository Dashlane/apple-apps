import Foundation
import SwiftUI

extension Color {
  static func textTint(style: Style, isEnabled: Bool) -> Color {
    TextShapeStyle().resolve(isEnabled: isEnabled, style: style)
  }

  static func textTint(style: Style, isEnabled: Bool, override: (Color) -> Color) -> Color {
    let defaultColor = textTint(style: style, isEnabled: isEnabled)
    return override(defaultColor)
  }
}
