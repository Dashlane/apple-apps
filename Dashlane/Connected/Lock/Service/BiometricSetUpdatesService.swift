import Foundation
import CoreSession
import DashlaneAppKit
import SwiftTreats
import DashTypes
import LocalAuthentication
import CoreKeychain
import LoginKit
import CoreSettings
import CoreFeature

struct BiometricSetUpdatesService {
    let login: Login
    let settings: UserLockSettings
    let keychainService: AuthenticationKeychainService
    let featureService: FeatureServiceProtocol
    let configurator: SecureLockConfigurator
    let teamSpaceService: TeamSpacesService
    let resetMasterPasswordService: ResetMasterPasswordService

    var reactivationNeededForBiometry: Bool {
        guard Device.biometryType != nil else {
            return false
        }
        return settings[.biometricEnrolmentChanged] == true
    }

    var reactivationNeededForMasterPasswordReset: Bool {
        return settings[.resetMasterPasswordWithBiometricsReactivationNeeded] == true && !teamSpaceService.isSSOUser
    }

    enum Setup {
        case biometry
        case biometryAndMasterPasswordReset
    }

    func setupToReactivate() -> Setup? {
        if reactivationNeededForMasterPasswordReset {
            assert(reactivationNeededForBiometry)
            return .biometryAndMasterPasswordReset
        }

        if reactivationNeededForBiometry {
            return .biometry
        }

        return nil
    }

        func checkForUpdatesInBiometricSet() {
        do {
            if try settings.isBiometricSetIntact() == false {
                disableBiometry()
                updateBiometricSetData()
            }
        } catch BiometrySetCheckError.latestBiometricSetDataNotFound {
            updateBiometricSetData()
        } catch {
                    }
    }

    func reactivationRequestAddressed() {
        settings[.biometricEnrolmentChanged] = false
        settings[.resetMasterPasswordWithBiometricsReactivationNeeded] = false
    }

                private func updateBiometricSetData() {
        let context = LAContext()
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            settings[.biometricSetData] = context.evaluatedPolicyDomainState
        }
    }

    private func disableBiometry() {
        settings[.biometricEnrolmentChanged] = true

        if featureService.isEnabled(.masterPasswordResetIsAvailable) && resetMasterPasswordService.needsReactivation {
            settings[.resetMasterPasswordWithBiometricsReactivationNeeded] = true
        }

        try? configurator.disableBiometry()
        try? resetMasterPasswordService.deactivate()
    }
}
