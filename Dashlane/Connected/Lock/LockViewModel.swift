import SwiftUI
import Combine
import DashlaneReportKit
import CoreKeychain
import CoreUserTracking
import DashlaneAppKit
import SwiftTreats
import LoginKit
import CoreSettings
import DashTypes

typealias ChangeMasterPasswordLauncher = () -> Void

@MainActor
class LockViewModel: ObservableObject, SessionServicesInjecting {
    enum Mode {
        case privacyShutter
        case masterPassword(MasterPasswordLocalViewModel)
        case biometry(BiometryViewModel)
        case pinCode(LockPinCodeAndBiometryViewModel)
    }

    @Published
    var lock: ScreenLocker.Lock?

    @Published
    var mode: Mode = .privacyShutter

    private let locker: ScreenLocker
    private let keychainService: AuthenticationKeychainService
    private let userSettings: UserSettings
    private let resetMasterPasswordService: ResetMasterPasswordService
    private let pinCodeAttempts: PinCodeAttempts
    let installerLogService: InstallerLogServiceProtocol
    private let usageLogService: UsageLogServiceProtocol
    private let teamspaceService: TeamSpacesService
    private let loginUsageLogService: LoginUsageLogServiceProtocol
    private let lockService: LockServiceProtocol
    private weak var sessionLifeCycleHandler: SessionLifeCycleHandler?
    private var subscriptions: Set<AnyCancellable> = .init()
    private var initialBiometry: Biometry?
    var changeMasterPasswordLauncher: ChangeMasterPasswordLauncher

    var canAutomaticallyPromptQuickLoginScreen: Bool
    private let activityReporter: ActivityReporterProtocol

        lazy var mainAuthenticationMode: Definition.Mode = teamspaceService.isSSOUser ? .sso : .masterPassword

    init(locker: ScreenLocker,
         keychainService: AuthenticationKeychainService,
         userSettings: UserSettings,
         resetMasterPasswordService: ResetMasterPasswordService,
         installerLogService: InstallerLogServiceProtocol,
         usageLogService: UsageLogServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         teamspaceService: TeamSpacesService,
         loginUsageLogService: LoginUsageLogServiceProtocol,
         lockService: LockServiceProtocol,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher) {
        self.locker = locker
        self.keychainService = keychainService
        self.userSettings = userSettings
        self.resetMasterPasswordService = resetMasterPasswordService
        self.changeMasterPasswordLauncher = changeMasterPasswordLauncher
        self.pinCodeAttempts = PinCodeAttempts(internalStore: userSettings.internalStore)
        self.usageLogService = usageLogService
        self.teamspaceService = teamspaceService
        self.loginUsageLogService = loginUsageLogService
        self.lockService = lockService
        self.installerLogService = installerLogService
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.activityReporter = activityReporter
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

    func updateMode(with lock: ScreenLocker.Lock?) {
        switch lock {
        case .privacyShutter, .none:
            self.mode = .privacyShutter
        case let .secure(secureMode):
            switch secureMode {
            case .masterKey:
                self.mode = .masterPassword(makeMasterPasswordViewModel())
            case .biometry(let type):
                guard canShow(secureMode) else { return }
                self.mode = .biometry(makeBiometryViewModel(biometryType: type))
            case .pincode(let code, let attempts, let masterKey):
                guard canShow(secureMode) else { return }
                guard !attempts.tooManyAttempts else { break }
                let model = makePincodeAndBiometryViewModel(masterKey: masterKey, pincode: code)
                self.mode = .pinCode(model)
            case .biometryAndPincode(let biometry, let code, let attempts, let masterKey):
                guard canShow(secureMode) else { return }
                guard !attempts.tooManyAttempts else { break }
                let model = makePincodeAndBiometryViewModel(masterKey: masterKey, pincode: code, biometryType: biometry)
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
        MasterPasswordLocalViewModel(login: locker.login,
                                     reason: .unlockApp,
                                     biometry: initialBiometry,
                                     usageLogService: loginUsageLogService,
                                     activityReporter: activityReporter,
                                     unlocker: locker,
                                     userSettings: userSettings,
                                     resetMasterPasswordService: resetMasterPasswordService,
                                     sessionLifeCycleHandler: sessionLifeCycleHandler,
                                     installerLogService: installerLogService,
                                     isSSOUser: teamspaceService.isSSOUser,
                                     isExtension: false) { [weak self] completionMode in
            guard let completionMode = completionMode, let self = self else {
                return
            }
            switch completionMode {
            case .biometry(let type):
                self.activityReporter.report(UserEvent.AskUseOtherAuthentication(next: .biometric, previous: self.mainAuthenticationMode))
                DispatchQueue.main.async {
                    self.mode = .biometry(self.makeBiometryViewModel(biometryType: type))
                }
            case .authenticated:
                self.performUnlock(self.mainAuthenticationMode)
            case .masterPasswordReset:
                self.changeMasterPasswordLauncher()
            case .sso:
                self.userSettings[.ssoAuthenticationRequested] = true
                self.sessionLifeCycleHandler?.logout(clearAutoLoginData: false)
            }
        }
    }

    func makeBiometryViewModel(biometryType: Biometry) -> BiometryViewModel {
        BiometryViewModel(login: locker.login,
                          reason: .unlockApp,
                          usageLogService: loginUsageLogService,
                          activityReporter: activityReporter,
                          settings: InMemoryLocalSettingsStore(), 
                          biometryType: biometryType,
                          keychainService: keychainService,
                          unlocker: locker,
                          installerLogService: installerLogService,
                          manualLockOrigin: true,
                          context: .passwordApp,
                          completion: { [weak self] isSuccess in
            guard let self = self else { return }
            guard isSuccess else {
                self.activityReporter.report(UserEvent.AskUseOtherAuthentication(next: self.mainAuthenticationMode, previous: .biometric))
                self.lock = .secure(.masterKey)
                self.updateMode(with: self.lock)
                return
            }
            self.performUnlock(.biometric)
        })
    }

    func makePincodeAndBiometryViewModel(masterKey: MasterKey, pincode: String, biometryType: Biometry? = nil) -> LockPinCodeAndBiometryViewModel {
        LockPinCodeAndBiometryViewModel(login: locker.login,
                                        reason: .unlockApp,
                                        usageLogService: loginUsageLogService,
                                        activityReporter: activityReporter,
                                        pinCodeAttempts: pinCodeAttempts,
                                        masterKey: masterKey,
                                        pincode: pincode,
                                        unlocker: locker,
                                        biometryType: biometryType,
                                        installerLogService: installerLogService) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure, .cancel:
                self.activityReporter.report(UserEvent.AskUseOtherAuthentication(next: self.mainAuthenticationMode, previous: .pin))
                self.lock = .secure(.masterKey)
                self.updateMode(with: self.lock)
                return
            default:
                self.performUnlock(.pin)
            }
        }
    }

    private func performUnlock(_ mode: Definition.Mode) {
        activityReporter.logSuccessfulUnlock(mode)
        if let performanceLogInfo = usageLogService.getPerformanceLogInfo() {
            activityReporter.report(performanceLogInfo.performanceUserEvent(for: .timeToUnlock))
        }
        usageLogService.logDidUnlock()
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
