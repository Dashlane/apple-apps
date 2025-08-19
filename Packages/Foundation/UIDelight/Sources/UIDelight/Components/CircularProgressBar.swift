import SwiftUI

@available(*, deprecated, message: "Component is deprecated.")
public struct CircularProgressBar: View {
  let progress: Double
  let color: Color
  let lineWidth: CGFloat

  public init(
    progress: Double,
    color: Color,
    lineWidth: CGFloat = 2.0
  ) {
    self.progress = progress
    self.color = color
    self.lineWidth = lineWidth
  }

  public var body: some View {
    Circle()
      .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
      .stroke(style: StrokeStyle(lineWidth: lineWidth * 1.3, lineCap: .round, lineJoin: .round))
      .foregroundStyle(color)
      .rotationEffect(Angle(degrees: 270.0))
      .animation(.linear, value: progress)
      .background(strokeCircle)
  }

  private var strokeCircle: some View {
    Circle()
      .stroke(lineWidth: lineWidth)
      .opacity(0.3)
      .foregroundStyle(color)
  }
}

struct CircularProgressBar_Previews: PreviewProvider {
  static var previews: some View {
    CircularProgressBar(progress: 0.70, color: Color.green)
  }
}
