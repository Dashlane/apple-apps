import Foundation

public protocol ConfigurableCryptoEngine: AnyObject, CryptoEngine {
  var config: CryptoRawConfig { get }
  var displayedKeyDerivationInfo: String { get }

  func update(to config: CryptoRawConfig) throws
}

public class ConfigurableCryptoEngineMock: ConfigurableCryptoEngine, @unchecked Sendable {
  let engine: CryptoEngine

  public var config: CryptoRawConfig
  public var displayedKeyDerivationInfo: String { return "" }

  public init(
    mode: MockCryptoEngine.OperationMode = .reverseEncrypt,
    config: CryptoRawConfig = .init(fixedSalt: nil, marker: "mock")
  ) {
    self.engine = .mock(mode)
    self.config = config
  }

  public func update(to config: CryptoRawConfig) throws {
    self.config = config
  }

  public func encrypt(_ data: Data) throws -> Data {
    return try engine.encrypt(data)
  }

  public func decrypt(_ data: Data) throws -> Data {
    return try engine.decrypt(data)
  }
}

extension ConfigurableCryptoEngine where Self == ConfigurableCryptoEngineMock {
  public static func mock(
    mode: MockCryptoEngine.OperationMode = .reverseEncrypt,
    config: CryptoRawConfig = .init(fixedSalt: nil, marker: "mock")
  ) -> ConfigurableCryptoEngine {
    return ConfigurableCryptoEngineMock(mode: mode, config: config)
  }
}
