import Foundation
import UIKit
import CoreSession
import DashlaneAppKit
import SwiftTreats
import LoginKit

extension UIAlertController {
    static func makeReactivationRequestAlert(forSetup setup: BiometricSetUpdatesService.Setup, lockService: LockService, resetMasterPasswordService: ResetMasterPasswordService) -> UIAlertController {
        switch setup {
        case .biometry:
            return makeReenableBiometricsPrompt(lockService: lockService)
        case .biometryAndMasterPasswordReset:
            return makeReenableBiometricsAndResetMasterPasswordPrompt(lockService: lockService, resetMasterPasswordService: resetMasterPasswordService)
        }
    }

    static private func makeReenableBiometricsPrompt(lockService: LockService) -> UIAlertController {
        let title = Device.localizedStringWithCurrentBiometry(key: "Authentication_BiometricsReactivationDialog_Title")
        let message = Device.localizedStringWithCurrentBiometry(key: "Authentication_BiometricsReactivationDialog_Description")
        let reenableTitle = NSLocalizedString("Authentication_BiometricsReactivationDialog_CTA", comment: "")
        let disableActionTitle = NSLocalizedString("Authentication_BiometricsReactivationDialog_Cancel", comment: "")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let commonAction: ((UIAlertAction) -> Void) = { _ in
            lockService.biometricSetUpdatesService.reactivationRequestAddressed()
        }

        let disableAction = UIAlertAction(title: disableActionTitle, style: .default) { action in
            commonAction(action)
        }
        alertController.addAction(disableAction)

        let reenable = UIAlertAction(title: reenableTitle, style: .default) { action in
            commonAction(action)
            try? lockService.secureLockConfigurator.enableBiometry()
        }
        alertController.addAction(reenable)
        return alertController
    }

    static private func makeReenableBiometricsAndResetMasterPasswordPrompt(lockService: LockService, resetMasterPasswordService: ResetMasterPasswordService) -> UIAlertController {
        let title = Device.localizedStringWithCurrentBiometry(key: "ResetMasterPassword_ReactivationDialog_Title")
        let message = Device.localizedStringWithCurrentBiometry(key: "ResetMasterPassword_ReactivationDialog_Description")
        let reenableTitle = NSLocalizedString("ResetMasterPassword_ReactivationDialog_CTA", comment: "")
        let disableActionTitle = NSLocalizedString("ResetMasterPassword_ReactivationDialog_Cancel", comment: "")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let commonAction: ((UIAlertAction) -> Void) = { _ in
            lockService.biometricSetUpdatesService.reactivationRequestAddressed()
        }

        let disableAction = UIAlertAction(title: disableActionTitle, style: .default) { action in
            commonAction(action)
        }
        alertController.addAction(disableAction)

        let reenable = UIAlertAction(title: reenableTitle, style: .default) { action in
            guard let masterPassword = lockService.session.configuration.masterKey.masterPassword else {
                return
            }
            commonAction(action)
            try? lockService.secureLockConfigurator.enableBiometry()
            try? resetMasterPasswordService.activate(using: masterPassword)
        }
        alertController.addAction(reenable)
        return alertController
    }

    static public func makeMPStoredInKeychainAlert(completion: @escaping (Bool) -> Void) -> UIAlertController {
        let message = Device.biometryType == nil ? L10n.Localizable.kwKeychainPasswordMsgPinOnly : L10n.Localizable.kwKeychainPasswordMsg(Device.currentBiometryDisplayableName)

        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: L10n.Localizable.cancel,
                              style: .cancel,
                              handler: { _ in completion(false) }))
        alert.addAction(UIAlertAction(title: L10n.Localizable.kwButtonOk, style: .default, handler: { _ in
            completion(true)
        }))

        return alert
    }
}
