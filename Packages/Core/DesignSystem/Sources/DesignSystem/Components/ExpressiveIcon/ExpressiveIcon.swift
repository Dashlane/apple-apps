import SwiftUI

public struct ExpressiveIcon: View {
  @Environment(\.style) var style
  @Environment(\.controlSize) var controlSize

  let icon: Image

  public init(_ icon: Image) {
    self.icon = icon
  }

  private var size: Double {
    switch controlSize {
    case .mini:
      return 24.0
    case .small:
      return 32.0
    case .regular:
      return 40.0
    case .large:
      return 60.0
    case .extraLarge:
      return 80.0
    @unknown default:
      return 40.0
    }
  }

  public var body: some View {
    icon
      .resizable()
      .aspectRatio(contentMode: .fit)
      .foregroundStyle(.ds.text)
      .padding(size / 4)
      .background {
        Squircle()
          .foregroundStyle(.ds.expressiveContainer)
      }
      .frame(width: size, height: size)
      .accessibilityHidden(true)
      .transformEnvironment(\.style) { style in
        style = .init(mood: style.mood, intensity: .quiet, priority: .low)
      }
  }
}

#Preview("Expressive Icon Sizes", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .mood, veriticalAxis: .controlSize) {
    ExpressiveIcon(.ds.shared.outlined)
  }
  .style(intensity: .quiet)
}

#Preview("Expressive Icon Intensities", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .mood, veriticalAxis: .intensity) {
    ExpressiveIcon(.ds.shared.outlined)
  }
}
