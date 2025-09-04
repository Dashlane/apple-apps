import SwiftUI

public struct TextShapeStyle: ShapeStyle {
  public func resolve(in environment: EnvironmentValues) -> Color {
    resolve(isEnabled: environment.isEnabled, style: environment.style)
  }

  public func resolve(isEnabled: Bool, style: Style) -> Color {
    if !isEnabled {
      .ds.text.oddity.disabled
    } else {
      switch style.mood {
      case .brand:
        switch style.intensity {
        case .quiet, .supershy:
          .ds.text.brand.standard
        case .catchy:
          .ds.text.inverse.catchy
        }
      case .danger:
        switch style.intensity {
        case .quiet, .supershy:
          .ds.text.danger.standard
        case .catchy:
          .ds.text.inverse.catchy
        }
      case .neutral:
        switch style.intensity {
        case .quiet, .supershy:
          .ds.text.neutral.standard
        case .catchy:
          .ds.text.inverse.catchy
        }
      case .positive:
        switch style.intensity {
        case .quiet, .supershy:
          .ds.text.positive.standard
        case .catchy:
          .ds.text.inverse.catchy
        }
      case .warning:
        switch style.intensity {
        case .quiet, .supershy:
          .ds.text.warning.standard
        case .catchy:
          .ds.text.inverse.catchy
        }
      }
    }
  }
}

extension DS {
  public static var text: TextShapeStyle { TextShapeStyle() }
}

#Preview("Text", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    Text("Text")
      .font(.body.bold())
      .foregroundStyle(.ds.text)
      .padding(4)
      .background(.ds.expressiveContainer)
  }
}

#Preview("Text Hightlighted", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    Text("Text")
      .font(.body.bold())
      .foregroundStyle(.ds.text)
      .padding(4)
      .background(.ds.expressiveContainer)

  }
  .environment(\.isHighlighted, true)

}

#Preview("Text Disabled", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    Text("Text")
      .font(.body.bold())
      .foregroundStyle(.ds.text)
      .padding(4)
      .background(.ds.expressiveContainer)

  }
  .disabled(true)
}
