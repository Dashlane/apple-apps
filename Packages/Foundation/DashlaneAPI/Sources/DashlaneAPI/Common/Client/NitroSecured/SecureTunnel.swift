import Foundation

public protocol SecureTunnel: SecureTunnelSender & SecureTunnelReceiver {
  var header: String { get }
}

public protocol SecureTunnelSender: Sendable {
  func push<T>(_ value: T) throws -> Data where T: Encodable
}

public protocol SecureTunnelReceiver: Sendable {
  func pull<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}
