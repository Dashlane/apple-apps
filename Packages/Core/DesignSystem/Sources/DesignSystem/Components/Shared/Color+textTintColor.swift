import Foundation
import SwiftUI

extension Color {
  static func textTint(style: Style, isEnabled: Bool) -> Color {
    if !isEnabled {
      return .ds.text.oddity.disabled
    } else if case .catchy = style.intensity {
      return .ds.text.inverse.catchy
    } else {
      switch style.mood {
      case .brand:
        switch style.intensity {
        case .quiet:
          return .ds.text.brand.standard
        case .supershy:
          return .ds.text.brand.quiet
        default:
          fatalError()
        }
      case .danger:
        switch style.intensity {
        case .quiet:
          return .ds.text.danger.standard
        case .supershy:
          return .ds.text.danger.quiet
        default:
          fatalError()
        }
      case .neutral:
        switch style.intensity {
        case .quiet:
          return .ds.text.neutral.standard
        case .supershy:
          return .ds.text.neutral.quiet
        default:
          fatalError()
        }
      case .positive:
        switch style.intensity {
        case .quiet:
          return .ds.text.positive.standard
        case .supershy:
          return .ds.text.positive.quiet
        default:
          fatalError()
        }
      case .warning:
        switch style.intensity {
        case .quiet:
          return .ds.text.warning.standard
        case .supershy:
          return .ds.text.warning.quiet
        default:
          fatalError()
        }
      }
    }
  }

  static func textTint(style: Style, isEnabled: Bool, override: (Color) -> Color) -> Color {
    let defaultColor = textTint(style: style, isEnabled: isEnabled)
    return override(defaultColor)
  }
}
