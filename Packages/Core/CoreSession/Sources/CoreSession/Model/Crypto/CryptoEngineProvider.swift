import Foundation
import DashTypes

public protocol CryptoEngineProvider {
        func makeLocalKey() -> Data

    func sessionCryptoEngine(for setting: CryptoRawConfig, masterKey: MasterKey) throws -> SessionCryptoEngine
    func sessionCryptoEngine(forEncryptedPayload payload: Data, masterKey: MasterKey) throws -> SessionCryptoEngine
    func defaultCryptoRawConfig(for masterKey: MasterKey) -> CryptoRawConfig

        func cryptoEngine(for key: Data) throws -> CryptoEngine
}

public extension CryptoEngineProvider {
    func sessionCryptoEngine(for masterKey: MasterKey) throws -> SessionCryptoEngine {
        try self.sessionCryptoEngine(for: defaultCryptoRawConfig(for: masterKey), masterKey: masterKey)
    }

}
