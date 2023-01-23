import Foundation
import CoreSession
import CoreUserTracking
import DashTypes
import SwiftTreats
import CoreLocalization

@MainActor
public class AuthenticatorPushViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum CompletionType {
        case success
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
    let validator: () async throws -> Void
    let completion: (AuthenticatorPushViewModel.CompletionType) -> Void
    let login: Login

    public init(login: Login,
                validator: @escaping () async throws -> Void,
                completion: @escaping (AuthenticatorPushViewModel.CompletionType) -> Void) {
        self.login = login
        self.validator = validator
        self.completion = completion
        message = L10n.Core.authenticatorPushViewTitle(Self.authenticatorAppName)
    }

    func sendAuthenticatorPush() async {
        inProgress = true
        showRetry = false
        message = L10n.Core.authenticatorPushViewTitle(Self.authenticatorAppName)
        
        do {
            try await validator()
            self.message = L10n.Core.authenticatorPushViewAccepted
            self.isSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.completion(.success)
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
            self.message = CoreLocalization.L10n.errorMessage(for: error, login: self.login)
        }
    }

    func showToken() {
        completion(.token)
    }
}
