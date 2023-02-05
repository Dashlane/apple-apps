import Foundation
import Combine
import CoreSession
import DashTypes
import CoreUserTracking
import DashlaneAppKit
import UIDelight
import LoginKit
import CoreLocalization
import SwiftTreats

protocol EmailViewModelProtocol: ObservableObject {
    var email: String { get set }
    var currentAlert: AlertContent? { get set }
    var bubbleErrorMessage: String? { get set }
    var shouldDisplayProgress: Bool { get set }
    var logger: AccountCreationInstallerLogger { get }
    func validate()
    func showLoginView()
    func cancel()
}

class EmailViewModel: EmailViewModelProtocol {

    enum CompletionResult {
        case next(Email)
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

    let accountCreationHandler: AccountCreationHandler

    @Published
    var currentAlert: AlertContent?

    @Published
    var bubbleErrorMessage: String?

    @Published
    var shouldDisplayProgress: Bool = false

    let completion: (_ result: CompletionResult) -> Void
    let logger: AccountCreationInstallerLogger
    let activityReporter: ActivityReporterProtocol

    init(accountCreationHandler: AccountCreationHandler,
         logger: AccountCreationInstallerLogger,
         activityReporter: ActivityReporterProtocol,
         completion: @escaping (_ result: CompletionResult) -> Void) {
        self.accountCreationHandler = accountCreationHandler
        self.activityReporter = activityReporter
        self.logger = logger
        self.completion = completion
    }

        func showLoginView() {
        completion(.login(Login(email)))
    }

    func cancel() {
        logger.log(.email(action: .back))
        completion(.cancel)
    }

        func validate() {
        self.logger.log(.email(action: .next))

                if skipValidationInDebug() { return }

                guard validateNotEmpty() else { return }

                guard let login = login(from: email) else { return }

                shouldDisplayProgress = true

                accountCreationHandler.accountCreationMethodAvailability(for: Login(email), context: LoginContext(origin: .mobile)) { [weak self] result in
            self?.handle(result, for: login)
        }
    }

    private func validateNotEmpty() -> Bool {
        guard !email.isEmpty else {
            self.logger.log(.email(action: .emailFieldEmpty))
            self.bubbleErrorMessage = L10n.Localizable.kwAddPwdsOnbdingEmailPlaceholder

            return false
        }

        return true
    }

                private func login(from input: String) -> Email? {
        let email = Email(input)

        guard email.isValid else {
            self.bubbleErrorMessage = CoreLocalization.L10n.errorMessage(for: AccountError.invalidEmail, login: Login(input))
            self.logger.log(.email(action: .emailNotValid))
            self.activityReporter.logAccountCreation(.errorNotValidEmail)
            return nil
        }

        return email
    }

        private func handle(_ result: Result<AccountCreationMethodAvailability?, Error>, for login: Email) {
        self.shouldDisplayProgress = false

        switch result {
        case .success(let method):
            handleAccountCreationMethodAvailability(method, for: login)
        case .failure(let error):
            if case AccountError.expiredVersion = error {
                self.currentAlert = VersionValidityAlert.errorAlert()
            } else {
                self.bubbleErrorMessage = CoreLocalization.L10n.errorMessage(for: error, login: Login(self.email))
            }
        }
    }

    private func handleAccountCreationMethodAvailability(_ method: AccountCreationMethodAvailability?, for login: Email) {
        switch method {
        case .none:
            self.bubbleErrorMessage = L10n.Localizable.kwAccountCreationExistingAccount
            self.logger.log(.email(action: .accountAlreadyExists))
            self.activityReporter.logAccountCreation(.errorAccountAlreadyExists)
        case let .sso(info):
            self.completion(.sso(login, info))
        case .masterpassword:
            self.shouldDisplayProgress = false
            self.completion(.next(login))
        }
    }

        private func skipValidationInDebug() -> Bool {
        #if DEBUG
        if email.isEmpty, !ProcessInfo.isTesting {
            let randomEmail = Login.generateTest()
            email = randomEmail
            self.completion(.next(Email(email)))
            return true
        }
        #endif
        return false
    }
}

private extension ActivityReporterProtocol {
    func logAccountCreation(_ status: Definition.AccountCreationStatus) {
        report(UserEvent.CreateAccount(isMarketingOptIn: false,
                                       status: status))
    }
}
