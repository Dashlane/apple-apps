import Foundation
import Combine
import DashlaneAppKit
import SwiftTreats
import LoginKit
import CoreSettings
import DashTypes

class FastLocalSetupInLoginViewModel: BiometrySettingsHandler, FastLocalSetupViewModel, SessionServicesInjecting {

    var shouldShowMasterPasswordReset: Bool {
        return masterPassword != nil
    }

    enum Completion {
        case next
    }

    private let usageLogService: FastLocalSetupLogService
    private let masterPassword: String?
    private let lockService: LockService
    private let masterPasswordResetService: ResetMasterPasswordService
    private let userSettings: UserSettings
    private let completion: (Completion) -> Void

    init(masterPassword: String?,
         biometry: Biometry?,
         lockService: LockService,
         masterPasswordResetService: ResetMasterPasswordService,
         userSettings: UserSettings,
         usageLogService: UsageLogServiceProtocol,
         completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void) {

        self.masterPassword = masterPassword
        self.lockService = lockService
        self.masterPasswordResetService = masterPasswordResetService
        self.userSettings = userSettings
        self.usageLogService = usageLogService.fastLocalSetupLogService
        self.completion = completion

        super.init(biometry: biometry)
    }

    func next() {
        if isBiometricsOn {
            try? lockService.secureLockConfigurator.enableBiometry()
        }

        if let masterPassword = masterPassword, isMasterPasswordResetOn {
            try? masterPasswordResetService.activate(using: masterPassword)
        }

        if isRememberMasterPasswordOn {
            try? lockService.secureLockConfigurator.enableRememberMasterPassword()
        }

        logSettings()
        completion(.next)
    }

    func back() {
        assertionFailure("There is no back button in the login context.")
    }

    func markDisplay() {
        userSettings[.fastLocalSetupForRemoteLoginDisplayed] = true
    }

    func logDisplay() {
        usageLogService.log(.shownInLogin)
    }

    func logSettings() {
        switch biometry {
        case .faceId:
            usageLogService.log(isBiometricsOn ? .faceIDEnabled : .faceIDDisabled)
        case .touchId:
            usageLogService.log(isBiometricsOn ? .touchIDEnabled : .touchIDDisabled)
        case .none: break
        }

        if isMasterPasswordResetOn {
            usageLogService.log(.masterPasswordResetEnabled)
        } else {
            usageLogService.log(.masterPasswordResetDisabled)
        }
    }
}
