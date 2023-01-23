import Foundation
import CoreSession
import Combine
import CoreUserTracking
import CoreSettings
import DashTypes
import SwiftTreats
import CoreKeychain
import SwiftUI

@MainActor
class LocalLoginUnlockViewModel: ObservableObject {

    enum Completion {
        enum AuthenticationMode {
                        case masterPassword

                        case resetMasterPassword

                        case biometry

                        case pincode

                        case rememberMasterPassword
        }

                case authenticated(AuthenticationMode)

                case sso

                case logout
    }

    enum UnlockMode: Equatable {
        static func == (lhs: LocalLoginUnlockViewModel.UnlockMode, rhs: LocalLoginUnlockViewModel.UnlockMode) -> Bool {
            switch (lhs, rhs) {
            case (.masterPassword, .masterPassword), (.pincode, .pincode), (.biometry, .biometry):
                return true
            default: return false
            }
        }

        case masterPassword
        case pincode(LockPinCodeAndBiometryViewModel)
        case biometry(BiometryViewModel)

        var biometryType: Biometry? {
            switch self {
            case .biometry(let model):
                return model.biometryType
            default: return nil
            }
        }
    }

    @Published
    var unlockMode: UnlockMode = .masterPassword

    @Published
    var showRememberPassword: Bool = false

    let login: Login
    let usageLogService: LoginUsageLogServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let unlocker: UnlockSessionHandler
    let userSettings: UserSettings
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    let installerLogService: InstallerLogServiceProtocol
    let isSSOUser: Bool
    let unlockType: UnlockType
    let completion: (Completion) -> Void
    let keychainService: AuthenticationKeychainServiceProtocol
    let localLoginHandler: LocalLoginHandler
    let context: LocalLoginFlowContext

    let verificationMode: Definition.VerificationMode
    let isBackupCode: Bool

    lazy var masterPasswordLocalViewModel: MasterPasswordLocalViewModel = {
        .init(login: login,
              verificationMode: verificationMode,
              isBackupCode: isBackupCode,
              reason: .login,
              biometry: unlockMode.biometryType,
              usageLogService: usageLogService,
              activityReporter: activityReporter,
              unlocker: unlocker,
              userSettings: userSettings,
              resetMasterPasswordService: resetMasterPasswordService,
              installerLogService: installerLogService,
              isSSOUser: isSSOUser,
              isExtension: context.isExtension) { [weak self] mode in
            guard let self = self else { return }
            switch mode {
            case .biometry(let biometry):
                self.logAskOtherAuthentication(for: .masterPassword, nextMode: .biometric)
                self.unlockMode = .biometry(self.makeBiometryViewModel(biometryType: biometry))
            case .sso:
                self.completion(.sso)
            case .masterPasswordReset:
                self.completion(.authenticated(.resetMasterPassword))
            case .authenticated:
                self.completion(.authenticated(.masterPassword))
            case .none:
                self.completion(.logout)
            }
        }
    }()

    init(login: Login,
         verificationMode: Definition.VerificationMode,
         isBackupCode: Bool,
         biometry: Biometry?,
         usageLogService: LoginUsageLogServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         localLoginHandler: LocalLoginHandler,
         unlocker: UnlockSessionHandler,
         keychainService: AuthenticationKeychainServiceProtocol,
         userSettings: UserSettings,
         resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
         installerLogService: InstallerLogServiceProtocol,
         isSSOUser: Bool,
         secureLockMode: SecureLockMode,
         unlockType: UnlockType,
         context: LocalLoginFlowContext,
         completion: @escaping (Completion) -> Void) {
        self.login = login
        self.isBackupCode = isBackupCode
        self.verificationMode = verificationMode
        self.localLoginHandler = localLoginHandler
        self.context = context
        self.unlockType = unlockType
        self.keychainService = keychainService
        self.usageLogService = usageLogService
        self.activityReporter = activityReporter
        self.unlocker = unlocker
        self.userSettings = userSettings
        self.resetMasterPasswordService = resetMasterPasswordService
        self.installerLogService = installerLogService
        self.isSSOUser = isSSOUser
        self.completion = completion

        showConvenientAuthenticationMethod(using: secureLockMode)
    }

    func showConvenientAuthenticationMethod(using secureLockMode: SecureLockMode) {
        guard secureLockMode.shouldShowConvenientAuthenticationMethod else { return }

        switch secureLockMode {
        case let .biometry(biometry):
            self.unlockMode = .biometry(self.makeBiometryViewModel(biometryType: biometry))
        case let .pincode(code, attempts, masterKey):
            let pinCodeViewModel = makePinCodeViewModel(masterKey: masterKey,
                                                         attempts: attempts,
                                                         pincode: code,
                                                         biometryType: nil)
            self.unlockMode = .pincode(pinCodeViewModel)
        case let .biometryAndPincode(biometry, code, attempts, masterKey):
            let pinCodeViewModel = makePinCodeViewModel(masterKey: masterKey,
                                                         attempts: attempts,
                                                         pincode: code,
                                                         biometryType: biometry)
            self.unlockMode = .pincode(pinCodeViewModel)

        case .rememberMasterPassword:
            self.showRememberPassword = true
        case .masterKey: break
        }
    }

    private func logFailure() {
        if case UnlockType.ssoValidation = unlockType {
            self.logAskOtherAuthentication(for: .pin, nextMode: .sso)
        } else {
            self.logAskOtherAuthentication(for: .pin, nextMode: .masterPassword)
        }
    }

    fileprivate func logAskOtherAuthentication(for mode: Definition.Mode, nextMode: Definition.Mode) {
        activityReporter.report(UserEvent.AskUseOtherAuthentication(next: nextMode, previous: mode))
    }

    func rememberPassword() async {
        if let masterKey = try? await keychainService.masterKey(for: self.localLoginHandler.login) {
            await self.validateLocalMasterKey(masterKey, unlocker: unlocker)
        } else {
            self.showRememberPassword = false
        }
    }

    private func validateLocalMasterKey(_ masterKey: CoreKeychain.MasterKey, unlocker: UnlockSessionHandler) async {
        switch masterKey {
        case .masterPassword(let masterPassword):
            do  {
                try await unlocker.validateMasterKey(.masterPassword(masterPassword, serverKey: nil))
                self.completion(.authenticated(.rememberMasterPassword))
            } catch {
                                try? self.keychainService.removeMasterKey(for: self.localLoginHandler.login)
                self.showRememberPassword = false
            }
        case .key(let key):
            do  {
                try await unlocker.validateMasterKey(.ssoKey(key))
                self.completion(.authenticated(.rememberMasterPassword))
            } catch {
                self.showRememberPassword = false
            }
        }
    }

    func logOnAppear() {
        if let performanceLogInfo = usageLogService.performanceLogInfo(.appLaunch) {
            activityReporter.report(performanceLogInfo.performanceUserEvent(for: .timeToAppReady))
            usageLogService.resetTimer(.appLaunch)
        }
    }
}


extension LocalLoginUnlockViewModel {
    func makeBiometryViewModel(biometryType: Biometry) -> BiometryViewModel {
        return BiometryViewModel(login: login,
                                 verificationMode: verificationMode,
                                 isBackupCode: isBackupCode,
                                 reason: .login,
                                 usageLogService: usageLogService,
                                 activityReporter: activityReporter,
                                 settings: InMemoryLocalSettingsStore(),
                                 biometryType: biometryType,
                                 keychainService: keychainService,
                                 unlocker: unlocker,
                                 installerLogService: installerLogService,
                                 context: context) { [weak self] isSuccess in
            guard let self = self else {
                return
            }
            if !isSuccess {
                self.unlockMode = .masterPassword
                self.logFailure()
            } else {
                self.completion(.authenticated(.biometry))
            }
        }
    }

    func makePinCodeViewModel(masterKey: CoreKeychain.MasterKey,
                              attempts: PinCodeAttempts,
                              pincode: String,
                              biometryType: Biometry? = nil) -> LockPinCodeAndBiometryViewModel {
        LockPinCodeAndBiometryViewModel(login: login,
                                        verificationMode: verificationMode,
                                        isBackupCode: isBackupCode,
                                        reason: .login,
                                        usageLogService: usageLogService,
                                        activityReporter: activityReporter,
                                        pinCodeAttempts: attempts,
                                        masterKey: masterKey,
                                        pincode: pincode,
                                        unlocker: unlocker,
                                        biometryType: biometryType,
                                        installerLogService: installerLogService) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .biometricAuthenticationSuccess:
                self.completion(.authenticated(.biometry))
                break
            case .pinAuthenticationSuccess:
                self.completion(.authenticated(.pincode))
                break
            case .failure, .cancel:
                self.unlockMode = .masterPassword
                self.logFailure()
            }
        }
    }
}

