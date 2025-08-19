import Combine
import CoreFeature
import CoreKeychain
import CorePremium
import CoreSession
import CoreSettings
import CoreTypes
import LogFoundation
import LoginKit
import UIKit

public protocol LockServiceProtocol {
  var secureLockProvider: SecureLockProvider { get }
  var secureLockConfigurator: SecureLockConfigurator { get }
  var locker: ApplicationLocker { get }
  func secureLockMode() -> SecureLockMode
  func secureLockModePublisher() -> AnyPublisher<SecureLockMode, Never>
}

class LockService: LockServiceProtocol {
  let session: Session
  let settings: UserLockSettings
  public let secureLockProvider: SecureLockProvider
  public let secureLockConfigurator: SecureLockConfigurator
  public let locker: ApplicationLocker
  let biometricSetUpdatesService: BiometricSetUpdatesService

  init(
    session: Session,
    appSettings: AppSettings,
    settings: LocalSettingsStore,
    userSpacesService: UserSpacesService,
    featureService: FeatureServiceProtocol,
    keychainService: AuthenticationKeychainServiceProtocol,
    deeplinkService: DeepLinkingServiceProtocol,
    resetMasterPasswordService: ResetMasterPasswordService,
    sessionLifeCycleHandler: SessionLifeCycleHandler?,
    logger: Logger
  ) {
    self.session = session
    self.settings = settings.keyed(by: UserLockSettingsKey.self)
    secureLockConfigurator = SecureLockConfigurator(
      session: session,
      keychainService: keychainService,
      settings: self.settings)

    biometricSetUpdatesService = BiometricSetUpdatesService(
      session: session,
      settings: self.settings,
      keychainService: keychainService,
      featureService: featureService,
      configurator: secureLockConfigurator,
      resetMasterPasswordService: resetMasterPasswordService)

    secureLockProvider = SecureLockProvider(
      login: session.login,
      settings: settings,
      keychainService: keychainService)

    #if targetEnvironment(macCatalyst)
      locker = .automaticLogout(
        SessionInactivityAutomaticLogout(
          userSpacesService: userSpacesService, sessionLifeCycleHandler: sessionLifeCycleHandler))
    #else
      locker = .screenLock(
        ScreenLocker(
          masterKey: session.authenticationMethod.sessionKey,
          secureLockProvider: secureLockProvider,
          settings: settings,
          userSpacesService: userSpacesService,
          deeplinkService: deeplinkService,
          logger: logger,
          session: session))
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

extension LockServiceProtocol where Self == LockServiceMock {
  static var mock: LockServiceProtocol {
    LockServiceMock()
  }
}
