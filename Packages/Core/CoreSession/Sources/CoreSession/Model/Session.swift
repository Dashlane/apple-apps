import CoreTypes
import Foundation

public struct Session: Hashable, Sendable {
  public let configuration: SessionConfiguration
  public let directory: SessionDirectory

  public let localKey: Data

  public let cryptoEngine: SessionCryptoEngine

  public let localCryptoEngine: CryptoEngine

  public let remoteCryptoEngine: CryptoEngine

  public var login: Login {
    return configuration.login
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(login)
  }

  public init(
    configuration: SessionConfiguration,
    localKey: Data,
    directory: SessionDirectory,
    cryptoEngine: SessionCryptoEngine,
    localCryptoEngine: CryptoEngine,
    remoteCryptoEngine: CryptoEngine
  ) {
    self.configuration = configuration
    self.localKey = localKey
    self.directory = directory
    self.cryptoEngine = cryptoEngine
    self.localCryptoEngine = localCryptoEngine
    self.remoteCryptoEngine = remoteCryptoEngine
  }

  public static func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.configuration == rhs.configuration
  }

}

extension Session {
  public static var mock: Session {
    .init(
      configuration: SessionConfiguration.mock(accountType: .masterPassword),
      localKey: Data(),
      directory: .init(url: URL(fileURLWithPath: "")),
      cryptoEngine: .mock(),
      localCryptoEngine: .mock(),
      remoteCryptoEngine: .mock())
  }

  public static func mock(accountType: AccountType = .masterPassword) -> Session {
    .init(
      configuration: SessionConfiguration.mock(accountType: accountType),
      localKey: Data(),
      directory: .init(url: URL(fileURLWithPath: "")),
      cryptoEngine: .mock(),
      localCryptoEngine: .mock(),
      remoteCryptoEngine: .mock())
  }
}
