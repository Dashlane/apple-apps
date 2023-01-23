import Foundation
import CoreSession
import CorePersonalData
import TOTPGenerator
import CoreNetworking
import Logger
import DashlaneCrypto
import DashlaneAppKit
import DashTypes
import Combine
import CoreSync
import AuthenticatorKit
import UIKit
import CoreUserTracking
import CoreKeychain
import LoginKit

@MainActor
class TwoFAActivationViewModel: ObservableObject, SessionServicesInjecting {

    enum Steps {
        case twoFAOption
        case recoverySetup(TFAOption)
        case phoneNumber(TwoFAPhoneNumberSetupViewModel)
        case recoveryCode(RecoveryCodesViewModel)
        case completion(TwoFACompletionViewModel)
    }

    @Published
    var steps: [Steps]

    var dismissPublisher = PassthroughSubject<Void, Never>()

    let accountAPIClient: AccountAPIClientProtocol

    let twoFAPhoneNumberSetupViewModelFactory: TwoFAPhoneNumberSetupViewModel.Factory
    let makeTwoFACompletionViewModelFactory: TwoFACompletionViewModel.Factory

    init(authenticatedAPIClient: DeprecatedCustomAPIClient,
         twoFAPhoneNumberSetupViewModelFactory: TwoFAPhoneNumberSetupViewModel.Factory,
         makeTwoFACompletionViewModelFactory: TwoFACompletionViewModel.Factory) {
        self.accountAPIClient = AccountAPIClient(apiClient: authenticatedAPIClient)
        self.twoFAPhoneNumberSetupViewModelFactory = twoFAPhoneNumberSetupViewModelFactory
        self.makeTwoFACompletionViewModelFactory = makeTwoFACompletionViewModelFactory
        self.steps = [.twoFAOption]
    }

    func makeTwoFAPhoneNumberSetupViewModel(option: TFAOption) -> TwoFAPhoneNumberSetupViewModel {
        twoFAPhoneNumberSetupViewModelFactory.make(accountAPIClient: accountAPIClient, option: option) { [weak self] response in
            guard let self = self, let response = response else {
                self?.dismissPublisher.send()
                return
            }
            self.steps.append(.recoveryCode(self.makeRecoveryCodesViewModel(option: option, response: response)))
        }
    }

    func makeTwoFACompletionViewModel(option: TFAOption, response: TOTPActivationResponse, completion: @escaping () -> Void) -> TwoFACompletionViewModel {
        makeTwoFACompletionViewModelFactory.make(option: option, response: response, accountAPIClient: accountAPIClient, completion: completion)
    }

    func makeRecoveryCodesViewModel(option: TFAOption, response: TOTPActivationResponse) -> RecoveryCodesViewModel {
        RecoveryCodesViewModel(codes: response.recoveryKeys) { [weak self] in
            guard let self = self else {
                return
            }
            self.steps.append(.completion(self.makeTwoFACompletionViewModel(option: option, response: response) { [weak self] in
                self?.dismissPublisher.send()
            }))
        }
    }
}

extension TwoFAActivationViewModel {
    static var mock: TwoFAActivationViewModel {
        return TwoFAActivationViewModel(authenticatedAPIClient: .fake,
                                        twoFAPhoneNumberSetupViewModelFactory: .init({ _, option, _ in .mock(option) }),
                                        makeTwoFACompletionViewModelFactory: .init({ option, response, _, _ in .mock(option, response: response) }))
    }
}
