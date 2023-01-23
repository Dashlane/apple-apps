import Foundation
import Combine
import DashlaneAppKit
import SwiftTreats
import LoginKit

class FastLocalSetupInAccountCreationViewModel: BiometrySettingsHandler, FastLocalSetupViewModel {
    let shouldShowMasterPasswordReset: Bool = true

    enum Completion {
        case back(isBiometricAuthenticationEnabled: Bool, isMasterPasswordResetEnabled: Bool, isRememberMasterPasswordEnabled: Bool)
        case next(isBiometricAuthenticationEnabled: Bool, isMasterPasswordResetEnabled: Bool, isRememberMasterPasswordEnabled: Bool)
    }

    private let logger: AccountCreationInstallerLogger
    private let completion: (Completion) -> Void

    init(biometry: Biometry?,
         logger: AccountCreationInstallerLogger,
         completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void) {
        self.logger = logger
        self.completion = completion
        super.init(biometry: biometry)
    }

    func next() {
        completion(.next(isBiometricAuthenticationEnabled: isBiometricsOn, isMasterPasswordResetEnabled: isMasterPasswordResetOn, isRememberMasterPasswordEnabled: isRememberMasterPasswordOn))
    }

    func back() {
        completion(.back(isBiometricAuthenticationEnabled: isBiometricsOn, isMasterPasswordResetEnabled: isMasterPasswordResetOn, isRememberMasterPasswordEnabled: isRememberMasterPasswordOn))
    }

    func logDisplay() {
        logger.log(.fastLocalSetup(action: .shown))
    }

    func markDisplay() {}
}
