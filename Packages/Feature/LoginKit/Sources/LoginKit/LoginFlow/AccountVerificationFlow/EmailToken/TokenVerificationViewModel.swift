import Combine
import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation

@MainActor
public final class TokenVerificationViewModel: ObservableObject, LoginKitServicesInjecting {

  static let expectedTokenSize = 6

  var login: Login {
    return Login(accountVerificationService.login)
  }

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
  let accountVerificationService: AccountVerificationService
  let completion: @MainActor (Result<AuthTicket, Error>) -> Void
  var errorCount: Int = 0
  let activityReporter: ActivityReporterProtocol
  private let mode: Definition.Mode

  private var cancellables: Set<AnyCancellable> = []

  public init(
    tokenPublisher: AnyPublisher<String, Never>?,
    accountVerificationService: AccountVerificationService,
    activityReporter: ActivityReporterProtocol,
    mode: Definition.Mode,
    completion: @escaping @MainActor (Result<AuthTicket, Error>) -> Void
  ) {
    self.tokenPublisher = tokenPublisher
    self.accountVerificationService = accountVerificationService
    self.completion = completion
    self.activityReporter = activityReporter
    self.mode = mode
    tokenPublisher?.assign(to: &$token)
  }

  public func requestToken() async {
    token = ""
    do {
      try await accountVerificationService.requestToken()
      self.errorMessage = nil
    } catch {
      self.errorMessage = CoreLocalization.L10n.errorMessage(for: error)
    }
  }

  public func validateToken() async {
    guard !inProgress else { return }

    guard token.count == Self.expectedTokenSize else {
      self.errorMessage = L10n.Core.badToken
      self.logError()
      return
    }

    inProgress = true

    do {
      let authTicket = try await accountVerificationService.validateToken(token)
      self.errorMessage = nil
      self.completion(.success(authTicket))
    } catch {
      self.logError()
      self.errorMessage = CoreLocalization.L10n.errorMessage(for: error)
    }
    inProgress = false
  }

  public func autofillToken() async {
    do {
      let token = try await accountVerificationService.qaToken()
      try await Task.sleep(nanoseconds: UInt64(TimeInterval(NSEC_PER_SEC) * 0.2))
      self.token = token
    } catch {}
  }

  public func logShowToken() {
    activityReporter.report(
      UserEvent.AskAuthentication(
        mode: self.mode,
        reason: .login,
        verificationMode: .emailToken
      )
    )
    activityReporter.reportPageShown(.loginToken)
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

  public func logResendToken() {
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
}

extension TokenVerificationViewModel {
  static var mock: TokenVerificationViewModel {
    TokenVerificationViewModel(
      tokenPublisher: PassthroughSubject().eraseToAnyPublisher(),
      accountVerificationService: .mock,
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
