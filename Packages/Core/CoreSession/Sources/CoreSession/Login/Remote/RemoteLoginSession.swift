import Foundation
import DashTypes

public struct RemoteLoginSession {
    public let login: Login
    let userData: DeviceRegistrationData
    let cryptoConfig: CryptoRawConfig
    let masterKey: MasterKey
    public let authentication: ServerAuthentication
    let remoteKey: Data?
    public let isRecoveryLogin: Bool
    public let newMasterPassword: String?
    public var analyticsIds: AnalyticsIdentifiers {
        return userData.analyticsIds
    }
}
