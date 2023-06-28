import Foundation
import CoreSettings
import CorePremium
import Combine
import LocalAuthentication
import LoginKit

class SSOEnableBiometricsOrPinViewModel: ObservableObject, SessionServicesInjecting {

    @Published
    var choosePinCode: Bool = false

    let dismiss = PassthroughSubject<Void, Never>()

    private let userSettings: UserSettings
    private let lockService: LockServiceProtocol

    let isBiometryAvailable: Bool

    init(userSettings: UserSettings,
         lockService: LockServiceProtocol) {
        self.userSettings = userSettings
        self.lockService = lockService

        let context = LAContext()
        isBiometryAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    func markAsViewed() {
        userSettings[.hasSeenBiometricsOrPinOnboarding] = true
    }

    func makePinCodeViewModel() -> PinCodeSelectionViewModel {
        PinCodeSelectionViewModel { [weak self] pin in
            guard let self else { return }
            self.choosePinCode = false
            guard let pin else { return }
            try? self.enablePincode(pin)
        }
    }

    func enableBiometry() {
        try? self.lockService.secureLockConfigurator.enableBiometry()
        dismiss.send()
    }

    func enablePincode(_ code: String) throws {
        try lockService.secureLockConfigurator.enablePinCode(code)
        dismiss.send()
    }
}

extension SSOEnableBiometricsOrPinViewModel {
    static var mock: SSOEnableBiometricsOrPinViewModel {
        .init(userSettings: .mock,
              lockService: LockServiceMock())
    }
}
