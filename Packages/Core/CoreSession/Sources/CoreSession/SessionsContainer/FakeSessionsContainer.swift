import CoreTypes
import Foundation

public final class FakeSessionsContainer: SessionsContainerProtocol, @unchecked Sendable {

  enum FakeError: Error {
    case notMocked
  }

  public init() {}

  var currentLogin: Login?
  var createSession: Result<Session, Error> = .failure(FakeError.notMocked)
  var directory: Result<SessionDirectory, Error> = .failure(FakeError.notMocked)
  var infoForSession: Result<SessionInfo, Error> = .failure(FakeError.notMocked)
  var loadSession: Result<Session, Error> = .failure(FakeError.notMocked)
  var migrateSession: Result<MigratingSession, Error> = .failure(FakeError.notMocked)
  var finalizeMigrationSession: Result<Session, Error> = .failure(FakeError.notMocked)
  var changeLoginSession: Result<Session, Error> = .failure(FakeError.notMocked)

  var removeSessionDirectoryBlock: (Login) -> Void = { _ in }

  public func fetchCurrentLogin() throws -> Login? {
    return currentLogin
  }

  public func saveCurrentLogin(_ login: Login?) throws {
    currentLogin = login
  }

  public func createSession(with configuration: SessionConfiguration, cryptoConfig: CryptoRawConfig)
    throws -> Session
  {
    try createSession.get()
  }

  public func loadSession(for info: LoadSessionInformation) throws -> Session {
    try loadSession.get()
  }

  public func update(_ cryptoConfig: CryptoRawConfig, for session: Session) throws {

  }

  public func sessionDirectory(for login: Login) throws -> SessionDirectory {
    return try directory.get()
  }

  public func removeSessionDirectory(for login: Login) throws {
    removeSessionDirectoryBlock(login)
  }

  public func info(for login: Login) throws -> SessionInfo {
    try infoForSession.get()
  }

  public func prepareMigration(
    of currentSession: Session,
    to newConfiguration: SessionConfiguration,
    cryptoConfig: CryptoRawConfig
  ) throws -> MigratingSession {
    try migrateSession.get()
  }

  public func prepareMigration(
    of currentSession: Session,
    to newMasterKey: MasterKey,
    remoteKey: Data?,
    cryptoConfig: CryptoRawConfig,
    loginOTPOption: ThirdPartyOTPOption?
  ) throws -> MigratingSession {
    try migrateSession.get()
  }

  public func finalizeMigration(using migrateSession: MigratingSession) throws -> Session {
    try finalizeMigrationSession.get()
  }

  public func update(_ session: Session, with analyticsId: AnalyticsIdentifiers) throws -> Session {
    try changeLoginSession.get()
  }

  public func localMigration(
    of session: Session, ssoKey: Data, remoteKey: Data, config: CryptoRawConfig
  ) throws -> Session {
    return session
  }

  public func localAccountsInfo() throws -> [(Login, SessionInfo?)] {
    if let currentLogin = currentLogin {
      let sessionInfo = try info(for: currentLogin)
      return [(currentLogin, sessionInfo)]
    }
    return []
  }

  public func update(_ session: Session, to login: CoreTypes.Login) throws -> Session {
    return Session(
      configuration: SessionConfiguration(
        login: login,
        masterKey: session.configuration.masterKey,
        keys: session.configuration.keys,
        info: session.configuration.info),
      localKey: session.localKey,
      directory: session.directory,
      cryptoEngine: session.cryptoEngine,
      localCryptoEngine: session.localCryptoEngine,
      remoteCryptoEngine: session.remoteCryptoEngine)
  }
}

extension SessionsContainerProtocol where Self == FakeSessionsContainer {
  public static var mock: Self { .init() }
}
