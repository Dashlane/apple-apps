import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension SecureNote {

  public var icon: VaultItemIcon {
    .secureNote(color.color)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.secureNote.outlined
  }
}
