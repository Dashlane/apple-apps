import Foundation

public enum L10n {
  public enum Core {
        public static let accessibilityInfoSection = L10n.tr("Core", "Accessibility_InfoSection", fallback: "Information box")
        public static let accessibilityClearSearchTextField = L10n.tr("Core", "accessibilityClearSearchTextField", fallback: "Clear text")
        public static let accessibilityClearText = L10n.tr("Core", "accessibilityClearText", fallback: "Clear text")
        public static let accountLoadingInfoText = L10n.tr("Core", "ACCOUNT_LOADING_INFO_TEXT", fallback: "Your account is loading...")
        public static let accountLoadingMayTakeMinute = L10n.tr("Core", "ACCOUNT_LOADING_MAY_TAKE_MINUTE", fallback: "This may take a minute.")
        public static let accountLoadingSuccessDescription = L10n.tr("Core", "ACCOUNT_LOADING_SUCCESS_DESCRIPTION", fallback: "Enjoy Dashlane on this new device.")
        public static let accountLoadingSuccessTitle = L10n.tr("Core", "ACCOUNT_LOADING_SUCCESS_TITLE", fallback: "You’re all set up!")
        public static let accountLoadingUnlinkingPrevious = L10n.tr("Core", "ACCOUNT_LOADING_UNLINKING_PREVIOUS", fallback: "Unlinking previous device...")
        public static let accountDoesNotExist = L10n.tr("Core", "AccountDoesNotExist", fallback: "No account found for this email address")
        public static let actionCannotLogin = L10n.tr("Core", "ACTION_CANNOT_LOGIN", fallback: "I can't log in")
        public static let actionForgotMyPassword = L10n.tr("Core", "ACTION_FORGOT_MY_PASSWORD", fallback: "I forgot my password")
        public static let actionItemTrialUpgradeRecommendationDescriptionPremium = L10n.tr("Core", "action_item_trial_upgrade_recommendation_description_premium", fallback: "Based on app usage, our Premium plan looks like a good fit for you. Upgrade today.")
        public static let actionItemTrialUpgradeRecommendationTitle = L10n.tr("Core", "action_item_trial_upgrade_recommendation_title", fallback: "Enjoying our Premium features?")
        public static let actionResend = L10n.tr("Core", "ACTION_RESEND", fallback: "Resend code")
        public static let addAddress = L10n.tr("Core", "addAddress", fallback: "Add address")
        public static let addBankAccount = L10n.tr("Core", "addBankAccount", fallback: "Add bank account")
        public static let addCompany = L10n.tr("Core", "addCompany", fallback: "Add company")
        public static let addCreditCard = L10n.tr("Core", "addCreditCard", fallback: "Add credit/debit card")
        public static let addDriverLicense = L10n.tr("Core", "addDriverLicense", fallback: "Add driver's license")
        public static let addEmail = L10n.tr("Core", "addEmail", fallback: "Add email")
        public static let addIDCard = L10n.tr("Core", "addIDCard", fallback: "Add ID card")
        public static let addName = L10n.tr("Core", "addName", fallback: "Add name")
        public static let addPassport = L10n.tr("Core", "addPassport", fallback: "Add passport")
        public static let addPassword = L10n.tr("Core", "addPassword", fallback: "Add login")
        public static let addPayment = L10n.tr("Core", "addPayment", fallback: "Add payment")
        public static let addPersonalInfo = L10n.tr("Core", "addPersonalInfo", fallback: "Add personal info")
        public static let addPhoneNumber = L10n.tr("Core", "addPhoneNumber", fallback: "Add phone number")
        public static let addSecureNote = L10n.tr("Core", "addSecureNote", fallback: "Add Secure Note")
        public static let addSocialSecurityNumber = L10n.tr("Core", "addSocialSecurityNumber", fallback: "Add social security number")
        public static let addTaxNumber = L10n.tr("Core", "addTaxNumber", fallback: "Add tax number")
        public static let addWebsite = L10n.tr("Core", "addWebsite", fallback: "Add website")
        public static let announcePremiumExpiredBody = L10n.tr("Core", "ANNOUNCE_PREMIUM_EXPIRED_BODY", fallback: " Your Premium benefits have expired.")
        public static let announcePremiumExpiredCta = L10n.tr("Core", "ANNOUNCE_PREMIUM_EXPIRED_CTA", fallback: "Renew Premium")
        public static let announcePremiumExpiring1DayBody = L10n.tr("Core", "ANNOUNCE_PREMIUM_EXPIRING_1_DAY_BODY", fallback: "Your Premium benefits expire in 1 day")
        public static func announcePremiumExpiringNDaysBody(_ p1: Int) -> String {
      return L10n.tr("Core", "ANNOUNCE_PREMIUM_EXPIRING_N_DAYS_BODY", p1, fallback: "Your Premium benefits expire in %1$d days")
    }
        public static let askLogout = L10n.tr("Core", "askLogout", fallback: "Log out?")
        public static let authenticationIncorrectMasterPasswordHelp1 = L10n.tr("Core", "Authentication_IncorrectMasterPassword_Help_1", fallback: "That Master Password isn't right. Need")
        public static let authenticationIncorrectMasterPasswordHelp2 = L10n.tr("Core", "Authentication_IncorrectMasterPassword_Help_2", fallback: "help logging in?")
        public static let authenticatorPushChallengeButton = L10n.tr("Core", "AUTHENTICATOR_PUSH_CHALLENGE_BUTTON", fallback: "Receive a push notification")
        public static let authenticatorTotpPushOption = L10n.tr("Core", "AUTHENTICATOR_TOTP_PUSH_OPTION", fallback: "Enter 2FA token")
        public static let authenticatorPushRetryButtonTitle = L10n.tr("Core", "authenticatorPushRetryButtonTitle", fallback: "Resend request")
        public static let authenticatorPushViewAccepted = L10n.tr("Core", "authenticatorPushViewAccepted", fallback: "Authentication accepted")
        public static let authenticatorPushViewDeniedError = L10n.tr("Core", "authenticatorPushViewDeniedError", fallback: "Authentication rejected")
        public static let authenticatorPushViewSendTokenButtonTitle = L10n.tr("Core", "authenticatorPushViewSendTokenButtonTitle", fallback: "Send code to email")
        public static let authenticatorPushViewTimeOutError = L10n.tr("Core", "authenticatorPushViewTimeOutError", fallback: "Your request has expired.")
        public static func authenticatorPushViewTitle(_ p1: Any) -> String {
      return L10n.tr("Core", "authenticatorPushViewTitle", String(describing: p1), fallback: "_")
    }
        public static let autofillBannerTitle = L10n.tr("Core", "autofillBannerTitle", fallback: "Autofill isn't on.")
        public static let autofillBannerTitleCta = L10n.tr("Core", "autofillBannerTitleCta", fallback: "Manage")
        public static let autofillBannerTitleNotActive = L10n.tr("Core", "autofillBannerTitleNotActive", fallback: "Log in faster with Autofill")
        public static let autofillDemoFieldsAction = L10n.tr("Core", "autofillDemoFields_action", fallback: "Set up Autofill")
        public static let autofillDemoFieldsGenerateText = L10n.tr("Core", "autofillDemoFields_generate_text", fallback: "Use the password generator to create and save a unique password for any login.")
        public static let autofillDemoFieldsGenerateTitle = L10n.tr("Core", "autofillDemoFields_generate_title", fallback: "Generate unique passwords in a few taps")
        public static let autofillDemoFieldsLoginText = L10n.tr("Core", "autofillDemoFields_login_text", fallback: "Turn on Dashlane Autofill to start logging into websites and apps with just a tap.")
        public static let autofillDemoFieldsLoginTitle = L10n.tr("Core", "autofillDemoFields_login_title", fallback: "Log in to your accounts in a fraction of the time")
        public static let autofillDemoFieldsSyncText = L10n.tr("Core", "autofillDemoFields_sync_text", fallback: "Autofill your info on any device logged in to your Dashlane account.")
        public static let autofillDemoFieldsSyncTitle = L10n.tr("Core", "autofillDemoFields_sync_title", fallback: "Sync your information across all your devices")
        public static let badToken = L10n.tr("Core", "BadToken", fallback: "Incorrect code. Please try again")
        public static let benefit2faAdvanced = L10n.tr("Core", "benefit_2fa_advanced", fallback: "<strong>U2F authentication</strong>")
        public static let benefit2faBasic = L10n.tr("Core", "benefit_2fa_basic", fallback: "2-factor authentication (2FA)")
        public static let benefitAutofill = L10n.tr("Core", "benefit_autofill", fallback: "Form and payment autofill")
        public static let benefitIndividualAcount = L10n.tr("Core", "benefit_individual_acount", fallback: "1 account")
        public static func benefitLimitedDeviceOne(_ p1: Any) -> String {
      return L10n.tr("Core", "benefit_limited_device_one", String(describing: p1), fallback: "_")
    }
        public static func benefitLimitedDeviceSome(_ p1: Any) -> String {
      return L10n.tr("Core", "benefit_limited_device_some", String(describing: p1), fallback: "_")
    }
        public static let benefitPasswordChanger = L10n.tr("Core", "benefit_password_changer", fallback: "One-click Password Changer")
        public static let benefitPasswordGenerator = L10n.tr("Core", "benefit_password_generator", fallback: "Password Generator")
        public static func benefitPasswordSharingLimited(_ p1: Any) -> String {
      return L10n.tr("Core", "benefit_password_sharing_limited", String(describing: p1), fallback: "_")
    }
        public static let benefitPasswordSharingUnlimited = L10n.tr("Core", "benefit_password_sharing_unlimited", fallback: "Unlimited login sharing")
        public static func benefitSecureFiles(_ p1: Any) -> String {
      return L10n.tr("Core", "benefit_secure_files", String(describing: p1), fallback: "_")
    }
        public static let benefitSecureNotes = L10n.tr("Core", "benefit_secure_notes", fallback: "Secure Notes")
        public static let benefitSecurityAlertsAdvanced = L10n.tr("Core", "benefit_security_alerts_advanced", fallback: "<strong>Dark Web Monitoring</strong> &amp; alerts")
        public static let benefitSecurityAlertsBasic = L10n.tr("Core", "benefit_security_alerts_basic", fallback: "Personalized security alerts")
        public static func benefitStorePasswordsLimited(_ p1: Any) -> String {
      return L10n.tr("Core", "benefit_store_passwords_limited", String(describing: p1), fallback: "_")
    }
        public static let benefitStorePasswordsUnlimited = L10n.tr("Core", "benefit_store_passwords_unlimited", fallback: "Unlimited logins")
        public static let benefitUnlimitedDevices = L10n.tr("Core", "benefit_unlimited_devices", fallback: "Sync across <strong>unlimited devices</strong>")
        public static let benefitVpn = L10n.tr("Core", "benefit_vpn", fallback: "<strong>VPN</strong> for WiFi protection")
        public static let cancel = L10n.tr("Core", "Cancel", fallback: "Cancel")
        public static let credentialProviderOnboardingCompletedCTA = L10n.tr("Core", "CredentialProviderOnboarding_CompletedCTA", fallback: "Done")
        public static let credentialProviderOnboardingCompletedTitle = L10n.tr("Core", "CredentialProviderOnboarding_CompletedTitle", fallback: "Uncheck Keychain")
        public static let credentialProviderOnboardingCTA = L10n.tr("Core", "CredentialProviderOnboarding_CTA", fallback: "Go to Settings")
        public static let credentialProviderOnboardingHeadLine = L10n.tr("Core", "CredentialProviderOnboarding_HeadLine", fallback: "Activate Dashlane Autofill in your phone settings")
        public static let credentialProviderOnboardingIntroTitle = L10n.tr("Core", "CredentialProviderOnboarding_IntroTitle", fallback: "Activate Dashlane Autofill")
        public static let credentialProviderOnboardingStep1 = L10n.tr("Core", "CredentialProviderOnboarding_step1", fallback: "1. Select Passwords")
        public static let credentialProviderOnboardingStep2 = L10n.tr("Core", "CredentialProviderOnboarding_step2", fallback: "2. Select AutoFill Passwords")
        public static let credentialProviderOnboardingStep3 = L10n.tr("Core", "CredentialProviderOnboarding_step3", fallback: "3. Activate AutoFill Passwords")
        public static let credentialProviderOnboardingStep4 = L10n.tr("Core", "CredentialProviderOnboarding_step4", fallback: "4. Choose Dashlane")
        public static let credentialProviderOnboardingTitle = L10n.tr("Core", "CredentialProviderOnboarding_Title", fallback: "Activate Password AutoFill")
        public static let currentBenefitDarkWebMonitoring = L10n.tr("Core", "current_benefit_dark_web_monitoring", fallback: "Dark Web Monitoring")
        public static let currentBenefitDevicesSyncUnlimited = L10n.tr("Core", "current_benefit_devices_sync_unlimited", fallback: "Access on unlimited devices")
        public static let currentBenefitMoreInfoDarkWebMonitoringText = L10n.tr("Core", "current_benefit_more_info_dark_web_monitoring_text", fallback: "This Premium tool scans the dark web for leaked personal data and helps you secure it.")
        public static let currentBenefitMoreInfoDarkWebMonitoringTitle = L10n.tr("Core", "current_benefit_more_info_dark_web_monitoring_title", fallback: "Dark Web Monitoring")
        public static let currentBenefitPasswordChanger = L10n.tr("Core", "current_benefit_password_changer", fallback: "Password Changer")
        public static let currentBenefitPasswordsUnlimited = L10n.tr("Core", "current_benefit_passwords_unlimited", fallback: "Unlimited logins")
        public static let currentBenefitSecureNotes = L10n.tr("Core", "current_benefit_secure_notes", fallback: "Secure Notes")
        public static let currentBenefitVpn = L10n.tr("Core", "current_benefit_vpn", fallback: "VPN")
        public static let currentPlanCtaAllPlans = L10n.tr("Core", "current_plan_cta_all_plans", fallback: "Compare plans")
        public static let currentPlanCtaPremium = L10n.tr("Core", "current_plan_cta_premium", fallback: "Get Premium")
        public static let currentPlanSuggestionTrialText = L10n.tr("Core", "current_plan_suggestion_trial_text", fallback: "You’ll be switched to the Free plan after your trial. This plan supports unlimited logins on one device.")
        public static let currentPlanTitleTrial = L10n.tr("Core", "current_plan_title_trial", fallback: "What’s included in the Premium trial:")
        public static let deviceUnlinkAlertMessage = L10n.tr("Core", "DEVICE_UNLINK_ALERT_MESSAGE", fallback: "There was a problem with unlinking your device(s). Please try again or contact Dashlane Support for help.")
        public static let deviceUnlinkAlertTitle = L10n.tr("Core", "DEVICE_UNLINK_ALERT_TITLE", fallback: "Something went wrong")
        public static let deviceUnlinkAlertTryAgain = L10n.tr("Core", "DEVICE_UNLINK_ALERT_TRY_AGAIN", fallback: "Try again")
        public static let deviceUnlinkLimitedMultiDevicesDescription = L10n.tr("Core", "DEVICE_UNLINK_LIMITED_MULTI_DEVICES_DESCRIPTION", fallback: "Upgrade to Premium to access your data on unlimited devices. Or, unlink a device to stay on your current plan.")
        public static func deviceUnlinkLimitedMultiDevicesTitle(_ p1: Any) -> String {
      return L10n.tr("Core", "DEVICE_UNLINK_LIMITED_MULTI_DEVICES_TITLE", String(describing: p1), fallback: "_")
    }
        public static let deviceUnlinkLimitedMultiDevicesUnlinkCta = L10n.tr("Core", "DEVICE_UNLINK_LIMITED_MULTI_DEVICES_UNLINK_CTA", fallback: "Unlink device")
        public static let deviceUnlinkLoadingUnlinkDevice = L10n.tr("Core", "DEVICE_UNLINK_LOADING_UNLINK_DEVICE", fallback: "Unlinking selected device")
        public static let deviceUnlinkLoadingUnlinkDevices = L10n.tr("Core", "DEVICE_UNLINK_LOADING_UNLINK_DEVICES", fallback: "Unlinking selected devices")
        public static let deviceUnlinkUnlinkDevicePremiumFeatureDescription = L10n.tr("Core", "DEVICE_UNLINK_UNLINK_DEVICE_PREMIUM_FEATURE_DESCRIPTION", fallback: "Our Premium plan also includes unlimited logins, VPN, and Dark Web Monitoring.")
        public static let deviceUnlinkUnlinkDevicesDescription = L10n.tr("Core", "DEVICE_UNLINK_UNLINK_DEVICES_DESCRIPTION", fallback: "We’ll securely transfer your Dashlane data to your new device in the next step.")
        public static let deviceUnlinkUnlinkDevicesSubtitle = L10n.tr("Core", "DEVICE_UNLINK_UNLINK_DEVICES_SUBTITLE", fallback: "The Essentials plan supports only 2 devices. Unlink all but one from this list.")
        public static let deviceUnlinkUnlinkDevicesTitle = L10n.tr("Core", "DEVICE_UNLINK_UNLINK_DEVICES_TITLE", fallback: "Select the devices to unlink")
        public static let deviceUnlinkUnlinkDevicesUpgradeCta = L10n.tr("Core", "DEVICE_UNLINK_UNLINK_DEVICES_UPGRADE_CTA", fallback: "Upgrade plan")
        public static let deviceUnlinkingLimitedDescription = L10n.tr("Core", "DEVICE_UNLINKING_LIMITED_DESCRIPTION", fallback: "Upgrade to Premium to access your data on unlimited devices. Or, unlink your previous device to continue.")
        public static let deviceUnlinkingLimitedPremiumCta = L10n.tr("Core", "DEVICE_UNLINKING_LIMITED_PREMIUM_CTA", fallback: "Upgrade to Premium")
        public static let deviceUnlinkingLimitedTitle = L10n.tr("Core", "DEVICE_UNLINKING_LIMITED_TITLE", fallback: "Your current plan supports only 1 device")
        public static let deviceUnlinkingLimitedUnlinkCta = L10n.tr("Core", "DEVICE_UNLINKING_LIMITED_UNLINK_CTA", fallback: "Unlink previous device")
        public static let deviceUnlinkingUnlinkBackCta = L10n.tr("Core", "DEVICE_UNLINKING_UNLINK_BACK_CTA", fallback: "Cancel")
        public static let deviceUnlinkingUnlinkCta = L10n.tr("Core", "DEVICE_UNLINKING_UNLINK_CTA", fallback: "Unlink")
        public static let deviceUnlinkingUnlinkDescription = L10n.tr("Core", "DEVICE_UNLINKING_UNLINK_DESCRIPTION", fallback: "All your Dashlane data will be securely transferred to your new device.")
        public static func deviceUnlinkingUnlinkLastActive(_ p1: Any) -> String {
      return L10n.tr("Core", "DEVICE_UNLINKING_UNLINK_LAST_ACTIVE", String(describing: p1), fallback: "_")
    }
        public static let deviceUnlinkingUnlinkTitle = L10n.tr("Core", "DEVICE_UNLINKING_UNLINK_TITLE", fallback: "Unlink your previous device?")
        public static let disableOtpUseRecoveryCode = L10n.tr("Core", "DISABLE_OTP_USE_RECOVERY_CODE", fallback: "Use a recovery code")
        public static let disableOtpUseRecoveryCodeCta = L10n.tr("Core", "DISABLE_OTP_USE_RECOVERY_CODE_CTA", fallback: "Turn off 2FA")
        public static let duoChallengeButton = L10n.tr("Core", "DUO_CHALLENGE_BUTTON", fallback: "Use Duo Push instead")
        public static let duoChallengeFailedMessage = L10n.tr("Core", "DUO_CHALLENGE_FAILED_MESSAGE", fallback: "The Duo login request was denied")
        public static let duoChallengePrompt = L10n.tr("Core", "DUO_CHALLENGE_PROMPT", fallback: "Approve the Duo login request to continue")
        public static let enterPasscode = L10n.tr("Core", "EnterPasscode", fallback: "Enter Passcode")
        public static let failedAutorenewalAnnouncementAction = L10n.tr("Core", "FAILED_AUTORENEWAL_ANNOUNCEMENT_ACTION", fallback: "Update payment details")
        public static let failedAutorenewalAnnouncementTitle = L10n.tr("Core", "FAILED_AUTORENEWAL_ANNOUNCEMENT_TITLE", fallback: "Please update your payment details to continue enjoying Premium benefits.")
                public static let freeTrialStartedDialogDescription = L10n.tr("Core", "free_trial_started_dialog_description", fallback: "Try out our Premium features for free for 30 days.\n\nFYI: You’ll be automatically switched to Dashlane Free after the trial ends.")
        public static let freeTrialStartedDialogLearnMoreCta = L10n.tr("Core", "free_trial_started_dialog_learn_more_cta", fallback: "Learn more")
        public static let freeTrialStartedDialogTitle = L10n.tr("Core", "free_trial_started_dialog_title", fallback: "Your free trial has started!")
        public static func introOffersFinalPriceDescriptionMonthly(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_finalPriceDescriptionMonthly", String(describing: p1), fallback: "_")
    }
        public static func introOffersFinalPriceDescriptionYearly(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_finalPriceDescriptionYearly", String(describing: p1), fallback: "_")
    }
        public static let introOffersForOneDay = L10n.tr("Core", "introOffers_forOneDay", fallback: "for 1 day")
        public static let introOffersForOneMonth = L10n.tr("Core", "introOffers_forOneMonth", fallback: "for 1 month")
        public static let introOffersForOneWeek = L10n.tr("Core", "introOffers_forOneWeek", fallback: "for 1 week")
        public static let introOffersForOneYear = L10n.tr("Core", "introOffers_forOneYear", fallback: "for 1 year")
        public static func introOffersForXDays(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_forXDays", String(describing: p1), fallback: "_")
    }
        public static func introOffersForXMonths(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_forXMonths", String(describing: p1), fallback: "_")
    }
        public static func introOffersForXWeeks(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_forXWeeks", String(describing: p1), fallback: "_")
    }
        public static func introOffersForXYears(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_forXYears", String(describing: p1), fallback: "_")
    }
        public static let introOffersPerMonthForOneMonth = L10n.tr("Core", "introOffers_perMonthForOneMonth", fallback: "/mo for 1 month")
        public static func introOffersPerMonthForXMonths(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_perMonthForXMonths", String(describing: p1), fallback: "_")
    }
        public static func introOffersPerXMonths(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_perXMonths", String(describing: p1), fallback: "_")
    }
        public static func introOffersPerXYears(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_perXYears", String(describing: p1), fallback: "_")
    }
        public static func introOffersPromoDiscountFirstMonth(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_discountFirstMonth", String(describing: p1), fallback: "_")
    }
        public static func introOffersPromoDiscountFirstXMonths(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_discountFirstXMonths", String(describing: p1), String(describing: p2), fallback: "_")
    }
        public static func introOffersPromoDiscountFirstXYears(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_discountFirstXYears", String(describing: p1), String(describing: p2), fallback: "_")
    }
        public static func introOffersPromoDiscountFirstYear(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_discountFirstYear", String(describing: p1), fallback: "_")
    }
        public static let introOffersPromoFirstDayFree = L10n.tr("Core", "introOffers_promo_firstDayFree", fallback: "First day free")
        public static let introOffersPromoFirstMonthFree = L10n.tr("Core", "introOffers_promo_firstMonthFree", fallback: "First month free")
        public static let introOffersPromoFirstWeekFree = L10n.tr("Core", "introOffers_promo_firstWeekFree", fallback: "First week free")
        public static func introOffersPromoFirstXDaysFree(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_firstXDaysFree", String(describing: p1), fallback: "_")
    }
        public static func introOffersPromoFirstXMonthsFree(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_firstXMonthsFree", String(describing: p1), fallback: "_")
    }
        public static func introOffersPromoFirstXWeeksFree(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_firstXWeeksFree", String(describing: p1), fallback: "_")
    }
        public static func introOffersPromoFirstXYearsFree(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_firstXYearsFree", String(describing: p1), fallback: "_")
    }
        public static let introOffersPromoFirstYearFree = L10n.tr("Core", "introOffers_promo_firstYearFree", fallback: "First year free")
        public static let introOffersPromoSaveFirstMonth = L10n.tr("Core", "introOffers_promo_saveFirstMonth", fallback: "Save on first month")
        public static func introOffersPromoSaveFirstXMonths(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_saveFirstXMonths", String(describing: p1), fallback: "_")
    }
        public static func introOffersPromoSaveFirstXYears(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_promo_saveFirstXYears", String(describing: p1), fallback: "_")
    }
        public static let introOffersPromoSaveFirstYear = L10n.tr("Core", "introOffers_promo_saveFirstYear", fallback: "Save on first year")
        public static let introOffersSpecialOffer = L10n.tr("Core", "introOffers_specialOffer", fallback: "Special offer")
        public static let invalidRecoveryPhoneNumberErrorMessage = L10n.tr("Core", "invalidRecoveryPhoneNumberErrorMessage", fallback: "Your mobile phone number is invalid. Please contact our Customer Support team to fix the issue.")
        public static let ios13SupportDropAnnouncementBody = L10n.tr("Core", "iOS13SupportDropAnnouncementBody", fallback: "You need to update to the latest version of iOS in order to continue receiving updates for this app. You can do this by going to the Settings app, then General ⇾ Software Update")
        public static let ios13SupportDropAnnouncementCTA = L10n.tr("Core", "iOS13SupportDropAnnouncementCTA", fallback: "Open Settings")
        public static let kwAccountCreationExistingAccount = L10n.tr("Core", "KW_ACCOUNT_CREATION_EXISTING_ACCOUNT", fallback: "A Dashlane account exists for this email address.")
        public static let kwAccountErrorTimeOut = L10n.tr("Core", "KW_ACCOUNT_ERROR_TIME_OUT", fallback: "The login request has timed out.")
        public static let kwadddatakwAddressIOS = L10n.tr("Core", "KW_ADD_DATA_KWAddressIOS", fallback: "Add an address")
        public static let kwadddatakwAuthentifiantIOS = L10n.tr("Core", "KW_ADD_DATA_KWAuthentifiantIOS", fallback: "Add a login")
        public static let kwadddatakwBankStatementIOS = L10n.tr("Core", "KW_ADD_DATA_KWBankStatementIOS", fallback: "Add a bank account")
        public static let kwadddatakwCompanyIOS = L10n.tr("Core", "KW_ADD_DATA_KWCompanyIOS", fallback: "Add a company")
        public static let kwadddatakwDriverLicenceIOS = L10n.tr("Core", "KW_ADD_DATA_KWDriverLicenceIOS", fallback: "Add a driver's license")
        public static let kwadddatakwEmailIOS = L10n.tr("Core", "KW_ADD_DATA_KWEmailIOS", fallback: "Add an email")
        public static let kwadddatakwFiscalStatementIOS = L10n.tr("Core", "KW_ADD_DATA_KWFiscalStatementIOS", fallback: "Add a tax number")
        public static let kwadddatakwidCardIOS = L10n.tr("Core", "KW_ADD_DATA_KWIDCardIOS", fallback: "Add an ID card")
        public static let kwadddatakwIdentityIOS = L10n.tr("Core", "KW_ADD_DATA_KWIdentityIOS", fallback: "Add a name")
        public static let kwadddatakwPassportIOS = L10n.tr("Core", "KW_ADD_DATA_KWPassportIOS", fallback: "Add a passport")
        public static let kwadddatakwPaymentMeanCreditCardIOS = L10n.tr("Core", "KW_ADD_DATA_KWPaymentMean_creditCardIOS", fallback: "Add a credit/debit card")
        public static let kwadddatakwPersonalWebsiteIOS = L10n.tr("Core", "KW_ADD_DATA_KWPersonalWebsiteIOS", fallback: "Add a website")
        public static let kwadddatakwPhoneIOS = L10n.tr("Core", "KW_ADD_DATA_KWPhoneIOS", fallback: "Add a phone number")
        public static let kwadddatakwSecureNoteIOS = L10n.tr("Core", "KW_ADD_DATA_KWSecureNoteIOS", fallback: "Add a secure note")
        public static let kwadddatakwSocialSecurityStatementIOS = L10n.tr("Core", "KW_ADD_DATA_KWSocialSecurityStatementIOS", fallback: "Add a social security number")
        public static let kwBack = L10n.tr("Core", "KW_BACK", fallback: "Back")
        public static let kwButtonClose = L10n.tr("Core", "KW_BUTTON_CLOSE", fallback: "Close")
        public static let kwButtonOk = L10n.tr("Core", "KW_BUTTON_OK", fallback: "OK")
        public static let kwCopy = L10n.tr("Core", "KW_COPY", fallback: "Copy")
        public static let kwCreateAccountPrivacy = L10n.tr("Core", "KW_CREATE_ACCOUNT_PRIVACY", fallback: "Privacy Policy")
        public static let kwCreateAccountTermsConditions = L10n.tr("Core", "KW_CREATE_ACCOUNT_TERMS_CONDITIONS", fallback: "Dashlane Terms of Service")
        public static let kwDelete = L10n.tr("Core", "KW_DELETE", fallback: "Delete")
        public static let kwDeviceCurrentDevice = L10n.tr("Core", "KW_DEVICE_CURRENT_DEVICE", fallback: "Current device")
        public static let kwEmailInvalid = L10n.tr("Core", "KW_EMAIL_INVALID", fallback: "This email address is invalid. Please try again.")
        public static let kwEmailTitle = L10n.tr("Core", "KW_EMAIL_TITLE", fallback: "Enter your email address")
        public static let kwEnterYourMasterPassword = L10n.tr("Core", "KW_ENTER_YOUR_MASTER_PASSWORD", fallback: "Enter Master Password")
        public static let kwErrorTitle = L10n.tr("Core", "KW_ERROR_TITLE", fallback: "Error")
        public static let kwExtSomethingWentWrong = L10n.tr("Core", "KW_EXT_SOMETHING_WENT_WRONG", fallback: "Something went wrong. Please retry.")
                public static func kwFeedbackEmailBody(_ p1: Any) -> String {
      return L10n.tr("Core", "KW_FEEDBACK_EMAIL_BODY", String(describing: p1), fallback: "_")
    }
        public static let kwFeedbackEmailSubject = L10n.tr("Core", "KW_FEEDBACK_EMAIL_SUBJECT", fallback: "iOS App Feedback")
        public static let kwHide = L10n.tr("Core", "KW_HIDE", fallback: "Hide")
                public static let kwLimitedRightMessage = L10n.tr("Core", "KW_LIMITED_RIGHT_MESSAGE", fallback: "You have limited rights to this login.\n\nYou can't view, copy or edit it, but you can use it with Dashlane extensions for auto-login.")
        public static let kwLinkedDefaultOther = L10n.tr("Core", "KW_Linked_Default_Other", fallback: "Other")
        public static func kwLockBiometryTypeLoadingMsg(_ p1: Any) -> String {
      return L10n.tr("Core", "KW_LOCK_BIOMETRY_TYPE_LOADING_MSG", String(describing: p1), fallback: "_")
    }
        public static let kwLogOut = L10n.tr("Core", "KW_LOG_OUT", fallback: "Log out")
        public static let kwLoginNow = L10n.tr("Core", "KW_LOGIN_NOW", fallback: "Log in")
        public static let kwLoginVcLoginButton = L10n.tr("Core", "KW_LOGIN_VC_LOGIN_BUTTON", fallback: "Log in")
        public static let kwNext = L10n.tr("Core", "KW_NEXT", fallback: "Next")
        public static let kwNoInternet = L10n.tr("Core", "KW_NO_INTERNET", fallback: "Please check your internet connection and try again.")
        public static let kwOtpMessage = L10n.tr("Core", "KW_OTP_MESSAGE", fallback: "Enter the 6-digit token from your 2-factor authentication (2FA) app to log in")
        public static let kwOtpPlaceholderText = L10n.tr("Core", "KW_OTP_PLACEHOLDER_TEXT", fallback: "Authentication code")
        public static let kwpasswordchangererrorAccountLocked = L10n.tr("Core", "KW_PASSWORDCHANGER_ERROR_accountLocked", fallback: "This account was blocked after too many incorrect attempts. Check your login details and try again later.")
        public static let kwPcOnboardingNotNow = L10n.tr("Core", "KW_PC_ONBOARDING_NOT_NOW", fallback: "Not now")
        public static let kwReveal = L10n.tr("Core", "KW_REVEAL", fallback: "Reveal")
                public static let kwSecureNoteLimitedRightMessage = L10n.tr("Core", "KW_SECURE_NOTE_LIMITED_RIGHT_MESSAGE", fallback: "You have limited rights to this secure note.\n\nYou cannot edit or share it.")
        public static let kwSend = L10n.tr("Core", "KW_SEND", fallback: "Send")
        public static let kwSendFeedback = L10n.tr("Core", "KW_SEND_FEEDBACK", fallback: "Share a problem")
        public static let kwSendLove = L10n.tr("Core", "KW_SEND_LOVE", fallback: "Rate 5 stars")
        public static let kwSendLoveFeedbackbuttonPasswordchanger = L10n.tr("Core", "KW_SEND_LOVE_FEEDBACKBUTTON_PASSWORDCHANGER", fallback: "Share a problem")
        public static let kwSendLoveHeadingPasswordchanger = L10n.tr("Core", "KW_SEND_LOVE_HEADING_PASSWORDCHANGER", fallback: "Are you happy with Dashlane?")
        public static let kwSendLoveNothanksbuttonPasswordchanger = L10n.tr("Core", "KW_SEND_LOVE_NOTHANKSBUTTON_PASSWORDCHANGER", fallback: "Not now")
        public static let kwSendLoveSendlovebuttonPasswordchanger = L10n.tr("Core", "KW_SEND_LOVE_SENDLOVEBUTTON_PASSWORDCHANGER", fallback: "Rate 5 Stars")
        public static let kwSendLoveSubheadingPasswordchanger = L10n.tr("Core", "KW_SEND_LOVE_SUBHEADING_PASSWORDCHANGER", fallback: "If you love the app, tell us why! If you are having trouble, let us know.")
        public static let kwSharingNoEmailAccount = L10n.tr("Core", "KW_SHARING_NO_EMAIL_ACCOUNT", fallback: "You don't have an email account configured on this device.")
        public static let kwSignOut = L10n.tr("Core", "KW_SIGN_OUT", fallback: "Log out")
        public static let kwThrottleMsg = L10n.tr("Core", "KW_THROTTLE_MSG", fallback: "Account is locked, please retry in 5 minutes.")
        public static let kwTokenMsg = L10n.tr("Core", "KW_TOKEN_MSG", fallback: "We just sent your verification code by email. (If you don't see it, check Spam/Junk)")
        public static let kwTokenPlaceholderText = L10n.tr("Core", "KW_TOKEN_PLACEHOLDER_TEXT", fallback: "Authentication code")
        public static let kwWrongMasterPasswordTryAgain = L10n.tr("Core", "KW_WRONG_MASTER_PASSWORD_TRY_AGAIN", fallback: "Wrong master password, try again")
        public static let kwAddressIOS = L10n.tr("Core", "KWAddressIOS", fallback: "Address")
        public static let kwAuthentifiantIOS = L10n.tr("Core", "KWAuthentifiantIOS", fallback: "Username")
        public static let kwBankStatementIOS = L10n.tr("Core", "KWBankStatementIOS", fallback: "Bank account")
        public static let kwCompanyIOS = L10n.tr("Core", "KWCompanyIOS", fallback: "Company")
        public static let kwDriverLicenceIOS = L10n.tr("Core", "KWDriverLicenceIOS", fallback: "Driver's License")
        public static let kwEmailIOS = L10n.tr("Core", "KWEmailIOS", fallback: "Email")
        public static let kwFiscalStatementIOS = L10n.tr("Core", "KWFiscalStatementIOS", fallback: "Tax number")
        public static let kwidCardIOS = L10n.tr("Core", "KWIDCardIOS", fallback: "ID Card")
        public static let kwIdentityIOS = L10n.tr("Core", "KWIdentityIOS", fallback: "Name")
        public static let kwPassportIOS = L10n.tr("Core", "KWPassportIOS", fallback: "Passport")
        public static let kwPaymentMeanCreditCardIOS = L10n.tr("Core", "KWPaymentMean_creditCardIOS", fallback: "Credit card")
        public static let kwPersonalWebsiteIOS = L10n.tr("Core", "KWPersonalWebsiteIOS", fallback: "Website")
        public static let kwPhoneIOS = L10n.tr("Core", "KWPhoneIOS", fallback: "Phone")
        public static let kwSecureNoteIOS = L10n.tr("Core", "KWSecureNoteIOS", fallback: "Note")
        public static let kwSocialSecurityStatementIOS = L10n.tr("Core", "KWSocialSecurityStatementIOS", fallback: "Social Security Number")
        public static let m2WImportFromChromeConfirmationPopupNo = L10n.tr("Core", "M2W_ImportFromChrome_ConfirmationPopup_No", fallback: "Not yet")
        public static let m2WImportFromChromeConfirmationPopupTitle = L10n.tr("Core", "M2W_ImportFromChrome_ConfirmationPopup_Title", fallback: "Have you logged in to Dashlane on your computer?")
        public static let m2WImportFromChromeConfirmationPopupYes = L10n.tr("Core", "M2W_ImportFromChrome_ConfirmationPopup_Yes", fallback: "Yes")
        public static let m2WImportFromChromeImportScreenBack = L10n.tr("Core", "M2W_ImportFromChrome_ImportScreen_Back", fallback: "Back")
        public static let m2WImportFromChromeImportScreenDone = L10n.tr("Core", "M2W_ImportFromChrome_ImportScreen_Done", fallback: "Done")
        public static let m2WImportFromChromeImportScreenPrimaryTitle = L10n.tr("Core", "M2W_ImportFromChrome_ImportScreen_PrimaryTitle", fallback: "My Account > Import Passwords")
        public static let m2WImportFromChromeImportScreenSecondaryTitle = L10n.tr("Core", "M2W_ImportFromChrome_ImportScreen_SecondaryTitle", fallback: "In the web app, you’ll find the import tool in the account menu:")
        public static let m2WImportFromChromeIntoScreenCancel = L10n.tr("Core", "M2W_ImportFromChrome_IntoScreen_Cancel", fallback: "Cancel")
        public static let m2WImportFromChromeIntoScreenCTA = L10n.tr("Core", "M2W_ImportFromChrome_IntoScreen_CTA", fallback: "Let’s begin")
        public static let m2WImportFromChromeIntoScreenPrimaryTitlePart1 = L10n.tr("Core", "M2W_ImportFromChrome_IntoScreen_PrimaryTitle_Part1", fallback: "Import from")
        public static let m2WImportFromChromeIntoScreenPrimaryTitlePart2 = L10n.tr("Core", "M2W_ImportFromChrome_IntoScreen_PrimaryTitle_Part2", fallback: "Chrome")
        public static let m2WImportFromChromeIntoScreenSecondaryTitle = L10n.tr("Core", "M2W_ImportFromChrome_IntoScreen_SecondaryTitle", fallback: "We’ve built an easy way to import via your computer.")
        public static let m2WImportFromChromeIntroScreenPrimaryTitle = L10n.tr("Core", "M2W_ImportFromChrome_IntroScreen_PrimaryTitle", fallback: "Import from Chrome")
        public static let m2WImportFromChromeURLScreenCTA = L10n.tr("Core", "M2W_ImportFromChrome_URLScreen_CTA", fallback: "Continue")
        public static let m2WImportFromChromeURLScreenPrimaryTitle = L10n.tr("Core", "M2W_ImportFromChrome_URLScreen_PrimaryTitle", fallback: "On your computer, go to the address above")
        public static let m2WImportFromDashIntroScreenBrowse = L10n.tr("Core", "M2W_ImportFromDash_IntroScreen_Browse", fallback: "Browse Files")
        public static let m2WImportFromDashIntroScreenPrimaryTitle = L10n.tr("Core", "M2W_ImportFromDash_IntroScreen_PrimaryTitle", fallback: "Import from a Dashlane backup file")
        public static let m2WImportFromDashIntroScreenSecondaryTitle = L10n.tr("Core", "M2W_ImportFromDash_IntroScreen_SecondaryTitle", fallback: "Make sure your DASH file is saved in your iCloud Drive so you can access it on this device.")
        public static let m2WImportFromDashPasswordScreenFieldPlaceholder = L10n.tr("Core", "M2W_ImportFromDash_PasswordScreen_FieldPlaceholder", fallback: "Enter password")
        public static let m2WImportFromDashPasswordScreenPrimaryTitle = L10n.tr("Core", "M2W_ImportFromDash_PasswordScreen_PrimaryTitle", fallback: "Unlock your DASH file")
        public static let m2WImportFromDashPasswordScreenSecondaryTitle = L10n.tr("Core", "M2W_ImportFromDash_PasswordScreen_SecondaryTitle", fallback: "Enter the password you created when exporting this DASH file.")
        public static let m2WImportFromDashPasswordScreenTroubleshooting = L10n.tr("Core", "M2W_ImportFromDash_PasswordScreen_Troubleshooting", fallback: "This password may be different than your account Master Password. Learn more about importing DASH files.")
        public static let m2WImportFromDashPasswordScreenTroubleshootingLink = L10n.tr("Core", "M2W_ImportFromDash_PasswordScreen_TroubleshootingLink", fallback: "Learn more about importing DASH files.")
        public static let m2WImportFromDashPasswordScreenUnlockImport = L10n.tr("Core", "M2W_ImportFromDash_PasswordScreen_UnlockImport", fallback: "Unlock")
        public static let m2WImportFromDashPasswordScreenWrongPassword = L10n.tr("Core", "M2W_ImportFromDash_PasswordScreen_WrongPassword", fallback: "Invalid password. Try again")
        public static let m2WImportFromKeychainIntroScreenBrowse = L10n.tr("Core", "M2W_ImportFromKeychain_IntroScreen_Browse", fallback: "Browse Files")
        public static let m2WImportFromKeychainIntroScreenNotExported = L10n.tr("Core", "M2W_ImportFromKeychain_IntroScreen_NotExported", fallback: "How do I export from Keychain?")
        public static let m2WImportFromKeychainIntroScreenPrimaryTitle = L10n.tr("Core", "M2W_ImportFromKeychain_IntroScreen_PrimaryTitle", fallback: "Import from Keychain")
        public static let m2WImportFromKeychainIntroScreenSecondaryTitle = L10n.tr("Core", "M2W_ImportFromKeychain_IntroScreen_SecondaryTitle", fallback: "Make sure you’ve exported your Apple Keychain content from your computer to your iCloud Drive so you can access it on this device.")
        public static let m2WImportFromKeychainURLScreenBrowse = L10n.tr("Core", "M2W_ImportFromKeychain_URLScreen_Browse", fallback: "Browse Files")
        public static let m2WImportFromKeychainURLScreenClose = L10n.tr("Core", "M2W_ImportFromKeychain_URLScreen_Close", fallback: "Cancel")
        public static let m2WImportFromKeychainURLScreenPrimaryTitle = L10n.tr("Core", "M2W_ImportFromKeychain_URLScreen_PrimaryTitle", fallback: "How to export from Apple Keychain")
                public static let m2WImportFromKeychainURLScreenSecondaryTitle = L10n.tr("Core", "M2W_ImportFromKeychain_URLScreen_SecondaryTitle", fallback: "On your computer, go to dashlane.com/keychain and follow the instructions. \n\nThen, return here and to choose the file you want to import.")
        public static let m2WImportGenericImportErrorScreenBrowse = L10n.tr("Core", "M2W_ImportGeneric_ImportErrorScreen_Browse", fallback: "Try another file")
        public static let m2WImportGenericImportErrorScreenGenericSecondaryTitle = L10n.tr("Core", "M2W_ImportGeneric_ImportErrorScreen_GenericSecondaryTitle", fallback: "An unexpected error occurred. Try again later or import a different file.")
        public static let m2WImportGenericImportErrorScreenPrimaryTitle = L10n.tr("Core", "M2W_ImportGeneric_ImportErrorScreen_PrimaryTitle", fallback: "Import failed")
        public static let m2WImportGenericImportErrorScreenSecondaryTitle = L10n.tr("Core", "M2W_ImportGeneric_ImportErrorScreen_SecondaryTitle", fallback: "We couldn’t read your file. Make sure it’s formatted correctly before trying again or import a different file.")
        public static let m2WImportGenericImportErrorScreenTroubleshooting = L10n.tr("Core", "M2W_ImportGeneric_ImportErrorScreen_Troubleshooting", fallback: "Troubleshoot common import errors in our Help Center")
        public static let m2WImportGenericImportErrorScreenTroubleshootingLink = L10n.tr("Core", "M2W_ImportGeneric_ImportErrorScreen_TroubleshootingLink", fallback: "Troubleshoot common import errors in our Help Center")
        public static let m2WImportGenericImportErrorScreenTryAgain = L10n.tr("Core", "M2W_ImportGeneric_ImportErrorScreen_TryAgain", fallback: "Try again")
        public static let m2WImportGenericImportScreenHeader = L10n.tr("Core", "M2W_ImportGeneric_ImportScreen_Header", fallback: "Import")
        public static let m2WImportGenericImportScreenImport = L10n.tr("Core", "M2W_ImportGeneric_ImportScreen_Import", fallback: "Import selected")
        public static func m2WImportGenericImportScreenPrimaryTitle(_ p1: Any) -> String {
      return L10n.tr("Core", "M2W_ImportGeneric_ImportScreen_PrimaryTitle", String(describing: p1), fallback: "_")
    }
        public static let macOSSupportDropAnnouncementBody = L10n.tr("Core", "macOSSupportDropAnnouncementBody", fallback: "You need to update to the latest version of macOS in order to continue receiving updates for this app. You can do this by opening System Preferences, then selecting Software Update.")
        public static let next = L10n.tr("Core", "Next", fallback: "Next")
        public static let otpRecoveryCannotAccessCodes = L10n.tr("Core", "OTP_RECOVERY_CANNOT_ACCESS_CODES", fallback: "Can’t access your app?")
        public static let otpRecoveryCannotAccessCodesDescription = L10n.tr("Core", "OTP_RECOVERY_CANNOT_ACCESS_CODES_DESCRIPTION", fallback: "Use one of the 10 recovery codes that were generated when you set up 2FA. We can also send you codes by text message.")
        public static let otpRecoveryDisableCannotAccessCodesDescription = L10n.tr("Core", "OTP_RECOVERY_DISABLE_CANNOT_ACCESS_CODES_DESCRIPTION", fallback: "Enter one of the recovery codes you received by text message.")
        public static let otpRecoveryDisableCannotAccessCodesTitle = L10n.tr("Core", "OTP_RECOVERY_DISABLE_CANNOT_ACCESS_CODES_TITLE", fallback: "2FA recovery")
        public static let otpRecoveryDisableSendFallbackSmsMessage = L10n.tr("Core", "OTP_RECOVERY_DISABLE_SEND_FALLBACK_SMS_MESSAGE", fallback: "We’ll send a text message with two recovery codes to the phone number associated with this account.")
        public static let otpRecoveryEnterBackupCode = L10n.tr("Core", "OTP_RECOVERY_ENTER_BACKUP_CODE", fallback: "Enter a recovery code")
        public static let otpRecoveryReset2Fa = L10n.tr("Core", "OTP_RECOVERY_RESET_2FA", fallback: "Receive a text message")
        public static let otpRecoverySendFallbackSmsCodeSentDescription = L10n.tr("Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_CODE_SENT_DESCRIPTION", fallback: "Use the first code to log in to Dashlane. The second code removes 2FA so you can reset it.")
        public static let otpRecoverySendFallbackSmsCodeSentTitle = L10n.tr("Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_CODE_SENT_TITLE", fallback: "Codes sent to your mobile phone")
        public static let otpRecoverySendFallbackSmsDescription = L10n.tr("Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_DESCRIPTION", fallback: "This will send a text to the mobile phone number on this account. After logging in, you'll need to set up 2FA again.")
        public static let otpRecoverySendFallbackSmsNoPhoneNumber = L10n.tr("Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_NO_PHONE_NUMBER", fallback: "There's no mobile phone number saved for this account. Please contact our Customer Support team to fix the issue.")
        public static let otpRecoverySendFallbackSmsTitle = L10n.tr("Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_TITLE", fallback: "2FA recovery")
        public static let otpRecoveryUseBackupCode = L10n.tr("Core", "OTP_RECOVERY_USE_BACKUP_CODE", fallback: "Log in with recovery code")
        public static let otpRecoveryUseBackupCodeCta = L10n.tr("Core", "OTP_RECOVERY_USE_BACKUP_CODE_CTA", fallback: "Log in")
        public static let otpRecoveryUseBackupCodeDescription = L10n.tr("Core", "OTP_RECOVERY_USE_BACKUP_CODE_DESCRIPTION", fallback: "Enter one of the 10 recovery codes that were generated when you set up 2FA.")
        public static let otpRecoveryUseBackupCodeTitle = L10n.tr("Core", "OTP_RECOVERY_USE_BACKUP_CODE_TITLE", fallback: "Use a recovery code")
        public static let paywallUpgradetag = L10n.tr("Core", "paywall_upgradetag", fallback: "Upgrade")
        public static let paywallsDwmMessage = L10n.tr("Core", "paywalls_dwm_message", fallback: "Upgrade to our Premium plan to monitor and protect yourself against hacks and data breaches.")
        public static let paywallsDwmTitle = L10n.tr("Core", "paywalls_dwm_title", fallback: "Dark Web Monitoring is a Premium feature")
        public static let paywallsPasswordChangerTitle = L10n.tr("Core", "paywalls_passwordChanger_title", fallback: "Password Changer is a paid feature")
        public static let paywallsPasswordChangerPremiumMessage = L10n.tr("Core", "paywalls_passwordChangerPremium_message", fallback: "Upgrade to our Premium plan to change multiple weak passwords—in just one click.")
        public static let paywallsPasswordLimitTitle = L10n.tr("Core", "paywalls_passwordLimit_title", fallback: "You've reached your login limit")
        public static let paywallsPasswordLimitPremiumMessage = L10n.tr("Core", "paywalls_passwordLimitPremium_message", fallback: "Upgrade to our Premium plan to get unlimited logins and sync across unlimited devices.")
        public static let paywallsPlanOptionsCTA = L10n.tr("Core", "paywalls_planOptions_CTA", fallback: "See plan options")
        public static let paywallsSecureNotesTitle = L10n.tr("Core", "paywalls_secureNotes_title", fallback: "Secure Notes is a paid feature")
        public static let paywallsSecureNotesPremiumMessage = L10n.tr("Core", "paywalls_secureNotesPremium_message", fallback: "Upgrade to our Premium plan to store and share encrypted documents.")
        public static let paywallsSharingLimitMessage = L10n.tr("Core", "paywalls_sharingLimit_message", fallback: "You can share up to 5 items with Dashlane Free. Upgrade to our Essentials plan to share unlimited items with multiple contacts.")
        public static let paywallsSharingLimitTitle = L10n.tr("Core", "paywalls_sharingLimit_title", fallback: "You've reached your sharing limit")
        public static let paywallsSharingLimitPremiumMessage = L10n.tr("Core", "paywalls_sharingLimitPremium_message", fallback: "You can share up to {0} items with Dashlane Free. Upgrade to our Premium plan to share unlimited items with multiple contacts.")
        public static let paywallsUpgradeToEssentialsCTA = L10n.tr("Core", "paywalls_upgradeToEssentials_CTA", fallback: "Upgrade to Essentials")
        public static let paywallsUpgradeToPremiumCTA = L10n.tr("Core", "paywalls_upgradeToPremium_CTA", fallback: "Upgrade to Premium")
        public static let paywallsVpnMessage = L10n.tr("Core", "paywalls_vpn_message", fallback: "Upgrade to our Premium plan to browse privately and securely online with VPN.")
        public static let paywallsVpnTitle = L10n.tr("Core", "paywalls_vpn_title", fallback: "VPN is a paid feature")
        public static let plansActionBarTitle = L10n.tr("Core", "plans_action_bar_title", fallback: "Plan options")
        public static let plansAdvancedDescription = L10n.tr("Core", "plans_advanced_description", fallback: "Manage unlimited passwords on all your devices, plus get advanced security tools.")
        public static let plansAdvancedTitle = L10n.tr("Core", "plans_advanced_title", fallback: "Advanced")
            public static let plansCgu = L10n.tr("Core", "plans_cgu", fallback: "• Annual subscriptions renew automatically. Cancel at any time.\n• Subscriptions may be changed in your iCloud account.")
            public static let plansCguAppleId = L10n.tr("Core", "plans_cgu_apple_id", fallback: "• Annual subscriptions renew automatically. Cancel at any time.\n• Subscriptions may be changed via your Apple ID.")
            public static let plansCguAppleId2 = L10n.tr("Core", "plans_cgu_apple_id_2", fallback: "• Annual subscriptions renew automatically. Cancel at any time.\n• Subscriptions may be changed via your Apple ID.")
        public static let plansCguMore = L10n.tr("Core", "plans_cgu_more", fallback: "For more information on Dashlane, see our Privacy Policy and Terms of Service.")
            public static func plansCtaMonthly(_ p1: Any) -> String {
      return L10n.tr("Core", "plans_cta_monthly", String(describing: p1), fallback: "_")
    }
            public static func plansCtaYearly(_ p1: Any) -> String {
      return L10n.tr("Core", "plans_cta_yearly", String(describing: p1), fallback: "_")
    }
            public static let plansEmptystateSubtitle = L10n.tr("Core", "plans_emptystate_subtitle", fallback: "Your purchase couldn’t be completed.\n Please try again later.")
        public static let plansEmptystateTitle = L10n.tr("Core", "plans_emptystate_title", fallback: "Something went wrong")
        public static let plansEssentialsDescription = L10n.tr("Core", "plans_essentials_description", fallback: "Get unlimited logins synced across <strong>2 devices</strong>.")
        public static let plansEssentialsTitle = L10n.tr("Core", "plans_essentials_title", fallback: "Essentials")
        public static let plansFamilyDescription = L10n.tr("Core", "plans_family_description", fallback: "Protect the whole family with <strong>10 individual Premium accounts</strong> for one low price.")
        public static let plansFamilyTitle = L10n.tr("Core", "plans_family_title", fallback: "Family")
        public static let plansFreeDescription = L10n.tr("Core", "plans_free_description", fallback: "")
        public static let plansOnGoingPlan = L10n.tr("Core", "plans_on_going_plan", fallback: "Your current plan")
        public static let plansPeriodicityToggleMonthly = L10n.tr("Core", "plans_periodicity_toggle_monthly", fallback: "Monthly prices")
        public static let plansPeriodicityToggleYearly = L10n.tr("Core", "plans_periodicity_toggle_yearly", fallback: "Annual prices")
        public static let plansPremiumDescription = L10n.tr("Core", "plans_premium_description", fallback: "Get unlimited logins synced across <strong>unlimited devices</strong>, plus Dark Web Monitoring and VPN protection.")
        public static let plansPremiumTitle = L10n.tr("Core", "plans_premium_title", fallback: "Premium")
        public static func plansPriceBilledMonthly(_ p1: Any) -> String {
      return L10n.tr("Core", "plans_price_billed_monthly", String(describing: p1), fallback: "_")
    }
        public static func plansPriceBilledYearly(_ p1: Any) -> String {
      return L10n.tr("Core", "plans_price_billed_yearly", String(describing: p1), fallback: "_")
    }
        public static func plansSave(_ p1: Any) -> String {
      return L10n.tr("Core", "plans_save", String(describing: p1), fallback: "_")
    }
        public static func plansSaveUpTo(_ p1: Any) -> String {
      return L10n.tr("Core", "plans_save_up_to", String(describing: p1), fallback: "_")
    }
        public static let planScreensActivateLabel = L10n.tr("Core", "planScreens_activateLabel", fallback: "Activate new features")
        public static let planScreensFreePlanDescription = L10n.tr("Core", "planScreens_freePlanDescription", fallback: "Simple, secure password manager on one device")
        public static let planScreensOK = L10n.tr("Core", "planScreens_OK", fallback: "OK")
        public static let planScreensPremiumFamilyAccounts = L10n.tr("Core", "planScreens_premiumFamily_Accounts", fallback: "<strong>10 individual</strong> Premium accounts")
        public static let planScreensPremiumFamilyPlanTitle = L10n.tr("Core", "planScreens_premiumFamilyPlanTitle", fallback: "Friends & Family")
        public static let planScreensPurchaseCompleteMessage = L10n.tr("Core", "planScreens_purchaseCompleteMessage", fallback: "Your new features are ready to use on all of your devices")
        public static func planScreensPurchaseCompleteTitle(_ p1: Any) -> String {
      return L10n.tr("Core", "planScreens_purchaseCompleteTitle", String(describing: p1), fallback: "_")
    }
        public static let planScreensPurchaseErrorMessage = L10n.tr("Core", "planScreens_purchaseErrorMessage", fallback: "Your purchase couldn't be completed. Please try again.")
        public static let planScreensPurchaseErrorTitle = L10n.tr("Core", "planScreens_purchaseErrorTitle", fallback: "Oops")
        public static func planScreensPurchaseScreenTitle(_ p1: Any) -> String {
      return L10n.tr("Core", "planScreens_purchaseScreenTitle", String(describing: p1), fallback: "_")
    }
        public static let planScreensTitleFreePlan = L10n.tr("Core", "planScreens_title_freePlan", fallback: "You're on a Free plan")
        public static let planScreensTitlePremium = L10n.tr("Core", "planScreens_title_premium", fallback: "You’re on a Premium plan")
        public static let planScreensTitleTrialPlan = L10n.tr("Core", "planScreens_title_trialPlan", fallback: "You’re on a Premium trial")
        public static let planScreensTrialTitle = L10n.tr("Core", "planScreens_trialTitle", fallback: "Premium Trial")
        public static let planScreensVerifyLabel = L10n.tr("Core", "planScreens_verifyLabel", fallback: "Register account upgrade")
        public static func planScreensYourPlan(_ p1: Any) -> String {
      return L10n.tr("Core", "planScreens_yourPlan", String(describing: p1), fallback: "_")
    }
        public static let resetMasterPasswordConfirmationDialogConfirm = L10n.tr("Core", "ResetMasterPassword_ConfirmationDialog_Confirm", fallback: "Reset Master Password")
        public static let resetMasterPasswordForget = L10n.tr("Core", "ResetMasterPassword_Forget", fallback: "Forgot?")
        public static let resetMasterPasswordIncorrectMasterPassword1 = L10n.tr("Core", "ResetMasterPassword_IncorrectMasterPassword_1", fallback: "Wrong Master Password. We can help you")
        public static let resetMasterPasswordIncorrectMasterPassword2 = L10n.tr("Core", "ResetMasterPassword_IncorrectMasterPassword_2", fallback: "reset your Master Password.")
        public static let resetMasterPasswordInterstitialCancel = L10n.tr("Core", "ResetMasterPassword_Interstitial_Cancel", fallback: "Cancel")
        public static let resetMasterPasswordInterstitialCTA = L10n.tr("Core", "ResetMasterPassword_Interstitial_CTA", fallback: "Enable reset")
                public static let resetMasterPasswordInterstitialDescription = L10n.tr("Core", "ResetMasterPassword_Interstitial_Description", fallback: "Enable this feature to make sure you can reset your Master Password if you ever forget it.\n\nYou can always do it later in the security section of the settings.")
        public static let resetMasterPasswordInterstitialSkip = L10n.tr("Core", "ResetMasterPassword_Interstitial_Skip", fallback: "Maybe later")
        public static let resetMasterPasswordInterstitialTitle = L10n.tr("Core", "ResetMasterPassword_Interstitial_Title", fallback: "Reset your Master Password easily")
        public static let signoutAskMasterPassword = L10n.tr("Core", "signoutAskMasterPassword", fallback: "Make sure you remember your Master Password. We’ll ask for it when you log back in.")
        public static let specialOfferAnnouncementBody = L10n.tr("Core", "SpecialOffer_Announcement_body", fallback: "Half-price for 1 year!")
        public static let specialOfferAnnouncementTitle = L10n.tr("Core", "SpecialOffer_Announcement_title", fallback: "Special Premium Offer")
        public static let ssoBlockedError = L10n.tr("Core", "ssoBlockedError", fallback: "Please contact your company admin to get access to this account creation.")
                        public static let tokenNotWorkingBody = L10n.tr("Core", "TOKEN_NOT_WORKING_BODY", fallback: "Verification codes are sent to your contact email address and valid for 3h, so that only you can connect your account on a new device.\n\nMake sure to check spam for the correct email address (this may be different to your Dashlane account email).\n\nIf you use Dashlane on another mobile device, you can also access the code in your app.")
        public static let tokenNotWorkingTitle = L10n.tr("Core", "TOKEN_NOT_WORKING_TITLE", fallback: "Trouble with this code?")
        public static let tooManyTokenAttempts = L10n.tr("Core", "TooManyTokenAttempts", fallback: "Too many attempts with this code.")
        public static let troubleLoggingIn = L10n.tr("Core", "TROUBLE_LOGGING_IN", fallback: "Trouble logging in?")
        public static let troubleWithToken = L10n.tr("Core", "TROUBLE_WITH_TOKEN", fallback: "Trouble with code?")
        public static let unlockDashlane = L10n.tr("Core", "UnlockDashlane", fallback: "Unlock Dashlane")
        public static let unlockWithSSOTitle = L10n.tr("Core", "unlockWithSSOTitle", fallback: "Unlock with SSO")
        public static let update = L10n.tr("Core", "update", fallback: "Update")
        public static let updateAppMessage = L10n.tr("Core", "updateAppMessage", fallback: "There’s a new version available for download! Please update the app by visiting the App Store.")
        public static let updateAppTitle = L10n.tr("Core", "updateAppTitle", fallback: "New version available")
        public static let zxcvbnSuggestionDefaultCommonPhrases = L10n.tr("Core", "ZXCVBN_SUGGESTION_DEFAULT_COMMON_PHRASES", fallback: "Avoid common phrases and sequences like \"atthebeach\" or \"12345\"")
        public static let zxcvbnSuggestionDefaultObviousSubstitutions = L10n.tr("Core", "ZXCVBN_SUGGESTION_DEFAULT_OBVIOUS_SUBSTITUTIONS", fallback: "Avoid obvious substitutions (e.g. Pas$w0rd)")
        public static let zxcvbnSuggestionDefaultPasswordLength = L10n.tr("Core", "ZXCVBN_SUGGESTION_DEFAULT_PASSWORD_LENGTH", fallback: "Aim for at least 10 characters")
        public static let zxcvbnSuggestionDefaultPersonalInfo = L10n.tr("Core", "ZXCVBN_SUGGESTION_DEFAULT_PERSONAL_INFO", fallback: "Avoid including personal information like dates of birth or pet names")
    public enum KWAddressIOS {
            public static let addressFull = L10n.tr("Core", "KWAddressIOS.addressFull", fallback: "Address")
            public static let addressName = L10n.tr("Core", "KWAddressIOS.addressName", fallback: "Item name")
            public static let building = L10n.tr("Core", "KWAddressIOS.building", fallback: "Building")
            public static let city = L10n.tr("Core", "KWAddressIOS.city", fallback: "City")
            public static let country = L10n.tr("Core", "KWAddressIOS.country", fallback: "Country")
            public static let county = L10n.tr("Core", "KWAddressIOS.county", fallback: "County")
            public static let digitCode = L10n.tr("Core", "KWAddressIOS.digitCode", fallback: "Door code")
            public static let door = L10n.tr("Core", "KWAddressIOS.door", fallback: "Apartment")
            public static let floor = L10n.tr("Core", "KWAddressIOS.floor", fallback: "Floor")
            public static let linkedPhone = L10n.tr("Core", "KWAddressIOS.linkedPhone", fallback: "Phone")
            public static let postcode = L10n.tr("Core", "KWAddressIOS.postcode", fallback: "Postcode")
            public static let receiver = L10n.tr("Core", "KWAddressIOS.receiver", fallback: "Recipient")
            public static let stairs = L10n.tr("Core", "KWAddressIOS.stairs", fallback: "Stair")
            public static let state = L10n.tr("Core", "KWAddressIOS.state", fallback: "State")
            public static let streetNumber = L10n.tr("Core", "KWAddressIOS.streetNumber", fallback: "Number")
            public static let zipCode = L10n.tr("Core", "KWAddressIOS.zipCode", fallback: "Zip Code")
    }
    public enum KWAuthentifiantIOS {
            public static let autoLogin = L10n.tr("Core", "KWAuthentifiantIOS.autoLogin", fallback: "Auto-login")
            public static let category = L10n.tr("Core", "KWAuthentifiantIOS.category", fallback: "Category")
            public static let email = L10n.tr("Core", "KWAuthentifiantIOS.email", fallback: "Email")
            public static let login = L10n.tr("Core", "KWAuthentifiantIOS.login", fallback: "Username")
            public static let note = L10n.tr("Core", "KWAuthentifiantIOS.note", fallback: "Notes")
            public static let otp = L10n.tr("Core", "KWAuthentifiantIOS.otp", fallback: "2FA token")
            public static let password = L10n.tr("Core", "KWAuthentifiantIOS.password", fallback: "Password")
            public static let passwordStrength = L10n.tr("Core", "KWAuthentifiantIOS.passwordStrength", fallback: "password strength")
            public static let secondaryLogin = L10n.tr("Core", "KWAuthentifiantIOS.secondaryLogin", fallback: "Alternate username")
            public static let sharing = L10n.tr("Core", "KWAuthentifiantIOS.sharing", fallback: "sharing with")
            public static let spaceId = L10n.tr("Core", "KWAuthentifiantIOS.spaceId", fallback: "Space")
            public static let subdomainOnly = L10n.tr("Core", "KWAuthentifiantIOS.subdomainOnly", fallback: "Subdomain Only")
            public static let title = L10n.tr("Core", "KWAuthentifiantIOS.title", fallback: "Item name")
            public static let url = L10n.tr("Core", "KWAuthentifiantIOS.url", fallback: "Website")
            public static let urlStringForUI = L10n.tr("Core", "KWAuthentifiantIOS.urlStringForUI", fallback: "Website")
      public enum AutoLogin {
                public static let `false` = L10n.tr("Core", "KWAuthentifiantIOS.autoLogin.false", fallback: "No")
                public static let `true` = L10n.tr("Core", "KWAuthentifiantIOS.autoLogin.true", fallback: "Yes")
      }
      public enum Domains {
                public static let add = L10n.tr("Core", "KWAuthentifiantIOS.domains.add", fallback: "Add another website")
                public static let addedByYou = L10n.tr("Core", "KWAuthentifiantIOS.domains.addedByYou", fallback: "Added by you")
                public static let automaticallyAdded = L10n.tr("Core", "KWAuthentifiantIOS.domains.automaticallyAdded", fallback: "Added by Dashlane")
                public static func duplicate(_ p1: Any) -> String {
          return L10n.tr("Core", "KWAuthentifiantIOS.domains.duplicate", String(describing: p1), fallback: "_")
        }
                public static let main = L10n.tr("Core", "KWAuthentifiantIOS.domains.main", fallback: "Primary")
                public static let placeholder = L10n.tr("Core", "KWAuthentifiantIOS.domains.placeholder", fallback: "Web address")
                public static let title = L10n.tr("Core", "KWAuthentifiantIOS.domains.title", fallback: "Websites")
                public static let update = L10n.tr("Core", "KWAuthentifiantIOS.domains.update", fallback: "Changes saved")
        public enum Duplicate {
                    public static func title(_ p1: Any) -> String {
            return L10n.tr("Core", "KWAuthentifiantIOS.domains.duplicate.title", String(describing: p1), fallback: "_")
          }
        }
      }
      public enum Title {
                public static let `default` = L10n.tr("Core", "KWAuthentifiantIOS.title.default", fallback: "Untitled login")
                public static let placeholder = L10n.tr("Core", "KWAuthentifiantIOS.title.placeholder", fallback: "My website")
      }
    }
    public enum KWBankStatementIOS {
            public static let accountNumber = L10n.tr("Core", "KWBankStatementIOS.accountNumber", fallback: "Account number")
            public static let bankAccountBank = L10n.tr("Core", "KWBankStatementIOS.bankAccountBank", fallback: "Bank")
            public static let bankAccountBIC = L10n.tr("Core", "KWBankStatementIOS.bankAccountBIC", fallback: "BIC/SWIFT")
            public static let bankAccountClabe = L10n.tr("Core", "KWBankStatementIOS.bankAccountClabe", fallback: "CLABE")
            public static let bankAccountIBAN = L10n.tr("Core", "KWBankStatementIOS.bankAccountIBAN", fallback: "IBAN")
            public static let bankAccountName = L10n.tr("Core", "KWBankStatementIOS.bankAccountName", fallback: "Item name")
            public static let bankAccountOwner = L10n.tr("Core", "KWBankStatementIOS.bankAccountOwner", fallback: "Account holder")
            public static let bankAccountSortCode = L10n.tr("Core", "KWBankStatementIOS.bankAccountSortCode", fallback: "Sort code")
            public static let localeFormat = L10n.tr("Core", "KWBankStatementIOS.localeFormat", fallback: "Country")
            public static let routingNumber = L10n.tr("Core", "KWBankStatementIOS.routingNumber", fallback: "Routing number")
      public enum BankAccountName {
                public static let placeholder = L10n.tr("Core", "KWBankStatementIOS.bankAccountName.placeholder", fallback: "My Bank account")
      }
    }
    public enum KWCompanyIOS {
            public static let jobTitle = L10n.tr("Core", "KWCompanyIOS.jobTitle", fallback: "Job title")
            public static let name = L10n.tr("Core", "KWCompanyIOS.name", fallback: "Item name")
    }
    public enum KWDriverLicenceIOS {
            public static let deliveryDate = L10n.tr("Core", "KWDriverLicenceIOS.deliveryDate", fallback: "Issue date")
            public static let fullname = L10n.tr("Core", "KWDriverLicenceIOS.fullname", fallback: "Full name")
            public static let linkedIdentity = L10n.tr("Core", "KWDriverLicenceIOS.linkedIdentity", fallback: "Item name")
            public static let localeFormat = L10n.tr("Core", "KWDriverLicenceIOS.localeFormat", fallback: "Country")
            public static let number = L10n.tr("Core", "KWDriverLicenceIOS.number", fallback: "Number")
            public static let sex = L10n.tr("Core", "KWDriverLicenceIOS.sex", fallback: "Gender")
            public static let state = L10n.tr("Core", "KWDriverLicenceIOS.state", fallback: "State")
    }
    public enum KWEmailIOS {
            public static let email = L10n.tr("Core", "KWEmailIOS.email", fallback: "Email")
            public static let emailName = L10n.tr("Core", "KWEmailIOS.emailName", fallback: "Item name")
            public static let type = L10n.tr("Core", "KWEmailIOS.type", fallback: "Type")
      public enum `Type` {
                public static let perso = L10n.tr("Core", "KWEmailIOS.type.PERSO", fallback: "Personal")
                public static let pro = L10n.tr("Core", "KWEmailIOS.type.PRO", fallback: "Business")
      }
    }
    public enum KWFiscalStatementIOS {
            public static let fiscalNumber = L10n.tr("Core", "KWFiscalStatementIOS.fiscalNumber", fallback: "Tax number")
            public static let localeFormat = L10n.tr("Core", "KWFiscalStatementIOS.localeFormat", fallback: "Country")
            public static let teledeclarantNumber = L10n.tr("Core", "KWFiscalStatementIOS.teledeclarantNumber", fallback: "Online number")
    }
    public enum KWIDCardIOS {
            public static let dateOfBirth = L10n.tr("Core", "KWIDCardIOS.dateOfBirth", fallback: "Date of birth")
            public static let deliveryDate = L10n.tr("Core", "KWIDCardIOS.deliveryDate", fallback: "Issue date")
            public static let expireDate = L10n.tr("Core", "KWIDCardIOS.expireDate", fallback: "Expiry date")
            public static let fullname = L10n.tr("Core", "KWIDCardIOS.fullname", fallback: "Full name")
            public static let linkedIdentity = L10n.tr("Core", "KWIDCardIOS.linkedIdentity", fallback: "Name")
            public static let localeFormat = L10n.tr("Core", "KWIDCardIOS.localeFormat", fallback: "Country")
            public static let number = L10n.tr("Core", "KWIDCardIOS.number", fallback: "Number")
            public static let sex = L10n.tr("Core", "KWIDCardIOS.sex", fallback: "Gender")
      public enum Sex {
                public static let female = L10n.tr("Core", "KWIDCardIOS.sex.FEMALE", fallback: "Female")
                public static let male = L10n.tr("Core", "KWIDCardIOS.sex.MALE", fallback: "Male")
      }
    }
    public enum KWIdentityIOS {
            public static let birthDate = L10n.tr("Core", "KWIdentityIOS.birthDate", fallback: "Date of birth")
            public static let birthPlace = L10n.tr("Core", "KWIdentityIOS.birthPlace", fallback: "Place of birth")
            public static let firstName = L10n.tr("Core", "KWIdentityIOS.firstName", fallback: "First name")
            public static let lastName = L10n.tr("Core", "KWIdentityIOS.lastName", fallback: "Last name")
            public static let middleName = L10n.tr("Core", "KWIdentityIOS.middleName", fallback: "Middle name")
            public static let pseudo = L10n.tr("Core", "KWIdentityIOS.pseudo", fallback: "Default username")
            public static let title = L10n.tr("Core", "KWIdentityIOS.title", fallback: "Title")
      public enum Title {
                public static let mlle = L10n.tr("Core", "KWIdentityIOS.title.MLLE", fallback: "Miss")
                public static let mme = L10n.tr("Core", "KWIdentityIOS.title.MME", fallback: "Mrs.")
                public static let mr = L10n.tr("Core", "KWIdentityIOS.title.MR", fallback: "Mr.")
                public static let ms = L10n.tr("Core", "KWIdentityIOS.title.MS", fallback: "Ms.")
                public static let mx = L10n.tr("Core", "KWIdentityIOS.title.MX", fallback: "Mx.")
                public static let noneOfThese = L10n.tr("Core", "KWIdentityIOS.title.NONE_OF_THESE", fallback: "None of these")
      }
    }
    public enum KWPassportIOS {
            public static let au = L10n.tr("Core", "KWPassportIOS.AU", fallback: "Passport")
            public static let ca = L10n.tr("Core", "KWPassportIOS.CA", fallback: "Passport")
            public static let ch = L10n.tr("Core", "KWPassportIOS.CH", fallback: "Passport")
            public static let dateOfBirth = L10n.tr("Core", "KWPassportIOS.dateOfBirth", fallback: "Date of birth")
            public static let deliveryDate = L10n.tr("Core", "KWPassportIOS.deliveryDate", fallback: "Issue date")
            public static let deliveryPlace = L10n.tr("Core", "KWPassportIOS.deliveryPlace", fallback: "Place of issue")
            public static let expireDate = L10n.tr("Core", "KWPassportIOS.expireDate", fallback: "Expiry date")
            public static let fullname = L10n.tr("Core", "KWPassportIOS.fullname", fallback: "Full name")
            public static let ie = L10n.tr("Core", "KWPassportIOS.IE", fallback: "Passport")
            public static let linkedIdentity = L10n.tr("Core", "KWPassportIOS.linkedIdentity", fallback: "Name")
            public static let localeFormat = L10n.tr("Core", "KWPassportIOS.localeFormat", fallback: "Country")
            public static let lu = L10n.tr("Core", "KWPassportIOS.LU", fallback: "Passport")
            public static let number = L10n.tr("Core", "KWPassportIOS.number", fallback: "Number")
            public static let sex = L10n.tr("Core", "KWPassportIOS.sex", fallback: "Gender")
            public static let us = L10n.tr("Core", "KWPassportIOS.US", fallback: "Passport")
    }
    public enum KWPaymentMeanCreditCardIOS {
            public static let bank = L10n.tr("Core", "KWPaymentMean_creditCardIOS.bank", fallback: "Issuing bank")
            public static let cardNumber = L10n.tr("Core", "KWPaymentMean_creditCardIOS.cardNumber", fallback: "Number")
            public static let ccNote = L10n.tr("Core", "KWPaymentMean_creditCardIOS.cCNote", fallback: "Notes")
            public static let color = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color", fallback: "Card color")
            public static let expiryDateForUi = L10n.tr("Core", "KWPaymentMean_creditCardIOS.expiryDateForUi", fallback: "Expiry date")
            public static let linkedBillingAddress = L10n.tr("Core", "KWPaymentMean_creditCardIOS.linkedBillingAddress", fallback: "Billing address")
            public static let localeFormat = L10n.tr("Core", "KWPaymentMean_creditCardIOS.localeFormat", fallback: "Country")
            public static let name = L10n.tr("Core", "KWPaymentMean_creditCardIOS.name", fallback: "Item name")
            public static let ownerName = L10n.tr("Core", "KWPaymentMean_creditCardIOS.ownerName", fallback: "Name on card")
            public static let securityCode = L10n.tr("Core", "KWPaymentMean_creditCardIOS.securityCode", fallback: "CVV code")
            public static let type = L10n.tr("Core", "KWPaymentMean_creditCardIOS.type", fallback: "Type")
      public enum Color {
                public static let black = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.BLACK", fallback: "Black")
                public static let blue1 = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.BLUE_1", fallback: "Blue")
                public static let blue2 = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.BLUE_2", fallback: "Dark Blue")
                public static let gold = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.GOLD", fallback: "Gold")
                public static let green1 = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.GREEN_1", fallback: "Green")
                public static let green2 = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.GREEN_2", fallback: "AmEx Green")
                public static let orange = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.ORANGE", fallback: "Orange")
                public static let red = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.RED", fallback: "Red")
                public static let silver = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.SILVER", fallback: "Silver")
                public static let white = L10n.tr("Core", "KWPaymentMean_creditCardIOS.color.WHITE", fallback: "White")
      }
    }
    public enum KWPersonalWebsiteIOS {
            public static let name = L10n.tr("Core", "KWPersonalWebsiteIOS.name", fallback: "Item name")
            public static let website = L10n.tr("Core", "KWPersonalWebsiteIOS.website", fallback: "Website")
    }
    public enum KWPhoneIOS {
            public static let localeFormat = L10n.tr("Core", "KWPhoneIOS.localeFormat", fallback: "Country code")
            public static let number = L10n.tr("Core", "KWPhoneIOS.number", fallback: "Number")
            public static let phoneName = L10n.tr("Core", "KWPhoneIOS.phoneName", fallback: "Item name")
            public static let type = L10n.tr("Core", "KWPhoneIOS.type", fallback: "Type")
      public enum `Type` {
                public static let phoneTypeFax = L10n.tr("Core", "KWPhoneIOS.type.PHONE_TYPE_FAX", fallback: "Fax")
                public static let phoneTypeLandline = L10n.tr("Core", "KWPhoneIOS.type.PHONE_TYPE_LANDLINE", fallback: "Home")
                public static let phoneTypeMobile = L10n.tr("Core", "KWPhoneIOS.type.PHONE_TYPE_MOBILE", fallback: "Cell phone")
                public static let phoneTypeWorkFax = L10n.tr("Core", "KWPhoneIOS.type.PHONE_TYPE_WORK_FAX", fallback: "Work fax")
                public static let phoneTypeWorkLandline = L10n.tr("Core", "KWPhoneIOS.type.PHONE_TYPE_WORK_LANDLINE", fallback: "Work")
                public static let phoneTypeWorkMobile = L10n.tr("Core", "KWPhoneIOS.type.PHONE_TYPE_WORK_MOBILE", fallback: "Work cell phone")
      }
    }
    public enum KWSecureNoteIOS {
            public static let category = L10n.tr("Core", "KWSecureNoteIOS.category", fallback: "Category")
            public static let colorTitle = L10n.tr("Core", "KWSecureNoteIOS.colorTitle", fallback: "Color")
            public static let content = L10n.tr("Core", "KWSecureNoteIOS.content", fallback: "Content")
            public static let emptyContent = L10n.tr("Core", "KWSecureNoteIOS.emptyContent", fallback: "Type note here...")
            public static let locked = L10n.tr("Core", "KWSecureNoteIOS.locked", fallback: "Locked")
            public static let protectedMessage = L10n.tr("Core", "KWSecureNoteIOS.protectedMessage", fallback: "This note is password-protected")
            public static let spaceId = L10n.tr("Core", "KWSecureNoteIOS.spaceId", fallback: "Space")
            public static let title = L10n.tr("Core", "KWSecureNoteIOS.title", fallback: "Title")
            public static let type = L10n.tr("Core", "KWSecureNoteIOS.type", fallback: "Color")
      public enum `Type` {
                public static let blue = L10n.tr("Core", "KWSecureNoteIOS.type.BLUE", fallback: "Blue")
                public static let brown = L10n.tr("Core", "KWSecureNoteIOS.type.BROWN", fallback: "Brown")
                public static let gray = L10n.tr("Core", "KWSecureNoteIOS.type.GRAY", fallback: "Grey")
                public static let green = L10n.tr("Core", "KWSecureNoteIOS.type.GREEN", fallback: "Green")
                public static let orange = L10n.tr("Core", "KWSecureNoteIOS.type.ORANGE", fallback: "Orange")
                public static let pink = L10n.tr("Core", "KWSecureNoteIOS.type.PINK", fallback: "Pink")
                public static let purple = L10n.tr("Core", "KWSecureNoteIOS.type.PURPLE", fallback: "Purple")
                public static let red = L10n.tr("Core", "KWSecureNoteIOS.type.RED", fallback: "Red")
                public static let yellow = L10n.tr("Core", "KWSecureNoteIOS.type.YELLOW", fallback: "Yellow")
      }
    }
    public enum KWSocialSecurityStatementIOS {
            public static let dateOfBirth = L10n.tr("Core", "KWSocialSecurityStatementIOS.dateOfBirth", fallback: "Date of birth")
            public static let linkedIdentity = L10n.tr("Core", "KWSocialSecurityStatementIOS.linkedIdentity", fallback: "Name")
            public static let localeFormat = L10n.tr("Core", "KWSocialSecurityStatementIOS.localeFormat", fallback: "Country")
            public static let sex = L10n.tr("Core", "KWSocialSecurityStatementIOS.sex", fallback: "Gender")
            public static let socialSecurityFullname = L10n.tr("Core", "KWSocialSecurityStatementIOS.socialSecurityFullname", fallback: "Full name")
            public static let socialSecurityNumber = L10n.tr("Core", "KWSocialSecurityStatementIOS.socialSecurityNumber", fallback: "Number")
    }
  }
  public enum CoreContext {
        public static let cancel = L10n.tr("Core-context", "Cancel", fallback: "⁣⁢Cancel⁡⁠⁯‍⁯؜؜⁮⁯؜⁡⁮؜‍؜⁪⁠⁬⁮⁣⁤")
        public static let next = L10n.tr("Core-context", "Next", fallback: "⁣⁢Next⁫⁫‌⁮⁮⁫⁠‍⁯⁬⁠⁪⁪⁫⁯⁫⁭⁮‌‍‌⁮⁮⁠⁭⁡⁮⁡⁣⁤")
  }
  public enum CorePending {
        public static let cancel = L10n.tr("Core-pending", "Cancel", fallback: "Cancel")
        public static let next = L10n.tr("Core-pending", "Next", fallback: "Next")
  }
  public enum CorePseudo {
        public static let cancel = L10n.tr("Core-pseudo", "Cancel", fallback: "[C~áñc~él]")
        public static let next = L10n.tr("Core-pseudo", "Next", fallback: "[Ñ~éxt]")
  }
}
extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
