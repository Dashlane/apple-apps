import CorePersonalData
import Foundation
import SwiftUI
import VaultKit

extension Credential: VaultItem {

  public var rawId: String {
    id.rawValue
  }

  public var enumerated: VaultItemEnumeration {
    .credential(self)
  }

  public var localizedTitle: String {
    displayTitle
  }

  public var localizedSubtitle: String {
    displaySubtitle ?? ""
  }

  public static var localizedName: String {
    fatalError()
  }
  public static var addIcon: SwiftUI.Image {
    fatalError()
  }

  public static var addTitle: String {
    fatalError()
  }
  public var icon: VaultItemIcon {
    .credential(self)
  }

  public static var nativeMenuAddTitle: String {
    fatalError()
  }

}
