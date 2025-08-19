import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats

@Loggable
@PersonalData
public struct Settings: Equatable {
  public static let id: Identifier = "SETTINGS_userId"

  public var id: Identifier {
    Self.id
  }

  public var anonymousUserId: String
  @OnSync(.lowerCasedKey(current: true, child: false))
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
  @Defaulted<Bool>.True
  public var richIcons: Bool

  @JSONEncoded
  @OnSync(.keepSpecUndefinedKey)
  public var spaceAnonIds: [String: String]

  @JSONEncoded
  @OnSync(.keepSpecUndefinedKey)
  public var iOSInfo: [String: String]

  public var generatorDefaultSize: UInt?
  public var generatorDefaultLetters: Bool?
  public var generatorDefaultDigits: Bool?
  public var generatorDefaultSymbols: Bool?

  public let deliveryType: String

  public var accountRecoveryKey: String?
  public var accountRecoveryKeyId: String?

  public init(
    cryptoFixedSalt: Data?,
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
    accountCreationDatetime: Date?,
    usagelogToken: String,
    accountRecoveryKey: String? = nil,
    accountRecoveryKeyId: String? = nil
  ) {
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
    self.accountCreationDatetime = accountCreationDatetime
    self.usagelogToken = usagelogToken
    self._spaceAnonIds = .init()
    self._iOSInfo = .init()
    self.deliveryType = "DELIVERY_TYPE_NORMAL"
    self.accountRecoveryKey = accountRecoveryKey
    self.accountRecoveryKeyId = accountRecoveryKeyId
  }
}

extension Settings {
  public init(
    cryptoConfig: CryptoRawConfig,
    anonymousUserId: String = UUID().uuidString,
    email: String
  ) {
    self.init(
      cryptoFixedSalt: cryptoConfig.fixedSalt,
      cryptoUserPayload: cryptoConfig.marker,
      realLogin: email,
      securityEmail: email,
      dashlaneName: email,
      accountCreationDatetime: Date(),
      usagelogToken: Identifier().rawValue)
  }
}

extension Settings {
  public var cryptoConfig: CryptoRawConfig? {
    get {
      guard !cryptoUserPayload.isEmpty else {
        return nil
      }
      return CryptoRawConfig(
        fixedSalt: cryptoFixedSalt,
        marker: cryptoUserPayload)
    }
    set {
      cryptoUserPayload = newValue?.marker ?? ""
      cryptoFixedSalt = newValue?.fixedSalt
    }
  }
}

extension Settings {
  public var accountRecoveryKeyInfo: AccountRecoveryKeyInfo? {
    get {
      guard let key = accountRecoveryKey, let id = accountRecoveryKey else {
        return nil
      }
      return AccountRecoveryKeyInfo(recoveryKey: key, recoveryId: id)
    }
    set {
      accountRecoveryKey = newValue?.recoveryKey
      accountRecoveryKeyId = newValue?.recoveryId
    }
  }
}
