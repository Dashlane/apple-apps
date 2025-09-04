import CoreTypes
import DashlaneAPI
import Foundation
import SwiftTreats

extension Array where Element == EncryptedRemoteKey {
  func ssoRemoteKey() -> EncryptedRemoteKey? {
    return self.first(where: { key in
      if key.type == .sso {
        return true
      }
      return false
    })
  }

  func masterPasswordRemoteKey() -> EncryptedRemoteKey? {
    return self.first(where: { key in
      if key.type == .masterPassword {
        return true
      }
      return false
    })
  }
}
