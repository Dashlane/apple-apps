import Foundation

extension Definition {

  public enum `ActionDuringTransfer`: String, Encodable, Sendable {
    case `accessVault` = "access_vault"
    case `cancelDeviceTransfer` = "cancel_device_transfer"
    case `cancelLogin` = "cancel_login"
    case `completeDeviceTransfer` = "complete_device_transfer"
    case `confirmRequest` = "confirm_request"
    case `contactSupport` = "contact_support"
    case `refreshRequest` = "refresh_request"
    case `rejectRequest` = "reject_request"
    case `returnToDeviceSetup` = "return_to_device_setup"
    case `returnToLogin` = "return_to_login"
    case `scanQrCode` = "scan_qr_code"
    case `selectLoggedInDevice` = "select_logged_in_device"
    case `selectTransferMethod` = "select_transfer_method"
    case `setPin` = "set_pin"
    case `setupBiometrics` = "setup_biometrics"
    case `submitSecurityChallengeAnswer` = "submit_security_challenge_answer"
    case `tapHelp` = "tap_help"
    case `tapLearnMore` = "tap_learn_more"
    case `tapResetAccount` = "tap_reset_account"
    case `tryAgain` = "try_again"
    case `viewSecurityChallengeSolution` = "view_security_challenge_solution"
  }
}
