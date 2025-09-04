import Foundation

extension Definition {

  public enum `MassDeploymentSetupStep`: String, Encodable, Sendable {
    case `clickCompleteStep2` = "click_complete_step_2"
    case `confirmPolicyApplied` = "confirm_policy_applied"
    case `downloadPolicy` = "download_policy"
    case `goToSetup` = "go_to_setup"
    case `reviewSetup` = "review_setup"
    case `startSetup` = "start_setup"
  }
}
