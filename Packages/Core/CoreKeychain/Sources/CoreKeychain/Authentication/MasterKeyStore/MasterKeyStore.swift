import CoreTypes
import Foundation
import LocalAuthentication

public typealias ExpirationDate = Date

final public class MasterKeyStore: KeychainManager {

  private let keychainManagerDataToStoreKey = "KWKeychainManagerDataToStoreKey"
  private let keychainManagerExpirationDateKey = "KWKeychainManagerExpirationDateKey"
  private let keychainManagerDestroyIfExpiredKey = "KWKeychainManagerDestroyIfExpiredKey"
  private let keychainManagerServerKey = "keychainManagerServerKey"

  let cryptoEngine: AuthenticationKeychainCryptoEngine
  let settings: SettingsDataProvider
  let accessGroup: String
  let userLogin: String

  public init(
    cryptoEngine: AuthenticationKeychainCryptoEngine,
    settings: SettingsDataProvider,
    accessGroup: String,
    userLogin: String
  ) {
    self.userLogin = userLogin
    self.cryptoEngine = cryptoEngine
    self.settings = settings
    self.accessGroup = accessGroup
  }

  public func checkMasterKeyStatus() throws -> MasterKeyStoredStatus {
    let keychainItemStatus = try self.status(for: .masterKey)
    guard keychainItemStatus != .notFound else {
      return .notAvailable
    }
    let expirationDate = try settings.masterKeyExpirationDate()
    guard Date() < expirationDate else {
      return MasterKeyStoredStatus(keychainItemStatus: keychainItemStatus, expired: true)
    }
    return MasterKeyStoredStatus(keychainItemStatus: keychainItemStatus, expired: false)
  }

  public func masterKey(context: LAContext? = nil) throws -> MasterKeyContainer {
    let keychainData = try retrieve(.masterKey, context: context)

    if let masterPassword = keychainData[keychainManagerDataToStoreKey] as? String,
      let expirationDate = keychainData[keychainManagerExpirationDateKey] as? Date
    {
      return MasterKeyContainer(
        masterKey: .masterPassword(masterPassword), expirationDate: expirationDate)
    } else if let key = keychainData[keychainManagerDataToStoreKey] as? Data,
      let expirationDate = keychainData[keychainManagerExpirationDateKey] as? Date
    {
      return MasterKeyContainer(masterKey: .key(key), expirationDate: expirationDate)
    } else {
      throw KeychainError.decryptionFailure
    }
  }

  @discardableResult
  public func storeMasterKey(
    _ masterKey: CoreTypes.MasterKey,
    expiringIn expirationTimeInterval: TimeInterval,
    accessMode: KeychainAccessMode
  ) throws -> MasterKeyContainer {
    let expirationDate = Date(timeInterval: expirationTimeInterval, since: Date())

    let data: [String: Any] = [
      keychainManagerDataToStoreKey: masterKey.value,
      keychainManagerExpirationDateKey: expirationDate,
      keychainManagerDestroyIfExpiredKey: true,
    ]

    try store(data, for: .masterKey, accessMode: accessMode)
    try settings.saveMasterKeyExpirationDate(expirationDate)
    return MasterKeyContainer(masterKey: masterKey, expirationDate: expirationDate)
  }

  public func storeServerKey(_ serverKey: String) throws {
    let data: [String: Any] = [keychainManagerServerKey: serverKey]

    try store(data, for: .serverKey, accessMode: .whenDeviceUnlocked)
  }

  public func serverKey() throws -> String {
    let keychainData = try retrieve(.serverKey)
    guard let serverKey = keychainData[keychainManagerServerKey] as? String else {
      throw KeychainError.decryptionFailure
    }
    return serverKey
  }

  public func removeMasterKey() throws {
    try removeKeychainData(for: .masterKey)
    settings.removeMasterKeyExpirationDate()
  }

  public func removeServerKey() throws {
    try removeKeychainData(for: .serverKey)
  }

  public func masterPasswordEquals(_ masterPassword: String) throws -> Bool {
    let keychainData = try retrieve(.masterKey)

    if let currentMasterPassword = keychainData[keychainManagerDataToStoreKey] as? String {
      return masterPassword == currentMasterPassword
    }
    return false
  }

  internal func checkMasterKeyStatus(referenceDateForMasterKeyExpiry: Date) throws
    -> MasterKeyStoredStatus
  {

    let itemAvailabilityStatus = try status(for: .masterKey)
    guard itemAvailabilityStatus != .notFound else { return .notAvailable }

    let expirationDate = try settings.masterKeyExpirationDate()
    guard referenceDateForMasterKeyExpiry < expirationDate else {
      return MasterKeyStoredStatus(keychainItemStatus: itemAvailabilityStatus, expired: true)
    }
    return MasterKeyStoredStatus(keychainItemStatus: itemAvailabilityStatus, expired: false)
  }

  public static func removeAllKeychainData(accessGroup: String) throws {
    let queries = KeychainQueryBuilder.makeDeleteAllQueries(accessGroup: accessGroup)
    try queries.forEach { query in
      let status = SecItemDelete(query as CFDictionary)
      switch status {
      case noErr, errSecItemNotFound:
        break
      default:
        throw KeychainError.unhandledError(status: status)
      }
    }
  }
}
