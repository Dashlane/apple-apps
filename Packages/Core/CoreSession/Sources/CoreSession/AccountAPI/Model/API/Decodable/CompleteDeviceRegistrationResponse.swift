import Foundation
import DashTypes

public struct RemoteKey: Codable, Equatable {
    public enum KeyType: String, Codable, Equatable {
        case sso
        case masterPassword = "master_password"
    }

    public let uuid: String
    public let key: String
    public let type: KeyType?
    
    public init(uuid: String, key: String, type: KeyType?) {
        self.uuid = uuid
        self.key = key
        self.type = type
    }
}

public struct CompleteDeviceRegistrationResponse: Decodable {
    public let deviceAccessKey: String
    public let deviceSecretKey: String
    public let settings: SettingsInfo
    public let numberOfDevices: Int
    public let hasDesktopDevices: Bool
    public let publicUserId: String
    public let sharingKeys: SharingKeys?
    public let serverKey: String?
    public let ssoServerKey: String?
    public let remoteKeys: [RemoteKey]?
    let deviceAnalyticsId: String
    let userAnalyticsId: String
    
    public var analyticsIds: AnalyticsIdentifiers {
        return AnalyticsIdentifiers(device: deviceAnalyticsId, user: userAnalyticsId)
    }

}

public struct SettingsInfo: Decodable {

    public enum SettingsType: String, Decodable {
        case settings = "SETTINGS"
    }

    public enum Action: String, Decodable {
       case edit = "BACKUP_EDIT"
    }

    public let backupDate: Date
    public let identifier: String
    public let time: Date
    public let content: String
    public let type: SettingsType
    public let action: Action
}
