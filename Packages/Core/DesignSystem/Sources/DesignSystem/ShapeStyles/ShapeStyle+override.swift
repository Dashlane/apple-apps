import SwiftUI

struct OverridedShapeStyle<Base: ShapeStyle>: ShapeStyle where Base.Resolved == Color {
  let base: Base
  let override: @Sendable (EnvironmentValues, Color) -> Color

  func resolve(in environment: EnvironmentValues) -> Color {
    override(environment, base.resolve(in: environment))
  }
}

extension ShapeStyle where Resolved == Color {
  func overriding(_ override: @Sendable @escaping (EnvironmentValues, Color) -> Color)
    -> OverridedShapeStyle<Self>
  {
    .init(base: self, override: override)
  }
}
