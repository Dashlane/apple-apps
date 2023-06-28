import Foundation
import DashTypes

public enum SessionsContainerError: Error, Equatable {
    case cannotDecypherLocalKey
    case invalidURL(_ reason: String)
}

#warning("TODO: Internal dispatch")
public struct SessionsContainer<StoreProvider: SessionStoreProviderProtocol>: SessionsContainerProtocol {

    internal var fileManager: FileManager
    public let baseURL: URL
    private let cryptoEngineProvider: CryptoEngineProvider
    private let sessionStoreProvider: StoreProvider

    public init(baseURL: URL,
                cryptoEngineProvider: CryptoEngineProvider,
                sessionStoreProvider: StoreProvider) throws {
        guard baseURL.isFileURL else { throw SessionsContainerError.invalidURL("Session URL needs to be local") }

        self.baseURL = baseURL
        self.fileManager = FileManager.default
        self.cryptoEngineProvider = cryptoEngineProvider
        self.sessionStoreProvider = sessionStoreProvider
    }

            public func fetchCurrentLogin() throws -> Login? {
        try sessionStoreProvider.currentLoginStore(forContainerURL: baseURL).load()
    }

        public func saveCurrentLogin(_ login: Login?) throws {
        try sessionStoreProvider.currentLoginStore(forContainerURL: baseURL).save(login)
    }

            private func writeSession(with configuration: SessionConfiguration, localKey: Data, cryptoConfig: CryptoRawConfig) throws -> Session {
        let login = configuration.login
        let cryptoEngine = try cryptoEngineProvider.sessionCryptoEngine(for: cryptoConfig, masterKey: configuration.masterKey)
        let encryptedLocalKey = try localKey.encrypt(using: cryptoEngine)

        let localCryptoEngine = try cryptoEngineProvider.cryptoEngine(for: localKey)
        let remoteCryptoEngine = try configuration.keys.remoteKey.map(cryptoEngineProvider.cryptoEngine) ?? cryptoEngine

        var directory = try SessionDirectory(baseURL: baseURL, login: login)
        if !directory.exists {
            try directory.create()
        }

        let session = Session(configuration: configuration,
                              localKey: localKey,
                              directory: directory,
                              cryptoEngine: cryptoEngine,
                              localCryptoEngine: localCryptoEngine,
                              remoteCryptoEngine: remoteCryptoEngine)

        try sessionStoreProvider.encryptedLocalKeyStore(for: login, info: configuration.info, directory: directory).save(encryptedLocalKey)
        try sessionStoreProvider.infoStore(for: login, directory: directory)
            .save(configuration.info)
        try sessionStoreProvider.keysStore(for: login, directory: directory, using: .init(session: cryptoEngine, local: localCryptoEngine), info: configuration.info).save(configuration.keys)

        return session
    }

    public func createSession(with configuration: SessionConfiguration, cryptoConfig: CryptoRawConfig) throws -> Session {
        let localKey = cryptoEngineProvider.makeLocalKey()
        return try writeSession(with: configuration, localKey: localKey, cryptoConfig: cryptoConfig)
    }

        public func update(_ cryptoConfig: CryptoRawConfig, for session: Session) throws {
        let localKey = session.localKey
        try session.cryptoEngine.update(to: cryptoConfig)
        let encryptedLocalKey = try localKey.encrypt(using: session.cryptoEngine)
        try sessionStoreProvider.encryptedLocalKeyStore(for: session.login, info: session.configuration.info, directory: session.directory).save(encryptedLocalKey)
    }

        public func info(for login: Login) throws -> SessionInfo {
        let directory = try SessionDirectory(baseURL: baseURL, login: login)
        return try sessionStoreProvider.infoStore(for: login, directory: directory).load()
    }

        public func loadSession(for loadInfo: LoadSessionInformation) throws -> Session {

                let login = loadInfo.login
        let directory = try sessionDirectory(for: login)
        let info = try sessionStoreProvider.infoStore(for: login, directory: directory).load()

        let encryptedLocalKey = try sessionStoreProvider.encryptedLocalKeyStore(for: login, info: info, directory: directory).load()
        let cryptoEngine = try cryptoEngineProvider.sessionCryptoEngine(forEncryptedPayload: encryptedLocalKey, masterKey: loadInfo.masterKey)

        guard let localKey = try? encryptedLocalKey.decrypt(using: cryptoEngine) else {
            throw SessionsContainerError.cannotDecypherLocalKey
        }

        let localCryptoEngine = try cryptoEngineProvider.cryptoEngine(for: localKey)
        let keys = try sessionStoreProvider.keysStore(for: login, directory: directory, using: .init(session: cryptoEngine, local: localCryptoEngine), info: info).load()

        let remoteCryptoEngine = try keys.remoteKey.map(cryptoEngineProvider.cryptoEngine) ?? cryptoEngine

        let configuration = SessionConfiguration(login: login,
                                                 masterKey: loadInfo.masterKey,
                                                 keys: keys,
                                                 info: info)
        return Session(configuration: configuration,
                                  localKey: localKey,
                                  directory: try sessionDirectory(for: login),
                                  cryptoEngine: cryptoEngine,
                                  localCryptoEngine: localCryptoEngine,
                                  remoteCryptoEngine: remoteCryptoEngine)

    }

        public func removeSessionDirectory(for login: Login) throws {
        guard let directory = try? sessionDirectory(for: login) else {
            return
        }
        try directory.remove()
    }
}

extension SessionsContainer {
    public func prepareMigration(of currentSession: Session,
                                 to newMasterKey: MasterKey,
                                 remoteKey: Data?,
                                 cryptoConfig: CryptoRawConfig,
                                 accountMigrationType: AccountMigrationType,
                                 loginOTPOption: ThirdPartyOTPOption?) throws -> MigratingSession {
        let newKeys = SessionSecureKeys(serverAuthentication: currentSession.configuration.keys.serverAuthentication, remoteKey: remoteKey, analyticsIds: currentSession.configuration.keys.analyticsIds)
        let newConfiguration = SessionConfiguration(login: currentSession.login,
                                                    masterKey: newMasterKey,
                                                    keys: newKeys, 
                                                    info: SessionInfo(deviceAccessKey: currentSession.configuration.info.deviceAccessKey,
                                                                      loginOTPOption: loginOTPOption,
                                                                      accountType: accountMigrationType == .masterPasswordToSSO ? .sso : .masterPassword))
        return try prepareMigration(of: currentSession, to: newConfiguration, cryptoConfig: cryptoConfig)
    }

    public func prepareMigration(of currentSession: Session,
                                 to newConfiguration: SessionConfiguration,
                                 cryptoConfig: CryptoRawConfig) throws -> MigratingSession {
        let cryptoEngine = try cryptoEngineProvider.sessionCryptoEngine(for: cryptoConfig, masterKey: newConfiguration.masterKey)
        let remoteCryptoEngine = try newConfiguration.keys.remoteKey.map(cryptoEngineProvider.cryptoEngine) ?? cryptoEngine

        return MigratingSession(source: currentSession,
                                target: .init(configuration: newConfiguration,
                                              cryptoConfig: cryptoConfig,
                                              sessionCryptoEngine: cryptoEngine,
                                              remoteCryptoEngine: remoteCryptoEngine))
    }

    public func finalizeMigration(using migrationSession: MigratingSession) throws -> Session {
        let newSession = try writeSession(with: migrationSession.target.configuration, localKey: migrationSession.source.localKey, cryptoConfig: migrationSession.target.cryptoConfig)

        if migrationSession.source.configuration == newSession.configuration { 
            try migrationSession.source.cryptoEngine.update(to: migrationSession.target.cryptoConfig)
        }

        return newSession
    }

    public func localMigration(of session: Session, ssoKey: Data, remoteKey: Data, config: CryptoRawConfig) throws -> Session {
        let keys = SessionSecureKeys(serverAuthentication: session.configuration.keys.serverAuthentication,
                                     remoteKey: remoteKey,
                                     analyticsIds: session.configuration.keys.analyticsIds)

        let sessionConfiguration = SessionConfiguration(login: session.login, masterKey: .ssoKey(ssoKey), keys: keys, info: session.configuration.info)

        return try writeSession(with: sessionConfiguration, localKey: session.localKey, cryptoConfig: config)
    }

    public func update(_ session: Session, with analyticsId: AnalyticsIdentifiers) throws -> Session {
        var configuration = session.configuration
        configuration.keys.analyticsIds = analyticsId
        try sessionStoreProvider.keysStore(for: session.login,
                                      directory: session.directory,
                                      using: .init(session: session.cryptoEngine,
                                                   local: session.localCryptoEngine),
                                      info: configuration.info).save(configuration.keys)

        return Session(configuration: configuration,
                       localKey: session.localKey,
                       directory: session.directory,
                       cryptoEngine: session.cryptoEngine,
                       localCryptoEngine: session.localCryptoEngine,
                       remoteCryptoEngine: session.remoteCryptoEngine)
    }

        public func localAccountsInfo() throws -> [(Login, SessionInfo?)] {
        let directoryContents = try FileManager.default.contentsOfDirectory(
            at: baseURL,
            includingPropertiesForKeys: nil
        )

        var localAccounts: [(Login, SessionInfo?)] = []
        for url in directoryContents {
            let encodedLogin = url.deletingPathExtension().lastPathComponent
            if let decodedData = Data(hexadecimalString: encodedLogin),
               let email = String(data: decodedData, encoding: .utf8),
                !email.isEmpty {
                let sessionInfo = try? info(for: .init(email))
                localAccounts.append((Login(email), sessionInfo))
            }
        }

        return localAccounts
    }
}

extension SessionsContainer {
        public func sessionDirectory(for login: Login) throws -> SessionDirectory {
        return try baseURL.sessionDirectoryIfExists(for: login)
    }
}

extension URL {
        public func sessionDirectoryIfExists(for login: Login) throws -> SessionDirectory {
        let directory = try SessionDirectory(baseURL: self, login: login)
        guard directory.exists else {
            throw URLError(.cannotOpenFile)
        }
        return directory
    }
}

extension SessionsContainer {
    public static var mock: SessionsContainerProtocol {
        FakeSessionsContainer()
    }
}
