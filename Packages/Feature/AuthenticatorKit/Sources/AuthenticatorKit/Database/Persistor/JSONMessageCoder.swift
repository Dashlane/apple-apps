import DashTypes
import Foundation

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
    let encryptedData = try engine.encrypt(dataJSON)

    return encryptedData
  }

  public func decode<T>(_ data: Data) throws -> T where T: Decodable {
    guard !data.isEmpty else {
      throw JSONMessageCoderError.noData
    }

    let decryptedData = try engine.decrypt(data)
    let decoded = try JSONDecoder().decode(T.self, from: decryptedData)
    return decoded
  }
}
