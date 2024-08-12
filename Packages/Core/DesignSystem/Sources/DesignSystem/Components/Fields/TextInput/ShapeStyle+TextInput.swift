import Foundation
import SwiftUI

struct TextInputValueShapeStyle: ShapeStyle, ShapeStyleColorResolver {
  func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
    TextShapeStyle { _, color in
      guard environment.isEnabled && environment.style.mood == .brand
      else { return color }
      return .ds.text.neutral.catchy
    }
  }

  func resolvedColor(in environment: EnvironmentValues) -> Color {
    TextShapeStyle { _, color in
      guard environment.isEnabled && environment.style.mood == .brand
      else { return color }
      return .ds.text.neutral.catchy
    }
    .resolvedColor(in: environment)
  }
}

extension ShapeStyle where Self == TextInputValueShapeStyle {
  static var textInputValue: Self { TextInputValueShapeStyle() }
}
