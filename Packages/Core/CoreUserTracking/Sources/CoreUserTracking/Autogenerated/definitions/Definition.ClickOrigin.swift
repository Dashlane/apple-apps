import Foundation

extension Definition {

  public enum `ClickOrigin`: String, Encodable, Sendable {
    case `accountDropdown` = "account_dropdown"
    case `accountStatus` = "account_status"
    case `activityLogPaywall` = "activity_log_paywall"
    case `adminOnboardingChecklist` = "admin_onboarding_checklist"
    case `adminTabExtensionInPopup` = "admin_tab_extension_in_popup"
    case `autofillDropdown` = "autofill_dropdown"
    case `banner`
    case `bannerActivityLogPaywall` = "banner_activity_log_paywall"
    case `bannerFrozenAccount` = "banner_frozen_account"
    case `bannerPasswordLimitCloseToBeReached` = "banner_password_limit_close_to_be_reached"
    case `bannerPasswordLimitReached` = "banner_password_limit_reached"
    case `bannerTacSettingsPoliciesPaywall` = "banner_tac_settings_policies_paywall"
    case `billingInformation` = "billing_information"
    case `bottomPageToast` = "bottom_page_toast"
    case `collectionsSharingStarterLimitCloseToBeReachedMain` =
      "collections_sharing_starter_limit_close_to_be_reached_main"
    case `collectionsSharingStarterLimitCloseToBeReachedModal` =
      "collections_sharing_starter_limit_close_to_be_reached_modal"
    case `collectionsSharingStarterLimitReachedMain` =
      "collections_sharing_starter_limit_reached_main"
    case `collectionsSharingStarterLimitReachedModal` =
      "collections_sharing_starter_limit_reached_modal"
    case `confidentialScim` = "confidential_scim"
    case `confidentialSso` = "confidential_sso"
    case `directorySyncPaywallPage` = "directory_sync_paywall_page"
    case `featureLimitationsBlock` = "feature_limitations_block"
    case `freePlanDetails` = "free_plan_details"
    case `frozenAccountModal` = "frozen_account_modal"
    case `generatePasswordWebcardB2BTrialEndReached` =
      "generate_password_webcard_b2b_trial_end_reached"
    case `generatePasswordWebcardPasswordLimitCloseToBeReached` =
      "generate_password_webcard_password_limit_close_to_be_reached"
    case `generatePasswordWebcardPasswordLimitReached` =
      "generate_password_webcard_password_limit_reached"
    case `groupsStarterLimitCloseToBeReached` = "groups_starter_limit_close_to_be_reached"
    case `groupsStarterLimitReached` = "groups_starter_limit_reached"
    case `importDataPasswordLimitReached` = "import_data_password_limit_reached"
    case `insufficientSeatsProvisioningErrorBanner` = "insufficient_seats_provisioning_error_banner"
    case `leftSideNavigationMenu` = "left_side_navigation_menu"
    case `moreTabExtension` = "more_tab_extension"
    case `needHelp` = "need_help"
    case `onboardedUsersLimit` = "onboarded_users_limit"
    case `orderSummary` = "order_summary"
    case `plans`
    case `premiumPlanDetails` = "premium_plan_details"
    case `proTip` = "pro_tip"
    case `savePasswordNotificationWebcard` = "save_password_notification_webcard"
    case `savePasswordWebcardPasswordLimitCloseToBeReached` =
      "save_password_webcard_password_limit_close_to_be_reached"
    case `scimPaywallBanner` = "scim_paywall_banner"
    case `splunkIntegration` = "splunk_integration"
    case `ssoPaywallBanner` = "sso_paywall_banner"
    case `ssoPaywallPage` = "sso_paywall_page"
    case `tacPopupLeftSideBar` = "tac_popup_left_side_bar"
    case `tacPopupTopRightMenu` = "tac_popup_top_right_menu"
    case `tacSettingsPolicies` = "tac_settings_policies"
    case `tacSettingsPoliciesPaywall` = "tac_settings_policies_paywall"
    case `usersSummary` = "users_summary"
    case `vpnFeatureActivationSetting` = "vpn_feature_activation_setting"
  }
}
