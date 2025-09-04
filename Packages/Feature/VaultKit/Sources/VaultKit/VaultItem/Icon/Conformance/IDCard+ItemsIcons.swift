import CorePersonalData
import DesignSystem
import Foundation
import IconLibrary
import SwiftUI

extension IDCard {
  public var placeholderIcon: Icon {
    return Icon(image: .ds.item.id.outlined, color: nil)
  }

  public var icon: VaultItemIcon {
    .idCard
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.id.outlined
  }
}
