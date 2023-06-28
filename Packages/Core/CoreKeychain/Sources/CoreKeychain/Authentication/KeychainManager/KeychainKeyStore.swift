import Foundation

public struct KeychainCustomStore {

    let identifier: String
    let accessGroup: String

    public init(identifier: String, accessGroup: String) {
        self.identifier = identifier
        self.accessGroup = accessGroup
    }

    public func fetch() -> Data? {
        var attributes: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                         kSecAttrAccount: identifier,
                                         kSecReturnData: true]
        #if !targetEnvironment(simulator)
        attributes[kSecAttrAccessGroup] = accessGroup
        #endif
        var item: CFTypeRef?
        let status = SecItemCopyMatching(attributes as CFDictionary, &item)
        guard status == errSecSuccess,
              let keyData = item as? Data else {
            return nil
        }
        return keyData
    }

    public func store(_ data: Data) throws {
        var attributes: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                         kSecAttrAccount: identifier,
                                         kSecValueData: data]
        #if !targetEnvironment(simulator)
        attributes[kSecAttrAccessGroup] = accessGroup
        #endif
        _ = SecItemDelete(attributes as CFDictionary)

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
}
