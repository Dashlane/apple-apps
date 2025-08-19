import CoreTypes
import Foundation
import LogFoundation

public protocol IPCMessageCoderProtocol {
  func encode<T: Encodable>(_ message: T) throws -> Data
  func decode<T: Decodable>(_ data: Data) throws -> T
}

@Loggable
public enum IPCMessageCoderError: Error {
  case noData
}
