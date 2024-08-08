import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Credential {

  public var icon: VaultItemIcon {
    .credential(self)
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.login.outlined
  }

}
