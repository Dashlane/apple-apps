import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Address {
  public var icon: VaultItemIcon {
    .address
  }

  public static var addIcon: SwiftUI.Image {
    .ds.geolocation.outlined
  }

}
