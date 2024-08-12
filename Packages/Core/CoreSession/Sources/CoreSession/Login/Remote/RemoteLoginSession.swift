import DashTypes
import Foundation

public struct RemoteLoginSession: Hashable {
  public let login: Login
  let userData: DeviceRegistrationData
  let cryptoConfig: CryptoRawConfig
  let masterKey: MasterKey
  public let authentication: ServerAuthentication
  let remoteKey: Data?
  public let isRecoveryLogin: Bool
  public let newMasterPassword: String?
  public let authTicket: AuthTicket
  let pin: String?
  let shouldEnableBiometry: Bool
  public var analyticsIds: AnalyticsIdentifiers {
    return userData.analyticsIds
  }
}
