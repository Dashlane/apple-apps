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
    let session: Session
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

    enum Setup {
        case biometry
        case biometryAndMasterPasswordReset(_ masterPassword: String)
    }

    func setupToReactivate() -> Setup? {
        if let password = reactivationNeededForMasterPasswordReset() {
            assert(reactivationNeededForBiometry)
            return .biometryAndMasterPasswordReset(password)
        }

        if reactivationNeededForBiometry {
            return .biometry
        }

        return nil
    }

    func reactivationNeededForMasterPasswordReset() -> String? {
        guard settings[.resetMasterPasswordWithBiometricsReactivationNeeded] == true, case let AuthenticationMethod.masterPassword(password, _) = session.authenticationMethod else {
            return nil
        }
        return password
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
