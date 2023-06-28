import Foundation
import CoreUserTracking
import CoreSession
import DashTypes
import CoreLocalization
import DashlaneAPI

@MainActor
public class TOTPVerificationViewModel: ObservableObject, LoginKitServicesInjecting {

    public var login: Login {
        return Login(accountVerificationService.login)
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

    public var canLogin: Bool {
        return !otp.isEmpty && !inProgress
    }

    @Published
    public var errorMessage: String?

    @Published
    var shouldDisplayError: Bool = false

    @Published
    public var inProgress: Bool = false

    let accountVerificationService: AccountVerificationService
    let loginMetricsReporter: LoginMetricsReporterProtocol
    let completion: (Result<(AuthTicket, Bool), Error>) -> Void
    public let hasDuoPush: Bool
    public let hasAuthenticatorPush: Bool
    let activityReporter: ActivityReporterProtocol
    public let lostOTPSheetViewModel: LostOTPSheetViewModel
    public let context: LocalLoginFlowContext = .passwordApp

    @Published
    public var showDuoPush: Bool = false

    @Published
    public var showAuthenticatorPush: Bool = false

    public init(accountVerificationService: AccountVerificationService,
                loginMetricsReporter: LoginMetricsReporterProtocol,
                activityReporter: ActivityReporterProtocol,
                recover2faWebService: Recover2FAWebService,
                pushType: PushType?,
                completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void) {
        self.accountVerificationService = accountVerificationService
        self.loginMetricsReporter = loginMetricsReporter
        self.activityReporter = activityReporter
        self.hasDuoPush = pushType == .duo
        self.hasAuthenticatorPush = pushType == .authenticator
        self.lostOTPSheetViewModel = LostOTPSheetViewModel(recover2faService: recover2faWebService)
        self.completion = completion
    }

    public func validate() {
        Task {
            await self.validate(code: otp)
        }
    }

    public func logOnAppear() {
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
        inProgress = true
        do {
            let authTicket: AuthTicket
            if type == .duo {
                authTicket = try await accountVerificationService.validateUsingDUOPush()
            } else {
                authTicket = try await accountVerificationService.validateUsingAuthenticatorPush()
            }
            self.errorMessage = nil
            self.completion(.success((authTicket, false)))
        } catch {
            self.logError()
            self.handleError(error)
        }
        inProgress = false
    }

    private func handleError(_ error: Error) {
        switch error {
        case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.invalidOtpBlocked):
            self.completion(.failure(error))
        default:
            self.errorMessage = CoreLocalization.L10n.errorMessage(for: AccountError.verificationDenied)
        }
    }

    public func useBackupCode(_ code: String) {
        Task {
            await validate(code: code, isBackupCode: true)
        }
    }

    private func validate(code: String, isBackupCode: Bool = false) async {
        do {
            inProgress = true
            let authTicket = try await accountVerificationService.validateOTP(code)
            self.errorMessage = nil
            self.completion(.success((authTicket, isBackupCode)))
        } catch {
            self.logError(isBackupCode: isBackupCode)
            self.handleError(error)
        }
        inProgress = false
    }

    public func makeAuthenticatorPushViewModel() -> AuthenticatorPushVerificationViewModel {
        AuthenticatorPushVerificationViewModel(login: Login(accountVerificationService.login),
                                               accountVerificationService: accountVerificationService) { [weak self] completionType in
            guard let self = self else {
                return
            }
            switch completionType {
            case let .success(authTicket):
                self.completion(.success((authTicket, false)))
            case .error(let error):
                self.completion(.failure(error))
            case .token:
                self.showAuthenticatorPush = false
            }
            self.inProgress = false
        }
    }
}

extension TOTPVerificationViewModel {
    static var mock: TOTPVerificationViewModel {
        TOTPVerificationViewModel(
            accountVerificationService: .mock,
            loginMetricsReporter: LoginMetricsReporter(appLaunchTimeStamp: 1.0),
            activityReporter: FakeActivityReporter(),
            recover2faWebService: .init(
                webService: MockWebService(),
                login: Login("")
            ),
            pushType: .authenticator,
            completion: { _ in }
        )
    }
}
