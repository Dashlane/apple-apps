import Foundation
import SwiftUI

public struct RectangleCornerRadii: Sendable {
  let topLeading: CGFloat

  let topTrailing: CGFloat

  let bottomLeading: CGFloat

  let bottomTrailing: CGFloat

  public init(
    topLeading: CGFloat, topTrailing: CGFloat, bottomLeading: CGFloat, bottomTrailing: CGFloat
  ) {
    self.topLeading = topLeading
    self.topTrailing = topTrailing
    self.bottomLeading = bottomLeading
    self.bottomTrailing = bottomTrailing
  }
}

public struct UnevenRoundedRectangle: Shape {
  public let cornerRadii: RectangleCornerRadii

  public init(cornerRadii: RectangleCornerRadii) {
    self.cornerRadii = cornerRadii
  }

  public init(
    topLeading: CGFloat = 0,
    topTrailing: CGFloat = 0,
    bottomLeading: CGFloat = 0,
    bottomTrailing: CGFloat = 0
  ) {
    self.init(
      cornerRadii: .init(
        topLeading: topLeading, topTrailing: topTrailing, bottomLeading: bottomLeading,
        bottomTrailing: bottomTrailing))
  }

  public func path(in rect: CGRect) -> Path {
    let width = rect.size.width
    let height = rect.size.height

    var path = Path()
    let maxRadius = min(height / 2, width / 2)

    let topRight = min(cornerRadii.topTrailing, maxRadius)
    let topLeft = min(cornerRadii.topLeading, maxRadius)
    let bottomLeft = min(cornerRadii.bottomLeading, maxRadius)
    let bottomRight = min(cornerRadii.bottomTrailing, maxRadius)

    path.move(
      to: CGPoint(
        x: rect.width / 2,
        y: rect.minY))

    path.addLine(
      to: CGPoint.init(
        x: rect.width - topRight,
        y: rect.minY))

    path.addQuadCurve(
      to: CGPoint.init(
        x: rect.width,
        y: topRight),
      control: CGPoint.init(
        x: rect.width,
        y: rect.minY))

    path.addLine(
      to: CGPoint.init(
        x: rect.width,
        y: rect.height - bottomRight))

    path.addQuadCurve(
      to: CGPoint.init(
        x: rect.width - bottomRight,
        y: rect.height),
      control: CGPoint.init(
        x: rect.width,
        y: rect.height))

    path.addLine(to: CGPoint.init(x: bottomLeft, y: rect.height))

    path.addQuadCurve(
      to: CGPoint(
        x: rect.minX,
        y: rect.height - bottomLeft),
      control: CGPoint.init(
        x: rect.minX,
        y: rect.height))

    path.addLine(
      to: CGPoint.init(
        x: rect.minX,
        y: topLeft))

    path.addQuadCurve(
      to: CGPoint(
        x: topLeft,
        y: rect.minY),
      control: CGPoint(
        x: rect.minX,
        y: rect.minY))

    path.addLine(
      to: CGPoint.init(
        x: rect.width / 2,
        y: rect.minY))

    return path

  }
}
