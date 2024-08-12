import CorePersonalData
import DesignSystem
import Foundation
import IconLibrary
import SwiftUI

extension IDCard {
  public var placeholderIcon: Icon {
    return Icon(image: .ds.item.id.outlined, colors: nil)
  }

  public var listIcon: VaultItemIcon {
    .static(.ds.item.id.outlined, backgroundColor: color)
  }

  public var icon: VaultItemIcon {
    .static(.ds.item.id.outlined)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.id.outlined
  }

  public var color: SwiftUI.Color? {
    switch nationality?.code {
    case "FR":
      return Color(asset: Asset.idCardFR)
    default:
      return nil
    }
  }
}
