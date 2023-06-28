import Foundation

public struct DevciceToDeviceTransferData: Codable {

    public struct Key: Codable {
        public let type: KeyType
        public let value: String

        public init(type: KeyType, value: String) {
            self.type = type
            self.value = value
        }
    }

    public let key: Key
    public let token: String?
    public let login: String
    public let version: Int

    public init(key: Key, token: String?, login: String, version: Int) {
        self.key = key
        self.token = token
        self.login = login
        self.version = version
    }
}

public enum KeyType: String, Codable {
    case masterPassword = "master_password"
    case sso
    case invisibleMasterPassword = "invisible_master_password"
}

public extension DevciceToDeviceTransferData.Key {
    var masterKey: MasterKey? {
        switch type {
        case .masterPassword, .invisibleMasterPassword:
            return .masterPassword(value, serverKey: nil)
        case .sso:
            guard let data = Data(base64Encoded: value) else {
                return nil
            }
            return .ssoKey(data)
        }
    }

    var accountType: AccountType {
        switch type {
        case .masterPassword:
            return .masterPassword
        case .invisibleMasterPassword:
            return .invisibleMasterPassword
        case .sso:
            return .sso
        }
    }

}

public extension MasterKey {
    func transferKey(accountType: AccountType) -> DevciceToDeviceTransferData.Key {
        switch self {
        case let .masterPassword(masterPassword, _):
            return .init(type: accountType == .masterPassword ? .masterPassword : .invisibleMasterPassword, value: masterPassword)
        case let .ssoKey(ssoKey):
            return .init(type: .sso, value: ssoKey.base64EncodedString())
        }
    }
}
