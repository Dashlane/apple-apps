import SwiftUI
import Combine
import CoreKeychain
import CoreUserTracking
import DashlaneAppKit
import SwiftTreats
import LoginKit
import CoreSettings
import DashTypes
import DashlaneAPI
import CoreSession
import CorePersonalData

typealias ChangeMasterPasswordLauncher = () -> Void

@MainActor
class LockViewModel: ObservableObject, SessionServicesInjecting {
    enum Mode {
        case privacyShutter
        case masterPassword(MasterPasswordLocalViewModel)
        case biometry(BiometryViewModel)
        case pinCode(LockPinCodeAndBiometryViewModel)
        case sso(Login)
        case passwordLessRecovery(recoverFromFailure: Bool)
    }

    @Published
    var lock: ScreenLocker.Lock?

    @Published
    var mode: Mode = .privacyShutter

    @Published
    var newMasterPassword: String?

    private let session: Session
    private let locker: ScreenLocker
    private let keychainService: AuthenticationKeychainService
    private let userSettings: UserSettings
    private let resetMasterPasswordService: ResetMasterPasswordService
    private let pinCodeAttempts: PinCodeAttempts
    private let teamspaceService: TeamSpacesService
    private let loginMetricsReporter: LoginMetricsReporterProtocol
    private let lockService: LockServiceProtocol
    private weak var sessionLifeCycleHandler: SessionLifeCycleHandler?
    private var subscriptions: Set<AnyCancellable> = .init()
    private var initialBiometry: Biometry?
    private let appAPIClient: AppAPIClient
    private let loginKitServices: LoginKitServicesContainer
    private let accountType: AccountType
    private let appservices: AppServicesContainer
    private let syncService: SyncServiceProtocol
    private let sessionCryptoUpdater: SessionCryptoUpdater
    private let userDeviceAPIClient: UserDeviceAPIClient
    private let syncedSettings: SyncedSettingsService
    private let databaseDriver: DatabaseDriver
    private let logger: Logger
    private let postARKChangeMasterPasswordViewModelFactory: PostARKChangeMasterPasswordViewModel.Factory
    var changeMasterPasswordLauncher: ChangeMasterPasswordLauncher

    var canAutomaticallyPromptQuickLoginScreen: Bool
    private let activityReporter: ActivityReporterProtocol

        lazy var mainAuthenticationMode: Definition.Mode = teamspaceService.isSSOUser ? .sso : .masterPassword

    init(locker: ScreenLocker,
         session: Session,
         appServices: AppServicesContainer,
         appAPIClient: AppAPIClient,
         userDeviceAPIClient: UserDeviceAPIClient,
         keychainService: AuthenticationKeychainService,
         userSettings: UserSettings,
         resetMasterPasswordService: ResetMasterPasswordService,
         activityReporter: ActivityReporterProtocol,
         teamspaceService: TeamSpacesService,
         loginMetricsReporter: LoginMetricsReporterProtocol,
         lockService: LockServiceProtocol,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         syncService: SyncServiceProtocol,
         sessionCryptoUpdater: SessionCryptoUpdater,
         syncedSettings: SyncedSettingsService,
         databaseDriver: DatabaseDriver,
         logger: Logger,
         newMasterPassword: String? = nil,
         changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher,
         postARKChangeMasterPasswordViewModelFactory: PostARKChangeMasterPasswordViewModel.Factory) {
        self.session = session
        self.locker = locker
        self.accountType = session.configuration.info.accountType
        self.keychainService = keychainService
        self.userSettings = userSettings
        self.resetMasterPasswordService = resetMasterPasswordService
        self.changeMasterPasswordLauncher = changeMasterPasswordLauncher
        self.pinCodeAttempts = PinCodeAttempts(internalStore: userSettings.internalStore)
        self.teamspaceService = teamspaceService
        self.loginMetricsReporter = loginMetricsReporter
        self.lockService = lockService
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.activityReporter = activityReporter
        self.appAPIClient = appAPIClient
        self.syncService = syncService
        self.userDeviceAPIClient = userDeviceAPIClient
        self.syncedSettings = syncedSettings
        self.databaseDriver = databaseDriver
        self.appservices = appServices
        self.sessionCryptoUpdater = sessionCryptoUpdater
        self.logger = logger
        self.newMasterPassword = newMasterPassword
        self.loginKitServices = appServices.makeLoginKitServicesContainer()
        self.postARKChangeMasterPasswordViewModelFactory = postARKChangeMasterPasswordViewModelFactory
                canAutomaticallyPromptQuickLoginScreen = !Device.isMac
        lock = locker.lock
        updateMode(with: lock)

        locker
            .$lock
            .filter { $0 != nil }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lock in
                guard let self = self else {
                    return
                }
                if self.lock != lock {
                    self.lock = lock
                    self.updateMode(with: lock)
                }
                self.initialBiometry = self.locker.lock?.biometry
            }
            .store(in: &subscriptions)
    }

    func updateMode(with lock: ScreenLocker.Lock?, recoverFromFailure: Bool = false) {
        switch lock {
        case .privacyShutter, .none:
            self.mode = .privacyShutter
        case let .secure(secureMode):
            switch secureMode {
            case .masterKey:
                switch accountType {
                case .masterPassword:
                    self.mode = .masterPassword(makeMasterPasswordViewModel())
                case .invisibleMasterPassword:
                    self.mode = .passwordLessRecovery(recoverFromFailure: recoverFromFailure)
                case .sso:
                    self.mode = .sso(locker.login)
                }
            case .biometry(let type):
                guard canShow(secureMode) else { return }
                self.mode = .biometry(makeBiometryViewModel(biometryType: type))
            case .pincode(let lock):
                guard canShow(secureMode) else { return }
                guard !lock.attempts.tooManyAttempts else { break }
                let model = makePincodeAndBiometryViewModel(lock: lock)
                self.mode = .pinCode(model)
            case .biometryAndPincode(let biometry, let lock):
                guard canShow(secureMode) else { return }
                guard !lock.attempts.tooManyAttempts else { break }
                let model = makePincodeAndBiometryViewModel(lock: lock, biometryType: biometry)
                self.mode = .pinCode(model)
            default:
                break
            }
        }
    }

                    func canShow(_ secureMode: SecureLockMode) -> Bool {
        guard canAutomaticallyPromptQuickLoginScreen || !secureMode.isBiometric else { return false }
        canAutomaticallyPromptQuickLoginScreen = false
        return true
    }

    func makeMasterPasswordViewModel() -> MasterPasswordLocalViewModel {
        loginKitServices.makeMasterPasswordLocalViewModel(
            login: locker.login,
            biometry: initialBiometry,
            authTicket: nil,
            unlocker: locker,
            context: .init(origin: .lock, localLoginContext: .passwordApp),
            resetMasterPasswordService: resetMasterPasswordService,
            userSettings: userSettings
        ) { [weak self] completionMode in
            guard let completionMode = completionMode else {
                self?.sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
                return
            }
            guard let self else { return }
            switch completionMode {
            case .biometry(let type):
                let mainAuthenticationMode = self.mainAuthenticationMode
                self.activityReporter.report(UserEvent.AskUseOtherAuthentication(next: .biometric,
                                                                                 previous: mainAuthenticationMode))
                DispatchQueue.main.async {
                    self.mode = .biometry(self.makeBiometryViewModel(biometryType: type))
                }
            case .authenticated:
                self.performUnlock(self.mainAuthenticationMode)
            case .masterPasswordReset:
                self.changeMasterPasswordLauncher()
            case let .accountRecovered(newMasterPassword):
                self.newMasterPassword = newMasterPassword
            }
        }
    }

    func makeBiometryViewModel(biometryType: Biometry) -> BiometryViewModel {
        loginKitServices.makeBiometryViewModel(login: locker.login,
                                               biometryType: biometryType,
                                               manualLockOrigin: true, 
                                               unlocker: locker,
                                               context: .init(origin: .lock, localLoginContext: .passwordApp),
                                               userSettings: userSettings) { [weak self] isSuccess in
            guard let self = self else { return }
            guard isSuccess else {
                let mainAuthenticationMode = self.mainAuthenticationMode
                self.activityReporter.report(UserEvent.AskUseOtherAuthentication(next: mainAuthenticationMode, previous: .biometric))
                self.lock = .secure(.masterKey)
                self.updateMode(with: self.lock)
                return
            }
            self.performUnlock(.biometric)
        }
    }

    func makePincodeAndBiometryViewModel(lock: SecureLockMode.PinCodeLock, biometryType: Biometry? = nil) -> LockPinCodeAndBiometryViewModel {
        LockPinCodeAndBiometryViewModel(login: locker.login,
                                        accountType: accountType,
                                        pinCodeLock: lock,
                                        biometryType: biometryType,
                                        context: .init(origin: .lock, localLoginContext: .passwordApp),
                                        unlocker: locker,
                                        loginMetricsReporter: loginMetricsReporter,
                                        activityReporter: activityReporter) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure, .cancel:
                let mainAuthenticationMode = self.mainAuthenticationMode
                self.activityReporter.report(UserEvent.AskUseOtherAuthentication(next: mainAuthenticationMode, previous: .pin))
                self.lock = .secure(.masterKey)
                self.updateMode(with: self.lock, recoverFromFailure: result == .failure)
                return
            default:
                self.performUnlock(.pin)
            }
        }
    }

    func makePasswordLessRecoveryViewModel(recoverFromFailure: Bool) -> PasswordLessRecoveryViewModel {
        PasswordLessRecoveryViewModel(login: locker.login,
                                      recoverFromFailure: recoverFromFailure) { completion in
            switch completion {
            case .logout:
                self.sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
            case .cancel:
                self.performUnlock(.pin)
            }
        }
    }

    func unlockWithSSO() {
        self.userSettings[.ssoAuthenticationRequested] = true
        self.sessionLifeCycleHandler?.logout(clearAutoLoginData: false)
    }

    private func performUnlock(_ mode: Definition.Mode) {
        activityReporter.logSuccessfulUnlock(mode)
        if let performanceLogInfo = loginMetricsReporter.getPerformanceLogInfo(.login) {
            activityReporter.report(performanceLogInfo.performanceUserEvent(for: .timeToUnlock))
        }
        loginMetricsReporter.resetTimer(.login)
        locker.unlock()
    }
}

fileprivate extension ScreenLocker.Lock {
    var secureLockMode: SecureLockMode? {
        guard case let ScreenLocker.Lock.secure(mode) = self else {
            return nil
        }
        return mode
    }

    var biometry: Biometry? {
        guard let secureLockMode = self.secureLockMode, case let SecureLockMode.biometry(biometry) = secureLockMode else {
            return nil
        }
        return biometry
    }
}

private extension ActivityReporterProtocol {
    func logSuccessfulUnlock(_ mode: Definition.Mode) {
        report(UserEvent.Login(isFirstLogin: false, mode: mode, status: .success))
    }
}

extension LockViewModel {
    func makePostARKChangeMasterPasswordViewModel(newMasterPassword: String) -> PostARKChangeMasterPasswordViewModel {
        let cryptoConfig = CryptoRawConfig.masterPasswordBasedDefault
        let currentMasterKey = session.authenticationMethod.sessionKey

        let migratingSession = try? appservices.sessionContainer.prepareMigration(of: session,
                                                                                  to: .masterPassword(newMasterPassword, serverKey: currentMasterKey.serverKey),
                                                                                  remoteKey: nil,
                                                                                  cryptoConfig: cryptoConfig,
                                                                                  accountMigrationType: .masterPasswordToMasterPassword,
                                                                                  loginOTPOption: session.configuration.info.loginOTPOption)

        let postCryptoChangeHandler = PostMasterKeyChangerHandler(keychainService: keychainService,
                                                                  resetMasterPasswordService: resetMasterPasswordService,
                                                                  syncService: syncService)

        let accountCryptoChangerService =  try? AccountCryptoChangerService(reportedType: .masterPasswordChange,
                                                                            migratingSession: migratingSession!,
                                                                            syncService: syncService,
                                                                            sessionCryptoUpdater: sessionCryptoUpdater,
                                                                            activityReporter: activityReporter,
                                                                            sessionsContainer: appservices.sessionContainer,
                                                                            databaseDriver: databaseDriver,
                                                                            postCryptoChangeHandler: postCryptoChangeHandler,
                                                                            apiNetworkingEngine: userDeviceAPIClient,
                                                                            logger: logger,
                                                                            cryptoSettings: cryptoConfig)
        let model = postARKChangeMasterPasswordViewModelFactory.make(accountCryptoChangerService: accountCryptoChangerService!,
                                                         completion: { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .finished(session):
                self.sessionLifeCycleHandler?.logoutAndPerform(action: .startNewSession(session, reason: .masterPasswordChangedForARK))
            case .cancel:
                self.newMasterPassword = nil
            }
        })
        return model

    }
}
