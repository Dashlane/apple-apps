import Foundation

extension Definition {

  public enum `FormName`: String, Encodable, Sendable {
    case `familiarityWithDashlane` = "familiarity_with_dashlane"
    case `reasonToCancelSubscription` = "reason_to_cancel_subscription"
    case `reasonToExtendTrial` = "reason_to_extend_trial"
  }
}
