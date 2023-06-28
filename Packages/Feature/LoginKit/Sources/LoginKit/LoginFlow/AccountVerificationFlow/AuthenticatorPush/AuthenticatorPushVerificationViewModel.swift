import Foundation
import CoreSession
import CoreUserTracking
import DashTypes
import SwiftTreats
import CoreLocalization

@MainActor
public class AuthenticatorPushVerificationViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum CompletionType {
        case success(_ authTicket: AuthTicket)
        case token
        case error(Error)
    }

    @Published
    var showRetry: Bool = false

    @Published
    var message: String

    @Published
    var inProgress: Bool = true

    @Published
    var isSuccess: Bool = false

    static let authenticatorAppName = "Dashlane Authenticator"
    let accountVerificationService: AccountVerificationService
    let completion: (AuthenticatorPushVerificationViewModel.CompletionType) -> Void
    let login: Login

    public init(login: Login,
                accountVerificationService: AccountVerificationService,
                completion: @escaping (AuthenticatorPushVerificationViewModel.CompletionType) -> Void) {
        self.login = login
        self.accountVerificationService = accountVerificationService
        self.completion = completion
        message = L10n.Core.authenticatorPushViewTitle(Self.authenticatorAppName)
    }

    func sendAuthenticatorPush() async {
        inProgress = true
        showRetry = false
        message = L10n.Core.authenticatorPushViewTitle(Self.authenticatorAppName)

        do {
            let authTicket = try await accountVerificationService.validateUsingAuthenticatorPush()
            self.message = L10n.Core.authenticatorPushViewAccepted
            self.isSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.completion(.success(authTicket))
            }
        } catch {
            self.isSuccess = false
            self.showRetry = true
            self.handleError(error)
        }
        self.inProgress = false
    }

    private func handleError(_ error: Error) {
        switch error {
        case AccountError.rateLimitExceeded:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.completion(.error(error))
            }
        case AccountError.verificationDenied:
            self.message = L10n.Core.authenticatorPushViewDeniedError
        case AccountError.verificationtimeOut:
            self.message = L10n.Core.authenticatorPushViewTimeOutError
        default:
            self.message = CoreLocalization.L10n.errorMessage(for: error)
        }
    }

    func showToken() {
        completion(.token)
    }
}
