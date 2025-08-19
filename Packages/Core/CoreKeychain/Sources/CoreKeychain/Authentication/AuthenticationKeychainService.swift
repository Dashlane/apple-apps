import Combine
import CoreTypes
import Foundation
import LocalAuthentication
import LogFoundation

extension AuthenticationKeychainServiceProtocol {
  public func masterKey(for login: Login) throws -> MasterKey {
    return try masterKey(for: login, using: nil)
  }

  public func masterKey(for login: Login) async throws -> MasterKey {
    return try await masterKey(for: login, using: nil)
  }

  public func masterKey(for login: Login, using context: LAContext?) async throws -> MasterKey {
    try await Task.detached {
      return try syncMasterKey(for: login, using: nil)
    }.value
  }

  @inline(__always)
  private func syncMasterKey(for login: Login, using context: LAContext?) throws -> MasterKey {
    return try masterKey(for: login, using: nil)
  }

  public func save(
    _ masterKey: CoreTypes.MasterKey,
    for login: Login,
    expiresAfter timeInterval: TimeInterval,
    accessMode: KeychainAccessMode = .afterBiometricAuthentication
  ) throws {
    try self.save(masterKey, for: login, expiresAfter: timeInterval, accessMode: accessMode)
  }
}

public protocol KeychainSettingsDataProvider {
  func provider(for login: Login) throws -> SettingsDataProvider
}

public struct AuthenticationKeychainService: AuthenticationKeychainServiceProtocol {

  public let cryptoEngine: AuthenticationKeychainCryptoEngine
  public let accessGroup: String
  let keychainSettingsDataProvider: KeychainSettingsDataProvider

  public let masterKeyStatusChanged = PassthroughSubject<MasterKeyStatusChange, Never>()

  @Loggable
  enum PinCodeRetrievalError: Error {
    case decodingError
    case noPinCodeFoundForThisUser
    case status(code: OSStatus)
  }

  @Loggable
  enum PinCodeSavingError: Error {
    case cantAccessKeychain
  }

  public init(
    cryptoEngineProvider: AuthenticationKeychainCryptoEngineProvider,
    keychainSettingsDataProvider: KeychainSettingsDataProvider,
    accessGroup: String
  ) {
    self.cryptoEngine = AuthenticationKeychainCryptoEngine(
      cryptoEngineProvider: cryptoEngineProvider)
    self.keychainSettingsDataProvider = keychainSettingsDataProvider
    self.accessGroup = accessGroup
  }

  func settingsDataProvider(for login: Login) throws -> SettingsDataProvider {
    return try keychainSettingsDataProvider.provider(for: login)
  }

  public func masterKeyStatus(for login: Login) -> MasterKeyStoredStatus {

    do {
      let settings = try settingsDataProvider(for: login)
      let store = MasterKeyStore(
        cryptoEngine: cryptoEngine,
        settings: settings,
        accessGroup: accessGroup,
        userLogin: login.email)
      return try store.checkMasterKeyStatus()
    } catch {
      return .notAvailable
    }
  }

  public func masterKey(for login: Login, using context: LAContext?) throws -> CoreTypes.MasterKey {
    let settings = try settingsDataProvider(for: login)
    let store = MasterKeyStore(
      cryptoEngine: cryptoEngine,
      settings: settings,
      accessGroup: accessGroup,
      userLogin: login.email)
    return try store.masterKey(context: context).masterKey
  }

  public func save(
    _ masterKey: CoreTypes.MasterKey,
    for login: Login,
    expiresAfter timeInterval: TimeInterval,
    accessMode: KeychainAccessMode
  ) throws {
    let settings = try settingsDataProvider(for: login)

    let store = MasterKeyStore(
      cryptoEngine: cryptoEngine,
      settings: settings,
      accessGroup: accessGroup,
      userLogin: login.email)

    try store.storeMasterKey(masterKey, expiringIn: timeInterval, accessMode: accessMode)

    masterKeyStatusChanged.send(.update(masterKey))
  }

  public func removeMasterKey(for login: Login) throws {
    let settings = try settingsDataProvider(for: login)

    let store = MasterKeyStore(
      cryptoEngine: cryptoEngine,
      settings: settings,
      accessGroup: accessGroup,
      userLogin: login.email)
    try store.removeMasterKey()
    try? store.removeServerKey()
    masterKeyStatusChanged.send(.removal)
  }

  public func pincode(for login: Login) throws -> String {
    try pincode(forLogin: login.email)
  }

  public func setPincode(_ pincode: String?, for login: Login) throws {
    let keychain = KeychainItemWrapper(identifier: "Dashlane", accessGroup: accessGroup)

    var pincodes = NSMutableDictionary()

    if let data = keychain[kSecValueData as String] as? String, !data.isEmpty {
      pincodes = NSMutableDictionary(dictionary: data.propertyListFromStringsFileFormat())
    }
    if let pincode = pincode {
      pincodes[login.email] = pincode
    } else {
      pincodes.removeObject(forKey: login.email)
    }
    keychain[kSecValueData as String] = pincodes.descriptionInStringsFileFormat as AnyObject
  }

  func pincode(forLogin login: String) throws -> String {
    var initialQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrGeneric: "Dashlane",
      kSecMatchLimit: kSecMatchLimitOne,
      kSecReturnAttributes: true,
    ]
    #if !targetEnvironment(simulator)
      initialQuery[kSecAttrAccessGroup] = accessGroup
    #endif

    var mainQueryRef: CFTypeRef?
    let status = SecItemCopyMatching(initialQuery as CFDictionary, &mainQueryRef)
    guard status == errSecSuccess else { throw PinCodeRetrievalError.status(code: status) }

    let mainQuery = mainQueryRef as! CFMutableDictionary
    var mainQuery2 = mainQuery as! [CFString: Any]

    mainQuery2[kSecReturnData] = kCFBooleanTrue
    mainQuery2[kSecClass] = kSecClassGenericPassword

    var pinCodesDataRef: CFTypeRef?
    let status2 = SecItemCopyMatching(mainQuery2 as CFDictionary, &pinCodesDataRef)
    guard status2 == errSecSuccess else {
      throw PinCodeRetrievalError.status(code: status2)
    }
    guard let pinCodesData = pinCodesDataRef as? Data else {
      throw PinCodeRetrievalError.decodingError

    }

    guard !pinCodesData.isEmpty else {
      throw PinCodeRetrievalError.noPinCodeFoundForThisUser
    }

    let pinCodes = String(decoding: pinCodesData, as: UTF8.self).propertyListFromStringsFileFormat()

    guard let pin = pinCodes[login] else {
      throw PinCodeRetrievalError.noPinCodeFoundForThisUser
    }
    return pin
  }

  public func removeServerKey(for login: Login) throws {
    let settings = try settingsDataProvider(for: login)

    let store = MasterKeyStore(
      cryptoEngine: cryptoEngine,
      settings: settings,
      accessGroup: accessGroup,
      userLogin: login.email)
    try store.removeServerKey()
  }

  public func serverKey(for login: Login) -> String? {
    guard let settings = try? settingsDataProvider(for: login) else {
      return nil
    }
    let store = MasterKeyStore(
      cryptoEngine: cryptoEngine,
      settings: settings,
      accessGroup: accessGroup,
      userLogin: login.email)
    return try? store.serverKey()
  }

  public func saveServerKey(
    _ serverKey: String,
    for login: Login
  ) throws {
    let settings = try settingsDataProvider(for: login)

    let store = MasterKeyStore(
      cryptoEngine: cryptoEngine,
      settings: settings,
      accessGroup: accessGroup,
      userLogin: login.email)
    _ = try store.storeServerKey(serverKey)
  }

  public func removeAllLocalData() throws {
    try MasterKeyStore.removeAllKeychainData(accessGroup: accessGroup)
  }

  public func masterPasswordEquals(
    _ masterPassword: String,
    for login: Login
  ) throws -> Bool {
    let settings = try settingsDataProvider(for: login)

    let store = MasterKeyStore(
      cryptoEngine: cryptoEngine,
      settings: settings,
      accessGroup: accessGroup,
      userLogin: login.email)
    return try store.masterPasswordEquals(masterPassword)
  }

  public func makeResetContainerKeychainManager(userLogin: UserLogin)
    -> ResetContainerKeychainManager
  {
    ResetContainerKeychainManagerImpl(
      cryptoEngine: cryptoEngine, accessGroup: accessGroup, userLogin: userLogin)
  }
}
