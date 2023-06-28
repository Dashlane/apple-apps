import Foundation
import DashTypes
import CoreNetworking
import CoreSync
import Combine
import TOTPGenerator
import CorePersonalData
import CoreUserTracking
import DashlaneAppKit
import AuthenticatorKit
import IconLibrary
import VaultKit

class AddOTPManuallyFlowViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {

    enum Step {
        case enterToken(AddOTPSecretViewModel)
        case manuallyChooseWebsite(ChooseWebsiteViewModel)
        case enterLoginDetails(AddLoginDetailsViewModel)
        case chooseCredential(viewModel: MatchingCredentialListViewModel)
        case addCredential(viewModel: CredentialDetailViewModel)
        case success(mode: AddOTPSuccessView.Mode, configuration: OTPConfiguration)
    }

    enum Completion {
        case completed(OTPConfiguration)
        case failure(AddOTPFlowViewModel.Step.FailureReason)
    }

    @Published
    var steps: [Step] = []

    private let completion: (Completion) -> Void

    let dismissPublisher = PassthroughSubject<Void, Never>()
    let vaultItemsService: VaultItemsServiceProtocol
    let matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory
    let chooseWebsiteViewModelFactory: ChooseWebsiteViewModel.Factory
    let addLoginDetailsViewModelFactory: AddLoginDetailsViewModel.Factory
    let credentialDetailViewModelFactory: CredentialDetailViewModel.Factory

    init(credential: Credential?,
         vaultItemsService: VaultItemsServiceProtocol,
         matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory,
         chooseWebsiteViewModelFactory: ChooseWebsiteViewModel.Factory,
         addLoginDetailsViewModelFactory: AddLoginDetailsViewModel.Factory,
         credentialDetailViewModelFactory: CredentialDetailViewModel.Factory,
         completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void) {
        self.chooseWebsiteViewModelFactory = chooseWebsiteViewModelFactory
        self.vaultItemsService = vaultItemsService
        self.addLoginDetailsViewModelFactory = addLoginDetailsViewModelFactory
        self.credentialDetailViewModelFactory = credentialDetailViewModelFactory
        self.matchingCredentialListViewModelFactory = matchingCredentialListViewModelFactory
        self.completion = completion
        if let credential = credential {
            add(.enterToken(makeAddOTPSecretKeyViewModel(credential: credential)))
        } else {
            add(.manuallyChooseWebsite(makeChooseWebsiteViewModel()))
        }
    }

    private func makeChooseWebsiteViewModel() -> ChooseWebsiteViewModel {
        chooseWebsiteViewModelFactory.make { [weak self] website in
            guard let self = self else { return }
            Task {

                                guard !website.lowercased().contains("dashlane") else {
                    await MainActor.run {
                        self.completion(.failure(.dashlaneSecretDetected))
                    }
                    return
                }

                let matchingCredentials = self.vaultItemsService.credentials.withoutOTP().matchingCredentials(forDomain: website)
                switch matchingCredentials.count {
                case 0:
                                        self.add(.enterLoginDetails(self.makeAddLoginDetailsViewModel(website: website,
                                                                                  credential: nil)))
                case 1:
                                        guard let credential = matchingCredentials.first else {
                        return
                    }
                    self.add(.enterLoginDetails(self.makeAddLoginDetailsViewModel(website: website,
                                                                        credential: credential)))
                default:
                                        self.add(.chooseCredential(viewModel: self.matchingCredentialListViewModelFactory.make(
                        website: website,
                        matchingCredentials: matchingCredentials
                    ) { [weak self] action in
                        self?.handleMatchingCredentialCompletion(action: action, for: website)
                    }))
                }
            }
        }
    }

    func add(_ navigationStep: Step) {
        Task {
            await MainActor.run {
                steps.append(navigationStep)
            }
        }
    }

    private func makeAddLoginDetailsViewModel(website: String,
                                              credential: Credential?) -> AddLoginDetailsViewModel {
        addLoginDetailsViewModelFactory.make(website: website,
                                             credential: credential,
                                             supportDashlane2FA: false) { [weak self] otpInfo in
            guard let self = self else { return }
            if let credential = credential {
                var editedCredential = credential
                editedCredential.otpURL = otpInfo.configuration.otpURL
                _ = try? self.vaultItemsService.save(editedCredential)
                self.add(.success(mode: .credentialPrefilled(editedCredential), configuration: otpInfo.configuration))
            } else {
                self.addCredentialStep(for: otpInfo.configuration)
            }
        }
    }

    private func makeAddOTPSecretKeyViewModel(credential: Credential) -> AddOTPSecretViewModel {
        AddOTPSecretViewModel(credential: credential) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(configuration):
                do {
                    let info = try OTPInfo(configuration: .init(otpURL: configuration.otpURL, supportDashlane2FA: false))
                    var tempCredential = credential
                    self.add(.success(mode: .credentialPrefilled(credential), configuration: info.configuration))
                    tempCredential.otpURL = info.configuration.otpURL
                    _ = try? self.vaultItemsService.save(tempCredential)
                } catch {
                    self.completion(.failure(.badSecretKey(credential.title)))
                }
            case .failure:
                self.completion(.failure(.badSecretKey(credential.title)))
            }
        }
    }

    func handleMatchingCredentialCompletion(action: MatchingCredentialListViewModel.Completion, for domain: String) {
        switch action {
        case .createCredential:
            add(.enterLoginDetails(makeAddLoginDetailsViewModel(website: domain, credential: nil)))
        case let .linkToCredential(credential):
            add(.enterLoginDetails(makeAddLoginDetailsViewModel(website: domain, credential: credential)))
        }
    }

    func handleSuccessCompletion(for mode: AddOTPSuccessView.Mode, configuration: OTPConfiguration) {
        switch mode {
        case let .promptToEnterCredential(configuration):
            addCredentialStep(for: configuration)
        case .credentialPrefilled:
            self.completion(.completed(configuration))
        }
    }

    func addCredentialStep(for configuration: OTPConfiguration) {
        let credential = Credential(OTPInfo(configuration: configuration))

        let viewModel = credentialDetailViewModelFactory.make(item: credential, mode: .adding(prefilled: false), origin: .adding) { [weak self] in
            self?.completion(.completed(configuration))
        }
        add(.addCredential(viewModel: viewModel))
    }
}

extension AddOTPManuallyFlowViewModel {
    static var mock: AddOTPManuallyFlowViewModel {
        .init(credential: nil,
              vaultItemsService: MockServicesContainer().vaultItemsService,
              matchingCredentialListViewModelFactory: .init {_, _, _ in .mock()},
              chooseWebsiteViewModelFactory: .init {_ in .mock()},
              addLoginDetailsViewModelFactory: .init {_, _, _, _ in .mock},
              credentialDetailViewModelFactory: .init({ _, _, _, _, _, _ in MockVaultConnectedContainer().makeCredentialDetailViewModel(item: PersonalDataMock.Credentials.amazon, mode: .adding(prefilled: false)) }),
              completion: {_ in})
    }
}
