import CoreTypes
import Foundation
import SwiftTreats

public struct SSOKeys: Hashable, Sendable {

  public struct Keys: Hashable, Sendable {
    public let remoteKey: Data
    public let ssoKey: Data

    init(remoteKey: Data, ssoKey: Data) {
      self.remoteKey = remoteKey
      self.ssoKey = ssoKey
    }

    public init(serverKey: Data, serviceProviderKey: Base64EncodedString) throws {
      let remoteKey = Data.random(ofSize: 64)
      guard let serviceProviderKeyData = Data(base64Encoded: serviceProviderKey) else {
        throw AccountError.unknown
      }
      let ssoKey = serverKey ^ serviceProviderKeyData

      self.init(remoteKey: remoteKey, ssoKey: ssoKey)
    }
  }

  public let keys: SSOKeys.Keys
  public let authTicket: AuthTicket

  init(remoteKey: Data, ssoKey: Data, authTicket: AuthTicket) {
    self.keys = .init(remoteKey: remoteKey, ssoKey: ssoKey)
    self.authTicket = authTicket
  }
}
