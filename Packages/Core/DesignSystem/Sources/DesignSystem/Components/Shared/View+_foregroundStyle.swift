import SwiftUI

protocol ShapeStyleColorResolver {
  func resolvedColor(in environment: EnvironmentValues) -> Color
}

struct ForegroundStyleModifier<S: ShapeStyle & ShapeStyleColorResolver>: ViewModifier {
  @Environment(\.self) private var environment
  private let shapeStyle: S

  init(_ shapeStyle: S) {
    self.shapeStyle = shapeStyle
  }

  func body(content: Content) -> some View {
    if #available(iOS 17, *) {
      return content.foregroundStyle(shapeStyle)
    } else {
      return content.foregroundColor(shapeStyle.resolvedColor(in: environment))
    }
  }
}

extension View {
  func _foregroundStyle<S: ShapeStyle & ShapeStyleColorResolver>(_ shapeStyle: S) -> some View {
    self.modifier(ForegroundStyleModifier(shapeStyle))
  }
}
