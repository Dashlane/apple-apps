import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine
import UserTrackingFoundation

@MainActor
public class TOTPVerificationViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting
{

  public let login: Login

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

  @Published public var stateMachine: TOTPVerificationStateMachine
  @Published public var isPerformingEvent: Bool = false

  let completion: (Result<(AuthTicket, Bool), Error>) -> Void
  public let hasDuoPush: Bool
  let activityReporter: ActivityReporterProtocol
  public let lostOTPSheetViewModel: LostOTPSheetViewModel
  public let context: UnlockOriginProcess = .passwordApp

  @Published
  public var showDuoPush: Bool = false

  public init(
    login: Login,
    stateMachine: TOTPVerificationStateMachine,
    appAPIClient: AppAPIClient,
    activityReporter: ActivityReporterProtocol,
    pushType: VerificationMethod.PushType?,
    completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) {
    self.login = login
    self.stateMachine = stateMachine
    self.activityReporter = activityReporter
    self.hasDuoPush = pushType == .duo
    self.lostOTPSheetViewModel = LostOTPSheetViewModel(
      appAPIClient: appAPIClient,
      login: login)
    self.completion = completion
  }

  public func willPerform(_ event: TOTPVerificationStateMachine.Event) async {
    switch event {
    case .validateOTP, .validateDuoPush:
      self.inProgress = true
    }
  }

  public func update(
    for event: TOTPVerificationStateMachine.Event,
    from oldState: TOTPVerificationStateMachine.State,
    to newState: TOTPVerificationStateMachine.State
  ) async {
    switch newState {
    case .initialize:
      break
    case let .otpVadidated(authTicket):
      self.completion(.success((authTicket, false)))
    case let .duoPushValidated(authTicket):
      self.completion(.success((authTicket, false)))
    case let .errorOccurred(error, isBackupCode):
      self.logError(isBackupCode: isBackupCode)
      self.handleError(error.underlyingError)
    }
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
    await self.perform(.validateDuoPush)
  }

  private func handleError(_ error: Error) {
    switch error {
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.invalidOTPBlocked):
      self.completion(.failure(error))
    default:
      self.errorMessage = CoreL10n.errorMessage(for: error)
    }
  }

  public func useBackupCode(_ code: String) {
    Task {
      await validate(code: code, isBackupCode: true)
    }
  }

  private func validate(code: String, isBackupCode: Bool = false) async {
    await self.perform(.validateOTP(code, isBackupCode: isBackupCode))
  }
}

extension TOTPVerificationViewModel {
  static var mock: TOTPVerificationViewModel {
    TOTPVerificationViewModel(
      login: Login("_"),
      stateMachine: .mock,
      appAPIClient: .fake,
      activityReporter: .mock,
      pushType: .duo,
      completion: { _ in }
    )
  }
}
