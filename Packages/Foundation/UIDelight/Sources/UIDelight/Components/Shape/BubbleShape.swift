import SwiftUI

@available(*, deprecated)
public enum BubbleShapeDirection: Sendable {
  case right
  case down
}

@available(*, deprecated)
public struct BubbleShape: Shape {
  static let arrowSize = CGFloat(10 * sqrt(2))

  let direction: BubbleShapeDirection

  public init(direction: BubbleShapeDirection = .down) {
    self.direction = direction
  }

  public func path(in rect: CGRect) -> Path {
    var path = Path()

    switch self.direction {
    case .down: path = down(in: rect)
    case .right: path = right(in: rect)
    }

    return path
  }

  private func down(in rect: CGRect) -> Path {
    var path = Path()

    let arrowOriginX = rect.width / 8

    let width = rect.size.width
    let height = rect.size.height

    let radius = min(min(3, height / 2), width / 2)

    path.move(to: CGPoint(x: radius / 2.0, y: 0))
    path.addLine(to: CGPoint(x: width - radius, y: 0))
    path.addArc(
      center: CGPoint(x: width - radius, y: radius), radius: radius,
      startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
    path.addLine(to: CGPoint(x: width, y: height - radius))
    path.addArc(
      center: CGPoint(x: width - radius, y: height - radius), radius: radius,
      startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

    path.addLine(to: .init(x: arrowOriginX + Self.arrowSize, y: height))
    path.addLine(to: .init(x: arrowOriginX + Self.arrowSize / 2, y: height + Self.arrowSize * 0.7))
    path.addLine(to: .init(x: arrowOriginX, y: height))

    path.addLine(to: CGPoint(x: radius, y: height))
    path.addArc(
      center: CGPoint(x: radius, y: height - radius), radius: radius,
      startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
    path.addLine(to: CGPoint(x: 0, y: radius))
    path.addArc(
      center: CGPoint(x: radius, y: radius), radius: radius, startAngle: Angle(degrees: 180),
      endAngle: Angle(degrees: 270), clockwise: false)

    return path
  }

  private func right(in rect: CGRect) -> Path {
    var path = Path()

    let width = rect.size.width
    let height = rect.size.height

    let radius = min(min(3, height / 2), width / 2)

    path.move(to: CGPoint(x: radius / 2.0, y: 0))
    path.addLine(to: CGPoint(x: width - radius, y: 0))
    path.addArc(
      center: CGPoint(x: width - radius, y: radius), radius: radius,
      startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
    path.addLine(to: CGPoint(x: width, y: height - radius))
    path.addArc(
      center: CGPoint(x: width - radius, y: height - radius), radius: radius,
      startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

    path.addLine(to: CGPoint(x: radius, y: height))
    path.addArc(
      center: CGPoint(x: radius, y: height - radius), radius: radius,
      startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
    path.addLine(to: CGPoint(x: 0, y: radius))
    path.addArc(
      center: CGPoint(x: radius, y: radius), radius: radius, startAngle: Angle(degrees: 180),
      endAngle: Angle(degrees: 270), clockwise: false)

    path.addLines([
      CGPoint(x: width, y: height / 2 - 5), CGPoint(x: width + Self.arrowSize * 0.3, y: height / 2),
      CGPoint(x: width, y: height / 2 + 5),
    ])

    return path
  }
}

struct BubbleShape_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      BubbleShape(direction: .down)
      BubbleShape(direction: .right)
    }
    .foregroundStyle(.blue)
    .frame(width: 100, height: 29)
    .padding(.all, 40)
    .previewLayout(.sizeThatFits)
  }
}
