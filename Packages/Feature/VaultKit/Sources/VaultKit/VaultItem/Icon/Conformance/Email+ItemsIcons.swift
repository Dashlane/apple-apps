import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Email {
  public var icon: VaultItemIcon {
    .email
  }

  public var listIcon: VaultItemIcon {
    .email
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.email.outlined
  }
}
