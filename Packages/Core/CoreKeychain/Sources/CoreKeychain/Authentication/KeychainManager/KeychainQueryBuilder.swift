import Foundation
import LocalAuthentication

typealias KeychainQuery = [CFString: Any]

public struct KeychainQueryBuilder {
    let item: KeychainItem
    let userLogin: UserLogin
    let accessGroup: String

    func makeCheckStatusQuery() -> KeychainQuery {
        var query: KeychainQuery = [kSecClass: item.keychainItemClass,
                                    kSecAttrService: item.keychainItemService,
                                    kSecAttrAccount: userLogin,
                                    kSecReturnData: false,
                                    kSecUseAuthenticationUI: kSecUseAuthenticationUIFail]

    #if !targetEnvironment(simulator)
        query[kSecAttrAccessGroup] = accessGroup
    #endif

        return query
    }

        func makeRetrieveQuery() -> KeychainQuery {
        var query: KeychainQuery = [kSecClass: item.keychainItemClass,
                                    kSecAttrService: item.keychainItemService,
                                    kSecAttrAccount: userLogin,
                                    kSecReturnData: true]

    #if !targetEnvironment(simulator)
        query[kSecAttrAccessGroup] = accessGroup
    #endif

        return query
    }

    func makeStoreQuery(data: Data, accessMode: KeychainAccessMode) -> KeychainQuery {
        var query: KeychainQuery = [kSecClass: item.keychainItemClass,
                                    kSecAttrService: item.keychainItemService,
                                    kSecAttrAccount: userLogin,
                                    kSecValueData: data]

        query.apply(accessMode)

        #if !targetEnvironment(simulator)
        query[kSecAttrAccessGroup] = accessGroup
        #endif

        return query
    }

    static func makeDeleteAllQueries(accessGroup: String) -> [KeychainQuery] {
        return [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
            .map { secClass in
                var query: KeychainQuery = [kSecClass: secClass]
#if !targetEnvironment(simulator)
                query[kSecAttrAccessGroup] = accessGroup
#endif
                return query
            }
    }
}

extension KeychainQuery {
    mutating func apply(_ accessMode: KeychainAccessMode) {
        self.merge(accessMode.accessModeAttribute) { (_, second) in second }
    }
}
