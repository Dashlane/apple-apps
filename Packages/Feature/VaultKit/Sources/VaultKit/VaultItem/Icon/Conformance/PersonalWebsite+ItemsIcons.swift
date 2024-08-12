import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension PersonalWebsite {
  public var listIcon: VaultItemIcon {
    .static(.ds.web.outlined)
  }

  public var icon: VaultItemIcon {
    .static(.ds.web.outlined)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.web.outlined
  }
}
