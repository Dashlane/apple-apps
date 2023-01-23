import Foundation
import SwiftUI
import CryptoKit
import SwiftTreats
import DashlaneAppKit
import LoginKit
import DashTypes
import CoreFeature

final class SettingsBiometricToggleViewModel: ObservableObject, SessionServicesInjecting {
    typealias Confirmed = Bool

    enum Alert {
        case pinCodeReplacementWarning(completion: (Confirmed) -> Void)
        case masterPasswordResetDeactivationWarning(completion: (Confirmed) -> Void)
        case masterPasswordResetActivationSuggestion(completion: (Confirmed) -> Void)
        case keychainStoredMasterPassword(completion: (Confirmed) -> Void)
    }

    enum Action {
        case enableMasterPasswordReset
        case disableRememberMasterPassword
        case disablePinCode
        case disableResetMasterPassword
    }

    let lockService: LockServiceProtocol
    let featureService: FeatureServiceProtocol
    let teamSpaceService: TeamSpacesService
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    let usageLogService: UsageLogServiceProtocol

    @Published
    var isToggleOn: Bool

    @Published
    var activeAlert: Alert?

    private let actionHandler: (Action) -> Void

    init(lockService: LockServiceProtocol,
         featureService: FeatureServiceProtocol,
         teamSpaceService: TeamSpacesService,
         resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
         usageLogService: UsageLogServiceProtocol,
         actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void) {
        self.lockService = lockService
        self.featureService = featureService
        self.teamSpaceService = teamSpaceService
        self.resetMasterPasswordService = resetMasterPasswordService
        self.usageLogService = usageLogService

        self.actionHandler = actionHandler

        isToggleOn = lockService.secureLockConfigurator.isBiometricActivated
    }

    func useBiometry(_ shouldEnable: Bool) {
        guard shouldEnable && !isBiometricActivated || !shouldEnable && isBiometricActivated
        else { return }

        if shouldEnable {
                        actionHandler(.disableRememberMasterPassword)
        }

        switch (shouldEnable, SecureEnclave.isAvailable) {
        case (true, true):
                        activateBiometry()
        case (true, false):
                        warnAboutPinCodeReplacement { [weak self] _ in
                self?.actionHandler(.disablePinCode)
                self?.activateBiometry()
            }
        case (false, _):
            warnAboutResetMasterPasswordDeactivation { [weak self] confirmed in
                if confirmed {
                    self?.actionHandler(.disableResetMasterPassword)
                    do {
                        try self?.disableBiometry()
                    } catch {
                        assertionFailure("Couldn't disable biometry [\(error.localizedDescription)]")
                        self?.setToggleOnWithAnimation(true)
                    }
                } else {
                    self?.setToggleOnWithAnimation(true)
                }
            }
        }
    }

    private func activateBiometry() {
                if teamSpaceService.isSSOUser || lockService.secureLockConfigurator.isPincodeActivated {
            do {
                try enableBiometry()
                if isResetMasterPasswordContainerAvailable && featureService.isEnabled(.masterPasswordResetIsAvailable) {
                    suggestActivatingResetMasterPassword()
                }

            } catch {
                setToggleOnWithAnimation(false)
            }
            return
        }

                activeAlert = .keychainStoredMasterPassword(completion: { [weak self] confirmed in
            guard let self = self else { return }
            if confirmed {
                do {
                    try self.enableBiometry()
                } catch {
                    self.setToggleOnWithAnimation(false)
                    return
                }
                                if self.featureService.isEnabled(.masterPasswordResetIsAvailable), !self.resetMasterPasswordService.isActive {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                        self.suggestActivatingResetMasterPassword()
                    }
                }
            } else {
                self.setToggleOnWithAnimation(false)
            }
        })
    }

    private func suggestActivatingResetMasterPassword() {
        activeAlert = .masterPasswordResetActivationSuggestion(completion: { [weak self] confirmation in
            guard let self = self, confirmation else { return }
            self.actionHandler(.enableMasterPasswordReset)
        })
    }

    private func warnAboutPinCodeReplacement(completion: @escaping (Confirmed) -> Void) {
        if lockService.secureLockConfigurator.isPincodeActivated {
            activeAlert = .pinCodeReplacementWarning(completion: completion)
        } else {
            completion(true)
        }
    }

    private func warnAboutResetMasterPasswordDeactivation(completion: @escaping (Confirmed) -> Void) {
        guard isResetMasterPasswordActivated && featureService.isEnabled(.masterPasswordResetIsAvailable) else {
            completion(true)
            return
        }
        activeAlert = .masterPasswordResetDeactivationWarning(completion: completion)
    }

    func enableBiometry() throws {
        try lockService.secureLockConfigurator.enableBiometry()
        setToggleOnWithAnimation(true)
        usageLogService.securitySettings.logBiometryStatus(isEnabled: true, origin: SecuritySettingsLogger.Origin.securitySettings)
    }

    func disableBiometry() throws {
        try lockService.secureLockConfigurator.disableBiometry()
        setToggleOnWithAnimation(false)
        usageLogService.securitySettings.logBiometryStatus(isEnabled: false, origin: SecuritySettingsLogger.Origin.securitySettings)
    }

        private func setToggleOnWithAnimation(_ on: Bool) {
        withAnimation {
            isToggleOn = on
        }
    }

    private var isResetMasterPasswordContainerAvailable: Bool {
        Device.biometryType != nil && !teamSpaceService.isSSOUser
    }

    private var isResetMasterPasswordActivated: Bool {
        resetMasterPasswordService.isActive
    }

    private var isBiometricActivated: Bool {
        lockService.secureLockConfigurator.isBiometricActivated
    }
}

extension SettingsBiometricToggleViewModel {

    static var mock: SettingsBiometricToggleViewModel {
        SettingsBiometricToggleViewModel(lockService: LockServiceMock(),
                                         featureService: .mock(),
                                         teamSpaceService: .mock(),
                                         resetMasterPasswordService: ResetMasterPasswordServiceMock(),
                                         usageLogService: UsageLogService.fakeService,
                                         actionHandler: { _ in })
    }
}
