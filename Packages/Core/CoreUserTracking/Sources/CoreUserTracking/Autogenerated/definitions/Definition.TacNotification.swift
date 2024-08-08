import Foundation

extension Definition {

  public enum `TacNotification`: String, Encodable, Sendable {
    case `teamActivityDownloadModalAlertError` = "team_activity_download_modal_alert_error"
    case `teamDirectorySyncKeyErrorMarkup` = "team_directory_sync_key_error_markup"
    case `teamNotificationsAddAdminsMarkup` = "team_notifications_add_admins_markup"
    case `teamNotificationsEnableAccountRecoveryMarkup` =
      "team_notifications_enable_account_recovery_markup"
    case `teamNotificationsFreeTrialD0T15Markup` = "team_notifications_free_trial_d0_t15_markup"
    case `teamNotificationsFreeTrialD15T30Markup` = "team_notifications_free_trial_d15_t30_markup"
    case `teamNotificationsFreeTrialD15T30MarkupOne` =
      "team_notifications_free_trial_d15_t30_markup_one"
    case `teamNotificationsFreeTrialD15T30MarkupOther` =
      "team_notifications_free_trial_d15_t30_markup_other"
    case `teamNotificationsFreeTrialD15T30MarkupZero` =
      "team_notifications_free_trial_d15_t30_markup_zero"
    case `teamNotificationsFreeTrialGracePeriodMarkup` =
      "team_notifications_free_trial_grace_period_markup"
    case `teamNotificationsRenewalGracePeriodMarkup` =
      "team_notifications_renewal_grace_period_markup"
    case `teamScimMarketingBusinessHomepageBody` = "team_scim_marketing_business_homepage_body"
    case `teamScimMarketingBusinessScimBody` = "team_scim_marketing_business_scim_body"
    case `teamScimMarketingTeamScimBody` = "team_scim_marketing_team_scim_body"
    case `teamTacInExtensionNotificationMessageMarkup` =
      "team_tac_in_extension_notification_message_markup"
  }
}
