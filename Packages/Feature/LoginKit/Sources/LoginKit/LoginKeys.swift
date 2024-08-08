import CoreSession
import Foundation

public struct LoginKeys {
  public let remoteKey: CoreSession.EncryptedRemoteKey?
  public let authTicket: CoreSession.AuthTicket

  public init(remoteKey: CoreSession.EncryptedRemoteKey?, authTicket: AuthTicket) {
    self.remoteKey = remoteKey
    self.authTicket = authTicket
  }
}
