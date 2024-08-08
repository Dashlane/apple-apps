import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Phone {
  public var listIcon: VaultItemIcon {
    .static(.ds.item.phoneMobile.outlined)
  }

  public var icon: VaultItemIcon {
    .static(.ds.item.phoneMobile.outlined)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.phoneMobile.outlined
  }
}
