import Foundation

public protocol SecureTunnel: Sender & Receiver {}

public protocol Sender: Sendable {
  func push<T>(_ value: T) throws -> Data where T: Encodable
}

public protocol Receiver: Sendable {
  func pull<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}
