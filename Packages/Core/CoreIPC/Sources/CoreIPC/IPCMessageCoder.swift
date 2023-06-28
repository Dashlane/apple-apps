import Foundation
import DashTypes

public struct IPCMessageCoder: IPCMessageCoderProtocol {

    let logger: Logger
    let engine: CryptoEngine

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(logger: Logger, engine: CryptoEngine) {
        self.logger = logger
        self.engine = engine
    }

    public func encode<T>(_ message: T) throws -> Data where T: Encodable {
        let dataJSON = try encoder.encode(message)
        guard let encryptedData = engine.encrypt(data: dataJSON) else {
            throw IPCMessageCoderError.cannotEncryptData
        }
        return encryptedData
    }

    public func decode<T>(_ data: Data) throws -> T where T: Decodable {
        guard !data.isEmpty else {
            throw IPCMessageCoderError.noData
        }
        guard let decryptedData = engine.decrypt(data: data) else {
            logger.error("Could not decrypt data")
            throw IPCMessageCoderError.cannotDecryptData
        }
        let decoded = try decoder.decode(T.self, from: decryptedData)
        return decoded
    }
}
