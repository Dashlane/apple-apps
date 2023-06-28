import Foundation
import DashTypes

public struct SessionConfiguration: Equatable, Codable {
    public let login: Login

        let masterKey: MasterKey
    public var keys: SessionSecureKeys
    public var info: SessionInfo

    public init(login: Login,
                masterKey: MasterKey,
                keys: SessionSecureKeys,
                info: SessionInfo) {
        self.login = login
        self.masterKey = masterKey
        self.info = info
        self.keys = keys
    }
}

public struct SessionInfo: Codable, Equatable {
        public let deviceAccessKey: String?
    public let loginOTPOption: ThirdPartyOTPOption? 
        private let isPartOfSSOCompany: Bool
    public let accountType: AccountType

    public init(deviceAccessKey: String?,
                loginOTPOption: ThirdPartyOTPOption?,
                accountType: AccountType) {
        self.deviceAccessKey = deviceAccessKey
        self.loginOTPOption = loginOTPOption
        self.accountType = accountType
        isPartOfSSOCompany = accountType == .sso
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.deviceAccessKey = try container.decodeIfPresent(String.self, forKey: .deviceAccessKey)
        self.loginOTPOption = try container.decodeIfPresent(ThirdPartyOTPOption.self, forKey: .loginOTPOption)
        self.isPartOfSSOCompany = try container.decode(Bool.self, forKey: .isPartOfSSOCompany)
        if let accountType = try container.decodeIfPresent(AccountType.self, forKey: .accountType) {
            self.accountType = accountType
        } else {
            self.accountType = isPartOfSSOCompany == true ? .sso : .masterPassword
        }
    }
}

public struct SessionSecureKeys: Codable, Equatable {
        public let serverAuthentication: ServerAuthentication
        public let remoteKey: Data?
            public var analyticsIds: AnalyticsIdentifiers?

    public init(serverAuthentication: ServerAuthentication, remoteKey: Data?, analyticsIds: AnalyticsIdentifiers?) {
        self.serverAuthentication = serverAuthentication
        self.remoteKey = remoteKey
        self.analyticsIds = analyticsIds
    }
}

public extension SessionConfiguration {
    static var mock: SessionConfiguration {
        .init(login: Login(""),
              masterKey: .masterPassword("", serverKey: nil),
              keys: SessionSecureKeys.mock,
              info: SessionInfo.mock)
    }
}

public extension SessionInfo {
    static var mock: SessionInfo {
        .init(deviceAccessKey: nil,
              loginOTPOption: nil,
              accountType: .masterPassword)
    }
}

public extension SessionSecureKeys {
    static var mock: SessionSecureKeys {
        .init(serverAuthentication: .uki(.init(deviceId: "", secret: "")),
                    remoteKey: nil,
                    analyticsIds: nil)
    }
}
