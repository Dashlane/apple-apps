import Foundation
import SwiftUI

struct TextShapeStyle: ShapeStyle, ShapeStyleColorResolver {
  private let override: ((EnvironmentValues, Color) -> Color)?

  init(override: ((EnvironmentValues, Color) -> Color)?) {
    self.override = override
  }

  init() {
    self.override = nil
  }

  func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
    resolvedColor(in: environment)
  }

  func resolvedColor(in environment: EnvironmentValues) -> Color {
    let defaultColor = Color.textTint(style: environment.style, isEnabled: environment.isEnabled)
    return override?(environment, defaultColor) ?? defaultColor
  }
}

struct ExpressiveContainerShapeStyle: ShapeStyle, ShapeStyleColorResolver {
  func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
    resolvedColor(in: environment)
  }

  func resolvedColor(in environment: EnvironmentValues) -> Color {
    switch environment.style.mood {
    case .brand:
      return Self.brandExpressiveContainer(in: environment)
    case .danger:
      return Self.dangerExpressiveContainer(in: environment)
    case .neutral:
      return Self.neutralExpressiveContainer(in: environment)
    case .positive:
      return Self.positiveExpressiveContainer(in: environment)
    case .warning:
      return Self.warningExpressiveContainer(in: environment)
    }
  }

  private static func brandExpressiveContainer(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      guard environment.isEnabled
      else { return .ds.container.expressive.brand.catchy.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.brand.catchy.active
        : .ds.container.expressive.brand.catchy.idle
    case .quiet:
      guard environment.isEnabled
      else { return .ds.container.expressive.brand.quiet.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.brand.quiet.active
        : .ds.container.expressive.brand.quiet.idle
    case .supershy:
      guard environment.isEnabled
      else { return .ds.container.expressive.brand.quiet.disabled.opacity(0) }

      return environment.isHighlighted
        ? .ds.container.expressive.brand.quiet.active
        : .ds.container.expressive.brand.quiet.active.opacity(0)
    }
  }

  private static func dangerExpressiveContainer(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      guard environment.isEnabled
      else { return .ds.container.expressive.danger.catchy.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.danger.catchy.active
        : .ds.container.expressive.danger.catchy.idle
    case .quiet:
      guard environment.isEnabled
      else { return .ds.container.expressive.danger.quiet.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.danger.quiet.active
        : .ds.container.expressive.danger.quiet.idle
    case .supershy:
      guard environment.isEnabled
      else { return .ds.container.expressive.danger.quiet.disabled.opacity(0) }

      return environment.isHighlighted
        ? .ds.container.expressive.danger.quiet.active
        : .ds.container.expressive.danger.quiet.active.opacity(0)
    }
  }

  private static func neutralExpressiveContainer(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      guard environment.isEnabled
      else { return .ds.container.expressive.neutral.catchy.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.neutral.catchy.active
        : .ds.container.expressive.neutral.catchy.idle
    case .quiet:
      guard environment.isEnabled
      else { return .ds.container.expressive.neutral.quiet.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.neutral.quiet.active
        : .ds.container.expressive.neutral.quiet.idle
    case .supershy:
      guard environment.isEnabled
      else { return .ds.container.expressive.neutral.quiet.disabled.opacity(0) }

      return environment.isHighlighted
        ? .ds.container.expressive.neutral.quiet.active
        : .ds.container.expressive.neutral.quiet.active.opacity(0)
    }
  }

  private static func positiveExpressiveContainer(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      guard environment.isEnabled
      else { return .ds.container.expressive.positive.catchy.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.positive.catchy.active
        : .ds.container.expressive.positive.catchy.idle
    case .quiet:
      guard environment.isEnabled
      else { return .ds.container.expressive.positive.quiet.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.positive.quiet.active
        : .ds.container.expressive.positive.quiet.idle
    case .supershy:
      guard environment.isEnabled
      else { return .ds.container.expressive.positive.quiet.disabled.opacity(0) }

      return environment.isHighlighted
        ? .ds.container.expressive.positive.quiet.active
        : .ds.container.expressive.positive.quiet.active.opacity(0)
    }
  }

  private static func warningExpressiveContainer(in environment: EnvironmentValues) -> Color {
    switch environment.style.intensity {
    case .catchy:
      guard environment.isEnabled
      else { return .ds.container.expressive.warning.catchy.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.warning.catchy.active
        : .ds.container.expressive.warning.catchy.idle
    case .quiet:
      guard environment.isEnabled
      else { return .ds.container.expressive.warning.quiet.disabled }

      return environment.isHighlighted
        ? .ds.container.expressive.warning.quiet.active
        : .ds.container.expressive.warning.quiet.idle
    case .supershy:
      guard environment.isEnabled
      else { return .ds.container.expressive.positive.quiet.disabled.opacity(0) }

      return environment.isHighlighted
        ? .ds.container.expressive.warning.quiet.active
        : .ds.container.expressive.warning.quiet.active.opacity(0)
    }
  }
}

extension ShapeStyle where Self == TextShapeStyle {
  static func text(override: @escaping (EnvironmentValues, Color) -> Color) -> Self {
    TextShapeStyle(override: override)
  }
  static var text: Self { TextShapeStyle() }
}

extension ShapeStyle where Self == ExpressiveContainerShapeStyle {
  static var expressiveContainer: Self { ExpressiveContainerShapeStyle() }
}
