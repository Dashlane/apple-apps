import CyrilKit
import Foundation

@SharingActor
class UserKeyStore {
  enum UserKeyError: Error {
    case notDefinedYet
  }
  private var keyPair: AsymmetricKeyPair?

  var needsKey: Bool {
    return keyPair == nil
  }

  func update(_ keyPair: AsymmetricKeyPair) {
    self.keyPair = keyPair
  }

  func get() throws -> SharingAsymmetricKey<UserId> {
    guard let pair = keyPair else {
      throw UserKeyError.notDefinedYet
    }

    return .init(asymmetricKey: pair)
  }
}
