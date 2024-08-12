import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension SecureNote {

  public var icon: VaultItemIcon {
    .static(.ds.item.secureNote.outlined, backgroundColor: color.color)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.secureNote.outlined
  }
}
