import Foundation
import CoreSession
import DashlaneAPI
import CorePasswords
import CoreUserTracking

@MainActor
public class AccountRecoveryKeyLoginFlowModel: ObservableObject, LoginKitServicesInjecting {

    public enum Completion {
        case completedWithChangeMP(CoreSession.MasterKey, AuthTicket, _ newMasterPassword: String)
        case completed(CoreSession.MasterKey, AuthTicket)
        case cancel
    }
    public enum Context {
        case remote(_ authTicket: AuthTicket)
        case deviceToDevice(_ authTicket: AuthTicket?, DeviceInfo)
        case local(_ authTicket: AuthTicket?, DeviceInfo)
    }

    enum Step {
        case verification(VerificationMethod, DeviceInfo)
        case recoveryKeyInput(_ authTicket: AuthTicket)
        case changeMasterPassword(MasterKey, AuthTicket)
    }

    @Published
    var steps: [Step] = []

    @Published
    var inProgress = false

    @Published
    var showError = false {
        didSet {
            if showError {
                inProgress = false
            }
        }
    }

    private let login: String
    private let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
    private let appAPIClient: AppAPIClient
    private let context: AccountRecoveryKeyLoginFlowModel.Context
    private let completion: @MainActor (Completion) -> Void
    private let accountType: AccountType
    private let passwordEvaluator: PasswordEvaluatorProtocol
    private let activityReporter: ActivityReporterProtocol
    
    public init(login: String,
                appAPIClient: AppAPIClient,
                accountType: AccountType,
                passwordEvaluator: PasswordEvaluatorProtocol,
                activityReporter: ActivityReporterProtocol,
                context: AccountRecoveryKeyLoginFlowModel.Context,
                accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
                completion: @escaping @MainActor (AccountRecoveryKeyLoginFlowModel.Completion) -> Void) {
        self.login = login
        self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
        self.appAPIClient = appAPIClient
        self.accountType = accountType
        self.context = context
        self.completion = completion
        self.passwordEvaluator = passwordEvaluator
        self.activityReporter = activityReporter
        logFlowStep(.start)
        switch context {
        case let .remote(authTicket):
            steps = [.recoveryKeyInput(authTicket)]
        case let .local(authTicket, deviceInfo), let .deviceToDevice(authTicket, deviceInfo):
            if let authTicket = authTicket {
                steps = [.recoveryKeyInput(authTicket)]
            } else {
                inProgress = true
                Task {
                    do {
                        let method = try await appAPIClient.authentication.get2FAStatusUnauthenticated(login: login).verificationMethod ?? .emailToken
                        steps = [.verification(method, deviceInfo)]
                    } catch {
                        logFlowStep(.error)
                        self.showError = true
                    }
                    inProgress = false
                }
            }
        }
    }

    func makeAccountVerificationFlowViewModel(method: VerificationMethod, deviceInfo: DeviceInfo) -> AccountVerificationFlowModel {
        accountVerificationFlowModelFactory.make(login: login, verificationMethod: method, deviceInfo: deviceInfo, debugTokenPublisher: nil, completion: { [weak self] completion in
            guard let self = self else {
                return
            }
            do {
                let (authTicket, _) = try completion.get()
                self.steps.append(.recoveryKeyInput(authTicket))
            } catch {
                self.showError = true
                logFlowStep(.error)
            }
        })
    }

    func makeAccountRecoveryKeyLoginViewModel(authTicket: AuthTicket) -> AccountRecoveryKeyLoginViewModel {
        return AccountRecoveryKeyLoginViewModel(login: login, appAPIClient: appAPIClient, authTicket: authTicket, accountType: accountType) { [weak self] masterKey, authTicket in
            guard let self = self else {
                return
            }
            guard accountType != .masterPassword else {
                self.steps.append(.changeMasterPassword(masterKey, authTicket))
                return
            }
            self.completion(.completed(masterKey, authTicket))
        }
    }

    func cancel() {
        logFlowStep(.cancel)
        completion(.cancel)
    }
    
    func makeNewMasterPasswordViewModel(masterKey: MasterKey, authTicket: AuthTicket) -> NewMasterPasswordViewModel {
        NewMasterPasswordViewModel(mode: .masterPasswordChange, evaluator: passwordEvaluator, activityReporter: activityReporter) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .back:
                _ = self.steps.popLast()
            case let .next(masterPassword):
                completion(.completedWithChangeMP(masterKey, authTicket, masterPassword))
            }
        }
    }
}

extension AccountRecoveryKeyLoginFlowModel {
    static var mock: AccountRecoveryKeyLoginFlowModel {
        AccountRecoveryKeyLoginFlowModel(login: "_", appAPIClient: .fake, accountType: .masterPassword, passwordEvaluator: PasswordEvaluatorMock.mock(), activityReporter: FakeActivityReporter(), context: .local(AuthTicket(value: "authTicket"), .mock), accountVerificationFlowModelFactory: .init({ _, _, _, _, _ in
                .mock(verificationMethod: .emailToken)
        }), completion: {_ in})
    }
}

extension AccountRecoveryKeyLoginFlowModel {
    func logFlowStep(_ step: Definition.FlowStep) {
        activityReporter.report(UserEvent.UseAccountRecoveryKey(flowStep: step))
    }
}
