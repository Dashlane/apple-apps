import Foundation
import DashTypes

public protocol IPCMessageCoderProtocol {
    func encode<T: Encodable>(_ message: T) throws -> Data
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public enum IPCMessageCoderError: Error {
    case cannotDecryptData
    case cannotEncryptData
    case noData
}
