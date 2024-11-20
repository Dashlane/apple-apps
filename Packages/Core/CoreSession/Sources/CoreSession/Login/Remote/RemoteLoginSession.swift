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
  public let verificationMethod: VerificationMethod?
  let pin: String?
  let shouldEnableBiometry: Bool
  let isBackupCode: Bool
  public var analyticsIds: AnalyticsIdentifiers {
    return userData.analyticsIds
  }
}

extension RemoteLoginSession {
  static func mock(
    masterKey: MasterKey, newMasterPassword: String? = nil,
    verificationMethod: VerificationMethod = .emailToken, isBackupCode: Bool = false,
    isRecoveryLogin: Bool = false
  ) -> RemoteLoginSession {
    RemoteLoginSession(
      login: Login(""),
      userData: .mock,
      cryptoConfig: .init(fixedSalt: nil, marker: "fakeConfig"),
      masterKey: masterKey,
      authentication: .signatureBased(
        .init(deviceAccessKey: "deviceAccessKey", deviceSecretKey: "deviceSecretKey")),
      remoteKey: nil,
      isRecoveryLogin: isRecoveryLogin,
      newMasterPassword: newMasterPassword,
      authTicket: AuthTicket(value: "authTicket"),
      verificationMethod: verificationMethod,
      pin: nil,
      shouldEnableBiometry: false,
      isBackupCode: isBackupCode)
  }
}
