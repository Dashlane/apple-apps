import DashlaneAPI
import Foundation
import UserTrackingFoundation

public class ForgotMasterPasswordSheetModel: LoginKitServicesInjecting {

  let hasMasterPasswordReset: Bool
  let didTapResetMP: (() -> Void)?
  let didTapAccountRecovery: (() -> Void)?

  private let login: String
  private let activityReporter: ActivityReporterProtocol

  public init(
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
