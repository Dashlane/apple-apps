import DashTypes
import Foundation

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
    return try engine.encrypt(dataJSON)
  }

  public func decode<T>(_ data: Data) throws -> T where T: Decodable {
    guard !data.isEmpty else {
      throw IPCMessageCoderError.noData
    }

    let decryptedData = try engine.decrypt(data)
    let decoded = try decoder.decode(T.self, from: decryptedData)
    return decoded
  }
}
