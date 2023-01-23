import Foundation
import DashTypes



public struct UploadContentParams: Encodable {
    let timestamp: Timestamp
    let fullBackupContent: String?
    let isPasswordChange: Bool
    let new2FASetting: TWOFASetting?
    let new2FAServerKey: String?
    let sharingKeys: SharingKeys?
    let transactions: [UploadTransaction]


                                            public init(timestamp: Timestamp,
                fullBackupContent: String? = nil,
                isPasswordChange: Bool = false,
                new2FASetting: TWOFASetting? = nil,
                new2FAServerKey: String? = nil,
                sharingKeys: SharingKeys? = nil,
                transactions: [UploadTransaction]) {

        self.timestamp = timestamp
        self.fullBackupContent = fullBackupContent
        self.isPasswordChange = isPasswordChange
        self.new2FASetting = new2FASetting
        self.new2FAServerKey = new2FAServerKey
        self.sharingKeys = sharingKeys
        self.transactions = transactions
    }

    public enum TWOFASetting: String, Encodable {
        case login = "login"
        case disabled = "disabled"
    }
}

struct DataForMasterPasswordChange: Encodable {
    
        let timestamp: Timestamp
        let new2FASetting: TwoFASettings?
    let sharingKeys: SharingKeys?
        let transactions: [UploadTransaction]
    let authTicket: String?
    let remoteKeys: [RemoteKey]?
    let updateVerification: Verification?
    struct TwoFASettings: Encodable {
        enum Status: String, Encodable {
            case disabled
            case login
        }
        
        let type: Status
        let serverKey: String?
    }
}

public struct Verification: Encodable {
    public enum LoginType: String, Encodable {
        case sso
        case email_token
        case totp = "totp_login"
    }
    public let type: LoginType
    public let ssoServerKey: String?
    public let serverKey: String?
    
    public init(type: LoginType, ssoServerKey: String? = nil, serverKey: String? = nil) {
        self.type = type
        self.ssoServerKey = ssoServerKey
        self.serverKey = serverKey
    }
}

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

public struct UploadContentService {
    let apiClient: DeprecatedCustomAPIClient
    
    public init(apiClient: DeprecatedCustomAPIClient) {
        self.apiClient = apiClient
    }
    
        public func upload(_ params: UploadContentParams) async throws -> SyncSummary {
        do {
            return try await apiClient.sendRequest(to: "v1/sync/UploadContent",
                                                    using: HTTPMethod.post,
                                                    input: params)
        } catch (let error as APIErrorResponse) {
            guard let code = error.errors.first?.code, let error = Error(rawValue: code) else {
                throw error
            }
            
            throw error
        }
    }
}

extension UploadContentService {
    struct Keys {
        static let timestamp = "timestamp"
        static let transactions = "transactions"
        static let needsKeys = "needsKeys"
        static let teamAdminGroups = "teamAdminGroups"
        static let isPasswordChange = "isPasswordChange"
        static let new2FASetting = "new2FASetting"
        static let new2FAServerKey = "new2FAServerKey"
        static let sharingKeys = "sharingKeys"
        static let fullBackupContent = "fullBackupContent"
    }
}

public extension UploadContentService {
    
        enum Error: String, Swift.Error {
                case conflictingUpload = "conflicting_upload"
        
                case change_password_needs_content = "change_password_needs_content"
                
        case TwoFAServerKeyProvidedIncorrectly = "2fa_server_key_provided_incorrectly"
        
                case TwoFASettingChangeMayOnlyHappenInPasswordChange = "2fa_setting_change_may_only_happen_in_password_change"
        
                case TwoFASettingSameAsCurrent = "2fa_setting_same_as_current"
        
                case Current2FaSettingCannotBeChangedAtUpload = "current_2fa_setting_cannot_be_changed_at_upload"
        
                case TwoFAServerKeyNotProvided = "2fa_server_key_not_provided"
        
                case ProvidedSharingPublicKeyDoesNotMatchCurrentOne = "provided_sharing_public_key_does_not_match_current_one"
        
                case SharingKeysAlreadySet = "sharing_keys_already_set"
        
                case SharingPrivateKeyUpdateMayOnlyHappenInPasswordChange = "sharing_private_key_update_may_only_happen_in_password_change"
    }
}

private class EncodableWrapper: Encodable {
    let value: Encodable
    
    init(value: Encodable) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
