import AutofillKit
import Combine
import CoreSettings
import CoreUserTracking
import Foundation
import LoginKit

struct ReportUserSettingsService {
  let userSettings: UserSettings
  let resetMPService: ResetMasterPasswordService
  let lock: LockService
  let autofillService: AutofillService
  let activityReporter: ActivityReporterProtocol

  func report() {
    let lockConfigurator = lock.secureLockConfigurator
    let clipboardExpirationActivated =
      userSettings[.clipboardExpirationDelay] as TimeInterval? != nil

    let settings = UserEvent.UserSettings(
      hasAuthenticationWithBiometrics: lockConfigurator.isBiometricActivated,
      hasAuthenticationWithPin: lockConfigurator.isPincodeActivated,
      hasAutofillActivated: autofillService.activationStatus.isEnabled,
      hasClearClipboard: clipboardExpirationActivated,
      hasLockOnExit: lock.locker.screenLocker?.lockOnExitState != .disabled,
      hasMasterPasswordBiometricReset: resetMPService.isActive,
      lockAutoTimeout: lock.locker.screenLocker?.lockDelay.map(Int.init))
    activityReporter.report(settings)
  }
}
