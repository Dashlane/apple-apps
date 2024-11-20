import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Address {
  public var listIcon: VaultItemIcon {
    .address
  }

  public var icon: VaultItemIcon {
    .address
  }

  public static var addIcon: SwiftUI.Image {
    Image(asset: Asset.imgAddress)
  }

}
