import CryptoKit
import Foundation
import LocalAuthentication

public typealias UserLogin = String
typealias KeychainData = [String: Any]

enum KeychainItemStatus: Equatable {
  case found(accessible: KeychainAccessMode)
  case notFound
}

protocol KeychainManager {
  var cryptoEngine: AuthenticationKeychainCryptoEngine { get }
  var accessGroup: String { get }
  var userLogin: String { get }

  func status(for item: KeychainItem) throws -> KeychainItemStatus
  func retrieve(_ item: KeychainItem, context: LAContext?) throws -> KeychainData
}

extension KeychainManager {

  func status(for item: KeychainItem) throws -> KeychainItemStatus {
    let query = KeychainQueryBuilder(item: item, userLogin: userLogin, accessGroup: accessGroup)
      .makeCheckStatusQuery()
    let status = SecItemCopyMatching(query as CFDictionary, nil)

    switch status {
    case errSecInteractionNotAllowed:
      return .found(accessible: .afterBiometricAuthentication)
    case errSecSuccess:
      return .found(accessible: .whenDeviceUnlocked)
    case errSecItemNotFound:
      return .notFound
    default:
      print(status)
      throw KeychainError.statusCheckFailure(status: status)
    }
  }

  func retrieve(_ item: KeychainItem, context: LAContext? = nil) throws -> KeychainData {
    var query = KeychainQueryBuilder(item: item, userLogin: userLogin, accessGroup: accessGroup)
      .makeRetrieveQuery()

    if let context = context {
      query[kSecUseAuthenticationContext] = context
    }

    var itemData: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &itemData)

    guard status != errSecItemNotFound else { throw KeychainError.itemNotFound }
    guard status != errSecUserCanceled else { throw KeychainError.userCanceledRequest }
    guard status != errSecAuthFailed else { throw KeychainError.userFailedAuthCheck }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

    guard let encryptedData = itemData as? Data else {
      throw KeychainError.emptyItemData(status: status)
    }
    let decryptedData = try cryptoEngine.decrypt(encryptedData, accessGroup: accessGroup)

    guard let archivedData = Data(base64Encoded: decryptedData) else {
      throw KeychainError.decryptionFailure
    }
    guard
      let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(
        ofClasses: [NSDictionary.self, NSDate.self], from: archivedData) as? KeychainData
    else { throw KeychainError.decryptionFailure }

    return unarchivedData
  }

  func removeKeychainData(for item: KeychainItem) throws {
    let query = KeychainQueryBuilder(item: item, userLogin: userLogin, accessGroup: accessGroup)
      .makeRetrieveQuery()
    let status = SecItemDelete(query as CFDictionary)
    switch status {
    case errSecItemNotFound:
      throw KeychainError.itemNotFound
    case noErr:
      return
    default:
      throw KeychainError.removalFailure(status: status)
    }
  }

  @discardableResult
  func store(_ data: KeychainData, for item: KeychainItem, accessMode: KeychainAccessMode) throws
    -> KeychainData
  {
    do {
      try removeKeychainData(for: item)
    } catch let error as KeychainError {
      if error != .itemNotFound { throw error }
    }

    guard
      let archivedData = try? NSKeyedArchiver.archivedData(
        withRootObject: data, requiringSecureCoding: false)
    else { throw KeychainError.encryptionFailure }
    let archivedDataString = archivedData.base64EncodedString()

    guard let encodedArchivedData = archivedDataString.data(using: String.Encoding.utf8) else {
      throw KeychainError.encryptionFailure
    }

    let encodedData = try cryptoEngine.encrypt(
      encodedArchivedData, accessMode: accessMode, accessGroup: accessGroup)

    let query = KeychainQueryBuilder(item: item, userLogin: userLogin, accessGroup: accessGroup)
      .makeStoreQuery(data: encodedData, accessMode: accessMode)
    let status = SecItemAdd(query as CFDictionary, nil)

    guard status == errSecSuccess else { throw KeychainError.storingFailure(status: status) }

    return data
  }
}
