import Foundation
import Security

@propertyWrapper
final public class KeychainItemAccessor {

    private let identifier: String
    private let accessGroup: String
    private let shouldAccessAfterFirstUnlock: Bool

    public init(identifier: String, accessGroup: String, shouldAccessAfterFirstUnlock: Bool) {
        self.identifier = identifier
        self.accessGroup = accessGroup
        self.shouldAccessAfterFirstUnlock = shouldAccessAfterFirstUnlock
    }

    private var baseDictionary: [String: AnyObject] {
        var dict = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier as AnyObject,
                        kSecUseDataProtectionKeychain as String: true as AnyObject
        ]

        #if !targetEnvironment(simulator)
        return dict.adding(key: kSecAttrAccessGroup as String, value: accessGroup as AnyObject)
        #else
        return dict
        #endif
    }

    private var query: [String: AnyObject] {
        return baseDictionary
            .adding(key: kSecMatchLimit as String, value: kSecMatchLimitOne)
    }

    private var addItemQuery: [String: AnyObject] {
        if shouldAccessAfterFirstUnlock {
            return baseDictionary
                .adding(key: kSecAttrAccessible as String, value: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as AnyObject)
        }
        return baseDictionary

    }

    public var wrappedValue: Data? {
        get {
            do {
                let data = try read()
                self.projectedValue = .success(data)
                return data
            } catch {
                self.projectedValue = .failure(error)
                return nil
            }
        }
        set {
            do {
                if let value = newValue {
                    if try read() == nil {
                        try add(value)
                    } else {
                        try update(value)
                    }
                    self.projectedValue = .success(value)
                } else {
                    try delete()
                    self.projectedValue = .success(nil)
                }

            } catch {
                self.projectedValue = .failure(error)
            }
        }
    }

    public var projectedValue: Result<Data?, Error>?

    private func delete() throws {
                let status = SecItemDelete(baseDictionary as CFDictionary)
        guard status != errSecItemNotFound else { return }
        try throwIfNotZero(status)
    }

    private func read() throws -> Data? {
        let query = self.query.adding(key: kSecReturnData as String, value: true as AnyObject)
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else { return nil }
        try throwIfNotZero(status)
        guard let data = result as? Data else {
            throw KeychainItemError.invalidData
        }
        return data
    }

    private func update(_ secret: Data) throws {
        let dictionary: [String: AnyObject] = [
            kSecValueData as String: secret as AnyObject
        ]
        try throwIfNotZero(SecItemUpdate(addItemQuery as CFDictionary, dictionary as CFDictionary))
    }

    private func add(_ secret: Data) throws {
        let dictionary = addItemQuery.adding(key: kSecValueData as String, value: secret as AnyObject)
        try throwIfNotZero(SecItemAdd(dictionary as CFDictionary, nil))
    }
}

private func throwIfNotZero(_ status: OSStatus) throws {
    guard status != 0 else { return }
    throw KeychainItemError.keychainError(status: status)
}

public enum KeychainItemError: Error {
    case invalidData
    case keychainError(status: OSStatus)
}

extension Dictionary {
    func adding(key: Key, value: Value) -> Dictionary {
        var copy = self
        copy[key] = value
        return copy
    }
}
