import UIKit
import Combine
import CoreSession
import DashTypes
import DashlaneAppKit
import CoreKeychain
import CoreSettings
import LoginKit
import CoreFeature

class LockService: Mockable {
    let session: Session
    let settings: UserLockSettings
    public let secureLockProvider: SecureLockProvider
    public let secureLockConfigurator: SecureLockConfigurator
    public let locker: ApplicationLocker
    let biometricSetUpdatesService: BiometricSetUpdatesService

    init(session: Session,
         appSettings: AppSettings,
         settings: LocalSettingsStore,
         teamSpaceService: TeamSpacesService,
         featureService: FeatureServiceProtocol,
         keychainService: AuthenticationKeychainService,
         resetMasterPasswordService: ResetMasterPasswordService,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         logger: Logger) {
        self.session = session
        self.settings = settings.keyed(by: UserLockSettingsKey.self)
        secureLockConfigurator = SecureLockConfigurator(session: session,
                                                        keychainService: keychainService,
                                                        settings: self.settings)

        biometricSetUpdatesService = BiometricSetUpdatesService(session: session,
                                                                settings: self.settings,
                                                                keychainService: keychainService,
                                                                featureService: featureService,
                                                                configurator: secureLockConfigurator,
                                                                teamSpaceService: teamSpaceService,
                                                                resetMasterPasswordService: resetMasterPasswordService)

        secureLockProvider = SecureLockProvider(login: session.login,
                                                settings: settings,
                                                keychainService: keychainService)

        #if targetEnvironment(macCatalyst)
                locker = .automaticLogout(SessionInactivityAutomaticLogout(teamSpaceService: teamSpaceService, sessionLifeCycleHandler: sessionLifeCycleHandler))
        #else
        locker = .screenLock(ScreenLocker(masterKey: session.authenticationMethod.sessionKey,
                                          secureLockProvider: secureLockProvider,
                                          settings: settings,
                                          teamSpaceService: teamSpaceService,
                                          logger: logger,
                                          login: session.login))
        #endif
    }

}

extension LockService {
    public func secureLockMode() -> SecureLockMode {
        secureLockProvider.secureLockMode()
    }

    public func secureLockModePublisher() -> AnyPublisher<SecureLockMode, Never> {
        settings.settingsChangePublisher(key: .biometric)
            .merge(with: settings.settingsChangePublisher(key: .pinCode))
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .map { [weak self] _ in
                return self?.secureLockProvider.secureLockMode()
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
