import Foundation

public protocol ResetContainerKeychainManager {
    func checkStatus() throws -> ResetContainerStatus
    func get() throws -> ResetContainer
    @discardableResult
    func store(_ masterPassword: MasterPassword, accessMode: KeychainAccessMode) throws -> ResetContainer
    func remove() throws
}

public extension ResetContainerKeychainManager {
    @discardableResult
    func store(_ masterPassword: MasterPassword) throws -> ResetContainer {
        try self.store(masterPassword, accessMode: .afterBiometricAuthentication)
    }

}

public typealias MasterPassword = String

public enum ResetContainerStatus: Equatable {
    case available
    case notAvailable

    init(keychainItemStatus: KeychainItemStatus) {
        switch keychainItemStatus {
        case .found:
            self = .available
        case .notFound:
            self = .notAvailable
        }
    }
}

public struct ResetContainerKeychainManagerImpl: ResetContainerKeychainManager, KeychainManager {

        static let keychainMasterPasswordKey = "MasterPasswordForReset"

        let cryptoEngine: KeychainCryptoEngine
    let accessGroup: String
    let userLogin: String

        public init(cryptoEngine: KeychainCryptoEngine, accessGroup: String, userLogin: String) {
        self.userLogin = userLogin
        self.cryptoEngine = cryptoEngine
        self.accessGroup = accessGroup
    }

                    public func checkStatus() throws -> ResetContainerStatus {

                let keychainItemStatus = try status(for: .resetContainer)

        guard keychainItemStatus != .notFound else {
            return .notAvailable
        }

        return .available
    }

                    public func get() throws -> ResetContainer {

        let keychainData = try retrieve(.resetContainer)
        guard let masterPassword = keychainData[ResetContainerKeychainManagerImpl.keychainMasterPasswordKey] as? String else {
                throw KeychainError.decryptionFailure
        }
        return ResetContainer(masterPassword: masterPassword)
    }

                        @discardableResult
    public func store(_ masterPassword: MasterPassword, accessMode: KeychainAccessMode = .afterBiometricAuthentication) throws -> ResetContainer {

        let data: [String : Any] = [ResetContainerKeychainManagerImpl.keychainMasterPasswordKey: masterPassword]
        try store(data, for: .resetContainer, accessMode: accessMode)
        return ResetContainer(masterPassword: masterPassword)
    }

        public func remove() throws {
        try removeKeychainData(for: .resetContainer)
    }

}
