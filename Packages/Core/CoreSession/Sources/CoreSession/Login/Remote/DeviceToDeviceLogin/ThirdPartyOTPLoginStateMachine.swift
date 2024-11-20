import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public struct ThirdPartyOTPLoginStateMachine: StateMachine {

  public enum State: Hashable {
    case initialize(VerificationMethod.PushType?)

    case didReceivedAuthTicket(AuthTicket, _ isBackupCode: Bool = false)

    case errorOccured(ThirdPartyOTPError, _ isBackupCode: Bool = false)
  }

  public enum Event {
    case start

    case validateOTP(String, _ isBackupCode: Bool)

    case sendPush
  }

  public var state: State

  public let login: Login
  public let option: ThirdPartyOTPOption
  private let apiClient: AppAPIClient
  private let logger: Logger

  public init(
    initialState: ThirdPartyOTPLoginStateMachine.State,
    login: Login,
    option: ThirdPartyOTPOption,
    apiClient: AppAPIClient,
    logger: Logger
  ) {
    self.login = login
    self.option = option
    self.apiClient = apiClient
    self.logger = logger
    self.state = initialState
  }

  public mutating func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch event {
    case .start:
      state = .initialize(option.pushType)
    case let .validateOTP(otp, isBackupCode):
      await validateOTP(otp, isBackupCode: isBackupCode)
    case .sendPush:
      if option.pushType == VerificationMethod.PushType.duo {
        await validateUsingDUOPush()
      }
    }
    logger.logInfo("Transition to state: \(state)")
  }

  private mutating func validateOTP(_ otp: String, isBackupCode: Bool) async {
    do {
      let verificationResponse = try await apiClient.authentication.performTotpVerification(
        login: login.email, otp: otp)
      state = .didReceivedAuthTicket(
        AuthTicket(value: verificationResponse.authTicket), isBackupCode)
    } catch {
      logger.error("OTP verification failed", error: error)
      state = .errorOccured(.wrongOTP, isBackupCode)
    }
  }

  private mutating func validateUsingDUOPush() async {
    guard option == .duoPush else {
      logger.error("Push not enabled")
      state = .errorOccured(ThirdPartyOTPError.duoPushNotEnabled)
      return
    }

    do {
      let verificationResponse = try await apiClient.authentication.performDuoPushVerification(
        login: login.email)
      state = .didReceivedAuthTicket(AuthTicket(value: verificationResponse.authTicket))
    } catch {
      logger.error("Duo push verification failed", error: error)
      state = .errorOccured(.duoChallengeFailed)
    }

  }
}

extension ThirdPartyOTPLoginStateMachine {
  public static func mock(option: ThirdPartyOTPOption = .duoPush) -> ThirdPartyOTPLoginStateMachine
  {
    ThirdPartyOTPLoginStateMachine(
      initialState: .initialize(option.pushType),
      login: Login("_"),
      option: option,
      apiClient: .mock({}),
      logger: LoggerMock())
  }
}
