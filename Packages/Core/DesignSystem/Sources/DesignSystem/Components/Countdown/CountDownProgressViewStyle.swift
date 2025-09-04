import SwiftUI

public struct CountdownProgressViewStyle: SwiftUI.ProgressViewStyle {
  @Environment(\.style) private var style
  @Environment(\.controlSize) private var controlSize

  var size: Double {
    switch controlSize {
    case .mini:
      return 12.0
    case .small:
      return 16.0
    case .regular:
      return 20.0
    case .large:
      return 28.0
    case .extraLarge:
      return 40.0
    @unknown default:
      return 24.0
    }
  }

  public func makeBody(configuration: Configuration) -> some View {
    ZStack {
      let gap = size / 10

      if let fractionCompleted = configuration.fractionCompleted {

        CountdownShape(gap: gap, fractionCompleted: fractionCompleted)
          .modifier(AnimatedCountdownShapeColorModifier(fractionCompleted: fractionCompleted))
      }
    }
    .frame(width: size, height: size)
  }
}

extension ProgressViewStyle where Self == CountdownProgressViewStyle {
  public static var countdown: Self { CountdownProgressViewStyle() }
}

private struct AnimatedCountdownShapeColorModifier: ViewModifier, Animatable {
  var fractionCompleted: Double

  var animatableData: Double {
    get { fractionCompleted }
    set { fractionCompleted = newValue }
  }

  var isWarning: Bool {
    fractionCompleted > 0.8
  }

  func body(content: Content) -> some View {
    content
      .foregroundStyle(isWarning ? Color.ds.text.warning.standard : Color.ds.text.brand.standard)
      .animation(.linear(duration: 0.3), value: isWarning)
  }
}

private struct CountdownShape: Shape, Animatable {
  static let offset: Double = 90
  let startAngle: Angle = .degrees(-Self.offset)
  let gap: Double
  var fractionCompleted: Double

  var animatableData: Double {
    get { fractionCompleted }
    set { fractionCompleted = newValue }
  }

  func path(in rect: CGRect) -> Path {
    let endAngle = fractionCompleted * 360 - Self.offset

    let baseShape = Circle()
    var rect = rect

    var path: Path = baseShape.path(in: rect)

    rect = rect.insetBy(dx: gap, dy: gap)
    path = path.subtracting(baseShape.path(in: rect), eoFill: true)

    rect = rect.insetBy(dx: gap, dy: gap)
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = min(rect.width, rect.height) / 2

    path.move(to: center)
    path.addArc(
      center: center, radius: radius, startAngle: startAngle, endAngle: .degrees(endAngle),
      clockwise: true)
    path.closeSubpath()

    return path
  }
}

#Preview("Sizes V2", traits: .sizeThatFitsLayout) {
  Grid {
    ForEach([.mini, .small, .regular, .large, .extraLarge], id: \.self) { (size: ControlSize) in
      GridRow {
        Text("\(size)")
          .foregroundStyle(.secondary)
        HStack {
          ForEach([0, 0.3, 0.5, 0.7, 1], id: \.self) { value in
            ProgressView(value: value)
          }
        }
      }
      .controlSize(size)
    }
  }
  .progressViewStyle(.countdown)
  .padding()
}

#Preview("Animated V2", traits: .sizeThatFitsLayout) {
  @Previewable @State var value: Double = 0

  ProgressView(value: value)
    .onAppear {
      withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
        value = 1
      }
    }
    .controlSize(.regular)
    .padding()
    .progressViewStyle(.countdown)
    .style(mood: .brand)

}
