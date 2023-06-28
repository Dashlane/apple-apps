import Foundation
import DashTypes
import DashlaneCrypto

public protocol JSONMessageCoderProtocol {
    func encode<T: Encodable>(_ message: T) throws -> Data
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public enum JSONMessageCoderError: Error {
    case cannotDecryptData
    case cannotEncryptData
    case noData
}

public struct JSONMessageCoder: JSONMessageCoderProtocol {

    let logger: Logger
    let engine: CryptoEngine

    public init(logger: Logger, engine: CryptoEngine) {
        self.logger = logger
        self.engine = engine
    }

    public func encode<T>(_ message: T) throws -> Data where T: Encodable {
        let dataJSON = try JSONEncoder().encode(message)
        guard let encryptedData = engine.encrypt(data: dataJSON) else {
            throw JSONMessageCoderError.cannotEncryptData
        }
        return encryptedData
    }

    public func decode<T>(_ data: Data) throws -> T where T: Decodable {
        guard !data.isEmpty else {
            throw JSONMessageCoderError.noData
        }
        guard let decryptedData = engine.decrypt(data: data) else {
            logger.error("Could not decrypt data")
            throw JSONMessageCoderError.cannotDecryptData
        }
        let decoded = try JSONDecoder().decode(T.self, from: decryptedData)
        return decoded
    }
}
