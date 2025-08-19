import CoreTypes

public protocol AccountCreationSettingsProvider: Sendable {
  func initialSettings(
    using cryptoConfig: CryptoRawConfig, remoteCryptoEngine: CryptoEngine, login: Login
  ) throws -> CoreSessionSettings
}

struct FakeAccountCreationSettingsProvider: AccountCreationSettingsProvider {
  func initialSettings(
    using cryptoConfig: CoreTypes.CryptoRawConfig, remoteCryptoEngine: any CoreTypes.CryptoEngine,
    login: CoreTypes.Login
  ) throws -> CoreSessionSettings {
    return CoreSessionSettings(content: "", time: Int(Timestamp.now.rawValue))
  }
}

extension AccountCreationSettingsProvider where Self == FakeAccountCreationSettingsProvider {
  static var mock: FakeAccountCreationSettingsProvider { .init() }
}
