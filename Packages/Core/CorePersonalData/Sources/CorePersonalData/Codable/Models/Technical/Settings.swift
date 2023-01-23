import Foundation
import SwiftTreats
import DashTypes

public struct Settings: PersonalDataCodable, Equatable {
        public static let id: Identifier = "SETTINGS_userId"
    public static let contentType: PersonalDataContentType = .settings
    
    public var id: Identifier {
        Self.id
    }
    public let metadata: RecordMetadata

    public var anonymousUserId: String
    public let accountCreationDatetime: Date?
    public let usagelogToken: String
    
    public var realLogin: String
    public var securityPhone: String
    public var securityEmail: String
    public var dashlaneName: String

    public var cryptoFixedSalt: Data?
    public var cryptoUserPayload: String
    
    @Defaulted<Set<String>>
    public var banishedUrlsList
    @Defaulted<Bool>.True
    public var autoLogin: Bool
    @Defaulted<Bool>.True
    public var syncBackup: Bool
  
    @JSONEncoded
    public var spaceAnonIds: [String: String]
    
    @JSONEncoded
    public var iOSInfo: [String: String]

    public var generatorDefaultSize: UInt?
    public var generatorDefaultLetters: Bool?
    public var generatorDefaultDigits: Bool?
    public var generatorDefaultSymbols: Bool?
    public var generatorDefaultPronounceable: Bool?
    
    public let deliveryType: String
    
    public init(cryptoFixedSalt: Data?,
                cryptoUserPayload: String,
                anonymousUserId: String = UUID().uuidString,
                realLogin: String,
                securityPhone: String = "",
                securityEmail: String = "",
                dashlaneName: String,
                generatorDefaultSize: UInt? = 16,
                generatorDefaultLetters: Bool? = true,
                generatorDefaultDigits: Bool? = true,
                generatorDefaultSymbols: Bool? = false,
                generatorDefaultPronounceable: Bool? = false,
                accountCreationDatetime: Date?,
                usagelogToken: String) {
        metadata = RecordMetadata(id: .temporary, contentType: Self.contentType)
        self.cryptoFixedSalt = cryptoFixedSalt
        self.cryptoUserPayload = cryptoUserPayload
        self.anonymousUserId = anonymousUserId
        self.realLogin = realLogin
        self.securityPhone = securityPhone
        self.securityEmail = securityEmail
        self.dashlaneName = dashlaneName
        self.generatorDefaultSize = generatorDefaultSize
        self.generatorDefaultLetters = generatorDefaultLetters
        self.generatorDefaultDigits = generatorDefaultDigits
        self.generatorDefaultSymbols = generatorDefaultSymbols
        self.generatorDefaultPronounceable = generatorDefaultPronounceable
        self.accountCreationDatetime = accountCreationDatetime
        self.usagelogToken = usagelogToken
        self._spaceAnonIds = .init()
        self._iOSInfo = .init()
        self.deliveryType = "DELIVERY_TYPE_NORMAL"
    }
}

extension Settings {
    public init(cryptoConfig: CryptoRawConfig,
                anonymousUserId: String = UUID().uuidString,
                email: String) {
        self.init(cryptoFixedSalt: cryptoConfig.fixedSalt,
                  cryptoUserPayload: cryptoConfig.parametersHeader,
                  realLogin: email,
                  securityEmail: email,
                  dashlaneName: email,
                  accountCreationDatetime: Date(),
                  usagelogToken: Identifier().rawValue)
    }
}

public extension Settings {
    var cryptoConfig: CryptoRawConfig? {
        get {
            guard !cryptoUserPayload.isEmpty else {
                return nil
            }
            return CryptoRawConfig(fixedSalt: cryptoFixedSalt,
                                   parametersHeader: cryptoUserPayload)
        }
        set {
            cryptoUserPayload = newValue?.parametersHeader ?? ""
            cryptoFixedSalt = newValue?.fixedSalt
        }
    }
}
