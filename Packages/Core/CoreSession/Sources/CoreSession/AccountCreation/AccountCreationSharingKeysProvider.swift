import CoreTypes
import DashlaneAPI

public protocol AccountCreationSharingKeysProvider: Sendable {
  func sharingKeys(using cryptoEngine: CryptoEngine) throws -> AccountCreateUserSharingKeys
}

struct FakeAccountCreationSharingKeysProvider: AccountCreationSharingKeysProvider {
  func sharingKeys(using cryptoEngine: any CoreTypes.CryptoEngine) throws
    -> DashlaneAPI.AccountCreateUserSharingKeys
  {
    AccountCreateUserSharingKeys(privateKey: "privateKey", publicKey: "publicKey")
  }
}

extension AccountCreationSharingKeysProvider where Self == FakeAccountCreationSharingKeysProvider {
  static var mock: Self { .init() }
}
