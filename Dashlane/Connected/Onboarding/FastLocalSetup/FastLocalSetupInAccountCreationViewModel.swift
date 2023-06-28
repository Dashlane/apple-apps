import Foundation
import Combine
import DashlaneAppKit
import SwiftTreats
import LoginKit

class FastLocalSetupInAccountCreationViewModel: BiometrySettingsHandler, FastLocalSetupViewModel, AccountCreationFlowDependenciesInjecting {
    let shouldShowMasterPasswordReset: Bool = true

    enum Completion {
                case back(isBiometricAuthenticationEnabled: Bool, isMasterPasswordResetEnabled: Bool, isRememberMasterPasswordEnabled: Bool)
        case next(isBiometricAuthenticationEnabled: Bool, isMasterPasswordResetEnabled: Bool, isRememberMasterPasswordEnabled: Bool)
    }

    private let completion: (Completion) -> Void

    init(biometry: Biometry? = Device.biometryType,
         completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void) {
        self.completion = completion
        super.init(biometry: biometry)
    }

    func next() {
        completion(.next(isBiometricAuthenticationEnabled: isBiometricsOn, isMasterPasswordResetEnabled: isMasterPasswordResetOn, isRememberMasterPasswordEnabled: isRememberMasterPasswordOn))
    }

    func back() {
        completion(.back(isBiometricAuthenticationEnabled: isBiometricsOn, isMasterPasswordResetEnabled: isMasterPasswordResetOn, isRememberMasterPasswordEnabled: isRememberMasterPasswordOn))
    }

    func markDisplay() {}
}
