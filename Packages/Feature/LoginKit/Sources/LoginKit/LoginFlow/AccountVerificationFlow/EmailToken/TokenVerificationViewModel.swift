import Combine
import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine
import UserTrackingFoundation

@MainActor
public final class TokenVerificationViewModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  static let expectedTokenSize = 6

  let login: Login

  var canLogin: Bool {
    return !token.isEmpty && !inProgress
  }

  @Published
  var token: String = "" {
    didSet {
      if token.count > Self.expectedTokenSize
        || token.rangeOfCharacter(from: CharacterSet.letters) != nil
      {
        token = oldValue
      } else if token.count == Self.expectedTokenSize && token != oldValue {
        Task {
          await validateToken()
        }
      }
      errorMessage = nil
    }
  }

  @Published
  var errorMessage: String?

  @Published
  var inProgress: Bool = false

  let tokenPublisher: AnyPublisher<String, Never>?

  @Published public var stateMachine: TokenVerificationStateMachine
  @Published public var isPerformingEvent: Bool = false

  let completion: @MainActor (Result<AuthTicket, Error>) -> Void
  var errorCount: Int = 0
  let activityReporter: ActivityReporterProtocol
  private let mode: Definition.Mode

  private var cancellables: Set<AnyCancellable> = []

  public init(
    login: Login,
    tokenPublisher: AnyPublisher<String, Never>?,
    stateMachine: TokenVerificationStateMachine,
    activityReporter: ActivityReporterProtocol,
    mode: Definition.Mode,
    completion: @escaping @MainActor (Result<AuthTicket, Error>) -> Void
  ) {
    self.login = login
    self.tokenPublisher = tokenPublisher
    self.stateMachine = stateMachine
    self.completion = completion
    self.activityReporter = activityReporter
    self.mode = mode
    tokenPublisher?.assign(to: &$token)
  }

  public func willPerform(_ event: TokenVerificationStateMachine.Event) async {
    switch event {
    case .validateToken:
      self.inProgress = true
    case .requestToken, .requestQAToken:
      break
    }
  }

  public func update(
    for event: TokenVerificationStateMachine.Event,
    from oldState: TokenVerificationStateMachine.State,
    to newState: TokenVerificationStateMachine.State
  ) async {
    switch newState {

    case .waitingForTokenInput:
      token = ""
      self.errorMessage = nil
    case let .qaTokenReceived(token):
      try? await Task.sleep(nanoseconds: UInt64(TimeInterval(NSEC_PER_SEC) * 0.2))
      self.token = token
    case let .tokenValidated(authTicket):
      inProgress = false
      self.completion(.success(authTicket))
    case let .errorOccured(error):
      inProgress = false
      logError()
      self.errorMessage = CoreL10n.errorMessage(for: error.underlyingError)
    }
  }

  public func requestToken() async {
    await perform(.requestToken)
  }

  public func validateToken() async {
    guard !inProgress else { return }

    guard token.count == Self.expectedTokenSize else {
      self.errorMessage = CoreL10n.badToken
      self.logError()
      return
    }

    await perform(.validateToken(token))
  }

  public func autofillToken() async {
    await self.perform(.requestQAToken)
  }

  func onViewAppear() async {
    logShowToken()
    await requestToken()
    #if DEBUG
      if login.isTest, !ProcessInfo.isTesting {
        await autofillToken()
      }
    #endif
  }

}

extension TokenVerificationViewModel {
  func logResendToken() {
    activityReporter.report(UserEvent.ResendToken())
  }

  func logError() {
    activityReporter.report(
      UserEvent.Login(
        isBackupCode: false,
        mode: .masterPassword,
        status: .errorWrongOtp,
        verificationMode: .emailToken
      )
    )
  }

  func logShowToken() {
    activityReporter.report(
      UserEvent.AskAuthentication(
        mode: self.mode,
        reason: .login,
        verificationMode: .emailToken
      )
    )
    activityReporter.reportPageShown(.loginToken)
  }
}

extension TokenVerificationViewModel {
  static var mock: TokenVerificationViewModel {
    TokenVerificationViewModel(
      login: Login("_"),
      tokenPublisher: PassthroughSubject().eraseToAnyPublisher(),
      stateMachine: .mock,
      activityReporter: .mock,
      mode: .masterPassword,
      completion: { _ in }
    )
  }
}

extension DashlaneAPI.APIError {
  func hasAuthenticationCodes(_ codes: [APIErrorCodes.Authentication]) -> Bool {
    codes.contains { hasAuthenticationCode($0) }
  }
}
