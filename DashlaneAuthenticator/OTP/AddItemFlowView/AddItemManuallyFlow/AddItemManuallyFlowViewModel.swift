import Foundation
import CorePersonalData
import AuthenticatorKit
import CoreUserTracking
import IconLibrary
import Combine
import DashTypes

@MainActor
class AddItemManuallyFlowViewModel: ObservableObject, AuthenticatorServicesInjecting, AuthenticatorMockInjecting {

    enum Step {
        case manuallyChooseWebsite(ChooseWebsiteViewModel)
        case credentialsMatchingWebsite(MatchingCredentialListViewModel)
        case addLoginDetailsForm(AddLoginDetailsViewModel)
        case failedToAddItem(String)
        case scanCode(AddItemScanCodeFlowViewModel)
        case preview(TokenRowViewModel, () -> Void)
        case dashlane2FAMessage(OTPInfo)
    }

    @Published var steps: [Step] = []

    @Published
    var showSuccess = false
    private let chooseWebSiteViewModelFactory: ChooseWebsiteViewModel.Factory
    private let addLoginDetailsViewModelFactory: AddLoginDetailsViewModel.Factory
    private let scanCodeViewModelFactory: AddItemScanCodeFlowViewModel.Factory
    private let tokenRowViewModelFactory: TokenRowViewModel.Factory
    private let matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory
    private let databaseService: AuthenticatorDatabaseServiceProtocol
    private let mode: AddItemMode
    private let didCreate: (OTPInfo, Definition.OtpAdditionMode) -> Void
    let isFirstToken: Bool

    init(databaseService: AuthenticatorDatabaseServiceProtocol,
         chooseWebSiteViewModelFactory: ChooseWebsiteViewModel.Factory,
         addLoginDetailsViewModelFactory: AddLoginDetailsViewModel.Factory,
         scanCodeViewModelFactory: AddItemScanCodeFlowViewModel.Factory,
         matchingCredentialListViewModelFactory: MatchingCredentialListViewModel.Factory,
         tokenRowViewModelFactory: TokenRowViewModel.Factory,
         mode: AddItemMode,
         isFirstToken: Bool,
         didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void) {
        self.chooseWebSiteViewModelFactory = chooseWebSiteViewModelFactory
        self.addLoginDetailsViewModelFactory = addLoginDetailsViewModelFactory
        self.scanCodeViewModelFactory = scanCodeViewModelFactory
        self.matchingCredentialListViewModelFactory = matchingCredentialListViewModelFactory
        self.databaseService = databaseService
        self.tokenRowViewModelFactory = tokenRowViewModelFactory
        self.mode = mode
        self.isFirstToken = isFirstToken
        self.didCreate = didCreate
        start()
        assert(!steps.isEmpty)
    }

    private func start() {
        let viewModel = chooseWebSiteViewModelFactory.make(completion: { [weak self] website in
            guard let self = self else { return }
            Task {

                                guard !website.contains("dashlane") else {
                    await MainActor.run {
                        self.matchingCredentialsToAddLoginDetails(website: website, userAction: .createCredential)
                    }
                    return
                }

                let matchingAction = await self.mode.matchingAction(forWebsite: website)
                await MainActor.run {
                    switch matchingAction {
                    case .notNeeded:
                                                self.matchingCredentialsToAddLoginDetails(website: website, userAction: .createCredential)
                    case .linkToCredential(let credential):
                        self.matchingCredentialsToAddLoginDetails(website: website, userAction: .linkToCredential(credential))
                    case  let .showList(matchingCredentials, _):
                        self.updateStepToMatchingCredentialSelection(forWebsite: website, matchingCredentials: matchingCredentials)
                    }
                }
            }
        })
        self.steps.append(.manuallyChooseWebsite(viewModel))
    }

    private func updateStepToMatchingCredentialSelection(forWebsite website: String, matchingCredentials: [Credential]) {
        let viewModel = matchingCredentialListViewModelFactory.make(website: website, matchingCredentials: matchingCredentials) { action in
            self.matchingCredentialsToAddLoginDetails(website: website, userAction: action)
        }
        self.steps.append(.credentialsMatchingWebsite(viewModel))
    }

    private func matchingCredentialsToAddLoginDetails(website: String, userAction: MatchingCredentialListViewModel.Completion) {
        let detailsModel: AddLoginDetailsViewModel
        switch userAction {
        case .createCredential:
            detailsModel = self.makeAddLoginDetailsViewModel(website: website,
                                                             credential: nil)
        case let .linkToCredential(credential):
            detailsModel = self.makeAddLoginDetailsViewModel(website: website,
                                                             credential: credential)
        }
        self.steps.append(.addLoginDetailsForm(detailsModel))
    }

    private func makeAddLoginDetailsViewModel(website: String, credential: Credential?) -> AddLoginDetailsViewModel {
        addLoginDetailsViewModelFactory.make(website: website,
                                             credential: credential,
                                             supportDashlane2FA: true) { otpInfo in
            do {
                if let credential = credential,
                   credential.email == otpInfo.configuration.login,
                   case let .paired(provider) = self.mode {
                    try provider.link(otpInfo, to: credential)
                } else {
                    try self.databaseService.add([otpInfo])
                }
                                self.steps.append(.preview(self.tokenRowViewModelFactory.make(token: otpInfo), {
                    if otpInfo.isDashlaneOTP {
                        self.steps.append(.dashlane2FAMessage(otpInfo))
                    } else {
                        self.complete(otpInfo, mode: .textCode)
                    }
                }))

            } catch {
                self.steps.append(.failedToAddItem(otpInfo.configuration.issuerOrTitle))
            }
        }
    }

            func startScanCodeFlow() {
        let viewModel = scanCodeViewModelFactory.make(otpInfo: nil, mode: mode, isFirstToken: isFirstToken, didCreate: { [weak self] otpInfo, mode in
            if otpInfo.isDashlaneOTP {
                self?.steps.append(.dashlane2FAMessage(otpInfo))
            } else {
                self?.complete(otpInfo, mode: mode)
            }
        })
        self.steps.append(.scanCode(viewModel))
    }

        func resetFlow() {
        while steps.count > 1 {
            _ = steps.popLast()
        }
    }

    func complete(_ otpInfo: OTPInfo, mode: Definition.OtpAdditionMode) {
        self.didCreate(otpInfo, .textCode)
    }
}

extension TokenRowViewModel: AuthenticatorServicesInjecting, AuthenticatorMockInjecting { }
