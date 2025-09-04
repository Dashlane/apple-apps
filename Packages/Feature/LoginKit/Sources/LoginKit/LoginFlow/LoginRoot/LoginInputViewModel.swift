import Combine
import CoreLocalization
import CoreNetworking
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import SwiftTreats
import SwiftUI
import UIDelight
import UIKit
import UserTrackingFoundation

@MainActor
public class LoginInputViewModel: ObservableObject, LoginKitServicesInjecting {

  let loginHandler: LoginStateMachine
  let completion: (LoginStateMachine.LoginResult?) -> Void
  let activityReporter: ActivityReporterProtocol

  @Published
  public var email: String {
    didSet {
      if oldValue != email {
        bubbleErrorMessage = nil
      }
    }
  }

  @Published
  public var bubbleErrorMessage: String?

  @Published
  public var currentAlert: AlertItem?

  public enum AlertItem: String, Identifiable {
    public var id: String { rawValue }

    case ssoBlockedAlert
    case versionValidityAlert
    case userDeactivatedAlert
  }

  @Published
  public var inProgress: Bool = false

  var canLogin: Bool {
    return !email.isEmpty && !inProgress
  }

  var staticErrorPublisher: AnyPublisher<Error?, Never>
  var cancellable: AnyCancellable?
  private let debugAccountsListFactory: DebugAccountListViewModel.Factory
  private let appAPIClient: AppAPIClient

  public init(
    email: String?,
    loginHandler: LoginStateMachine,
    activityReporter: ActivityReporterProtocol,
    debugAccountsListFactory: DebugAccountListViewModel.Factory,
    staticErrorPublisher: AnyPublisher<Error?, Never>,
    appAPIClient: AppAPIClient,
    completion: @escaping (LoginStateMachine.LoginResult?) -> Void
  ) {
    self.loginHandler = loginHandler
    self.email = email ?? ""
    self.debugAccountsListFactory = debugAccountsListFactory
    self.activityReporter = activityReporter
    self.completion = completion
    self.staticErrorPublisher = staticErrorPublisher
    self.appAPIClient = appAPIClient
    self.cancellable = self.staticErrorPublisher.sink { [weak self] error in
      self?.receiveStaticError(error)
    }
  }

  public func login() async {
    guard canLogin else {
      return
    }
    let login = Login(email)
    guard Email(email).isValid else {
      self.logError()
      self.updateUI(for: AccountError.invalidEmail)
      return
    }
    self.inProgress = true

    do {
      let loginResult = try await loginHandler.login(
        using: login, deviceId: Device.uniqueIdentifier())
      self.inProgress = false
      self.bubbleErrorMessage = nil
      self.completion(loginResult)
    } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.b2bSSOUserNotFound)
    {
      checkForSSOAccountCreation()
    } catch {
      self.inProgress = false
      self.logError()
      self.updateUI(for: error)
    }
  }

  func checkForSSOAccountCreation() {
    Task {
      do {
        guard
          let method = try await appAPIClient.account.accountCreationMethodAvailibility(
            for: Login(email)), case let .sso(info) = method
        else {
          throw AccountError.userNotFound
        }
        self.completion(.ssoAccountCreation(Login(self.email), info))
      } catch {
        self.inProgress = false
        self.logError()
        self.updateUI(for: error)
      }
    }
  }

  public func cancel() {
    activityReporter.report(UserEvent.UseAnotherAccount())
    completion(nil)
  }

  func receiveStaticError(_ error: Error?) {
    updateUI(for: error)
  }

  public func updateUI(for error: Error?) {
    guard let error = error else {
      return
    }

    switch error {
    case AccountError.invalidEmail:
      self.bubbleErrorMessage = CoreL10n.errorMessage(for: error)
    case let error as DashlaneAPI.APIError
    where error.hasAuthenticationCode(APIErrorCodes.Authentication.userNotFound):
      self.bubbleErrorMessage = CoreL10n.accountDoesNotExist
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.ssoBlocked):
      self.currentAlert = .ssoBlockedAlert
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.expiredVersion):
      self.currentAlert = .versionValidityAlert
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.invalidOTPBlocked):
      self.bubbleErrorMessage = CoreL10n.kwThrottleMsg
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.teamGenericError):
      self.bubbleErrorMessage = CoreL10n.Login.Team.genericError
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.deactivatedUser):
      self.currentAlert = .userDeactivatedAlert
    default:
      self.bubbleErrorMessage = CoreL10n.errorMessage(for: error)
    }
  }

  func logError() {
    activityReporter.report(UserEvent.Login(status: .errorWrongEmail))
  }

  public func updateApp() {
    defer {
      currentAlert = nil
    }
    guard let iTunesAppUrl = Bundle.main.object(forInfoDictionaryKey: "iTunesAppUrl") as? String,
      let url = URL(string: iTunesAppUrl)
    else {
      return
    }
    UIApplication.shared.open(url)
  }

  public func makeDebugAccountViewModel() -> DebugAccountListViewModel {
    debugAccountsListFactory.make()
  }

  public func deviceToDeviceLogin() {
    completion(.deviceToDeviceRemoteLogin(nil, loginHandler.deviceInfo))
  }
}

extension LoginInputViewModel {
  static var mock: LoginInputViewModel {
    LoginInputViewModel(
      email: "_",
      loginHandler: .mock,
      activityReporter: .mock,
      debugAccountsListFactory: .init({ .mock }),
      staticErrorPublisher: Just(nil).eraseToAnyPublisher(),
      appAPIClient: .fake
    ) { _ in }
  }
}
