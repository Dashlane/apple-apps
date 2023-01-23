import Foundation
import Combine
import CoreSession
import CoreUserTracking
import DashTypes
import SwiftTreats
import CoreLocalization

@MainActor
public class TOTPRemoteLoginViewModel: TOTPLoginViewModel, LoginKitServicesInjecting {
    
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
            if otp.count > 6 ||  otp.rangeOfCharacter(from: CharacterSet.letters) != nil {
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
    var shouldDisplayError: Bool = false

    @Published
    public var inProgress: Bool = false

    let validator: ThirdPartyOTPDeviceRegistrationValidator
    let usageLogService: LoginUsageLogServiceProtocol
    let completion: (TOTPRemoteLoginViewModel.CompletionType) -> Void
    public let hasDuoPush: Bool
    public let hasAuthenticatorPush: Bool
    public let loginInstallerLogger: LoginInstallerLogger
    let activityReporter: ActivityReporterProtocol
    public let lostOTPSheetViewModel: LostOTPSheetViewModel
    public let context: LocalLoginFlowContext = .passwordApp

    @Published
    public var showDuoPush: Bool = false

    @Published
    public var showAuthenticatorPush: Bool = false
    
    public init(validator: ThirdPartyOTPDeviceRegistrationValidator,
                usageLogService: LoginUsageLogServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                recover2faWebService: Recover2FAWebService,
                loginInstallerLogger: LoginInstallerLogger,
                completion: @escaping (TOTPRemoteLoginViewModel.CompletionType) -> Void) {
        self.validator = validator
        self.usageLogService = usageLogService
        self.activityReporter = activityReporter
        self.hasDuoPush = validator.option == .duoPush
        self.hasAuthenticatorPush = validator.option == .authenticatorPush
        self.loginInstallerLogger = loginInstallerLogger
        self.lostOTPSheetViewModel = LostOTPSheetViewModel(recover2faService: recover2faWebService)
        self.completion = completion
    }

    public func validate() {
        Task {
            await self.validate(code: otp)
        }
    }

    public func logOnAppear() {
        loginInstallerLogger.logOTPClick()
        activityReporter.report(UserEvent.AskAuthentication(mode: .masterPassword,
                                                            reason: .login,
                                                            verificationMode: .otp1))
        activityReporter.reportPageShown(.loginToken)
    }

    func logError(isBackupCode: Bool = false) {
        activityReporter.report(UserEvent.Login(isBackupCode: isBackupCode,
                                                mode: .masterPassword,
                                                status: .errorWrongOtp,
                                                verificationMode: .otp1))
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
            self.handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        switch error {
        case AccountError.rateLimitExceeded,
             AccountError.invalidOtpBlocked:
            self.completion(.error(error))
        default:
            self.errorMessage = CoreLocalization.L10n.errorMessage(for: error, login: self.validator.login)
            self.loginInstallerLogger.logBadToken()
        }
    }

    public func useBackupCode(_ code: String) {
        Task {
            await validate(code: code, isBackupCode: true)
        }
    }

    private func validate(code: String, isBackupCode: Bool = false) async {
        do {
            try await validator.validateOTP(code)
            self.errorMessage = nil
            self.usageLogService.didUseOTP()
            self.completion(.success(isBackupCode: isBackupCode))
            self.loginInstallerLogger.logTokenOK()
        } catch {
            self.logError(isBackupCode: isBackupCode)
            self.handleError(error)
        }
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
