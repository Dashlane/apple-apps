import Foundation
import CoreUserTracking
import CoreLocalization
import Combine
import CoreSession
import DashlaneAPI
import DashTypes

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
            if token.count > Self.expectedTokenSize ||  token.rangeOfCharacter(from: CharacterSet.letters) != nil {
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

    private var cancellables: Set<AnyCancellable> = []

    public init(
        tokenPublisher: AnyPublisher<String, Never>?,
        accountVerificationService: AccountVerificationService,
        activityReporter: ActivityReporterProtocol,
        completion: @escaping @MainActor (Result<AuthTicket, Error>) -> Void
    ) {
        self.tokenPublisher = tokenPublisher
        self.accountVerificationService = accountVerificationService
        self.completion = completion
        self.activityReporter = activityReporter
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
        } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCodes([.accountBlockedContactSupport, .verificationTimeout, .verificationRequiresRequest]) {
            self.logError()
            self.completion(.failure(error))
        } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCode(APIErrorCodes.Authentication.verificationFailed) {
            self.logError()
            self.errorMessage = CoreLocalization.L10n.errorMessage(for: AccountError.verificationDenied)
        } catch {
            self.logError()
            self.errorMessage = CoreLocalization.L10n.errorMessage(for: error)
        }
        inProgress = false
    }

        public func autofillToken() async {
        do {
            self.token = try await accountVerificationService.qaToken()
        } catch {}
    }

    public func logShowToken() {
        activityReporter.report(
            UserEvent.AskAuthentication(
                mode: .masterPassword,
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
            activityReporter: FakeActivityReporter(),
            completion: { _ in }
        )
    }
}

extension DashlaneAPI.APIError {
    func hasAuthenticationCodes(_ codes: [APIErrorCodes.Authentication]) -> Bool {
        codes.contains { hasAuthenticationCode($0) }
    }
}
