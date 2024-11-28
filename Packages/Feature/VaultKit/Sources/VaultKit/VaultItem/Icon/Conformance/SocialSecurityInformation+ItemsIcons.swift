import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension SocialSecurityInformation {
  public var listIcon: VaultItemIcon {
    .socialSecurityCard
  }

  public var icon: VaultItemIcon {
    .socialSecurityCard
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.socialSecurity.outlined
  }

  public var backgroundColor: SwiftUI.Color? {
    switch country?.code {
    case "FR":
      return Color(asset: Asset.socialSecurityInformationFR)
    case "GB":
      return Color(asset: Asset.socialSecurityInformationGB)
    case "US":
      return Color(asset: Asset.socialSecurityInformationUS)
    default:
      return nil
    }
  }
}
