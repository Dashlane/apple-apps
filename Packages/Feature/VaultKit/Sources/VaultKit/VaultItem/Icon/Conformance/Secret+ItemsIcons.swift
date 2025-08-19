import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Secret {
  public var icon: VaultItemIcon {
    .secret
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.secret.outlined
  }
}
