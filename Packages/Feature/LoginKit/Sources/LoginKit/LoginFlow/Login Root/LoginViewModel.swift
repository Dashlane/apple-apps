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
public class LoginViewModel: ObservableObject, LoginKitServicesInjecting {

    let loginHandler: LoginHandler
    let loginMetricsReporter: LoginMetricsReporterProtocol
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

    var canLogin: Bool {
        return !email.isEmpty && !inProgress
    }

    var staticErrorPublisher: AnyPublisher<Error?, Never>
    var cancellable: AnyCancellable?
    private let versionValidityAlertProvider: AlertContent
    private let debugAccountsListFactory: DebugAccountListViewModel.Factory
    private let appAPIClient: AppAPIClient

    public init(email: String?,
                loginHandler: LoginHandler,
                activityReporter: ActivityReporterProtocol,
                loginMetricsReporter: LoginMetricsReporterProtocol,
                debugAccountsListFactory: DebugAccountListViewModel.Factory,
                staticErrorPublisher: AnyPublisher<Error?, Never>,
                versionValidityAlertProvider: AlertContent,
                appAPIClient: AppAPIClient,
                completion: @escaping (LoginHandler.LoginResult?) -> Void) {
        self.loginHandler = loginHandler
        self.email = email ?? ""
        self.debugAccountsListFactory = debugAccountsListFactory
        self.activityReporter = activityReporter
        self.loginMetricsReporter = loginMetricsReporter
        self.completion = completion
        self.versionValidityAlertProvider = versionValidityAlertProvider
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
            let loginResult = try await loginHandler.login(using: login, deviceId: Device.uniqueIdentifier(), context: LoginContext(origin: .mobile))
            self.inProgress = false
            self.bubbleErrorMessage = nil
            self.completion(loginResult)
        } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.b2bSsoUserNotFound) {
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
                guard let method = try await appAPIClient.account.accountCreationMethodAvailibility(for: Login(email), context: LoginContext(origin: .mobile)), case let .sso(info) = method else {
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
            self.bubbleErrorMessage = L10n.errorMessage(for: error)
        case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.userNotFound):
            self.bubbleErrorMessage = L10n.Core.accountDoesNotExist
        case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.ssoBlocked):
            self.currentAlert = .init(title: L10n.Core.ssoBlockedError,
                                      buttons: .one(.init(title: L10n.Core.kwButtonOk)))
        case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.clientVersionDoesNotSupportSsoMigration):
            self.currentAlert = .init(title: L10n.Core.updateAppTitle,
                                      message: L10n.Core.updateAppMessage,
                                      buttons: .two(primaryButton: .init(title: L10n.Core.kwPcOnboardingNotNow),
                                                    secondaryButton: .init(title: L10n.Core.update,
                                                                           action: { [weak self] in self?.updateApp() })))
        case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.expiredVersion):
            self.currentAlert = self.versionValidityAlertProvider
        case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.invalidOtpBlocked):
            self.bubbleErrorMessage = L10n.Core.kwThrottleMsg
        case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.teamGenericError):
            self.bubbleErrorMessage = L10n.Core.Login.Team.genericError
        default:
            self.bubbleErrorMessage = L10n.errorMessage(for: error)
        }
    }

        public func resetLoginUsageLogs() {
        loginMetricsReporter.reset()
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

    public func deviceToDeviceLogin() {
        completion(.deviceToDeviceRemoteLogin(loginHandler.makeDeviceToDeviceLoginHandler(context: LoginContext(origin: .mobile))))
    }
}

extension LoginViewModel {
    static var mock: LoginViewModel {
        LoginViewModel(
            email: "_",
            loginHandler: .mock,
            activityReporter: FakeActivityReporter(),
            loginMetricsReporter: .fake,
            debugAccountsListFactory: .init({ .mock }),
            staticErrorPublisher: Just(nil).eraseToAnyPublisher(),
            versionValidityAlertProvider: AlertContent(title: ""),
            appAPIClient: .fake
        ) { _ in }
    }
}
