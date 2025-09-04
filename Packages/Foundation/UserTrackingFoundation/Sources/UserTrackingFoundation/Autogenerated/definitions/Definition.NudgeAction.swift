import Foundation

extension Definition {

  public enum `NudgeAction`: String, Encodable, Sendable {
    case `completedSetup` = "completed_setup"
    case `seeInContextNudgeExample` = "see_in_context_nudge_example"
    case `sentTestNudge` = "sent_test_nudge"
    case `startedSetup` = "started_setup"
    case `uninstalledIntegration` = "uninstalled_integration"
  }
}
