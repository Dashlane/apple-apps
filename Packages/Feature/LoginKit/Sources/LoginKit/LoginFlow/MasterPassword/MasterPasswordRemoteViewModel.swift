import Foundation
import CoreSession
import Combine
import DashTypes
import DashlaneCrypto
import CoreUserTracking
import SwiftTreats
import CoreSettings
import CoreLocalization

@MainActor
public class MasterPasswordRemoteViewModel: MasterPasswordViewModel, LoginKitServicesInjecting {
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

    public var shouldSuggestMPReset: Bool {
        return false
    }

    @Published
    public var showWrongPasswordError: Bool = false

    let validator: RemoteLoginHandler
    let usageLogService: LoginUsageLogServiceProtocol
    let completion: () -> Void
    let logger: Logger
    public let isExtension: Bool
    public let installerLogService: InstallerLogServiceProtocol
    let remoteLoginInfoProvider: RemoteLoginDelegate
    public let isSSOUser: Bool = false
    public let keys: LoginKeys
    public let activityReporter: ActivityReporterProtocol

        private let verificationMode: Definition.VerificationMode
    private let isBackupCode: Bool

    public init(login: Login,
                verificationMode: Definition.VerificationMode,
                isBackupCode: Bool,
                isExtension: Bool,
                usageLogService: LoginUsageLogServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                validator: RemoteLoginHandler,
                logger: Logger,
                remoteLoginDelegate: RemoteLoginDelegate,
                installerLogService: InstallerLogServiceProtocol,
                keys: LoginKeys,
                completion: @escaping () -> Void) {
        self.login = login
        self.isExtension = isExtension
        self.verificationMode = verificationMode
        self.isBackupCode = isBackupCode
        self.usageLogService = usageLogService
        self.installerLogService = installerLogService
        self.remoteLoginInfoProvider = remoteLoginDelegate
        self.validator = validator
        self.logger = logger
        self.keys = keys
        self.completion = completion
        self.activityReporter = activityReporter
    }

    public func validate() {
        self.showWrongPasswordError = false
        inProgress = true
        usageLogService.startLoginTimer(from: .masterPassword)

        validateMasterPassword { result in
            switch result {
            case .success:
                self.errorMessage = nil
                self.completion()
                self.usageLogService.didRegisterNewDevice()
                self.installerLogService.login.logMasterPasswordOk()
            case .failure(let error):
                self.inProgress = false
                self.usageLogService.resetTimer(.login)
                self.attempts += 1
                switch error {
                case RemoteLoginHandler.Error.wrongMasterKey:
                    self.showWrongPasswordError = true
                    self.installerLogService.login.logWrongMasterPassword()
                    self.logLoginStatus(.errorWrongPassword)
                default:
                    self.errorMessage = CoreLocalization.L10n.errorMessage(for: error, login: self.validator.login)
                    self.logLoginStatus(.errorUnknown)
                }
            }
        }
    }

    public func didTapResetMP() {}
    public func unlockWithSSO() {}

    public func validateMasterPassword(completion: @escaping CompletionBlock<Void, Swift.Error>) {
        if let remoteKey = keys.remoteKey, let remoteKeyData = Data(base64Encoded: remoteKey.key) {
            let cryptoCenter = CryptoCenter(from: remoteKeyData)

            guard let decipheredRemoteKey = try? cryptoCenter?.decrypt(data: remoteKeyData, with: .password(password)) else {
                completion(.failure(RemoteLoginHandler.Error.wrongMasterKey))
                return
            }
            validator.validateMasterKey(.masterPassword(password), authTicket: keys.authTicket, remoteKey: decipheredRemoteKey, using: remoteLoginInfoProvider, completion: completion)
        } else {
            validator.validateMasterKey(.masterPassword(password), authTicket: keys.authTicket, using: remoteLoginInfoProvider, completion: completion)
        }
    }

    public func logLoginStatus(_ status: Definition.Status) {
        activityReporter.report(UserEvent.Login(isBackupCode: isBackupCode,
                                                mode: .masterPassword,
                                                status: status,
                                                verificationMode: verificationMode))
    }

    public func logOnAppear() {
        activityReporter.reportPageShown(.unlockMp)
    }

    public func logForgotPassword() {
        activityReporter.report(UserEvent.ForgetMasterPassword(hasBiometricReset: false,
                                                               hasTeamAccountRecovery: false))
    }
}
