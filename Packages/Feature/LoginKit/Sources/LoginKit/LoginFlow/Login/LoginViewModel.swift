import Foundation
import CoreSession
import Combine
import DashTypes
import CoreUserTracking
import SwiftTreats
import UIDelight
import SwiftUI
import CoreLocalization
#if canImport(UIKit)
import UIKit
import CoreNetworking
#endif
import DashlaneAPI

@MainActor
public protocol LoginViewModelProtocol: ObservableObject {
    var email: String { get set }
    var inProgress: Bool { get }
    var bubbleErrorMessage: String? { get set }
    var currentAlert: AlertContent? { get set }

    func makeDebugAccountViewModel() -> DebugAccountListViewModel
    func login() async
    func cancel()
    func resetLoginUsageLogs()
    func updateApp()
}

public extension LoginViewModelProtocol {
    var canLogin: Bool {
        return !email.isEmpty && !inProgress
    }
}

@MainActor
public class LoginViewModel: LoginViewModelProtocol, LoginKitServicesInjecting {

    let loginHandler: LoginHandler
    let installerLogService: InstallerLogServiceProtocol
    let loginUsageLogService: LoginUsageLogServiceProtocol
    let completion: (LoginHandler.LoginResult?) -> Void
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
    public var currentAlert: AlertContent?

    @Published
    public var inProgress: Bool = false

    var staticErrorPublisher: AnyPublisher<Error?, Never>
    var cancellable: AnyCancellable?
    private let versionValidityAlertProvider: AlertContent
    private let debugAccountsListFactory: DebugAccountListViewModel.Factory
    private let accountCreationHandler: AccountCreationHandler
    
    public init(email: String?,
                loginHandler: LoginHandler,
                sessionsContainer: SessionsContainerProtocol,
                activityReporter: ActivityReporterProtocol,
                installerLogService: InstallerLogServiceProtocol,
                loginUsageLogService: LoginUsageLogServiceProtocol,
                debugAccountsListFactory: DebugAccountListViewModel.Factory,
                staticErrorPublisher: AnyPublisher<Error?, Never>,
                versionValidityAlertProvider: AlertContent,
                appAPIClient: AppAPIClient,
                completion: @escaping (LoginHandler.LoginResult?) -> Void) {
        self.loginHandler = loginHandler
        self.email = email ?? ""
        self.debugAccountsListFactory = debugAccountsListFactory
        self.activityReporter = activityReporter
        self.loginUsageLogService = loginUsageLogService
        self.completion = completion
        self.versionValidityAlertProvider = versionValidityAlertProvider
        self.installerLogService = installerLogService
        self.staticErrorPublisher = staticErrorPublisher
        self.accountCreationHandler = AccountCreationHandler(apiClient: appAPIClient)
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
        self.installerLogService.login.logEmailIsCorrect()
        self.inProgress = true
        
        do {
            let loginResult = try await loginHandler.login(using: login, deviceId: Device.uniqueIdentifier(), context: LoginContext(origin: .mobile))
            self.inProgress = false
            self.bubbleErrorMessage = nil
            self.completion(loginResult)
        } catch AccountError.userNotFound {
            checkForSSOAccountCreation()
        } catch {
            self.inProgress = false
            self.logError()
            self.updateUI(for: error)
        }
    }

        func checkForSSOAccountCreation() {
        accountCreationHandler.accountCreationMethodAvailability(for: Login(email), context: LoginContext(origin: .mobile)) { result in
            do {
                guard let method = try result.get(), case let .sso(info) = method else {
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
        installerLogService.login.logLoginBack()
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
            self.installerLogService.login.logEmailIsIncorrect()
            self.bubbleErrorMessage = L10n.errorMessage(for: error, login: Login(self.email))
        case AccountError.userNotFound:
            self.installerLogService.login.logUserNotFound()
            self.bubbleErrorMessage = L10n.errorMessage(for: error, login: Login(self.email))
        case AccountError.ssoBlocked:
            self.installerLogService.sso.log(.loginEmailIsNotProvisionedSSOAccount)
            self.currentAlert = .init(title: L10n.errorMessage(for: error, login: Login(self.email)),
                                      buttons: .one(.init(title: L10n.Core.kwButtonOk)))
        case AccountError.ssoMigrationNotSupported:
            self.currentAlert = .init(title: L10n.Core.updateAppTitle,
                                      message: L10n.Core.updateAppMessage,
                                      buttons: .two(primaryButton: .init(title: L10n.Core.kwPcOnboardingNotNow),
                                                    secondaryButton: .init(title: L10n.Core.update,
                                                                           action: { [weak self] in self?.updateApp() })))
        case AccountError.expiredVersion:
            self.currentAlert = self.versionValidityAlertProvider
        case AccountError.invalidOtpBlocked,
            AccountError.rateLimitExceeded:
            self.bubbleErrorMessage = L10n.errorMessage(for: error, login: Login(self.email))
        default:
            self.bubbleErrorMessage = L10n.errorMessage(for: error, login: Login(self.email))
        }
    }

        public func resetLoginUsageLogs() {
        loginUsageLogService.reset()
    }

    func logError() {
        activityReporter.report(UserEvent.Login(status: .errorWrongEmail))
    }

    public func updateApp() {
        defer {
            currentAlert = nil
        }
        guard let iTunesAppUrl = Bundle.main.object(forInfoDictionaryKey: "iTunesAppUrl") as? String,
              let url = URL(string: iTunesAppUrl) else {
            return
        }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }

    public func makeDebugAccountViewModel() -> DebugAccountListViewModel {
        debugAccountsListFactory.make()
    }
}
