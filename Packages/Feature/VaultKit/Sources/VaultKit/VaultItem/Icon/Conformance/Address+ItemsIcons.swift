import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Address {
  public var listIcon: VaultItemIcon {
    .static(.ds.home.outlined)
  }

  public var icon: VaultItemIcon {
    .static(.ds.home.outlined)
  }

  public static var addIcon: SwiftUI.Image {
    Image(asset: Asset.imgAddress)
  }

}
