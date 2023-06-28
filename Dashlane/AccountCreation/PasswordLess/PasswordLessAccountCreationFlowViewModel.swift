import Foundation
import DashTypes
import SwiftTreats

@MainActor
class PasswordLessAccountCreationFlowViewModel: ObservableObject, AccountCreationFlowDependenciesInjecting {
    enum Step {
        case intro
        case pinCode 
        case biometry(biometry: Biometry)
        case userConsent
        case complete(SessionServicesContainer)
    }

    enum CompletionResult { 
        case finished(SessionServicesContainer)
        case cancel
    }

    @Published
    var steps: [Step] = [.intro]

    @Published
    var error: Error?

    let userConsentViewModelFactory: UserConsentViewModel.Factory
    let fastLocalSetupViewModelFactory: FastLocalSetupInAccountCreationViewModel.Factory

    let userCountryProvider: UserCountryProvider
    @Published
    var configuration: AccountCreationConfiguration
    let accountCreationService: AccountCreationService
    let completion: @MainActor (PasswordLessAccountCreationFlowViewModel.CompletionResult) -> Void

    init(configuration: AccountCreationConfiguration,
         userCountryProvider: UserCountryProvider,
         accountCreationService: AccountCreationService,
         userConsentViewModelFactory: UserConsentViewModel.Factory,
         fastLocalSetupViewModelFactory: FastLocalSetupInAccountCreationViewModel.Factory,
         completion: @escaping @MainActor (PasswordLessAccountCreationFlowViewModel.CompletionResult) -> Void) {
        self.completion = completion
        self.configuration = configuration
        self.accountCreationService = accountCreationService
        self.userCountryProvider = userCountryProvider
        self.userConsentViewModelFactory = userConsentViewModelFactory
        self.fastLocalSetupViewModelFactory = fastLocalSetupViewModelFactory
    }

    func makeUserContentViewModel() -> UserConsentViewModel {
        return userConsentViewModelFactory.make(isEmailMarketingOptInRequired: userCountryProvider.userCountry.isEu) { [weak self] completion in
            guard let self = self else {
                return
            }

            switch completion {
            case .next(_, let hasUserAcceptedEmailMarketing):
                self.configuration.hasUserAcceptedEmailMarketing = hasUserAcceptedEmailMarketing
                Task {
                    await self.load()
                }

            case .back(_, let hasUserAcceptedEmailMarketing):
                self.configuration.hasUserAcceptedEmailMarketing = hasUserAcceptedEmailMarketing
                self.steps.removeLast()
            }
        }
    }

    func startCreation() {
        steps.append(.pinCode)
    }

    func setupPin(_ pin: String) {
        configuration.local.pincode = pin
        if let biometry = Device.biometryType {
            steps.append(.biometry(biometry: biometry))
        } else {
            steps.append(.userConsent)
        }
    }

    func enableBiometry() {
        configuration.local.isBiometricAuthenticationEnabled = true
        steps.append(.userConsent)
    }

    func skipBiometry() {
        steps.append(.userConsent)
    }

    private func load() async {
        do {
            let sessionServices = try await self.accountCreationService.createAccountAndLoad(using: configuration)
            self.steps.append(.complete(sessionServices))
        } catch {
            self.error = error
        }
    }

    func finish(with sessionServices: SessionServicesContainer) {
        self.completion(.finished(sessionServices))
    }

    func cancel() {
        self.completion(.cancel)
    }
}
