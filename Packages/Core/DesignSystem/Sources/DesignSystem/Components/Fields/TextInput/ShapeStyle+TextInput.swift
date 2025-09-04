import Foundation
import SwiftUI

struct TextInputValueShapeStyle: ShapeStyle {
  func resolve(in environment: EnvironmentValues) -> Color {
    guard environment.style.mood == .brand && !environment.isFocused && environment.isEnabled else {
      return TextShapeStyle().resolve(in: environment)
    }

    return .ds.text.neutral.catchy
  }
}

extension ShapeStyle where Self == TextInputValueShapeStyle {
  static var textInputValue: Self { TextInputValueShapeStyle() }
}
