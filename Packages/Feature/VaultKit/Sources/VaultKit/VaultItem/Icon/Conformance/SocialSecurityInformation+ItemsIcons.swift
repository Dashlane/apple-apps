import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension SocialSecurityInformation {
  public var icon: VaultItemIcon {
    .socialSecurityCard
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.socialSecurity.outlined
  }
}
