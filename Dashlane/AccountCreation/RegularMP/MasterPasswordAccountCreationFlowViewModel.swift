import Foundation
import DashTypes
import SwiftTreats

@MainActor
class MasterPasswordAccountCreationFlowViewModel: ObservableObject, AccountCreationFlowDependenciesInjecting {
    enum Step: Equatable {
        case fastLocalSetup(biometry: Biometry?) 
        case userConsent
    }

    enum CompletionResult { 
        case finished(SessionServicesContainer)
        case cancel
    }

    @Published
    var steps: [Step] {
        didSet {
            if steps.isEmpty {
                self.completion(.cancel)
            }
        }
    }

    @Published
    var error: Error?

    let userConsentViewModelFactory: UserConsentViewModel.Factory
    let fastLocalSetupViewModelFactory: FastLocalSetupInAccountCreationViewModel.Factory
    let userCountryProvider: UserCountryProvider
    var configuration: AccountCreationConfiguration
    let accountCreationService: AccountCreationService
    let completion: @MainActor (MasterPasswordAccountCreationFlowViewModel.CompletionResult) -> Void

    init(configuration: AccountCreationConfiguration,
         userCountryProvider: UserCountryProvider,
         accountCreationService: AccountCreationService,
         userConsentViewModelFactory: UserConsentViewModel.Factory,
         fastLocalSetupViewModelFactory: FastLocalSetupInAccountCreationViewModel.Factory,
         completion: @escaping @MainActor (MasterPasswordAccountCreationFlowViewModel.CompletionResult) -> Void) {
        self.completion = completion
        self.configuration = configuration
        self.accountCreationService = accountCreationService
        self.userCountryProvider = userCountryProvider
        self.userConsentViewModelFactory = userConsentViewModelFactory
        self.fastLocalSetupViewModelFactory = fastLocalSetupViewModelFactory

        if let biometry = Device.biometryType {
            steps = [.fastLocalSetup(biometry: biometry)]
        } else if Device.isMac {
                        steps = [.fastLocalSetup(biometry: nil)]
        } else {
                        steps = [.userConsent]
        }
    }

    func makeFastLocalSetup() -> FastLocalSetupInAccountCreationViewModel {
        return fastLocalSetupViewModelFactory.make { [weak self] completion in
            guard let self = self else {
                return
            }

            switch completion {
            case let .next(isBiometricAuthenticationEnabled, isMasterPasswordResetEnabled, isRememberMasterPasswordEnabled):
                self.configuration.local.isBiometricAuthenticationEnabled = isBiometricAuthenticationEnabled
                self.configuration.local.isMasterPasswordResetEnabled = isMasterPasswordResetEnabled
                self.configuration.local.isRememberMasterPasswordEnabled = isRememberMasterPasswordEnabled
                self.steps.append(.userConsent)

            case .back:
                self.completion(.cancel)
            }
        }
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

    private func load() async {
        do {
            let sessionServices = try await self.accountCreationService.createAccountAndLoad(using: configuration)
            self.completion(.finished(sessionServices))
        } catch {
            self.error = error
        }
    }

    func cancel() {
        self.completion(.cancel)
    }
}
