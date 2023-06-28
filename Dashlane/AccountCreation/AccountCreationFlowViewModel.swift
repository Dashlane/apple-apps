import SwiftUI
import CoreSession
import DashTypes
import CorePasswords
import LoginKit
import CoreUserTracking

@MainActor
class AccountCreationFlowViewModel: ObservableObject, AccountCreationFlowDependenciesInjecting {
    enum Step {
        case email
        case masterPassword(email: Email)
        case create(AccountCreationConfiguration)
    }

    enum CompletionResult {
        case finished(SessionServicesContainer)
        case cancel
        case login(Login)
        case startSSO(email: Email, info: SSOLoginInfo)
    }

    @Published
    var steps: [Step] = [.email]

    let completion: @MainActor (CompletionResult) -> Void
    let evaluator: PasswordEvaluatorProtocol
    let activityReporter: ActivityReporterProtocol
    let emailViewModelFactory: AccountEmailViewModel.Factory
    let masterPasswordAccountCreationModelFactory: MasterPasswordAccountCreationFlowViewModel.Factory
    let passwordLessAccountCreationModelFactory: PasswordLessAccountCreationFlowViewModel.Factory

    private var savedMasterPassword: String?

    init(evaluator: PasswordEvaluatorProtocol,
         activityReporter: ActivityReporterProtocol,
         emailViewModelFactory: AccountEmailViewModel.Factory,
         masterPasswordAccountCreationModelFactory: MasterPasswordAccountCreationFlowViewModel.Factory,
         passwordLessAccountCreationModelFactory: PasswordLessAccountCreationFlowViewModel.Factory,
         completion: @escaping @MainActor (AccountCreationFlowViewModel.CompletionResult) -> Void) {
        self.evaluator = evaluator
        self.activityReporter = activityReporter
        self.emailViewModelFactory = emailViewModelFactory
        self.masterPasswordAccountCreationModelFactory = masterPasswordAccountCreationModelFactory
        self.passwordLessAccountCreationModelFactory = passwordLessAccountCreationModelFactory
        self.completion = completion
    }

    func makeEmailViewModel() -> AccountEmailViewModel {
        emailViewModelFactory.make { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .next(let email):
                self.steps.append(.masterPassword(email: email))
            case .login(let login):
                self.completion(.login(login))
            case let .sso(email, info):
                self.completion(.startSSO(email: email, info: info))
            case .cancel:
                self.completion(.cancel)
            }
        }
    }

    func makeNewPasswordModel(email: Email) -> NewMasterPasswordViewModel {
        NewMasterPasswordViewModel(mode: .accountCreation,
                                   masterPassword: savedMasterPassword,
                                   evaluator: evaluator,
                                   activityReporter: activityReporter) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .next(masterPassword: masterPassword):
                self.savedMasterPassword = masterPassword
                let configuration = AccountCreationConfiguration(email: email, password: masterPassword, accountType: .masterPassword)
                self.steps.append(.create(configuration))
            case let .back(masterPassword: masterPassword):
                self.savedMasterPassword = masterPassword
                self.steps.removeLast()
            }
        }
    }

    func startPasswordLess(email: Email) {
        let passwordPasswordGenerator = PasswordGenerator(length: 40, composition: .all, distinguishable: false)
        let configuration = AccountCreationConfiguration(email: email, password: passwordPasswordGenerator.generate(), accountType: .invisibleMasterPassword)
        self.steps.append(.create(configuration))
    }

    func makeMasterPasswordAccountCreationFlow(configuration: AccountCreationConfiguration) -> MasterPasswordAccountCreationFlowViewModel {
        masterPasswordAccountCreationModelFactory.make(configuration: configuration) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .finished(sessionServices):
                self.completion(.finished(sessionServices))
            case .cancel:
                self.steps.removeLast()
            }
        }
    }

    func makePasswordLessAccountCreationFlow(configuration: AccountCreationConfiguration) -> PasswordLessAccountCreationFlowViewModel {
        passwordLessAccountCreationModelFactory.make(configuration: configuration) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .finished(sessionServices):
                self.completion(.finished(sessionServices))
            case .cancel:
                self.steps.removeLast()
            }
        }
    }
}
