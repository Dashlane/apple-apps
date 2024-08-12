import Foundation

extension Definition {

  public enum `Button`: String, Encodable, Sendable {
    case `addNow` = "add_now"
    case `back`
    case `buyDashlane` = "buy_dashlane"
    case `buySeats` = "buy_seats"
    case `cancel`
    case `cancelSubscription` = "cancel_subscription"
    case `checkImproveHealthScore` = "check_improve_health_score"
    case `close`
    case `confirmUpgrade` = "confirm_upgrade"
    case `contactSupportTeam` = "contact_support_team"
    case `copyReferralLink` = "copy_referral_link"
    case `createPersonalAccount` = "create_personal_account"
    case `discard`
    case `dismiss`
    case `done`
    case `downloadBillingHistory` = "download_billing_history"
    case `downloadCsv` = "download_csv"
    case `downloadExtension` = "download_extension"
    case `extendTrial` = "extend_trial"
    case `inviteNow` = "invite_now"
    case `inviteReferralsByEmail` = "invite_referrals_by_email"
    case `manageLogins` = "manage_logins"
    case `next`
    case `ok`
    case `open`
    case `openAdminConsole` = "open_admin_console"
    case `openDashboard` = "open_dashboard"
    case `openGroupsPage` = "open_groups_page"
    case `openPasswordHealthScore` = "open_password_health_score"
    case `openSharingCenter` = "open_sharing_center"
    case `openUsersPage` = "open_users_page"
    case `openVault` = "open_vault"
    case `reInviteUsers` = "re_invite_users"
    case `reactivateSubscription` = "reactivate_subscription"
    case `remainFree` = "remain_free"
    case `reviewSubscription` = "review_subscription"
    case `searchBar` = "search_bar"
    case `seeAll` = "see_all"
    case `seeB2BPlanTiers` = "see_b2b_plan_tiers"
    case `seeOtherMethods` = "see_other_methods"
    case `seePlan` = "see_plan"
    case `seeSetupGuide` = "see_setup_guide"
    case `seeUsers` = "see_users"
    case `selectBusinessPlan` = "select_business_plan"
    case `selectStarterPlan` = "select_starter_plan"
    case `selectTeamPlan` = "select_team_plan"
    case `setUp` = "set_up"
    case `shareReferralLinkOnX` = "share_referral_link_on_x"
    case `skip`
    case `submit`
    case `tryNow` = "try_now"
    case `unfreezeAccount` = "unfreeze_account"
    case `upgradeBusinessTier` = "upgrade_business_tier"
    case `upgradeFriendsAndFamilyPlan` = "upgrade_friends_and_family_plan"
    case `upgradePaidPlan` = "upgrade_paid_plan"
    case `upgradePremiumPlan` = "upgrade_premium_plan"
  }
}
