import SwiftUI

public struct IndeterminateProgressViewStyle: ProgressViewStyle {
  @Environment(\.controlSize) private var controlSize
  @Environment(\.style) private var style

  @ScaledMetric private var baseDimension = 32
  @ScaledMetric private var lineWidth = 2.5

  @State private var animating = false

  private let invertColors: Bool

  init(invertColors: Bool = false) {
    self.invertColors = invertColors
  }

  public func makeBody(configuration: Configuration) -> some View {
    Circle()
      .stroke(
        .indicator(matching: style, invert: invertColors),
        lineWidth: lineWidth * controlSize.scaleFactor
      )
      .overlay(
        Circle()
          .trim(from: 0.0, to: 1 / 3)
          .stroke(
            .track(matching: style, invert: invertColors),
            style: StrokeStyle(
              lineWidth: lineWidth * controlSize.scaleFactor,
              lineCap: .round
            )
          )
          .rotationEffect(.degrees(animating ? 270 : -90))
      )
      .frame(
        width: baseDimension * controlSize.scaleFactor,
        height: baseDimension * controlSize.scaleFactor
      )
      .onAppear {
        withAnimation(.linear(duration: 0.875).repeatForever(autoreverses: false)) {
          animating = true
        }
      }
  }
}

extension ShapeStyle where Self == Color {
  fileprivate static func track(matching style: Style, invert: Bool) -> Self {
    if invert && style.intensity == .catchy {
      return .ds.text.inverse.catchy
    }
    switch style.mood {
    case .neutral:
      return .ds.text.neutral.quiet
    case .brand:
      return .ds.text.brand.quiet
    case .warning:
      return .ds.text.warning.quiet
    case .danger:
      return .ds.text.danger.quiet
    case .positive:
      return .ds.text.positive.quiet
    }
  }
  fileprivate static func indicator(matching style: Style, invert: Bool) -> Self {
    return track(matching: style, invert: invert).opacity(0.2)
  }
}

extension ControlSize {
  fileprivate var scaleFactor: Double {
    guard case .mini = self else { return 2 }
    return 0.625
  }
}

extension ProgressViewStyle where Self == IndeterminateProgressViewStyle {
  public static var indeterminate: Self { IndeterminateProgressViewStyle() }
}

#Preview {
  VStack(spacing: 40) {
    ProgressView()
      .progressViewStyle(.indeterminate)
      .controlSize(.mini)
      .padding(-12)
      .style(intensity: .quiet)

    HStack(spacing: 16) {
      ForEach(Mood.allCases) { mood in
        ProgressView()
          .style(mood: mood, intensity: .quiet)
      }
    }
    .progressViewStyle(.indeterminate)
    .controlSize(.mini)
    .style(intensity: .quiet)

    ProgressView()
      .progressViewStyle(.indeterminate)
  }
}
