import Foundation

extension Definition {

  public enum `ProfilingFeaturesPossibleAnswers`: String, Encodable, Sendable {
    case `justInTimeProvisioning` = "just_in_time_provisioning"
    case `massDeployment` = "mass_deployment"
    case `notSure` = "not_sure"
    case `scim`
    case `siem`
    case `sso`
  }
}
