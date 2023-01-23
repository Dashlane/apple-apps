import Foundation
import Combine
import CoreSession
import CoreUserTracking
import DashTypes
import CoreLocalization

@MainActor
public protocol TokenViewModelProtocol: ObservableObject {
    var login: Login { get }
    var token: String { get set }
    var errorMessage: String? { get set }
    var inProgress: Bool { get }
    var logger: LoginInstallerLogger { get }
    func requestToken() async
    func validateToken()
    func autofillToken()
    func logResendToken()
    func logShowToken()
}

@MainActor
public extension TokenViewModelProtocol {
    var canLogin: Bool {
        return !token.isEmpty && !inProgress
    }
}

@MainActor
public class TokenViewModel: TokenViewModelProtocol, LoginKitServicesInjecting {
    static let expectedTokenSize = 6
    public enum CompletionType {
        case success
        case error(Error)
    }

    public var login: Login {
        return validator.login
    }

    @Published
    public var token: String = "" {
        didSet {
            if token.count > Self.expectedTokenSize ||  token.rangeOfCharacter(from: CharacterSet.letters) != nil {
                token = oldValue
            } else if token.count == Self.expectedTokenSize && token != oldValue {
                validateToken()
            }
            errorMessage = nil
        }
    }

    @Published
    public var errorMessage: String?

    @Published
    public var inProgress: Bool = false

    let tokenPublisher: AnyPublisher<String, Never>
    let validator: TokenDeviceRegistrationValidator
    let completion: (TokenViewModel.CompletionType) -> Void
    public let logger: LoginInstallerLogger
    var errorCount: Int = 0
    let activityReporter: ActivityReporterProtocol
    let testAccountAPIClient: TestAccountAPIClient

    private var cancellables: Set<AnyCancellable> = []

    public init(tokenPublisher: AnyPublisher<String, Never>,
                validator: TokenDeviceRegistrationValidator,
                networkEngine: DeprecatedCustomAPIClient,
                activityReporter: ActivityReporterProtocol,
                logger: LoginInstallerLogger,
                completion: @escaping (TokenViewModel.CompletionType) -> Void) {
        self.tokenPublisher = tokenPublisher
        self.validator = validator
        self.completion = completion
        self.logger = logger
        self.activityReporter = activityReporter
        self.testAccountAPIClient = .init(engine: networkEngine)

        tokenPublisher.assign(to: &$token)
    }

    public func requestToken() async {
        token = ""
        do {
            try await validator.requestToken()
            self.errorMessage = nil
        } catch {
            self.errorMessage = CoreLocalization.L10n.errorMessage(for: error, login: self.validator.login)
        }
    }

    public func validateToken() {
        guard !inProgress else {
            return
        }

        self.logger.logTokenClick()

        guard token.count == Self.expectedTokenSize else {
            self.errorMessage = L10n.Core.badToken
            self.logger.logBadToken()
            self.logError()
            return
        }

        inProgress = true

        validator.validateToken(token) { result in
            DispatchQueue.main.async {
                self.inProgress = false

                switch result {
                case .success:
                    self.errorMessage = nil
                    self.logger.logTokenOK()
                    self.completion(.success)
                case let .failure(error):
                    self.logError()
                    switch error {
                    case AccountError.accountBlocked,
                         AccountError.verificationRequiresRequest,
                         AccountError.rateLimitExceeded,
                         AccountError.tooManyAttempts:
                        self.completion(.error(error))
                        self.logger.logTokenTooManyAttempts()

                    default:
                        self.errorMessage = CoreLocalization.L10n.errorMessage(for: error, login: self.validator.login)
                        self.logger.logBadToken()
                    }
                }
            }

        }
    }

        public func autofillToken() {
        Task {
            self.token = try await testAccountAPIClient.token(for: validator.login)
        }
    }

    public func logShowToken() {
        logger.logShowToken()
        activityReporter.report(UserEvent.AskAuthentication(mode: .masterPassword,
                                                            reason: .login,
                                                            verificationMode: .emailToken))
        activityReporter.reportPageShown(.loginToken)
    }

    public func logResendToken() {
        activityReporter.report(UserEvent.ResendToken())
    }

    func logError() {
        activityReporter.report(UserEvent.Login(isBackupCode: false,
                                                mode: .masterPassword,
                                                status: .errorWrongOtp,
                                                verificationMode: .emailToken))
    }
}
