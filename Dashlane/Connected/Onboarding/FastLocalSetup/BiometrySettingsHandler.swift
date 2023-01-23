import Foundation
import Combine
import DashlaneAppKit
import SwiftTreats

class BiometrySettingsHandler: ObservableObject {
    @Published
    var isBiometricsOn: Bool = true {
        didSet {
            if isBiometricsOn == false && isMasterPasswordResetOn == true {
                isMasterPasswordResetOn = false
                biometryNeededPublisher.send()
            }
        }
    }

    @Published
    var isMasterPasswordResetOn: Bool = true {
        didSet {
            if isBiometricsOn == false && isMasterPasswordResetOn == true {
                isBiometricsOn = true
                biometryNeededPublisher.send()
            }
        }
    }

    var isRememberMasterPasswordOn: Bool

        let biometryNeededPublisher = PassthroughSubject<Void, Never>()

    let biometry: Biometry?

    let mode: FastLocalSetupMode

    init(biometry: Biometry?) {
        if let biometry = biometry {
            self.biometry = biometry
            mode = .biometry(biometry)
        } else {
            mode = .rememberMasterPassword
            self.biometry = nil
        }

        switch mode {
        case .biometry:
            isBiometricsOn = true
            isMasterPasswordResetOn = true
            isRememberMasterPasswordOn = false
        case .rememberMasterPassword:
            isBiometricsOn = false
            isMasterPasswordResetOn = false
            isRememberMasterPasswordOn = true
        }
    }
}
