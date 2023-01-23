import Foundation
import SwiftUI
import Combine
import CryptoKit
import DashTypes

final class PinCodeSettingsViewModel: ObservableObject, SessionServicesInjecting {
    typealias Confirmed = Bool

    enum Action {
        case deactivateMasterPasswordReset
        case disableBiometry
        case disableRememberMasterPassword
    }

    enum Alert {
        case deviceNotProtected(completion: () -> Void)
        case keychainStoredMasterPassword(pinCode: String, completion: (Confirmed) -> Void)
        case biometryReplacement(completion: (Confirmed) -> Void)
    }

    let lockService: LockServiceProtocol
    let teamSpaceService: TeamSpacesService
    let usageLogService: UsageLogServiceProtocol

    @Published
    var isToggleOn: Bool

    @Published
    var canChangePinCode: Bool

    @Published
    var displayPinCodeSelection = false

    @Published
    var activeAlert: Alert?

    private let actionHandler: (Action) -> Void

    init(lockService: LockServiceProtocol,
         teamSpaceService: TeamSpacesService,
         usageLogService: UsageLogServiceProtocol,
         actionHandler: @escaping (PinCodeSettingsViewModel.Action) -> Void) {
        self.lockService = lockService
        self.teamSpaceService = teamSpaceService
        self.usageLogService = usageLogService
        self.actionHandler = actionHandler

        isToggleOn = lockService.secureLockConfigurator.isPincodeActivated
        canChangePinCode = lockService.secureLockConfigurator.isPincodeActivated
    }

    func enablePinCode(_ enable: Bool) {
                if enable {
            actionHandler(.disableRememberMasterPassword)
        }

        switch (enable, SecureEnclave.isAvailable) {
        case (true, true):
                        displayPinCodeSelection = true
        case (true, false):
            activeAlert = .biometryReplacement(completion: { [weak self] confirmed in
                guard let self = self else { return }

                self.activeAlert = nil

                if confirmed {
                    self.actionHandler(.disableBiometry)
                    self.displayPinCodeSelection = true
                } else {
                    self.toggleValueWithAnimation(false)
                }
            })
        case (false, _):
            do {
                try disablePinCode()
                withAnimation {
                    isToggleOn = false
                    canChangePinCode = false
                }
            } catch {
                assertionFailure("Couldn't disable pincode [\(error.localizedDescription)]")
                if isPinCodeActivated {
                    toggleValueWithAnimation(true)
                }
            }
        }
    }

    func makePinCodeSelectionViewModel() -> PinCodeSelectionViewModel {
        PinCodeSelectionViewModel(currentPin: nil) { [weak self] (newPinCode) in
            self?.displayPinCodeSelection = false

            guard let self = self else { return }

                        guard let newPinCode = newPinCode else {
                                if !self.isPinCodeActivated {
                    self.toggleValueWithAnimation(false)
                }
                return
            }

                        if self.teamSpaceService.isSSOUser || self.lockService.secureLockConfigurator.isBiometricActivated {
                do {
                    try self.enablePinCode(newPinCode)
                    withAnimation { self.canChangePinCode = true }
                } catch {
                    assertionFailure("Couldn't enable pincode [\(error.localizedDescription)]")
                }
                return
            }

                        self.activeAlert = .keychainStoredMasterPassword(pinCode: newPinCode, completion: { [weak self] confirmed in
                guard let self = self else { return }
                guard confirmed else {
                    self.toggleValueWithAnimation(false)
                    return
                }
                do {
                    try self.enablePinCode(newPinCode)
                    withAnimation { self.canChangePinCode = true }
                } catch {
                    assertionFailure("Couldn't enable pincode [\(error.localizedDescription)]")
                    self.toggleValueWithAnimation(false)
                }
            })
        }
    }

    private func enablePinCode(_ code: String) throws {
        try lockService.secureLockConfigurator.enablePinCode(code)
        usageLogService.securitySettings.logPinStatus(isEnabled: true, origin: SecuritySettingsLogger.Origin.securitySettings)
    }

    private func disablePinCode() throws {
        try lockService.secureLockConfigurator.disablePinCode()
        usageLogService.securitySettings.logPinStatus(isEnabled: false, origin: SecuritySettingsLogger.Origin.securitySettings)
    }

        func handleToggleValueChange(newValue enabled: Bool) {
        guard enabled && !isPinCodeActivated || !enabled && isPinCodeActivated
        else { return }
                if enabled, !lockService.secureLockConfigurator.canActivatePinCode {
            activeAlert = .deviceNotProtected(completion: { [weak self] in
                self?.toggleValueWithAnimation(false)
            })
            return
        }
        enablePinCode(enabled)
    }

        private func toggleValueWithAnimation(_ on: Bool) {
        withAnimation { isToggleOn = on }
    }

    private var isPinCodeActivated: Bool {
        lockService.secureLockConfigurator.isPincodeActivated
    }
}

extension PinCodeSettingsViewModel {

    static var mock: PinCodeSettingsViewModel {
        PinCodeSettingsViewModel(lockService: LockServiceMock(),
                                 teamSpaceService: .mock(),
                                 usageLogService: UsageLogService.fakeService,
                                 actionHandler: { _ in })
    }
}
