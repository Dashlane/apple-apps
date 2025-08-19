import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension FiscalInformation {
  public var icon: VaultItemIcon {
    .fiscalInformation
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.taxNumber.outlined
  }
}
