import Foundation
import SwiftUI

struct AppIcon: Identifiable, Equatable, Comparable {
  static func < (lhs: AppIcon, rhs: AppIcon) -> Bool {
    lhs.name < rhs.name
  }

  enum Category {
    case primary
    case brand
    case pride
    case legacy

    init(alternativeName: String) {
      self =
        switch alternativeName {
        case "8_PrideIcon":
          .pride

        case let name where name.contains("legacy"):
          .legacy

        default:
          .brand
        }
    }
  }

  var id: String {
    return name
  }

  let name: String
  let category: Category

  let image: Image
}

extension AppIcon {
  static var primaryIcon: AppIcon {
    guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
      let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
      let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
      let lastIcon = iconFiles.last
    else {
      return AppIcon(name: "AppIcon", category: .primary, image: Image(.primaryAppIcon))
    }
    return AppIcon(name: lastIcon, category: .primary, image: Image(.primaryAppIcon))
  }

  static func alternateIcons() -> [AppIcon] {
    guard
      let bundleIcons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
      let alternateIcons = bundleIcons["CFBundleAlternateIcons"] as? [String: Any]
    else {
      return []
    }

    return alternateIcons.compactMap { _, value -> AppIcon? in
      guard let iconData = value as? [String: String],
        let icon = iconData["CFBundleIconName"]
      else {
        return nil
      }

      let image = Image(icon + "Image")
      return AppIcon(name: icon, category: AppIcon.Category(alternativeName: icon), image: image)
    }
  }
}
