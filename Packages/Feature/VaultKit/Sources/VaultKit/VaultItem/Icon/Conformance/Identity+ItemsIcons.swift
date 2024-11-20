import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Identity {
  public var icon: VaultItemIcon {
    .identity
  }

  public var listIcon: VaultItemIcon {
    .identity
  }

  public static var addIcon: SwiftUI.Image {
    .ds.item.personalInfo.outlined
  }
}
