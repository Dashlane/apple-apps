import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Company {
  public var icon: VaultItemIcon {
    .company
  }

  public var listIcon: VaultItemIcon {
    .company
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.company.outlined
  }
}
