import SwiftUI

public struct BorderShapeStyle: ShapeStyle {
  public func resolve(in environment: EnvironmentValues) -> Color {
    switch environment.style.mood {
    case .brand:
      Self.brandColor(in: environment)
    case .danger:
      Self.dangerColor(in: environment)
    case .neutral:
      Self.neutralColor(in: environment)
    case .positive:
      Self.positiveColor(in: environment)
    case .warning:
      Self.warningColor(in: environment)
    }
  }

  private static func brandColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.border.brand.standard.idle
      } else if environment.isHighlighted {
        .ds.border.brand.standard.hover
      } else {
        .ds.border.brand.standard.active
      }

    case .quiet, .supershy:
      .ds.border.brand.quiet.idle
    }
  }

  private static func dangerColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.border.danger.standard.idle
      } else if environment.isHighlighted {
        .ds.border.danger.standard.hover
      } else {
        .ds.border.danger.standard.active
      }

    case .quiet, .supershy:
      .ds.border.danger.quiet.idle
    }
  }

  private static func neutralColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.border.neutral.standard.idle
      } else if environment.isHighlighted {
        .ds.border.neutral.standard.hover
      } else {
        .ds.border.neutral.standard.active
      }

    case .quiet, .supershy:
      .ds.border.neutral.quiet.idle
    }
  }

  private static func positiveColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.border.positive.standard.idle
      } else if environment.isHighlighted {
        .ds.border.positive.standard.hover
      } else {
        .ds.border.positive.standard.active
      }

    case .quiet, .supershy:
      .ds.border.positive.quiet.idle
    }
  }

  private static func warningColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.border.warning.standard.idle
      } else if environment.isHighlighted {
        .ds.border.warning.standard.hover
      } else {
        .ds.border.warning.standard.active
      }

    case .quiet, .supershy:
      .ds.border.warning.quiet.idle
    }
  }
}

extension DS {
  public static var border: BorderShapeStyle { BorderShapeStyle() }
}

#Preview("Border", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .stroke(.ds.border, lineWidth: 3)
      .frame(width: 30, height: 30)
  }
}

#Preview("Border Hightlighted", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .stroke(.ds.border, lineWidth: 3)
      .frame(width: 30, height: 30)
  }
  .environment(\.isHighlighted, true)
}

#Preview("Border Disabled", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .stroke(.ds.border, lineWidth: 3)
      .frame(width: 30, height: 30)
  }
  .disabled(true)
}
