import Combine
import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import SwiftTreats
import UIDelight

@MainActor
class AccountEmailViewModel: ObservableObject, AccountCreationFlowDependenciesInjecting {

  enum CompletionResult {
    case next(Email, isB2BAccount: Bool)
    case login(Login)
    case sso(Email, SSOLoginInfo)
    case cancel
  }

  @Published
  var email: String = "" {
    didSet {
      bubbleErrorMessage = nil
    }
  }

  @Published
  var currentAlert: AlertContent?

  @Published
  var bubbleErrorMessage: String? {
    didSet {
      if bubbleErrorMessage != nil {
        shouldDisplayProgress = false
      }
    }
  }

  @Published
  var shouldDisplayProgress: Bool = false

  private let completion: (_ result: CompletionResult) -> Void
  private let activityReporter: ActivityReporterProtocol
  private let appAPIClient: AppAPIClient

  init(
    appAPIClient: AppAPIClient,
    activityReporter: ActivityReporterProtocol,
    completion: @escaping (_ result: AccountEmailViewModel.CompletionResult) -> Void
  ) {
    self.appAPIClient = appAPIClient
    self.activityReporter = activityReporter
    self.completion = completion
  }

  func showLoginView() {
    completion(.login(Login(email)))
  }

  func cancel() {
    completion(.cancel)
  }

  func validate() async {

    if skipValidationInDebug() { return }

    guard validateNotEmpty() else { return }

    guard let login = login(from: email) else { return }

    shouldDisplayProgress = true

    do {
      let method = try await appAPIClient.account.accountCreationMethodAvailibility(
        for: Login(email))
      handleAccountCreationMethodAvailibility(method, for: login)
    } catch let error as DashlaneAPI.APIError where error.hasAccountCode(.expiredVersion) {
      self.currentAlert = VersionValidityAlert.errorAlert()
    } catch let error as AccountExistsError where error == .unlikelyValue {
      self.activityReporter.logAccountCreation(.errorNotValidEmail)
      self.bubbleErrorMessage = CoreLocalization.L10n.errorMessage(for: error)
    } catch {
      self.bubbleErrorMessage = CoreLocalization.L10n.errorMessage(for: error)
    }
  }

  private func validateNotEmpty() -> Bool {
    guard !email.isEmpty else {
      self.bubbleErrorMessage = L10n.Localizable.kwAddPwdsOnbdingEmailPlaceholder

      return false
    }

    return true
  }

  private func login(from input: String) -> Email? {
    let email = Email(input)

    guard email.isValid else {
      self.bubbleErrorMessage = CoreLocalization.L10n.errorMessage(for: AccountError.invalidEmail)
      self.activityReporter.logAccountCreation(.errorNotValidEmail)
      return nil
    }

    return email
  }

  private func handleAccountCreationMethodAvailibility(
    _ method: AccountCreationMethodAvailibility?, for login: Email
  ) {
    switch method {
    case .none:
      self.bubbleErrorMessage = CoreLocalization.L10n.Core.kwAccountCreationExistingAccount
      self.activityReporter.logAccountCreation(.errorAccountAlreadyExists)
    case let .sso(info):
      self.completion(.sso(login, info))
    case let .masterpassword(isB2BAccount):
      self.shouldDisplayProgress = false
      self.completion(.next(login, isB2BAccount: isB2BAccount))
    }
  }

  private func skipValidationInDebug() -> Bool {
    #if DEBUG
      if email.isEmpty, !ProcessInfo.isTesting {
        let randomEmail = Login.generateTest()
        email = randomEmail
        self.completion(.next(Email(email), isB2BAccount: false))
        return true
      }
    #endif
    return false
  }
}

extension ActivityReporterProtocol {
  fileprivate func logAccountCreation(_ status: Definition.AccountCreationStatus) {
    report(
      UserEvent.CreateAccount(
        isMarketingOptIn: false,
        status: status))
  }
}
