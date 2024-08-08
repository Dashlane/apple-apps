import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import UIComponents

@MainActor
public class DeviceTransferOTPLoginViewModel: ObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case success(AuthTicket, isBackupCode: Bool)
    case error(Error)
    case cancel
  }

  @Published
  var state: ProgressionState = .inProgress(L10n.Core.deviceToDevicePushInProgress)

  @Published
  var otpValue: String = "" {
    didSet {
      isTokenError = false
    }
  }

  @Published
  var showPushView = false

  @Published
  var isTokenError = false

  @Published
  var inProgress = false

  var canValidate: Bool {
    otpValue.count == 6
  }

  public var stateMachine: ThirdPartyOTPLoginStateMachine
  let activityReporter: ActivityReporterProtocol
  let lostOTPSheetViewModel: LostOTPSheetViewModel
  let completion: (DeviceTransferOTPLoginViewModel.CompletionType) -> Void

  public init(
    initialState: ThirdPartyOTPLoginStateMachine.State,
    login: Login,
    option: ThirdPartyOTPOption,
    activityReporter: ActivityReporterProtocol,
    appAPIClient: AppAPIClient,
    thirdPartyOTPLoginStateMachineFactory: ThirdPartyOTPLoginStateMachine.Factory,
    completion: @escaping (DeviceTransferOTPLoginViewModel.CompletionType) -> Void
  ) {
    self.stateMachine = thirdPartyOTPLoginStateMachineFactory.make(
      initialState: initialState, login: login, option: option)
    self.activityReporter = activityReporter
    self.lostOTPSheetViewModel = LostOTPSheetViewModel(
      appAPIClient: appAPIClient,
      login: login)
    self.completion = completion
    Task {
      await perform(.start)
    }
  }

  public func sendPush() async {
    await perform(.sendPush)
  }

  public func useBackupCode(_ code: String) {
    Task {
      await validate(code: code, isBackupCode: true)
    }
  }

  private func validate(code: String, isBackupCode: Bool = false) async {
    await perform(.validateOTP(code, isBackupCode))
  }

  func logError(isBackupCode: Bool = false) {
    activityReporter.report(
      UserEvent.Login(
        isBackupCode: isBackupCode,
        mode: .deviceTransfer,
        status: .errorWrongOtp,
        verificationMode: .otp1))
  }

  public func validate() {
    Task {
      await self.validate(code: otpValue)
    }
  }
}

@MainActor
extension DeviceTransferOTPLoginViewModel: StateMachineBasedObservableObject {
  public func update(
    for event: ThirdPartyOTPLoginStateMachine.Event,
    from oldState: ThirdPartyOTPLoginStateMachine.State,
    to newState: ThirdPartyOTPLoginStateMachine.State
  ) {
    switch newState {
    case let .initialize(pushType):
      showPushView = pushType != nil
    case let .didReceivedAuthTicket(authTicket, isBackupCode):
      self.completion(.success(authTicket, isBackupCode: isBackupCode))
    case let .errorOccured(error, isBackupCode) where error == .wrongOTP:
      self.logError(isBackupCode: isBackupCode)
      isTokenError = true
    case let .errorOccured(error, _) where error == .duoChallengeFailed:
      self.logError()
      state = .failed(L10n.Core.authenticatorPushViewDeniedError, {})
    case let .errorOccured(error, _):
      self.completion(.error(error))
    }
  }
}
