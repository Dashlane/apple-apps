import CoreTypes
import CryptoKit
import Foundation
import LogFoundation

public struct SecureEnclaveKeys {
  let privateKey: SecKey
  let publicKey: SecKey
}

public enum SecureEnclaveKeysStatus {
  case unavailable
  case available(SecureEnclaveKeys)
}

@Loggable
enum SecureEnclaveError: Error {
  case keysFetchingError(status: OSStatus)
  case keysPrivateKeyCreationError
  case keysPublicKeyCreationError
  case encryptFailed
  case decryptFailed
}

struct SecureEnclaveKeysStore {

  let status: SecureEnclaveKeysStatus

  private let accessGroup: String

  init(accessGroup: String) {
    self.accessGroup = accessGroup

    guard SecureEnclave.isAvailable else {
      self.status = .unavailable
      return
    }

    let tag = "com.dashlane.master.password.secure.enclave.key"

    do {
      if let keys = try SecureEnclave.fetchExistingKeys(with: tag) {
        self.status = .available(keys)
      } else {
        let keys = try SecureEnclave.createNewKeys(with: tag, accessGroup: accessGroup)
        self.status = .available(keys)
      }
    } catch let error {
      assertionFailure("Secure Enclave keys initialization error: \(error)")
      self.status = .unavailable
    }
  }
}

extension SecureEnclave {
  fileprivate static func fetchExistingKeys(with tag: String) throws -> SecureEnclaveKeys? {
    let query: [CFString: Any] = [
      kSecClass: kSecClassKey,
      kSecAttrApplicationTag: tag,
      kSecReturnRef: true,
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status == errSecSuccess, CFGetTypeID(item) == SecKeyGetTypeID() else {
      if status == errSecItemNotFound {
        return nil
      } else {
        throw SecureEnclaveError.keysFetchingError(status: status)
      }
    }

    let privateKey = item as! SecKey

    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      return nil
    }

    return SecureEnclaveKeys(privateKey: privateKey, publicKey: publicKey)
  }

  fileprivate static func createNewKeys(with tag: String, accessGroup: String) throws
    -> SecureEnclaveKeys
  {
    let access = SecAccessControlCreateWithFlags(
      nil,
      kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      .privateKeyUsage,
      nil)

    var attributes: [CFString: Any] = [
      kSecClass: kSecClassKey,
      kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits: 256,
      kSecAttrTokenID: kSecAttrTokenIDSecureEnclave,
      kSecPrivateKeyAttrs: [
        kSecAttrIsPermanent: true,
        kSecAttrApplicationTag: tag,
        kSecAttrAccessControl: access as Any,
      ],
    ]
    #if !targetEnvironment(simulator)
      attributes[kSecAttrAccessGroup] = accessGroup
    #endif

    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, nil) else {
      throw SecureEnclaveError.keysPrivateKeyCreationError
    }

    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw SecureEnclaveError.keysPublicKeyCreationError
    }

    return SecureEnclaveKeys(privateKey: privateKey, publicKey: publicKey)
  }
}

extension SecureEnclave {
  static func cryptoKeys(accessGroup: String) -> SecureEnclaveKeysStatus {
    return SecureEnclaveKeysStore(accessGroup: accessGroup).status
  }
}
