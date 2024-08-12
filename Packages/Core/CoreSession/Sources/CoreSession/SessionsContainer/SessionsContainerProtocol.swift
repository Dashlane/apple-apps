import DashTypes
import Foundation

public protocol SessionsContainerProtocol {
  func fetchCurrentLogin() throws -> Login?

  func saveCurrentLogin(_ login: Login?) throws

  func createSession(with configuration: SessionConfiguration, cryptoConfig: CryptoRawConfig) throws
    -> Session

  func loadSession(for info: LoadSessionInformation) throws -> Session

  func update(_ cryptoConfig: CryptoRawConfig, for session: Session) throws

  func sessionDirectory(for login: Login) throws -> SessionDirectory

  func removeSessionDirectory(for login: Login) throws

  func info(for login: Login) throws -> SessionInfo

  func prepareMigration(
    of currentSession: Session,
    to newConfiguration: SessionConfiguration,
    cryptoConfig: CryptoRawConfig
  ) throws -> MigratingSession

  func prepareMigration(
    of currentSession: Session,
    to newMasterKey: MasterKey,
    remoteKey: Data?,
    cryptoConfig: CryptoRawConfig,
    accountMigrationType: AccountMigrationType,
    loginOTPOption: ThirdPartyOTPOption?
  ) throws -> MigratingSession

  func finalizeMigration(using migrateSession: MigratingSession) throws -> Session

  func update(_ session: Session, with analyticsId: AnalyticsIdentifiers) throws -> Session

  func localMigration(of session: Session, ssoKey: Data, remoteKey: Data, config: CryptoRawConfig)
    throws -> Session

  func localAccountsInfo() throws -> [(Login, SessionInfo?)]
}

public struct MigratingSession {
  public struct Target {
    public let configuration: SessionConfiguration
    public let cryptoConfig: CryptoRawConfig
    public let sessionCryptoEngine: CryptoEngine
    public let remoteCryptoEngine: CryptoEngine
  }
  public let source: Session
  public let target: Target
}

extension MigratingSession.Target {
  public func encryptedRemoteKey() throws -> Data? {
    return try configuration.keys.remoteKey?.encrypt(using: sessionCryptoEngine)
  }
}
