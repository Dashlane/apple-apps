import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Company {
  public var icon: VaultItemIcon {
    .static(.ds.item.company.outlined)
  }

  public var listIcon: VaultItemIcon {
    .static(.ds.item.company.outlined)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.company.outlined
  }
}
