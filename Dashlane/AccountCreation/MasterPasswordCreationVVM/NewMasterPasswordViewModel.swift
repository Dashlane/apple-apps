import Foundation
import CoreSession
import CorePasswords
import Combine
import CoreUserTracking
import DashlaneAppKit
import LoginKit
import SwiftTreats
import DashTypes
import CoreKeychain

class NewMasterPasswordViewModel: ObservableObject {

    enum Mode {
        case accountCreation
        case masterPasswordChange
    }

    let mode: Mode

    @Published
    var invalidPasswordAttempts: Int = 0

    @Published
    var password: String {
        didSet {
            errorLabel = nil
        }
    }

    @Published
    var confirmationPassword: String = "" {
        didSet {
            errorLabel = nil
        }
    }

    var passwordStrengthMessage: String {
        if password.isEmpty {
            return L10n.Localizable.masterpasswordCreationExplaination
        }

        return passwordEvaluation.strength.description
    }

    var passwordStrength: PasswordStrength? {
        if password.isEmpty {
            return nil
        }

        return passwordEvaluation.strength
    }

    private var passwordEvaluation: PasswordEvaluation {
        return evaluator.evaluate(password)
    }

    @Published
    var errorLabel: String?

    @Published
    var focusActivated: Bool = false

    enum Step {
        case masterPasswordCreation
        case masterPasswordConfirmation
    }

    @Published
    private(set) var step: Step

    var canCreate: Bool {
        guard let passwordStrength = passwordStrength else {
            return false
        }

        return passwordStrength.rawValue >= PasswordStrength.somewhatGuessable.rawValue
    }

    let completion: (Completion) -> Void
    let evaluator: PasswordEvaluatorProtocol
    let logger: AccountCreationInstallerLogger? 
    let activityReporter: ActivityReporterProtocol
    let keychainService: AuthenticationKeychainServiceProtocol
    let login: Login?

    lazy var stepOnFocusPublisher: AnyPublisher<Step, Never> = {
        return $step.combineLatest($focusActivated) { step, focusActivated in
            guard focusActivated else {
                return nil
            }
            return step
        }
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }()

    enum Completion {
        case next(masterPassword: String)
        case back(masterPassword: String?)
    }

    init(mode: Mode, masterPassword: String? = "",
         evaluator: PasswordEvaluatorProtocol,
         logger: AccountCreationInstallerLogger?,
         keychainService: AuthenticationKeychainServiceProtocol,
         login: Login? = nil,
         activityReporter: ActivityReporterProtocol,
         step: Step = .masterPasswordCreation,
         completion: @escaping (Completion) -> Void) {
        self.mode = mode
        self.password = masterPassword ?? ""
        self.step = step
        self.login = login
        self.evaluator = evaluator
        self.logger = logger
        self.completion = completion
        self.keychainService = keychainService
        self.activityReporter = activityReporter
    }

        private func move(to step: Step) {
        self.step = step

        if step == .masterPasswordConfirmation {
            logger?.log(.masterPasswordConfirmation(action: .shown))
        }
    }

    func next() {
        switch step {
        case .masterPasswordCreation:
            logger?.log(.masterPasswordInitialEntry(action: .next))
            validateMasterPasswordInitialEntry()
        case .masterPasswordConfirmation:
            logger?.log(.masterPasswordConfirmation(action: .next))
            validateMasterPasswordConfirmation()
        }
    }

    func back() {
        switch step {
        case .masterPasswordCreation:
            logger?.log(.masterPasswordInitialEntry(action: .back))
            completion(.back(masterPassword: password != "" ? password : nil))
        case .masterPasswordConfirmation:
            logger?.log(.masterPasswordConfirmation(action: .back))
            move(to: .masterPasswordCreation)
        }
    }

        func validateMasterPasswordInitialEntry() {
        #if DEBUG
        if !ProcessInfo.isTesting, password.isEmpty {
            password = TestAccount.password
        }
        #endif

        if let login = login,
           let isEqualToCurrentMP = try? keychainService.masterPasswordEquals(password, for: login),
           isEqualToCurrentMP == true {
            invalidPasswordAttempts += 1
            errorLabel = L10n.Localizable.changeMasterPasswordMustBeDifferentError
            return
        }

        passwordStrength.map { logger?.logPasswordStrengthWhenValidationIsRequested($0) }

        if canCreate {
            move(to: .masterPasswordConfirmation)
        } else {
            invalidPasswordAttempts += 1
            return
        }
    }

    func validateMasterPasswordConfirmation() {
        #if DEBUG
        if !ProcessInfo.isTesting, confirmationPassword.isEmpty {
            confirmationPassword = TestAccount.password
        }
        #endif

        if let login = login,
           let isEqualToCurrentMP = try? keychainService.masterPasswordEquals(password, for: login),
           isEqualToCurrentMP == true {
            errorLabel = L10n.Localizable.changeMasterPasswordMustBeDifferentError
            return
        }

        guard password == confirmationPassword else {
            logger?.log(.masterPasswordConfirmation(action: .passwordsNotMatching))
            errorLabel = L10n.Localizable.minimalisticOnboardingMasterPasswordSecondConfirmationPasswordsNotMatching
            logError()
            return
        }

        if canCreate {
            logger?.log(.masterPasswordConfirmation(action: .passwordsMatching))
            completion(.next(masterPassword: password))
        } else {
            invalidPasswordAttempts += 1
            return
        }
    }

    func logError() {
        if mode == .masterPasswordChange {
            activityReporter.report(UserEvent.ChangeMasterPassword(flowStep: .error))
        }
    }

}

extension PasswordStrength {
    var description: String {
        switch self {
        case .tooGuessable:
            return L10n.Localizable.accountCreationPasswordStrengthVeryLow

        case .veryGuessable:
            return L10n.Localizable.accountCreationPasswordStrengthLow

        case .somewhatGuessable:
            return L10n.Localizable.accountCreationPasswordStrengthMedium

        case .safelyUnguessable:
            return L10n.Localizable.accountCreationPasswordStrengthSafe

        case .veryUnguessable:
            return L10n.Localizable.accountCreationPasswordStrengthHigh

        }
    }
}
