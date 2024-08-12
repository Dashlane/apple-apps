import DashlaneAPI
import Foundation
import Sodium

public struct NitroSecureTunnel: SecureTunnel {
  enum NitroError: Error {
    case couldNotEncrypt
    case couldNotDecrypt
  }

  let pushStream: SecretStream.XChaCha20Poly1305.PushStream
  let pullStream: SecretStream.XChaCha20Poly1305.PullStream

  public var header: String {
    Data(pushStream.header()).hexadecimalString
  }

  public func pull<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
    guard let (decrypted, _) = pullStream.pull(cipherText: [UInt8](data)) else {
      throw NitroError.couldNotDecrypt
    }
    let jsond = try JSONDecoder().decode(T.self, from: Data(decrypted))
    return jsond
  }

  public func push<T>(_ value: T) throws -> Data where T: Encodable {
    let jsondata = try JSONEncoder().encode(value)
    guard let encrypted = pushStream.push(message: [UInt8](jsondata)) else {
      throw NitroError.couldNotEncrypt
    }
    return Data(encrypted)
  }
}
