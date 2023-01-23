import Foundation
import CoreSession
import Combine
import DashTypes
import CoreKeychain
import CoreUserTracking
import SwiftTreats
import CoreSettings
import CoreLocalization

@MainActor
public class MasterPasswordLocalViewModel: MasterPasswordViewModel {

    public let login: Login

    @Published
    public var attempts: Int = 0

    @Published
    public var password: String = "" {
        didSet {
            guard password != oldValue else { return }
            errorMessage = nil
            showWrongPasswordError = false
        }
    }

    @Published
    public var errorMessage: String?

    @Published
    public var inProgress: Bool = false

    @Published
    public var shouldDisplayError: Bool = false

    @Published
    public var showWrongPasswordError: Bool = false

    public let unlocker: UnlockSessionHandler
    public let completion: (CompletionMode?) -> Void
    public let isExtension: Bool

    public let sessionLifeCycleHandler: SessionLifeCycleHandler?

    let userSettings: UserSettings
    let usageLogService: LoginUsageLogServiceProtocol

        let pinCodeAttempts: PinCodeAttempts

    let resetMPLogger: ResetMasterPasswordInstallerLogsService

    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol

    public let shouldSuggestMPReset: Bool

    public let biometry: Biometry?
    public let isSSOUser: Bool

    public let installerLogService: InstallerLogServiceProtocol
    public let activityReporter: ActivityReporterProtocol

    public enum CompletionMode: Equatable {
                case authenticated
                case masterPasswordReset

        case biometry(Biometry)
        case sso
    }
    
        private let verificationMode: Definition.VerificationMode
    private let isBackupCode: Bool?
    private let reason: Definition.Reason

    public init(login: Login,
                verificationMode: Definition.VerificationMode = Definition.VerificationMode.none,
                isBackupCode: Bool? = nil,
                reason: Definition.Reason,
                biometry: Biometry?,
                usageLogService: LoginUsageLogServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                unlocker: UnlockSessionHandler,
                userSettings: UserSettings,
                resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
                sessionLifeCycleHandler: SessionLifeCycleHandler? = nil,
                installerLogService: InstallerLogServiceProtocol,
                isSSOUser: Bool,
                isExtension: Bool,
                completion: @escaping (CompletionMode?) -> Void) {
        self.login = login
        self.isExtension = isExtension
        self.verificationMode = verificationMode
        self.isBackupCode = isBackupCode
        self.reason = reason
        self.usageLogService = usageLogService
        self.unlocker = unlocker
        self.userSettings = userSettings
        self.pinCodeAttempts = .init(internalStore: userSettings.internalStore)
        self.installerLogService = installerLogService
        self.resetMPLogger = .init(logService: installerLogService)
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.completion = completion
        self.resetMasterPasswordService = resetMasterPasswordService
        self.biometry = biometry
        shouldSuggestMPReset = resetMasterPasswordService.isActive
        self.isSSOUser = isSSOUser
        self.activityReporter = activityReporter
    }

    public func logout() {
        completion(nil)
        sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
    }

    public func validate() async {
        self.showWrongPasswordError = false
        await validate(masterPassword: password, mode: .authenticated)
    }

    private func validate(masterPassword password: String, mode: CompletionMode) async {
        inProgress = true
        usageLogService.startLoginTimer(from: .masterPassword)
        
        do {
            try await unlocker.validateMasterKey(.masterPassword(password))
            self.errorMessage = nil
            self.pinCodeAttempts.removeAll()
            self.completion(mode)
            self.installerLogService.login.logMasterPasswordOk()
        } catch {
            self.usageLogService.resetTimer(.login)
            self.inProgress = false
            self.attempts += 1
            switch error {
            case LocalLoginHandler.Error.wrongMasterKey:
                self.showWrongPasswordError = true
                self.installerLogService.login.logWrongMasterPassword()
                self.logLoginStatus(.errorWrongPassword)
            default:
                self.errorMessage = L10n.errorMessage(for: error, login: self.login)
                self.logLoginStatus(.errorUnknown)
            }
        }
    }

    public func showBiometryView() {
        guard let biometry = biometry else {
            return
        }
        completion(.biometry(biometry))
    }

    public func unlockWithSSO() {
        completion(.sso)
    }

    public func logLoginStatus(_ status: Definition.Status) {
        activityReporter.report(UserEvent.Login(isBackupCode: isBackupCode,
                                                mode: .masterPassword,
                                                status: status,
                                                verificationMode: verificationMode))
    }

    public func logForgotPassword() {
        activityReporter.report(UserEvent.ForgetMasterPassword(hasBiometricReset: shouldSuggestMPReset,
                                                               hasTeamAccountRecovery: false))
    }

    public func logOnAppear() {
        if verificationMode == .none {
            activityReporter.report(UserEvent.AskAuthentication(mode: .masterPassword,
                                                                reason: reason,
                                                                verificationMode: verificationMode))
        }
        activityReporter.reportPageShown(.unlockMp)
    }
}

@MainActor
extension MasterPasswordLocalViewModel {

    public func didTapResetMP() {
        logForgotPassword()
        self.inProgress = true
        Task.delayed(by: 0.5) { @MainActor in
            do {
                let masterPassword = try self.resetMasterPasswordService.storedMasterPassword()
                await self.validate(masterPassword: masterPassword, mode: .masterPasswordReset)
            } catch KeychainError.userCanceledRequest {
                self.resetMPLogger.log(.resetMasterPasswordStart(result: .failure(subtype: .userCanceledRequest), origin: .login))
            } catch {
                self.errorMessage = L10n.errorMessage(for: error, login: self.login)
                self.resetMPLogger.log(.resetMasterPasswordStart(result: .failure(subtype: .resetMasterPasswordInternalError), origin: .login))
            }
            self.inProgress = false
        }
    }
}
