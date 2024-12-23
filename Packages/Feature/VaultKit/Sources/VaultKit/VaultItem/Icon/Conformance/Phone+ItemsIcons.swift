import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Phone {
  public var listIcon: VaultItemIcon {
    .phoneNumber
  }

  public var icon: VaultItemIcon {
    .phoneNumber
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.phoneMobile.outlined
  }
}
