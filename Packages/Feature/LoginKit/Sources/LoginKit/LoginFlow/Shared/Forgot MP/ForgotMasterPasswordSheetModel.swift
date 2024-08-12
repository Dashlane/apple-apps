import CoreUserTracking
import DashlaneAPI
import Foundation

class ForgotMasterPasswordSheetModel {

  let hasMasterPasswordReset: Bool
  let didTapResetMP: (() -> Void)?
  let didTapAccountRecovery: (() -> Void)?

  private let login: String
  private let activityReporter: ActivityReporterProtocol

  init(
    login: String,
    activityReporter: ActivityReporterProtocol,
    hasMasterPasswordReset: Bool,
    didTapResetMP: (() -> Void)? = nil,
    didTapAccountRecovery: (() -> Void)? = nil
  ) {
    self.login = login
    self.hasMasterPasswordReset = hasMasterPasswordReset
    self.didTapResetMP = didTapResetMP
    self.didTapAccountRecovery = didTapAccountRecovery
    self.activityReporter = activityReporter
  }

  func logForgotPassword() {
    let hasResetMP = self.hasMasterPasswordReset
    activityReporter.report(
      UserEvent.ForgetMasterPassword(
        hasBiometricReset: hasResetMP,
        hasTeamAccountRecovery: false))
  }
}
