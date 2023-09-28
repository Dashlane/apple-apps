import Foundation
import CoreSession
import Combine
import CoreUserTracking
import CoreSettings
import DashTypes
import SwiftTreats
import CoreKeychain
import SwiftUI
import DashlaneAPI

@MainActor
public class LocalLoginUnlockViewModel: ObservableObject, LoginKitServicesInjecting {
    public enum Completion {
        public enum AuthenticationMode {
                        case masterPassword

                        case resetMasterPassword

                        case biometry

                        case pincode

                        case rememberMasterPassword
            
            case accountRecovered(_ newMasterPassword: String)
        }

                case authenticated(AuthenticationMode)

                case sso

                case logout
    }

    enum UnlockMode: Equatable {
        case masterPassword
        case pincode(pinCodeLock: SecureLockMode.PinCodeLock, biometry: Biometry?)
        case biometry(Biometry)
        case passwordLessRecovery(afterFailure: Bool)
        case sso

        var biometryType: Biometry? {
            switch self {
            case .biometry(let biometryType):
                return biometryType
            default: return nil
            }
        }
    }

    enum UnlockOrigin {
        case login
        case lock
    }

        @Published
    var unlockMode: UnlockMode

    @Published
    var showRememberPassword: Bool = false

    let login: Login
    let loginMetricsReporter: LoginMetricsReporterProtocol
    let activityReporter: ActivityReporterProtocol
    let unlocker: UnlockSessionHandler
    let userSettings: UserSettings
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    let accountType: AccountType
    let unlockType: UnlockType
    let completion: (Completion) -> Void
    let keychainService: AuthenticationKeychainServiceProtocol
    let context: LoginUnlockContext
    let appAPIClient: AppAPIClient
    let masterPasswordLocalViewModelFactory: MasterPasswordLocalViewModel.Factory
    let biometryViewModelFactory: BiometryViewModel.Factory
    let lockPinCodeAndBiometryViewModelFactory: LockPinCodeAndBiometryViewModel.Factory
    let passwordLessRecoveryViewModelFactory: PasswordLessRecoveryViewModel.Factory
    let expectedSecureLockMode: SecureLockMode
    let sessionCleaner: SessionCleaner

    public init(login: Login,
                accountType: AccountType,
                unlockType: UnlockType,
                secureLockMode: SecureLockMode,
                unlocker: UnlockSessionHandler,
                context: LoginUnlockContext,
                userSettings: UserSettings,
                loginMetricsReporter: LoginMetricsReporterProtocol,
                activityReporter: ActivityReporterProtocol,
                resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
                appAPIClient: AppAPIClient,
                sessionCleaner: SessionCleaner,
                keychainService: AuthenticationKeychainServiceProtocol,
                masterPasswordLocalViewModelFactory: MasterPasswordLocalViewModel.Factory,
                biometryViewModelFactory: BiometryViewModel.Factory,
                lockPinCodeAndBiometryViewModelFactory: LockPinCodeAndBiometryViewModel.Factory,
                passwordLessRecoveryViewModelFactory: PasswordLessRecoveryViewModel.Factory,
                completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
    ) {
        self.login = login
        self.context = context
        self.unlockType = unlockType
        self.keychainService = keychainService
        self.loginMetricsReporter = loginMetricsReporter
        self.activityReporter = activityReporter
        self.unlocker = unlocker
        self.userSettings = userSettings
        self.resetMasterPasswordService = resetMasterPasswordService
        self.accountType = accountType
        self.completion = completion
        self.appAPIClient = appAPIClient
        self.masterPasswordLocalViewModelFactory = masterPasswordLocalViewModelFactory
        self.lockPinCodeAndBiometryViewModelFactory = lockPinCodeAndBiometryViewModelFactory
        self.passwordLessRecoveryViewModelFactory = passwordLessRecoveryViewModelFactory
        self.biometryViewModelFactory = biometryViewModelFactory
        self.unlockMode = accountType.fallbackUnlockMode(afterFailure: false)
        expectedSecureLockMode = secureLockMode
        self.sessionCleaner = sessionCleaner
        selectConvenientUnlockModeMethodIfPossible(for: secureLockMode)
    }

    private func selectConvenientUnlockModeMethodIfPossible(for secureLockMode: SecureLockMode) {
        switch secureLockMode {
        case let .biometry(biometry):
            unlockMode = .biometry(biometry)

        case let .pincode(pinCodeLock):
            if pinCodeLock.attempts.tooManyAttempts {
                unlockMode = accountType.fallbackUnlockMode(afterFailure: true)
            } else {
                unlockMode = .pincode(pinCodeLock: pinCodeLock, biometry: nil)
            }

        case let .biometryAndPincode(biometry, pinCodeLock):
            if pinCodeLock.attempts.tooManyAttempts {
                unlockMode = accountType.fallbackUnlockMode(afterFailure: true)
            } else {
                unlockMode = .pincode(pinCodeLock: pinCodeLock, biometry: biometry)
            }

        case .rememberMasterPassword:
            self.showRememberPassword = true
            fallthrough

        case .masterKey:
            unlockMode = accountType.fallbackUnlockMode(afterFailure: false)
        }
    }

    func logOnAppear() {
        if let performanceLogInfo = loginMetricsReporter.getPerformanceLogInfo(.appLaunch) {
            activityReporter.report(performanceLogInfo.performanceUserEvent(for: .timeToAppReady))
            loginMetricsReporter.resetTimer(.appLaunch)
        }
    }

    func unlockWithSSO() {
        completion(.sso) 
    }
}

extension LocalLoginUnlockViewModel {
    func authenticateUsingRememberPassword() async {
        if let masterKey = try? await keychainService.masterKey(for: self.login) {
            await self.validateLocalMasterKeyForRememberPassword(masterKey, unlocker: unlocker)
        } else {
            self.showRememberPassword = false
        }
    }

    private func validateLocalMasterKeyForRememberPassword(_ masterKey: CoreKeychain.MasterKey, unlocker: UnlockSessionHandler) async {
        switch masterKey {
        case .masterPassword(let masterPassword):
            do {
                try await unlocker.validateMasterKey(.masterPassword(masterPassword, serverKey: nil), isRecoveryLogin: false)
                self.completion(.authenticated(.rememberMasterPassword))
            } catch {
                                try? self.keychainService.removeMasterKey(for: self.login)
                self.showRememberPassword = false
            }
        case .key(let key):
            do {
                try await unlocker.validateMasterKey(.ssoKey(key), isRecoveryLogin: false)
                self.completion(.authenticated(.rememberMasterPassword))
            } catch {
                self.showRememberPassword = false
            }
        }
    }
}

extension LocalLoginUnlockViewModel {
    func makeMasterPasswordLocalViewModel() -> MasterPasswordLocalViewModel {
        masterPasswordLocalViewModelFactory.make(login: login,
                                                 biometry: unlockMode.biometryType,
                                                 authTicket: unlockType.authTicket,
                                                 unlocker: unlocker,
                                                 context: context,
                                                 resetMasterPasswordService: resetMasterPasswordService,
                                                 userSettings: userSettings) { [weak self] mode in
            guard let self = self else { return }
            switch mode {
            case .biometry(let biometry):
                self.activityReporter.logAskOtherAuthentication(for: .masterPassword, nextMode: .biometric)
                self.unlockMode = .biometry(biometry)
            case .masterPasswordReset:
                self.completion(.authenticated(.resetMasterPassword))
            case .authenticated:
                self.completion(.authenticated(.masterPassword))
            case .none:
                self.completion(.logout)
            case let .accountRecovered(newMasterPassword):
                self.completion(.authenticated(.accountRecovered(newMasterPassword)))
            }
        }
    }

    func makeBiometryViewModel(biometryType: Biometry) -> BiometryViewModel {
        biometryViewModelFactory.make(
            login: login,
            biometryType: biometryType,
            unlocker: unlocker,
            context: context,
            userSettings: userSettings
        ) { [weak self] isSuccess in
            guard let self = self else {
                return
            }

            if !isSuccess {
                self.unlockMode = self.accountType.fallbackUnlockMode(afterFailure: true)
                self.activityReporter.logFailure(for: self.unlockType)
            } else {
                self.completion(.authenticated(.biometry))
            }
        }
    }

    func makePinCodeViewModel(lock: SecureLockMode.PinCodeLock,
                              biometryType: Biometry? = nil) -> LockPinCodeAndBiometryViewModel {
        lockPinCodeAndBiometryViewModelFactory.make(
            login: login,
            accountType: accountType,
            pinCodeLock: lock,
            biometryType: biometryType,
            context: context,
            unlocker: unlocker
        ) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .biometricAuthenticationSuccess:
                self.completion(.authenticated(.biometry))

            case .pinAuthenticationSuccess:
                self.completion(.authenticated(.pincode))

            case .failure:
                self.unlockMode = self.accountType.fallbackUnlockMode(afterFailure: true)

            case .recover:
                self.unlockMode = self.accountType.fallbackUnlockMode(afterFailure: false)

            case .cancel:
                let unlockMethod = self.accountType.fallbackUnlockMode(afterFailure: false)
                switch unlockMethod {
                case .passwordLessRecovery: 
                    self.completion(.logout)
                default:
                    self.unlockMode = unlockMethod
                }
            }
        }
    }

    func makePasswordLessRecoveryViewModel(recoverFromFailure: Bool) -> PasswordLessRecoveryViewModel {
        passwordLessRecoveryViewModelFactory.make(login: login, recoverFromFailure: recoverFromFailure) { [weak self] completion in
            guard let self = self else {
                return
            }

            switch completion {
            case .logout:
                sessionCleaner.removeLocalData(for: login)
                self.completion(.logout)
            case .cancel:
                self.selectConvenientUnlockModeMethodIfPossible(for: self.expectedSecureLockMode)
            }
        }
    }
}

fileprivate extension ActivityReporterProtocol {
    func logFailure(for unlockType: UnlockType) {
        if case UnlockType.ssoValidation = unlockType {
            self.logAskOtherAuthentication(for: .pin, nextMode: .sso)
        } else {
            self.logAskOtherAuthentication(for: .pin, nextMode: .masterPassword)
        }
    }

    func logAskOtherAuthentication(for mode: Definition.Mode, nextMode: Definition.Mode) {
        report(UserEvent.AskUseOtherAuthentication(next: nextMode, previous: mode))
    }
}

extension AccountType {
    func fallbackUnlockMode(afterFailure: Bool) -> LocalLoginUnlockViewModel.UnlockMode {
        switch self {
        case .masterPassword:
            return .masterPassword
        case .invisibleMasterPassword:
            return .passwordLessRecovery(afterFailure: afterFailure)
        case .sso:
            return .sso
        }
    }
}
