import Foundation

public protocol EncryptEngine: Sendable {
  func encrypt(_ data: Data) throws -> Data
}

public protocol DecryptEngine: Sendable {
  func decrypt(_ data: Data) throws -> Data
}

public protocol CryptoEngine: EncryptEngine, DecryptEngine {}

extension Data {
  public func decrypt(using cryptoEngine: DecryptEngine) throws -> Data {
    return try cryptoEngine.decrypt(self)
  }

  public func encrypt(using cryptoEngine: EncryptEngine) throws -> Data {
    return try cryptoEngine.encrypt(self)
  }
}

public enum EncryptionSecret: Equatable, Sendable {
  case key(Data)
  case password(String)
}

extension EncryptionSecret {
  public var isPassword: Bool {
    switch self {
    case .key:
      return false
    case .password:
      return true
    }
  }
}

public struct MockCryptoEngine: CryptoEngine, @unchecked Sendable {
  public enum OperationMode {
    case passthrough
    case reverseEncrypt
    case failure(Error)

    func transform(_ data: Data) throws -> Data {
      switch self {
      case .passthrough:
        return data
      case .reverseEncrypt:
        return Data(data.reversed())
      case .failure(let erorr):
        throw erorr
      }
    }
  }

  let mode: OperationMode

  public init(mode: OperationMode = .reverseEncrypt) {
    self.mode = mode
  }

  public func encrypt(_ data: Data) throws -> Data {
    return try mode.transform(data)
  }

  public func decrypt(_ data: Data) throws -> Data {
    return try mode.transform(data)
  }
}

extension CryptoEngine where Self == MockCryptoEngine {
  public static func mock(_ mode: MockCryptoEngine.OperationMode = .reverseEncrypt)
    -> MockCryptoEngine
  {
    return MockCryptoEngine(mode: mode)
  }
}
