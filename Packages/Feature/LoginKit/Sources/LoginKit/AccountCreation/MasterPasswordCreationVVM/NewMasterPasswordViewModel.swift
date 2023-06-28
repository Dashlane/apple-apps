import Foundation
import CoreSession
import CorePasswords
import Combine
import CoreUserTracking
import DashlaneAppKit
import SwiftTreats
import DashTypes
import CoreKeychain
import CoreLocalization

public final class NewMasterPasswordViewModel: ObservableObject, LoginKitServicesInjecting {
    public enum Mode {
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
    
        var passwordStrength: PasswordStrength? {
        if password.isEmpty {
            return nil
        }
        
        return evaluator.evaluate(password)
    }
    
    @Published
    var errorLabel: String?
    
    @Published
    var focusActivated: Bool = false
    
    public enum Step {
        case masterPasswordCreation
        case masterPasswordConfirmation
    }
    
    @Published
    private(set) var step: Step
    
    var canCreate: Bool {
        guard let passwordStrength else {
            return false
        }
        
        return passwordStrength.rawValue >= PasswordStrength.somewhatGuessable.rawValue
    }
    
    let completion: (Completion) -> Void
    let evaluator: PasswordEvaluatorProtocol
    let activityReporter: ActivityReporterProtocol
        let keychainService: AuthenticationKeychainServiceProtocol?
    let login: Login?
    
    lazy var stepOnFocusPublisher: some Publisher<Step, Never> = {
        $step.combineLatest($focusActivated) { step, focusActivated in
            guard focusActivated else {
                return nil
            }
            return step
        }
        .compactMap { $0 }
    }()
    
    public enum Completion {
        case next(masterPassword: String)
        case back(masterPassword: String?)
    }
    
    public init(mode: NewMasterPasswordViewModel.Mode,
                masterPassword: String? = "",
                evaluator: PasswordEvaluatorProtocol,
                keychainService: AuthenticationKeychainServiceProtocol? = nil,
                login: Login? = nil,
                activityReporter: ActivityReporterProtocol,
                step: NewMasterPasswordViewModel.Step = .masterPasswordCreation,
                completion: @escaping (NewMasterPasswordViewModel.Completion) -> Void) {
        self.mode = mode
        self.password = masterPassword ?? ""
        self.step = step
        self.login = login
        self.evaluator = evaluator
        self.completion = completion
        self.keychainService = keychainService
        self.activityReporter = activityReporter
    }
    
        
    private func move(to step: Step) {
        self.step = step
    }
    
    func next() {
        switch step {
        case .masterPasswordCreation:
            validateMasterPasswordInitialEntry()
        case .masterPasswordConfirmation:
            validateMasterPasswordConfirmation()
        }
    }
    
    func back() {
        switch step {
        case .masterPasswordCreation:
            completion(.back(masterPassword: password != "" ? password : nil))
        case .masterPasswordConfirmation:
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
           let isEqualToCurrentMP = try? keychainService?.masterPasswordEquals(password, for: login),
           isEqualToCurrentMP == true {
            invalidPasswordAttempts += 1
            errorLabel = L10n.Core.changeMasterPasswordMustBeDifferentError
            return
        }
        
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
           let isEqualToCurrentMP = try? keychainService?.masterPasswordEquals(password, for: login),
           isEqualToCurrentMP == true {
            errorLabel = L10n.Core.changeMasterPasswordMustBeDifferentError
            return
        }
        
        guard password == confirmationPassword else {
            errorLabel = L10n.Core.minimalisticOnboardingMasterPasswordSecondConfirmationPasswordsNotMatching
            logError()
            return
        }
        
        if canCreate {
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
            return L10n.Core.accountCreationPasswordStrengthVeryLow
            
        case .veryGuessable:
            return L10n.Core.accountCreationPasswordStrengthLow
            
        case .somewhatGuessable:
            return L10n.Core.accountCreationPasswordStrengthMedium
            
        case .safelyUnguessable:
            return L10n.Core.accountCreationPasswordStrengthSafe
            
        case .veryUnguessable:
            return L10n.Core.accountCreationPasswordStrengthHigh
            
        }
    }
}
