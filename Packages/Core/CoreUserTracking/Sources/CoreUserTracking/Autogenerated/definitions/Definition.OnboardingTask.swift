import Foundation

extension Definition {

  public enum `OnboardingTask`: String, Encodable, Sendable {
    case `addFirstLogin` = "add_first_login"
    case `assignNewAdmin` = "assign_new_admin"
    case `closeGuide` = "close_guide"
    case `createSharingGroup` = "create_sharing_group"
    case `getMobileApp` = "get_mobile_app"
    case `invitePlanMembers` = "invite_plan_members"
    case `shareItem` = "share_item"
    case `tryAutofill` = "try_autofill"
    case `visitDashboardPasswordHealth` = "visit_dashboard_password_health"
    case `visitVault` = "visit_vault"
  }
}
