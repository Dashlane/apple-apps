import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension CreditCard {
  public var icon: VaultItemIcon {
    .creditCard(self)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.payment.outlined
  }

}
