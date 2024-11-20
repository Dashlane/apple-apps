import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Passport {
  public var listIcon: VaultItemIcon {
    .passport
  }

  public var icon: VaultItemIcon {
    .passport
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.passport.outlined
  }

  private var color: Color {
    PassportColor.localized(from: country?.code).color
  }
}

extension PassportColor {
  public var color: Color {
    switch self {
    case .black:
      return .ds.container.agnostic.inverse.standard
    case .burgundy:
      return Color(asset: Asset.passportBurgundy)
    case .green:
      return Color(asset: Asset.passportGreen)
    case .navy:
      return Color(asset: Asset.passportNavy)
    case .red:
      return Color(asset: Asset.passportRed)
    }
  }
}
