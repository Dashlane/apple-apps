import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension FiscalInformation {
  public var listIcon: VaultItemIcon {
    .bankAccount
  }

  public var icon: VaultItemIcon {
    .bankAccount
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.bankAccount.outlined
  }
}
