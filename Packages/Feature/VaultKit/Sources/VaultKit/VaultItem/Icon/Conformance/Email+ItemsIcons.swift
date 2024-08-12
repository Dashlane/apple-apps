import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Email {
  public var icon: VaultItemIcon {
    .static(.ds.item.email.outlined)
  }

  public var listIcon: VaultItemIcon {
    .static(.ds.item.email.outlined)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.email.outlined
  }
}
