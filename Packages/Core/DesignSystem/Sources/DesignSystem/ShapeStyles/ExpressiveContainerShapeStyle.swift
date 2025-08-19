import SwiftUI

public struct ExpressiveContainerShapeStyle: ShapeStyle {
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
        .ds.container.expressive.brand.catchy.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.brand.catchy.active
      } else {
        .ds.container.expressive.brand.catchy.idle
      }

    case .quiet:
      if !environment.isEnabled {
        .ds.container.expressive.brand.quiet.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.brand.quiet.active
      } else {
        .ds.container.expressive.brand.quiet.idle
      }

    case .supershy:
      if !environment.isEnabled {
        .ds.container.expressive.brand.quiet.disabled.opacity(0)
      } else if environment.isHighlighted {
        .ds.container.expressive.brand.quiet.active
      } else {
        .ds.container.expressive.brand.quiet.active.opacity(0)
      }
    }
  }

  private static func dangerColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.container.expressive.danger.catchy.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.danger.catchy.active
      } else {
        .ds.container.expressive.danger.catchy.idle
      }

    case .quiet:
      if !environment.isEnabled {
        .ds.container.expressive.danger.quiet.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.danger.quiet.active
      } else {
        .ds.container.expressive.danger.quiet.idle
      }

    case .supershy:
      if !environment.isEnabled {
        .ds.container.expressive.danger.quiet.disabled.opacity(0)
      } else if environment.isHighlighted {
        .ds.container.expressive.danger.quiet.active
      } else {
        .ds.container.expressive.danger.quiet.active.opacity(0)
      }
    }
  }

  private static func neutralColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.container.expressive.neutral.catchy.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.neutral.catchy.active
      } else {
        .ds.container.expressive.neutral.catchy.idle
      }

    case .quiet:
      if !environment.isEnabled {
        .ds.container.expressive.neutral.quiet.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.neutral.quiet.active
      } else {
        .ds.container.expressive.neutral.quiet.idle
      }

    case .supershy:
      if !environment.isEnabled {
        .ds.container.expressive.neutral.quiet.disabled.opacity(0)
      } else if environment.isHighlighted {
        .ds.container.expressive.neutral.quiet.active
      } else {
        .ds.container.expressive.neutral.quiet.active.opacity(0)
      }
    }
  }

  private static func positiveColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.container.expressive.positive.catchy.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.positive.catchy.active
      } else {
        .ds.container.expressive.positive.catchy.idle
      }

    case .quiet:
      if !environment.isEnabled {
        .ds.container.expressive.positive.quiet.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.positive.quiet.active
      } else {
        .ds.container.expressive.positive.quiet.idle
      }

    case .supershy:
      if !environment.isEnabled {
        .ds.container.expressive.positive.quiet.disabled.opacity(0)
      } else if environment.isHighlighted {
        .ds.container.expressive.positive.quiet.active
      } else {
        .ds.container.expressive.positive.quiet.active.opacity(0)
      }
    }
  }

  private static func warningColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      if !environment.isEnabled {
        .ds.container.expressive.warning.catchy.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.warning.catchy.active
      } else {
        .ds.container.expressive.warning.catchy.idle
      }

    case .quiet:
      if !environment.isEnabled {
        .ds.container.expressive.warning.quiet.disabled
      } else if environment.isHighlighted {
        .ds.container.expressive.warning.quiet.active
      } else {
        .ds.container.expressive.warning.quiet.idle
      }

    case .supershy:
      if !environment.isEnabled {
        .ds.container.expressive.warning.quiet.disabled.opacity(0)
      } else if environment.isHighlighted {
        .ds.container.expressive.warning.quiet.active
      } else {
        .ds.container.expressive.warning.quiet.active.opacity(0)
      }
    }
  }
}

extension DS {
  public static var expressiveContainer: ExpressiveContainerShapeStyle {
    ExpressiveContainerShapeStyle()
  }
}

#Preview("Expressive Container", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .frame(width: 30, height: 30)
      .foregroundStyle(.ds.expressiveContainer)
  }
}

#Preview("Expressive Container Hightlighted", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .frame(width: 30, height: 30)
      .foregroundStyle(.ds.expressiveContainer)
  }
  .environment(\.isHighlighted, true)
}

#Preview("Expressive Container Disabled", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .frame(width: 30, height: 30)
      .foregroundStyle(.ds.expressiveContainer)
  }
  .disabled(true)
}
