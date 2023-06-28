import Foundation
import LoginKit
import CoreSession
import CoreNetworking
import CoreFeature
import Logger
import DashTypes
import UIKit

@MainActor
class TwoFASetupViewModel: ObservableObject, SessionServicesInjecting {

    enum ActivationAction: String, Identifiable {
        case enableLock
        case downloadAuthApp
        case setupTwoFA

        var id: String {
            rawValue
        }
    }

    let lockService: LockServiceProtocol

    @Published
    var displayPinCodeSelection: Bool = false

    var hasLock: Bool {
        lockService.secureLockMode() != .masterKey
    }

    var activationAction: ActivationAction {
        if Authenticator.isOnDevice && self.hasLock {
            return .setupTwoFA
        } else if Authenticator.isOnDevice {
                        return .enableLock
        } else {
            return .downloadAuthApp
        }
    }

    let twoFAActivationViewModelFactory: TwoFAActivationViewModel.Factory

    init(lockService: LockServiceProtocol,
         twoFAActivationViewModelFactory: TwoFAActivationViewModel.Factory) {
        self.twoFAActivationViewModelFactory = twoFAActivationViewModelFactory
        self.lockService = lockService
    }

    func makePinCodeSelectionViewModel() -> PinCodeSelectionViewModel {
        PinCodeSelectionViewModel(currentPin: nil) { [weak self] (newPinCode) in
            self?.displayPinCodeSelection = false
            guard let self = self,
                  let newPinCode = newPinCode else {
                return
            }
            do {
                try self.enablePinCode(newPinCode)
            } catch {
                assertionFailure("Couldn't enable pincode [\(error.localizedDescription)]")
            }
        }
    }

    private func enablePinCode(_ code: String) throws {
        try lockService.secureLockConfigurator.enablePinCode(code)
    }

    func enableBiometry() throws {
        try lockService.secureLockConfigurator.enableBiometry()
    }
}

extension TwoFASetupViewModel {
    static var mock: TwoFASetupViewModel {
        .init(lockService: LockServiceMock(),
              twoFAActivationViewModelFactory: .init({ .mock }))
    }
}
