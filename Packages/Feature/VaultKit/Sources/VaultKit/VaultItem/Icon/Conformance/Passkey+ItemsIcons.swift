import CorePersonalData
import Foundation
import SwiftUI

extension Passkey {
  public static var addIcon: Image {
    assertionFailure("Users cannot add passkeys manually")
    return .ds.passkey.outlined
  }

  public var icon: VaultItemIcon {
    .passkey(self)
  }
}
