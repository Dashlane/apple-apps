import Foundation
import Combine
import CoreSession
import CoreUserTracking
import DashTypes
import SwiftTreats
import CoreKeychain
import CoreLocalization

@MainActor
public class TOTPLocalLoginViewModel: TOTPLoginViewModel {
    public enum CompletionType {
        case success(isBackupCode: Bool)
        case error(Error)
    }

    public var login: Login {
        return validator.login
    }

    @Published
    public var otp: String = "" {
        didSet {
            if otp.count > 6 || otp.rangeOfCharacter(from: CharacterSet.letters) != nil {
                otp = oldValue
                return
            }
            guard oldValue.count <= 6 else { return }
            errorMessage = nil
            if otp.count == 6 && oldValue != otp {
                self.validate()
            }
        }
    }

    @Published
    public var errorMessage: String?

    @Published
    public var shouldDisplayError: Bool = false

    @Published
    public var inProgress: Bool = false

    public let validator: ThirdPartyOTPLocalLoginValidator
    let usageLogService: LoginUsageLogServiceProtocol
    public let completion: (CompletionType) -> Void
    public let hasDuoPush: Bool
    public let hasAuthenticatorPush: Bool
    public let loginInstallerLogger: LoginInstallerLogger
    let activityReporter: ActivityReporterProtocol
    public let lostOTPSheetViewModel: LostOTPSheetViewModel
    public let hasLock: Bool
    let keychainService: AuthenticationKeychainServiceProtocol
    public let context: LocalLoginFlowContext

    @Published
    public var showDuoPush: Bool = false

    @Published
    public var showAuthenticatorPush: Bool = false
    
    public init(validator: ThirdPartyOTPLocalLoginValidator,
                usageLogService: LoginUsageLogServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                loginInstallerLogger: LoginInstallerLogger,
                recover2faWebService: Recover2FAWebService,
                keychainService: AuthenticationKeychainServiceProtocol,
                hasLock: Bool,
                context: LocalLoginFlowContext,
                completion: @escaping (CompletionType) -> Void) {
        self.validator = validator
        self.hasDuoPush = validator.option == .duoPush
        self.hasAuthenticatorPush = validator.option == .authenticatorPush
        self.completion = completion
        self.context = context
        self.loginInstallerLogger = loginInstallerLogger
        self.usageLogService = usageLogService
        self.activityReporter = activityReporter
        self.hasLock = hasLock
        self.keychainService = keychainService
        self.lostOTPSheetViewModel = LostOTPSheetViewModel(recover2faService: recover2faWebService)
    }

    public func validate() {
        validate(code: otp)
    }

    public func logOnAppear() {
        loginInstallerLogger.logOTPClick()
        activityReporter.report(UserEvent.AskAuthentication(mode: .masterPassword,
                                                            reason: .login,
                                                            verificationMode: .otp2))
        activityReporter.reportPageShown(.loginToken)
    }

    public func logError(isBackupCode: Bool = false) {
        activityReporter.report(UserEvent.Login(isBackupCode: isBackupCode,
                                                mode: .masterPassword,
                                                status: .errorWrongOtp,
                                                verificationMode: .otp2))
    }

    public func sendPush(_ type: PushType) async {
        do {
            if type == .duo {
                try await validator.validateUsingDUOPush()
            } else {
                try await validator.validateUsingAuthenticatorPush()
            }
            self.errorMessage = nil
            self.completion(.success(isBackupCode: false))
            self.loginInstallerLogger.logTokenOK()
        } catch {
            self.logError()
            self.errorMessage = CoreLocalization.L10n.errorMessage(for: error, login: self.validator.login)
            self.loginInstallerLogger.logBadToken()
        }
    }
    
    public func useBackupCode(_ code: String) {
        validate(code: code, isBackupCode: true)
    }

    private func validate(code: String, isBackupCode: Bool = false) {
        Task {
            do {
                let serverKey = try await validator.validateOTP(code)
                self.errorMessage = nil
                self.saveServerKey(serverKey)
                self.completion(.success(isBackupCode: isBackupCode))
                self.usageLogService.didUseOTP()
                self.loginInstallerLogger.logTokenOK()
            } catch {
                self.logError(isBackupCode: isBackupCode)
                switch error {
                case AccountError.rateLimitExceeded,
                    AccountError.invalidOtpBlocked:
                    self.completion(.error(error))
                default:
                    self.errorMessage = CoreLocalization.L10n.errorMessage(for: error, login: self.validator.login)
                    self.loginInstallerLogger.logBadToken()
                }
            }
        }
    }

    private func saveServerKey(_ serverKey: String) {
        guard hasLock else {
            return
        }
        try? keychainService.saveServerKey(serverKey, for: validator.login)
    }
    
    public func makeAuthenticatorPushViewModel() -> AuthenticatorPushViewModel {
        AuthenticatorPushViewModel(login: validator.login,
                                   validator: validator.validateUsingAuthenticatorPush) { [weak self] completionType in
            guard let self = self else {
                return
            }
            switch completionType {
            case .success:
                self.completion(.success(isBackupCode: false))
            case .error(let error):
                self.completion(.error(error))
            case .token:
                self.showAuthenticatorPush = false
            }
        }
    }
}
