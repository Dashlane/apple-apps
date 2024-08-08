import SwiftUI

struct IndeterminateCircularProgress: View {
  let gradient: Gradient
  let lineWidth: CGFloat
  @State
  private var angle: Angle = Angle(degrees: 0)

  init(lineWidth: CGFloat = 3, color: Color = .gray) {
    self.lineWidth = lineWidth
    self.gradient = Gradient(colors: [.clear, color])
  }

  var body: some View {
    Circle()
      .stroke(lineWidth: lineWidth)
      .fill(
        AngularGradient(
          gradient: gradient, center: .center, startAngle: angle,
          endAngle: angle + Angle(degrees: 360))
      )
      .onAppear {
        withAnimation(
          Animation
            .linear(duration: 1)
            .repeatForever(autoreverses: false)
        ) {
          self.angle = Angle(degrees: 360)
        }
      }
  }

}

struct IndeterminateCircularProgress_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      IndeterminateCircularProgress(color: .pink)
        .frame(width: 40, height: 40)
        .padding(50)
      IndeterminateCircularProgress(lineWidth: 10, color: .blue)
        .frame(width: 300, height: 300)
        .padding(50)
    }.previewLayout(.sizeThatFits)

  }
}
