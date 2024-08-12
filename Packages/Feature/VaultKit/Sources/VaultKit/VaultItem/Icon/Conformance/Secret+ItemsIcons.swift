import CorePersonalData
import DesignSystem
import Foundation
import SwiftUI

extension Secret {
  public var icon: VaultItemIcon {
    .static(Asset.imgSecret.swiftUIImage, backgroundColor: .gray)
  }

  public static var addIcon: SwiftUI.Image {
    Asset.imgSecret.swiftUIImage
  }
}
