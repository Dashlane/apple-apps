import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation

@MainActor
public class TOTPVerificationViewModel: ObservableObject, LoginKitServicesInjecting {

  public var login: Login {
    return Login(accountVerificationService.login)
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
  let activityReporter: ActivityReporterProtocol
  public let lostOTPSheetViewModel: LostOTPSheetViewModel
  public let context: LocalLoginFlowContext = .passwordApp

  @Published
  public var showDuoPush: Bool = false

  public init(
    accountVerificationService: AccountVerificationService,
    appAPIClient: AppAPIClient,
    loginMetricsReporter: LoginMetricsReporterProtocol,
    activityReporter: ActivityReporterProtocol,
    pushType: VerificationMethod.PushType?,
    completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) {
    self.accountVerificationService = accountVerificationService
    self.loginMetricsReporter = loginMetricsReporter
    self.activityReporter = activityReporter
    self.hasDuoPush = pushType == .duo
    self.lostOTPSheetViewModel = LostOTPSheetViewModel(
      appAPIClient: appAPIClient,
      login: Login(accountVerificationService.login))
    self.completion = completion
  }

  public func validate() {
    Task {
      await self.validate(code: otp)
    }
  }

  public func logOnAppear() {
    activityReporter.report(
      UserEvent.AskAuthentication(
        mode: .masterPassword,
        reason: .login,
        verificationMode: .otp1))
    activityReporter.reportPageShown(.loginToken)
  }

  func logError(isBackupCode: Bool = false) {
    activityReporter.report(
      UserEvent.Login(
        isBackupCode: isBackupCode,
        mode: .masterPassword,
        status: .errorWrongOtp,
        verificationMode: .otp1))
  }

  public func sendPush(_ type: VerificationMethod.PushType) async {
    inProgress = true
    do {
      let authTicket: AuthTicket
      authTicket = try await accountVerificationService.validateUsingDUOPush()
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
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.invalidOTPBlocked):
      self.completion(.failure(error))
    default:
      self.errorMessage = CoreLocalization.L10n.errorMessage(for: error)
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
}

extension TOTPVerificationViewModel {
  static var mock: TOTPVerificationViewModel {
    TOTPVerificationViewModel(
      accountVerificationService: .mock,
      appAPIClient: .fake,
      loginMetricsReporter: LoginMetricsReporter(appLaunchTimeStamp: 1.0),
      activityReporter: .mock,
      pushType: .duo,
      completion: { _ in }
    )
  }
}
