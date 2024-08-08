import Foundation

extension Definition {

  public enum `PossibleFormAnswers`: String, Encodable, Sendable {
    case `choseOtherPasswordManager` = "chose_other_password_manager"
    case `downsizedEmployeeCount` = "downsized_employee_count"
    case `familiarWithDashlane` = "familiar_with_dashlane"
    case `missingCriticalFeatures` = "missing_critical_features"
    case `needHelpScim` = "need_help_scim"
    case `needHelpSso` = "need_help_sso"
    case `needMoreTimeConvince` = "need_more_time_convince"
    case `needMoreTimeTeamUsage` = "need_more_time_team_usage"
    case `needSalesRep` = "need_sales_rep"
    case `neverUsedBefore` = "never_used_before"
    case `noInternalUsage` = "no_internal_usage"
    case `noNeedForPasswordManager` = "no_need_for_password_manager"
    case `notAwareTrialEnding` = "not_aware_trial_ending"
    case `other`
    case `technicalIssues` = "technical_issues"
    case `tooExpensive` = "too_expensive"
    case `usedAnotherPasswordManager` = "used_another_password_manager"
  }
}
