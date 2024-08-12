import Foundation

public typealias Nonce = [UInt8]

public protocol DeviceTransferSecretBox: Sendable {
  func seal<T: Encodable>(_ data: T, nonce: Nonce?) throws -> (Base64EncodedString, Nonce)
  func open<T: Decodable>(
    _ type: T.Type, from text: Base64EncodedString, nonce: DashTypes.Base64EncodedString
  ) throws -> T
}

public struct DeviceTransferSecretBoxMock: DeviceTransferSecretBox {
  public func seal<T>(_ data: T, nonce: Nonce?) throws -> (Base64EncodedString, Nonce)
  where T: Encodable {
    return ("", Data().bytes)
  }

  public func open<T>(_ type: T.Type, from text: Base64EncodedString, nonce: Base64EncodedString)
    throws -> T where T: Decodable
  {
    return try JSONDecoder().decode(T.self, from: Data())
  }
}

extension DeviceTransferSecretBox where Self == DeviceTransferSecretBoxMock {
  public static func mock() -> DeviceTransferSecretBoxMock {
    return DeviceTransferSecretBoxMock()
  }
}
