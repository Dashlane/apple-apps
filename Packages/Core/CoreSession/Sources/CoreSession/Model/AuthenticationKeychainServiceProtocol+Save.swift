import CoreTypes
import Foundation

extension AuthenticationKeychainServiceProtocol {
  public func saveMasterKey(
    _ masterKey: CoreSession.MasterKey,
    for login: Login,
    accessMode: KeychainAccessMode
  ) throws {
    switch masterKey {
    case let .masterPassword(masterPassword, serverKey):
      try save(
        .masterPassword(masterPassword),
        for: login,
        expiresAfter: defaultPasswordValidityPeriod,
        accessMode: accessMode)
      if let serverKey = serverKey {
        try saveServerKey(serverKey, for: login)
      }
    case .ssoKey(let key):
      try save(
        .key(key),
        for: login,
        expiresAfter: defaultRemoteKeyValidityPeriod,
        accessMode: accessMode)
    }
  }
}
