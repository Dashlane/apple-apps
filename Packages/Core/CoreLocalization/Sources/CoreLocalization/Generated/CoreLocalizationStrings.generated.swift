import Foundation

public enum L10n {
  public enum Core {
    public static let _2faSetupCta = L10n.tr("Core", "2faSetup_cta", fallback: "Add 2FA token")
    public static let accessibilityInfoSection = L10n.tr(
      "Core", "Accessibility_InfoSection", fallback: "Information box")
    public static func accessibilityCardNumberEndingWith(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "accessibilityCardNumberEndingWith", String(describing: p1), fallback: "_")
    }
    public static let accessibilityClearSearchTextField = L10n.tr(
      "Core", "accessibilityClearSearchTextField", fallback: "Clear text")
    public static let accessibilityClearText = L10n.tr(
      "Core", "accessibilityClearText", fallback: "Clear text")
    public static let accessibilityCollapsed = L10n.tr(
      "Core", "accessibilityCollapsed", fallback: "Collapsed")
    public static let accessibilityDeletingItem = L10n.tr(
      "Core", "accessibilityDeletingItem", fallback: "Deleting item")
    public static let accessibilityExpanded = L10n.tr(
      "Core", "accessibilityExpanded", fallback: "Expanded")
    public static let accessibilityGeneratedPasswordRefreshed = L10n.tr(
      "Core", "accessibilityGeneratedPasswordRefreshed",
      fallback: "The generated password has been refreshed")
    public static func accessibilityGenericNumberEndingWidth(_ p1: Int, _ p2: Any) -> String {
      return L10n.tr(
        "Core", "accessibilityGenericNumberEndingWidth", p1, String(describing: p2), fallback: "_")
    }
    public static let accessibilityHidden = L10n.tr(
      "Core", "accessibilityHidden", fallback: "Hidden")
    public static let accessibilityPresented = L10n.tr(
      "Core", "accessibilityPresented", fallback: "Presented")
    public static let accountCreationPasswordStrengthHigh = L10n.tr(
      "Core", "ACCOUNT_CREATION_PASSWORD_STRENGTH_HIGH", fallback: "Boom! Now that’s strong")
    public static let accountCreationPasswordStrengthLow = L10n.tr(
      "Core", "ACCOUNT_CREATION_PASSWORD_STRENGTH_LOW", fallback: "Keep it up")
    public static let accountCreationPasswordStrengthMedium = L10n.tr(
      "Core", "ACCOUNT_CREATION_PASSWORD_STRENGTH_MEDIUM", fallback: "Good progress")
    public static let accountCreationPasswordStrengthSafe = L10n.tr(
      "Core", "ACCOUNT_CREATION_PASSWORD_STRENGTH_SAFE", fallback: "Loving this")
    public static let accountCreationPasswordStrengthVeryLow = L10n.tr(
      "Core", "ACCOUNT_CREATION_PASSWORD_STRENGTH_VERY_LOW", fallback: "Nice start")
    public static let accountLoadingInfoText = L10n.tr(
      "Core", "ACCOUNT_LOADING_INFO_TEXT", fallback: "Your account is loading...")
    public static let accountLoadingMayTakeMinute = L10n.tr(
      "Core", "ACCOUNT_LOADING_MAY_TAKE_MINUTE", fallback: "This may take a minute.")
    public static let accountLoadingSuccessDescription = L10n.tr(
      "Core", "ACCOUNT_LOADING_SUCCESS_DESCRIPTION", fallback: "Enjoy Dashlane on this new device.")
    public static let accountLoadingSuccessTitle = L10n.tr(
      "Core", "ACCOUNT_LOADING_SUCCESS_TITLE", fallback: "You’re all set up!")
    public static let accountLoadingUnlinkingPrevious = L10n.tr(
      "Core", "ACCOUNT_LOADING_UNLINKING_PREVIOUS", fallback: "Unlinking previous device...")
    public static let accountRecoveryKeyCancelAlertCancelCta = L10n.tr(
      "Core", "Account_recovery_key_cancel_alert_cancel_cta", fallback: "Dismiss")
    public static let accountRecoveryKeyCancelAlertCta = L10n.tr(
      "Core", "Account_recovery_key_cancel_alert_cta", fallback: "Yes, cancel")
    public static let accountRecoveryKeyCancelAlertMessage = L10n.tr(
      "Core", "Account_recovery_key_cancel_alert_message",
      fallback:
        "The setup of your account recovery key is not completed until you confirm your key.")
    public static let accountRecoveryKeyCancelAlertTitle = L10n.tr(
      "Core", "Account_recovery_key_cancel_alert_title", fallback: "Cancel recovery setup?")
    public static let accountRecoveryNavigationTitle = L10n.tr(
      "Core", "ACCOUNT_RECOVERY_NAVIGATION_TITLE", fallback: "Account Recovery")
    public static let accountCreationSurveyChoiceAlreadyUsedPWM = L10n.tr(
      "Core", "accountCreation_survey_choice_alreadyUsedPWM",
      fallback: "I’m new to Dashlane, but I have used a password manager before")
    public static let accountCreationSurveyChoiceKnowDashlane = L10n.tr(
      "Core", "accountCreation_survey_choice_knowDashlane",
      fallback: "I know my way around Dashlane pretty well")
    public static let accountCreationSurveyChoiceNeverUsedPWM = L10n.tr(
      "Core", "accountCreation_survey_choice_neverUsedPWM",
      fallback: "I have never used Dashlane before")
    public static let accountCreationSurveyTitle = L10n.tr(
      "Core", "accountCreation_survey_title", fallback: "How familiar are you with Dashlane?")
    public static let accountDoesNotExist = L10n.tr(
      "Core", "AccountDoesNotExist", fallback: "No account found for this email address")
    public static let actionCannotLogin = L10n.tr(
      "Core", "ACTION_CANNOT_LOGIN", fallback: "I can't log in")
    public static let actionForgotMyPassword = L10n.tr(
      "Core", "ACTION_FORGOT_MY_PASSWORD", fallback: "I forgot my password")
    public static func actionItemSharingDetailCollection(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr(
        "Core", "ACTION_ITEM_SHARING_DETAIL_COLLECTION", String(describing: p1),
        String(describing: p2), fallback: "_")
    }
    public static let actionItemTrialUpgradeRecommendationDescriptionPremium = L10n.tr(
      "Core", "action_item_trial_upgrade_recommendation_description_premium",
      fallback: "Based on app usage, our Premium plan looks like a good fit for you. Upgrade today."
    )
    public static let actionItemTrialUpgradeRecommendationTitle = L10n.tr(
      "Core", "action_item_trial_upgrade_recommendation_title",
      fallback: "Enjoying our Premium features?")
    public static let actionResend = L10n.tr("Core", "ACTION_RESEND", fallback: "Resend code")
    public static let addLoginDetailsAddCode = L10n.tr(
      "Core", "ADD_LOGIN_DETAILS_ADD_CODE", fallback: "Add new")
    public static let addLoginDetailsEmailOrUsername = L10n.tr(
      "Core", "ADD_LOGIN_DETAILS_EMAIL_OR_USERNAME", fallback: "EMAIL OR USERNAME")
    public static let addLoginDetailsEmailOrUsernamePlaceholder = L10n.tr(
      "Core", "ADD_LOGIN_DETAILS_EMAIL_OR_USERNAME_PLACEHOLDER", fallback: "_")
    public static let addLoginDetailsError = L10n.tr(
      "Core", "ADD_LOGIN_DETAILS_ERROR", fallback: "That doesn’t look right. Please try again.")
    public static let addLoginDetailsSetupCode = L10n.tr(
      "Core", "ADD_LOGIN_DETAILS_SETUP_CODE", fallback: "SETUP CODE")
    public static let addLoginDetailsSetupCodePlaceholder = L10n.tr(
      "Core", "ADD_LOGIN_DETAILS_SETUP_CODE_PLACEHOLDER",
      fallback: "Example: HVWO ZWK4 EFXF QXLT ...")
    public static let addLoginDetailsTitle = L10n.tr(
      "Core", "ADD_LOGIN_DETAILS_TITLE", fallback: "Add account details")
    public static let addLoginDetailsWebsiteOrApp = L10n.tr(
      "Core", "ADD_LOGIN_DETAILS_WEBSITE_OR_APP", fallback: "WEBSITE OR APP")
    public static let addAddress = L10n.tr("Core", "addAddress", fallback: "Add address")
    public static let addASecret = L10n.tr("Core", "addASecret", fallback: "Add a secret")
    public static let addBankAccount = L10n.tr(
      "Core", "addBankAccount", fallback: "Add bank account")
    public static let addCompany = L10n.tr("Core", "addCompany", fallback: "Add company")
    public static let addCredentialGeneratorCTA = L10n.tr(
      "Core", "addCredentialGeneratorCTA", fallback: "Open Generator")
    public static let addCredentialWebsiteLogin = L10n.tr(
      "Core", "addCredentialWebsiteLogin", fallback: "Login")
    public static let addCredentialWebsiteSection = L10n.tr(
      "Core", "addCredentialWebsiteSection", fallback: "Website")
    public static let addCredentialWebsiteSpace = L10n.tr(
      "Core", "addCredentialWebsiteSpace", fallback: "Space")
    public static let addCreditCard = L10n.tr(
      "Core", "addCreditCard", fallback: "Add credit/debit card")
    public static let addDriverLicense = L10n.tr(
      "Core", "addDriverLicense", fallback: "Add driver's license")
    public static let addEmail = L10n.tr("Core", "addEmail", fallback: "Add email")
    public static let addID = L10n.tr("Core", "addID", fallback: "Add ID")
    public static let addIDCard = L10n.tr("Core", "addIDCard", fallback: "Add ID card")
    public static let addName = L10n.tr("Core", "addName", fallback: "Add name")
    public static let addNewPasswordSuccessMessage = L10n.tr(
      "Core", "addNewPasswordSuccessMessage", fallback: "Added! Tap Done to autofill this login.")
    public static let addPassport = L10n.tr("Core", "addPassport", fallback: "Add passport")
    public static let addPassword = L10n.tr("Core", "addPassword", fallback: "Add login")
    public static let addPayment = L10n.tr("Core", "addPayment", fallback: "Add payment")
    public static let addPersonalInfo = L10n.tr(
      "Core", "addPersonalInfo", fallback: "Add personal info")
    public static let addPhoneNumber = L10n.tr(
      "Core", "addPhoneNumber", fallback: "Add phone number")
    public static let addSecret = L10n.tr("Core", "addSecret", fallback: "Add secret")
    public static let addSecureNote = L10n.tr("Core", "addSecureNote", fallback: "Add Secure Note")
    public static let addSocialSecurityNumber = L10n.tr(
      "Core", "addSocialSecurityNumber", fallback: "Add social security number")
    public static let addTaxNumber = L10n.tr("Core", "addTaxNumber", fallback: "Add tax number")
    public static let addWebsite = L10n.tr("Core", "addWebsite", fallback: "Add website")
    public static let announcePremiumExpiredBody = L10n.tr(
      "Core", "ANNOUNCE_PREMIUM_EXPIRED_BODY", fallback: " Your Premium benefits have expired.")
    public static let announcePremiumExpiredCta = L10n.tr(
      "Core", "ANNOUNCE_PREMIUM_EXPIRED_CTA", fallback: "Renew Premium")
    public static let announcePremiumExpiring1DayBody = L10n.tr(
      "Core", "ANNOUNCE_PREMIUM_EXPIRING_1_DAY_BODY",
      fallback: "Your Premium benefits expire in 1 day")
    public static func announcePremiumExpiringNDaysBody(_ p1: Int) -> String {
      return L10n.tr(
        "Core", "ANNOUNCE_PREMIUM_EXPIRING_N_DAYS_BODY", p1,
        fallback: "Your Premium benefits expire in %1$d days")
    }
    public static let askLogout = L10n.tr("Core", "askLogout", fallback: "Log out?")
    public static let authenticationIncorrectMasterPasswordHelp1 = L10n.tr(
      "Core", "Authentication_IncorrectMasterPassword_Help_1",
      fallback: "That Master Password isn't right. Need")
    public static let authenticationIncorrectMasterPasswordHelp2 = L10n.tr(
      "Core", "Authentication_IncorrectMasterPassword_Help_2", fallback: "help logging in?")
    public static let authenticatorPushChallengeButton = L10n.tr(
      "Core", "AUTHENTICATOR_PUSH_CHALLENGE_BUTTON", fallback: "Receive a push notification")
    public static let authenticatorSunsetDetails = L10n.tr(
      "Core", "authenticator_sunset_details",
      fallback: "Tap for details, and instructions on how to migrate to another app")
    public static let authenticatorSunsetExportAction = L10n.tr(
      "Core", "authenticator_sunset_export_action", fallback: "Export tokens")
    public static let authenticatorSunsetExportLearnMore = L10n.tr(
      "Core", "authenticator_sunset_export_learnMore", fallback: "Learn more")
    public static let authenticatorSunsetExportMessage = L10n.tr(
      "Core", "authenticator_sunset_export_message",
      fallback: "Here's how to export and migrate your tokens to a new Authenticator.")
    public static let authenticatorSunsetExportStep1 = L10n.tr(
      "Core", "authenticator_sunset_export_step1", fallback: "Export your tokens")
    public static let authenticatorSunsetExportStep2 = L10n.tr(
      "Core", "authenticator_sunset_export_step2",
      fallback: "Install another authenticator like Google or Microsoft authenticator")
    public static let authenticatorSunsetExportStep3 = L10n.tr(
      "Core", "authenticator_sunset_export_step3",
      fallback: "Easily input your tokens into the new app")
    public static let authenticatorSunsetExportTitle = L10n.tr(
      "Core", "authenticator_sunset_export_title",
      fallback: "How to export your tokens to a new authenticator app")
    public static let authenticatorSunsetLearnMore = L10n.tr(
      "Core", "authenticator_sunset_learnMore", fallback: "Learn more")
    public static func authenticatorSunsetMessage(_ p1: Any) -> String {
      return L10n.tr("Core", "authenticator_sunset_message", String(describing: p1), fallback: "_")
    }
    public static let authenticatorTotpPushOption = L10n.tr(
      "Core", "AUTHENTICATOR_TOTP_PUSH_OPTION", fallback: "Enter 2FA token")
    public static let authenticatorPushRetryButtonTitle = L10n.tr(
      "Core", "authenticatorPushRetryButtonTitle", fallback: "Resend request")
    public static let authenticatorPushViewAccepted = L10n.tr(
      "Core", "authenticatorPushViewAccepted", fallback: "Authentication accepted")
    public static let authenticatorPushViewDeniedError = L10n.tr(
      "Core", "authenticatorPushViewDeniedError", fallback: "Authentication rejected")
    public static let authenticatorPushViewSendTokenButtonTitle = L10n.tr(
      "Core", "authenticatorPushViewSendTokenButtonTitle", fallback: "Send code to email")
    public static let authenticatorPushViewTimeOutError = L10n.tr(
      "Core", "authenticatorPushViewTimeOutError", fallback: "Your request has expired.")
    public static func authenticatorPushViewTitle(_ p1: Any) -> String {
      return L10n.tr("Core", "authenticatorPushViewTitle", String(describing: p1), fallback: "_")
    }
    public static let authenticatorSunsetBannerAccessDescription = L10n.tr(
      "Core", "authenticatorSunset_banner_access_description",
      fallback: "Tap for details and instructions on how to access your 2FA tokens here.")
    public static let authenticatorSunsetBannerDismiss = L10n.tr(
      "Core", "authenticatorSunset_banner_dismiss", fallback: "Dismiss")
    public static let authenticatorSunsetBannerLearnMore = L10n.tr(
      "Core", "authenticatorSunset_banner_learnMore", fallback: "Learn more")
    public static let authenticatorSunsetBannerRelocateDescription = L10n.tr(
      "Core", "authenticatorSunset_banner_relocate_description",
      fallback:
        "Tap for details and instructions on how to relocate your Dashlane 2FA tokens to another app."
    )
    public static func authenticatorSunsetBannerTitle(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "authenticatorSunset_banner_title", String(describing: p1), fallback: "_")
    }
    public static let authenticatorSunsetRelocateActionLearnMore = L10n.tr(
      "Core", "authenticatorSunset_relocate_action_learnMore",
      fallback: "Learn about token relocation")
    public static let authenticatorSunsetRelocateActionOpenSettings = L10n.tr(
      "Core", "authenticatorSunset_relocate_action_openSettings", fallback: "Open Security settings"
    )
    public static let authenticatorSunsetRelocatePage = L10n.tr(
      "Core", "authenticatorSunset_relocate_page", fallback: "Dashlane 2FA")
    public static let authenticatorSunsetRelocateStep1 = L10n.tr(
      "Core", "authenticatorSunset_relocate_step1",
      fallback: "Disable 2FA from your Dashlane security settings")
    public static let authenticatorSunsetRelocateStep2 = L10n.tr(
      "Core", "authenticatorSunset_relocate_step2",
      fallback: "Install a new Authenticator App (e.g., Google Authenticator)")
    public static let authenticatorSunsetRelocateStep3 = L10n.tr(
      "Core", "authenticatorSunset_relocate_step3",
      fallback: "Reconfigure Dashlane 2FA with your new authenticator app")
    public static let authenticatorSunsetRelocateSubtitle = L10n.tr(
      "Core", "authenticatorSunset_relocate_subtitle",
      fallback:
        "Your Dashlane 2FA token that is stored in the Dashlane Authenticator will need to migrate to another authenticator before the sunset, here is how:"
    )
    public static let authenticatorSunsetRelocateTitle = L10n.tr(
      "Core", "authenticatorSunset_relocate_title",
      fallback: "We need to relocate your Dashlane token")
    public static let autofillBannerTitle = L10n.tr(
      "Core", "autofillBannerTitle", fallback: "Autofill isn't on.")
    public static let autofillBannerTitleCta = L10n.tr(
      "Core", "autofillBannerTitleCta", fallback: "Manage")
    public static let autofillBannerTitleNotActive = L10n.tr(
      "Core", "autofillBannerTitleNotActive", fallback: "Log in faster with Autofill")
    public static let autofillDemoFieldsAction = L10n.tr(
      "Core", "autofillDemoFields_action", fallback: "Set up Autofill")
    public static let autofillDemoFieldsGenerateText = L10n.tr(
      "Core", "autofillDemoFields_generate_text",
      fallback: "Use the password generator to create and save a unique password for any login.")
    public static let autofillDemoFieldsGenerateTitle = L10n.tr(
      "Core", "autofillDemoFields_generate_title",
      fallback: "Generate unique passwords in a few taps")
    public static let autofillDemoFieldsLoginText = L10n.tr(
      "Core", "autofillDemoFields_login_text",
      fallback: "Turn on Dashlane Autofill to start logging into websites and apps with just a tap."
    )
    public static let autofillDemoFieldsLoginTitle = L10n.tr(
      "Core", "autofillDemoFields_login_title",
      fallback: "Log in to your accounts in a fraction of the time")
    public static let autofillDemoFieldsSyncText = L10n.tr(
      "Core", "autofillDemoFields_sync_text",
      fallback: "Autofill your info on any device logged in to your Dashlane account.")
    public static let autofillDemoFieldsSyncTitle = L10n.tr(
      "Core", "autofillDemoFields_sync_title",
      fallback: "Sync your information across all your devices")
    public static let badToken = L10n.tr(
      "Core", "BadToken", fallback: "Incorrect code. Please try again")
    public static let benefit2faAdvanced = L10n.tr(
      "Core", "benefit_2fa_advanced", fallback: "**U2F authentication**")
    public static let benefit2faBasic = L10n.tr(
      "Core", "benefit_2fa_basic", fallback: "2-factor authentication (2FA)")
    public static let benefitAutofill = L10n.tr(
      "Core", "benefit_autofill", fallback: "Form and payment autofill")
    public static let benefitIndividualAcount = L10n.tr(
      "Core", "benefit_individual_acount", fallback: "1 account")
    public static func benefitLimitedDeviceOne(_ p1: Any) -> String {
      return L10n.tr("Core", "benefit_limited_device_one", String(describing: p1), fallback: "_")
    }
    public static func benefitLimitedDeviceSome(_ p1: Any) -> String {
      return L10n.tr("Core", "benefit_limited_device_some", String(describing: p1), fallback: "_")
    }
    public static let benefitPasswordChanger = L10n.tr(
      "Core", "benefit_password_changer", fallback: "One-click Password Changer")
    public static let benefitPasswordGenerator = L10n.tr(
      "Core", "benefit_password_generator", fallback: "Password Generator")
    public static func benefitPasswordSharingLimited(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "benefit_password_sharing_limited", String(describing: p1), fallback: "_")
    }
    public static let benefitPasswordSharingUnlimited = L10n.tr(
      "Core", "benefit_password_sharing_unlimited", fallback: "Unlimited login sharing")
    public static func benefitSecureFiles(_ p1: Any) -> String {
      return L10n.tr("Core", "benefit_secure_files", String(describing: p1), fallback: "_")
    }
    public static let benefitSecureNotes = L10n.tr(
      "Core", "benefit_secure_notes", fallback: "Secure Notes")
    public static let benefitSecurityAlertsAdvanced = L10n.tr(
      "Core", "benefit_security_alerts_advanced", fallback: "**Dark Web Monitoring** &amp; alerts")
    public static let benefitSecurityAlertsBasic = L10n.tr(
      "Core", "benefit_security_alerts_basic", fallback: "Personalized security alerts")
    public static func benefitStorePasswordsLimited(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "benefit_store_passwords_limited", String(describing: p1), fallback: "_")
    }
    public static let benefitStorePasswordsUnlimited = L10n.tr(
      "Core", "benefit_store_passwords_unlimited", fallback: "Unlimited logins")
    public static let benefitUnlimitedDevices = L10n.tr(
      "Core", "benefit_unlimited_devices", fallback: "Sync across **unlimited devices**")
    public static let benefitVpn = L10n.tr(
      "Core", "benefit_vpn", fallback: "**VPN** for WiFi protection")
    public static let benefitVpnFamily = L10n.tr(
      "Core", "benefit_vpn_family", fallback: "**VPN** for WiFi protection (1 account per plan)")
    public static let cancel = L10n.tr("Core", "Cancel", fallback: "Cancel")
    public static let changePinLengthCta = L10n.tr(
      "Core", "Change_pin_length_cta", fallback: "Change PIN length")
    public static let changePinLengthDialogFourDigits = L10n.tr(
      "Core", "Change_pin_length_dialog_four_digits", fallback: "4 Digits")
    public static let changePinLengthDialogSixDigits = L10n.tr(
      "Core", "Change_pin_length_dialog_six_digits", fallback: "6 Digits")
    public static let changePinLengthDialogTitle = L10n.tr(
      "Core", "Change_pin_length_dialog_title", fallback: "Change PIN length?")
    public static let changeMasterPasswordMustBeDifferentError = L10n.tr(
      "Core", "changeMasterPasswordMustBeDifferentError",
      fallback: "Your new password must be different from your current password.")
    public static let chooseServiceAddDetails = L10n.tr(
      "Core", "CHOOSE_SERVICE_ADD_DETAILS", fallback: "Add account details")
    public static let chooseServiceSearchPlaceholder = L10n.tr(
      "Core", "CHOOSE_SERVICE_SEARCH_PLACEHOLDER", fallback: "Search websites")
    public static let chooseServiceSuggestedSectionTitle = L10n.tr(
      "Core", "CHOOSE_SERVICE_SUGGESTED_SECTION_TITLE", fallback: "Suggested")
    public static let chooseServiceTitle = L10n.tr(
      "Core", "CHOOSE_SERVICE_TITLE", fallback: "Select account")
    public static let collectionSharingTeamOnlyWarning = L10n.tr(
      "Core", "collectionSharing_teamOnlyWarning",
      fallback:
        "This collection can only be shared with users in your organization. Please check the email address and try again."
    )
    public static let copyError = L10n.tr("Core", "copyError", fallback: "Copy error")
    public static let copyErrorConfirmation = L10n.tr(
      "Core", "copyErrorConfirmation", fallback: "Error copied")
    public static let createMasterPasswordAccountCta = L10n.tr(
      "Core", "Create_master_password_account_cta", fallback: "Create Master Password")
    public static let createAccountNeedHelp = L10n.tr(
      "Core", "createAccount_needHelp", fallback: "Need help?")
    public static let createaccountPrivacysettingsTermsConditions = L10n.tr(
      "Core", "CREATEACCOUNT_PRIVACYSETTINGS_TERMS_CONDITIONS", fallback: "Terms of Service")
    public static let createAccountReEnterPassword = L10n.tr(
      "Core", "createAccount_re-enterPassword", fallback: "New Master Password")
    public static let createAccountSeeTips = L10n.tr(
      "Core", "createAccount_seeTips", fallback: "See our tips")
    public static let credentialDetailViewOtpFieldLabel = L10n.tr(
      "Core", "CredentialDetailView_otpFieldLabel", fallback: "2-factor authentication (2FA)")
    public static let credentialProviderOnboardingCompletedCTA = L10n.tr(
      "Core", "CredentialProviderOnboarding_CompletedCTA", fallback: "Done")
    public static let credentialProviderOnboardingCompletedTitle = L10n.tr(
      "Core", "CredentialProviderOnboarding_CompletedTitle", fallback: "Uncheck Keychain")
    public static let credentialProviderOnboardingCTA = L10n.tr(
      "Core", "CredentialProviderOnboarding_CTA", fallback: "Go to Settings")
    public static let credentialProviderOnboardingHeadLine = L10n.tr(
      "Core", "CredentialProviderOnboarding_HeadLine",
      fallback: "Activate Dashlane Autofill in your phone settings")
    public static let credentialProviderOnboardingIntroTitle = L10n.tr(
      "Core", "CredentialProviderOnboarding_IntroTitle", fallback: "Activate Dashlane Autofill")
    public static let credentialProviderOnboardingStep1 = L10n.tr(
      "Core", "CredentialProviderOnboarding_step1", fallback: "1. Select Passwords")
    public static let credentialProviderOnboardingStep2 = L10n.tr(
      "Core", "CredentialProviderOnboarding_step2", fallback: "2. Select AutoFill Passwords")
    public static let credentialProviderOnboardingStep3 = L10n.tr(
      "Core", "CredentialProviderOnboarding_step3", fallback: "3. Activate AutoFill Passwords")
    public static let credentialProviderOnboardingStep4 = L10n.tr(
      "Core", "CredentialProviderOnboarding_step4", fallback: "4. Choose Dashlane")
    public static let credentialProviderOnboardingTitle = L10n.tr(
      "Core", "CredentialProviderOnboarding_Title", fallback: "Activate Password AutoFill")
    public static let currentBenefitDarkWebMonitoring = L10n.tr(
      "Core", "current_benefit_dark_web_monitoring", fallback: "Dark Web Monitoring")
    public static let currentBenefitDevicesSyncUnlimited = L10n.tr(
      "Core", "current_benefit_devices_sync_unlimited", fallback: "Access on unlimited devices")
    public static let currentBenefitMoreInfoDarkWebMonitoringText = L10n.tr(
      "Core", "current_benefit_more_info_dark_web_monitoring_text",
      fallback:
        "This Premium tool scans the dark web for leaked personal data and helps you secure it.")
    public static let currentBenefitMoreInfoDarkWebMonitoringTitle = L10n.tr(
      "Core", "current_benefit_more_info_dark_web_monitoring_title", fallback: "Dark Web Monitoring"
    )
    public static let currentBenefitPasswordChanger = L10n.tr(
      "Core", "current_benefit_password_changer", fallback: "Password Changer")
    public static let currentBenefitPasswordsUnlimited = L10n.tr(
      "Core", "current_benefit_passwords_unlimited", fallback: "Unlimited logins")
    public static let currentBenefitSecureNotes = L10n.tr(
      "Core", "current_benefit_secure_notes", fallback: "Secure Notes")
    public static let currentBenefitVpn = L10n.tr("Core", "current_benefit_vpn", fallback: "VPN")
    public static let currentPlanCtaAllPlans = L10n.tr(
      "Core", "current_plan_cta_all_plans", fallback: "Compare plans")
    public static let currentPlanCtaPremium = L10n.tr(
      "Core", "current_plan_cta_premium", fallback: "Get Premium")
    public static let currentPlanSuggestionTrialText = L10n.tr(
      "Core", "current_plan_suggestion_trial_text",
      fallback:
        "You’ll be switched to the Free plan after your trial. This plan supports unlimited logins on one device."
    )
    public static let currentPlanTitleTrial = L10n.tr(
      "Core", "current_plan_title_trial", fallback: "What’s included in the Premium trial:")
    public static let customFieldsAddAnotherButton = L10n.tr(
      "Core", "customFieldsAddAnotherButton", fallback: "Add another custom field")
    public static let customFieldsAddButton = L10n.tr(
      "Core", "customFieldsAddButton", fallback: "Add a custom field")
    public static let customFieldsContent = L10n.tr(
      "Core", "customFieldsContent", fallback: "Field content")
    public static let customFieldsContentPlaceholder = L10n.tr(
      "Core", "customFieldsContentPlaceholder", fallback: "Field content")
    public static func customFieldsCountLabel(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr(
        "Core", "customFieldsCountLabel", String(describing: p1), String(describing: p2),
        fallback: "_")
    }
    public static let customFieldsDetails = L10n.tr(
      "Core", "customFieldsDetails", fallback: "Field details")
    public static let customFieldsLabel = L10n.tr(
      "Core", "customFieldsLabel", fallback: "Field label")
    public static let customFieldsLabelPlaceholder = L10n.tr(
      "Core", "customFieldsLabelPlaceholder", fallback: "Field label")
    public static let customFieldsManageButton = L10n.tr(
      "Core", "customFieldsManageButton", fallback: "Manage custom fields")
    public static let customFieldsProtected = L10n.tr(
      "Core", "customFieldsProtected", fallback: "Content protected")
    public static let customFieldsRemove = L10n.tr("Core", "customFieldsRemove", fallback: "Remove")
    public static let customFieldsTipContent = L10n.tr(
      "Core", "customFieldsTipContent",
      fallback:
        "Store any information you need to log into your accounts. We can even autofill them on the Dashlane web app."
    )
    public static let customFieldsTipLabel = L10n.tr(
      "Core", "customFieldsTipLabel", fallback: "GET STARTED")
    public static let customFieldsTipsTitle = L10n.tr(
      "Core", "customFieldsTipsTitle", fallback: "Save and fill custom fields")
    public static let customFieldsTitle = L10n.tr(
      "Core", "customFieldsTitle", fallback: "Custom fields")
    public static let dashlaneBusinessActiveSpacesTitle = L10n.tr(
      "Core", "DASHLANE_BUSINESS_ACTIVE_SPACES_TITLE", fallback: "You have Spaces")
    public static let debugInfoCopyAllInformation = L10n.tr(
      "Core", "debugInfo_copyAllInformation", fallback: "Copy all information")
    public static let debugInfoTakeAScreenshot = L10n.tr(
      "Core", "debugInfo_takeAScreenshot", fallback: "Take a screenshot")
    public static let debugInfoTitle = L10n.tr(
      "Core", "debugInfo_title", fallback: "Debug information")
    public static let deleteLocalDataAlertDeleteCta = L10n.tr(
      "Core", "DELETE_LOCAL_DATA_ALERT_DELETE_CTA", fallback: "Yes, delete")
    public static let deleteLocalDataAlertMessage = L10n.tr(
      "Core", "DELETE_LOCAL_DATA_ALERT_MESSAGE",
      fallback:
        "This will only delete the data on your device and won’t affect your Dashlane account.")
    public static let deleteLocalDataAlertTitle = L10n.tr(
      "Core", "DELETE_LOCAL_DATA_ALERT_TITLE", fallback: "Delete local data?")
    public static let detailItemViewAccessibilityEditableHint = L10n.tr(
      "Core", "DetailItemView_Accessibility_EditableHint", fallback: "Editable")
    public static let detailItemViewAccessibilityGenerateHint = L10n.tr(
      "Core", "DetailItemView_Accessibility_GenerateHint",
      fallback: "Generates a random password based on guidelines that you set")
    public static let detailItemViewAccessibilityNumberMissingIconLabel = L10n.tr(
      "Core", "DetailItemView_Accessibility_NumberMissingIconLabel", fallback: "Number missing")
    public static let detailItemViewAccessibilityPasswordMissingIconLabel = L10n.tr(
      "Core", "DetailItemView_Accessibility_PasswordMissingIconLabel", fallback: "Password missing")
    public static let detailItemViewAccessibilitySelectEmail = L10n.tr(
      "Core", "DetailItemView_Accessibility_SelectEmail", fallback: "Select an email")
    public static let deviceToDeviceHelpCta = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_HELP_CTA", fallback: "Help")
    public static let deviceToDeviceHelpMessage1 = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_HELP_MESSAGE_1",
      fallback:
        "Confirm that the mobile device you used to scan the QR code is logged in to your Dashlane account."
    )
    public static let deviceToDeviceHelpMessage2 = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_HELP_MESSAGE_2",
      fallback:
        "On your logged-in device, open the Dashlane app **Settings**. Select **Add new mobile device**, then choose **Scan QR code**."
    )
    public static let deviceToDeviceHelpMessage3 = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_HELP_MESSAGE_3",
      fallback:
        "Logging in with a QR code requires a logged-in mobile device. Otherwise, log in with your Master Password."
    )
    public static let deviceToDeviceHelpSubtitle1 = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_HELP_SUBTITLE_1", fallback: "QR code isn’t working")
    public static let deviceToDeviceHelpSubtitle2 = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_HELP_SUBTITLE_2",
      fallback: "I don’t have Dashlane on another mobile device")
    public static let deviceToDeviceHelpTitle = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_HELP_TITLE", fallback: "Troubleshooting tips")
    public static let deviceToDeviceLoadingProgress = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOADING_PROGRESS", fallback: "Loading account info...")
    public static let deviceToDeviceLoginCaption = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_CAPTION", fallback: "Logged in on a different mobile device?")
    public static let deviceToDeviceLoginCompleted = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_COMPLETED", fallback: "You’re logged in!")
    public static let deviceToDeviceLoginCta = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_CTA", fallback: "Log in with a QR code")
    public static let deviceToDeviceLoginErrorMessage = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_ERROR_MESSAGE",
      fallback: "There was an issue loading your Dashlane account information. Please try again.")
    public static let deviceToDeviceLoginErrorRetry = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_ERROR_RETRY", fallback: "Try again")
    public static let deviceToDeviceLoginErrorTitle = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_ERROR_TITLE",
      fallback: "We couldn’t load your account information")
    public static let deviceToDeviceLoginLoadErrorMessage = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_LOAD_ERROR_MESSAGE",
      fallback: "There was an issue logging you in to your Dashlane account. Please try again.")
    public static let deviceToDeviceLoginLoadErrorTitle = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_LOAD_ERROR_TITLE",
      fallback: "We couldn’t log you in to your account")
    public static let deviceToDeviceLoginProgress = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_LOGIN_PROGRESS", fallback: "Logging you in...")
    public static let deviceToDeviceNavigationTitle = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_NAVIGATION_TITLE", fallback: "Login")
    public static let deviceToDevicePushFallbackCta = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_PUSH_FALLBACK_CTA", fallback: "Use 2FA token")
    public static let deviceToDevicePushInProgress = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_PUSH_IN_PROGRESS",
      fallback: "We sent a request to your authenticator app")
    public static let deviceToDeviceQrcodeTitle = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_QRCODE_TITLE",
      fallback: "Scan the QR code using the camera on your logged-in mobile device")
    public static let deviceToDeviceVerifyLoginMessage = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_VERIFY_LOGIN_MESSAGE",
      fallback: "Before logging in, make sure this is the Dashlane account you want to log in to:")
    public static let deviceToDeviceVerifyLoginTitle = L10n.tr(
      "Core", "DEVICE_TO_DEVICE_VERIFY_LOGIN_TITLE", fallback: "Confirm your email address")
    public static let deviceUnlinkAlertMessage = L10n.tr(
      "Core", "DEVICE_UNLINK_ALERT_MESSAGE",
      fallback:
        "There was a problem with unlinking your device(s). Please try again or contact Dashlane Support for help."
    )
    public static let deviceUnlinkAlertTitle = L10n.tr(
      "Core", "DEVICE_UNLINK_ALERT_TITLE", fallback: "Something went wrong")
    public static let deviceUnlinkAlertTryAgain = L10n.tr(
      "Core", "DEVICE_UNLINK_ALERT_TRY_AGAIN", fallback: "Try again")
    public static let deviceUnlinkLimitedMultiDevicesDescription = L10n.tr(
      "Core", "DEVICE_UNLINK_LIMITED_MULTI_DEVICES_DESCRIPTION",
      fallback:
        "Upgrade to Premium to access your data on unlimited devices. Or, unlink a device to stay on your current plan."
    )
    public static func deviceUnlinkLimitedMultiDevicesTitle(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "DEVICE_UNLINK_LIMITED_MULTI_DEVICES_TITLE", String(describing: p1), fallback: "_")
    }
    public static let deviceUnlinkLimitedMultiDevicesUnlinkCta = L10n.tr(
      "Core", "DEVICE_UNLINK_LIMITED_MULTI_DEVICES_UNLINK_CTA", fallback: "Unlink device")
    public static let deviceUnlinkLoadingUnlinkDevice = L10n.tr(
      "Core", "DEVICE_UNLINK_LOADING_UNLINK_DEVICE", fallback: "Unlinking selected device")
    public static let deviceUnlinkLoadingUnlinkDevices = L10n.tr(
      "Core", "DEVICE_UNLINK_LOADING_UNLINK_DEVICES", fallback: "Unlinking selected devices")
    public static let deviceUnlinkUnlinkDevicePremiumFeatureDescription = L10n.tr(
      "Core", "DEVICE_UNLINK_UNLINK_DEVICE_PREMIUM_FEATURE_DESCRIPTION",
      fallback: "Our Premium plan also includes unlimited logins, VPN, and Dark Web Monitoring.")
    public static let deviceUnlinkUnlinkDevicesDescription = L10n.tr(
      "Core", "DEVICE_UNLINK_UNLINK_DEVICES_DESCRIPTION",
      fallback: "We’ll securely transfer your Dashlane data to your new device in the next step.")
    public static let deviceUnlinkUnlinkDevicesSubtitle = L10n.tr(
      "Core", "DEVICE_UNLINK_UNLINK_DEVICES_SUBTITLE",
      fallback: "The Essentials plan supports only 2 devices. Unlink all but one from this list.")
    public static let deviceUnlinkUnlinkDevicesTitle = L10n.tr(
      "Core", "DEVICE_UNLINK_UNLINK_DEVICES_TITLE", fallback: "Select the devices to unlink")
    public static let deviceUnlinkUnlinkDevicesUpgradeCta = L10n.tr(
      "Core", "DEVICE_UNLINK_UNLINK_DEVICES_UPGRADE_CTA", fallback: "Upgrade plan")
    public static let deviceUnlinkingLimitedDescription = L10n.tr(
      "Core", "DEVICE_UNLINKING_LIMITED_DESCRIPTION",
      fallback:
        "Upgrade to Premium to access your data on unlimited devices. Or, unlink your previous device to continue."
    )
    public static let deviceUnlinkingLimitedPremiumCta = L10n.tr(
      "Core", "DEVICE_UNLINKING_LIMITED_PREMIUM_CTA", fallback: "Upgrade to Premium")
    public static let deviceUnlinkingLimitedTitle = L10n.tr(
      "Core", "DEVICE_UNLINKING_LIMITED_TITLE", fallback: "Your current plan supports only 1 device"
    )
    public static let deviceUnlinkingLimitedUnlinkCta = L10n.tr(
      "Core", "DEVICE_UNLINKING_LIMITED_UNLINK_CTA", fallback: "Unlink previous device")
    public static let deviceUnlinkingUnlinkBackCta = L10n.tr(
      "Core", "DEVICE_UNLINKING_UNLINK_BACK_CTA", fallback: "Cancel")
    public static let deviceUnlinkingUnlinkCta = L10n.tr(
      "Core", "DEVICE_UNLINKING_UNLINK_CTA", fallback: "Unlink")
    public static let deviceUnlinkingUnlinkDescription = L10n.tr(
      "Core", "DEVICE_UNLINKING_UNLINK_DESCRIPTION",
      fallback: "All your Dashlane data will be securely transferred to your new device.")
    public static func deviceUnlinkingUnlinkLastActive(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "DEVICE_UNLINKING_UNLINK_LAST_ACTIVE", String(describing: p1), fallback: "_")
    }
    public static let deviceUnlinkingUnlinkTitle = L10n.tr(
      "Core", "DEVICE_UNLINKING_UNLINK_TITLE", fallback: "Unlink your previous device?")
    public static let disableOtpUseRecoveryCode = L10n.tr(
      "Core", "DISABLE_OTP_USE_RECOVERY_CODE", fallback: "Use a recovery code")
    public static let disableOtpUseRecoveryCodeCta = L10n.tr(
      "Core", "DISABLE_OTP_USE_RECOVERY_CODE_CTA", fallback: "Turn off 2FA")
    public static let documentsStorageSectionTitle = L10n.tr(
      "Core", "documentsStorageSectionTitle", fallback: "Attached files")
    public static let duoChallengeButton = L10n.tr(
      "Core", "DUO_CHALLENGE_BUTTON", fallback: "Use Duo Push instead")
    public static let duoChallengeFailedMessage = L10n.tr(
      "Core", "DUO_CHALLENGE_FAILED_MESSAGE", fallback: "The Duo login request was denied")
    public static let duoChallengePrompt = L10n.tr(
      "Core", "DUO_CHALLENGE_PROMPT", fallback: "Approve the Duo login request to continue")
    public static let dwmOnboardingCardPWGTabEmailCopied = L10n.tr(
      "Core", "DWMOnboarding_Card_PWG_Tab_Email_Copied", fallback: "Password copied!")
    public static let dwmOnboardingFixBreachesDetailNoPassword = L10n.tr(
      "Core", "DWMOnboarding_FixBreaches_Detail_NoPassword", fallback: "Missing password")
    public static let emptyConfidentialCardsListCta = L10n.tr(
      "Core", "EMPTY_CONFIDENTIAL_CARDS_LIST_CTA", fallback: "Add an ID")
    public static let emptyConfidentialCardsListText = L10n.tr(
      "Core", "EMPTY_CONFIDENTIAL_CARDS_LIST_TEXT",
      fallback: "Keep passport and ID numbers here and leave originals safe at home.")
    public static let emptyPasswordsListCta = L10n.tr(
      "Core", "EMPTY_PASSWORDS_LIST_CTA", fallback: "Add a login")
    public static let emptyPasswordsListText = L10n.tr(
      "Core", "EMPTY_PASSWORDS_LIST_TEXT",
      fallback: "With all your logins secured here, never forget one again.")
    public static let emptyPaymentsListCta = L10n.tr(
      "Core", "EMPTY_PAYMENTS_LIST_CTA", fallback: "Add a payment")
    public static let emptyPaymentsListText = L10n.tr(
      "Core", "EMPTY_PAYMENTS_LIST_TEXT",
      fallback: "Payment details stored here will be filled for you at checkout.")
    public static let emptyPersonalInfoListCta = L10n.tr(
      "Core", "EMPTY_PERSONAL_INFO_LIST_CTA", fallback: "Add my info")
    public static let emptyPersonalInfoListText = L10n.tr(
      "Core", "EMPTY_PERSONAL_INFO_LIST_TEXT",
      fallback: "When you store personal details here, Dashlane can fill forms for you.")
    public static let emptyRecentActivityText = L10n.tr(
      "Core", "EMPTY_RECENT_ACTIVITY_TEXT",
      fallback: "As you use the app, your recent items will appear here.")
    public static let emptySearchResultsText = L10n.tr(
      "Core", "EMPTY_SEARCH_RESULTS_TEXT",
      fallback: "Nothing stored in Dashlane matches your search")
    public static let emptySecretsListText = L10n.tr(
      "Core", "EMPTY_SECRETS_LIST_TEXT",
      fallback:
        "Protect infrastructure secrets like API keys and encryption codes here, and retrieve them securely using our command-line interface (CLI) capabilities."
    )
    public static let emptySecureNotesListCta = L10n.tr(
      "Core", "EMPTY_SECURE_NOTES_LIST_CTA", fallback: "Add a secure note")
    public static let emptySecureNotesListText = L10n.tr(
      "Core", "EMPTY_SECURE_NOTES_LIST_TEXT",
      fallback: "Store any important info here, from WiFi passwords to alarm codes.")
    public static let emptySecretsListCta = L10n.tr(
      "Core", "emptySecretsListCta", fallback: "Add your first secret")
    public static let enterPasscode = L10n.tr("Core", "EnterPasscode", fallback: "Enter PIN")
    public static let existingSecureFilesAttachedCta = L10n.tr(
      "Core", "existingSecureFilesAttachedCta", fallback: "Attach another file")
    public static let failedAutorenewalAnnouncementAction = L10n.tr(
      "Core", "FAILED_AUTORENEWAL_ANNOUNCEMENT_ACTION", fallback: "Update payment details")
    public static let failedAutorenewalAnnouncementTitle = L10n.tr(
      "Core", "FAILED_AUTORENEWAL_ANNOUNCEMENT_TITLE",
      fallback: "Please update your payment details to continue enjoying Premium benefits.")
    public static let forgotMpSheetRecoveryActionTitle = L10n.tr(
      "Core", "FORGOT_MP_SHEET_RECOVERY_ACTION_TITLE", fallback: "Use recovery key")
    public static let forgotMpSheetTitle = L10n.tr(
      "Core", "FORGOT_MP_SHEET_TITLE", fallback: "Forgot your password?")
    public static let freeTrialStartedDialogDescription = L10n.tr(
      "Core", "free_trial_started_dialog_description",
      fallback:
        "Try out our Premium features for free for 30 days.\n\nFYI: You’ll be automatically switched to Dashlane Free after the trial ends."
    )
    public static func freeTrialStartedDialogDescriptionDayleft(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "free_trial_started_dialog_description_dayleft", String(describing: p1),
        fallback: "_\nYou’ll be automatically switched back to the Free plan after the trial ends.")
    }
    public static func freeTrialStartedDialogDescriptionDaysleft(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "free_trial_started_dialog_description_daysleft", String(describing: p1),
        fallback: "_\nYou’ll be automatically switched back to the Free plan after the trial ends.")
    }
    public static let freeTrialStartedDialogLearnMoreCta = L10n.tr(
      "Core", "free_trial_started_dialog_learn_more_cta", fallback: "Learn more")
    public static let freeTrialStartedDialogTitle = L10n.tr(
      "Core", "free_trial_started_dialog_title", fallback: "Your free trial has started!")
    public static let frozenAccountAction = L10n.tr(
      "Core", "frozenAccount_action", fallback: "Get more storage")
    public static let frozenAccountMessage = L10n.tr(
      "Core", "frozenAccount_message",
      fallback:
        "You have over 25 passwords saved. Remove passwords or upgrade to regain full access to your account."
    )
    public static let frozenAccountTitle = L10n.tr(
      "Core", "frozenAccount_title", fallback: "Your account is read-only")
    public static let generatedPassword = L10n.tr(
      "Core", "generated_password", fallback: "Generated password")
    public static let generatedPasswordListTitle = L10n.tr(
      "Core", "GENERATED_PASSWORD_LIST_TITLE", fallback: "Previously generated")
    public static let goPremium = L10n.tr("Core", "GoPremium", fallback: "Go Premium")
    public static func id(_ p1: Int) -> String {
      return L10n.tr("Core", "id", p1, fallback: "%1$d ID")
    }
    public static func idsPlural(_ p1: Int) -> String {
      return L10n.tr("Core", "idsPlural", p1, fallback: "%1$d IDs")
    }
    public static let importFromLastpassBannerDescription = L10n.tr(
      "Core", "importFromLastpassBannerDescription",
      fallback:
        "We noticed you’re using LastPass on this device. Instead of using multiple password managers, import your stored data right into Dashlane. That way, all your data will be protected by AES-256 encryption and a patented security architecture."
    )
    public static let importFromLastpassBannerPrimaryCta = L10n.tr(
      "Core", "importFromLastpassBannerPrimaryCta", fallback: "Get started")
    public static let importFromLastpassBannerSecondaryCta = L10n.tr(
      "Core", "importFromLastpassBannerSecondaryCta", fallback: "Dismiss")
    public static let importFromLastpassBannerTitle = L10n.tr(
      "Core", "importFromLastpassBannerTitle",
      fallback: "Did you know you can easily import your LastPass data into Dashlane?")
    public static let importFromLastpassIntroDescription = L10n.tr(
      "Core", "importFromLastpassIntroDescription",
      fallback:
        "After you’ve exported your LastPass vault as a CSV file, you can drag and drop it here.")
    public static let importFromLastpassIntroTitle = L10n.tr(
      "Core", "importFromLastpassIntroTitle", fallback: "Import your data from LastPass")
    public static let importLoadingItems = L10n.tr(
      "Core", "importLoadingItems", fallback: "Loading items...")
    public static func introOffersFinalPriceDescriptionMonthly(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_finalPriceDescriptionMonthly", String(describing: p1), fallback: "_")
    }
    public static func introOffersFinalPriceDescriptionYearly(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_finalPriceDescriptionYearly", String(describing: p1), fallback: "_")
    }
    public static let introOffersForOneDay = L10n.tr(
      "Core", "introOffers_forOneDay", fallback: "for 1 day")
    public static let introOffersForOneMonth = L10n.tr(
      "Core", "introOffers_forOneMonth", fallback: "for 1 month")
    public static let introOffersForOneWeek = L10n.tr(
      "Core", "introOffers_forOneWeek", fallback: "for 1 week")
    public static let introOffersForOneYear = L10n.tr(
      "Core", "introOffers_forOneYear", fallback: "for 1 year")
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
    public static let introOffersPerMonthForOneMonth = L10n.tr(
      "Core", "introOffers_perMonthForOneMonth", fallback: "/mo for 1 month")
    public static func introOffersPerMonthForXMonths(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_perMonthForXMonths", String(describing: p1), fallback: "_")
    }
    public static func introOffersPerXMonths(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_perXMonths", String(describing: p1), fallback: "_")
    }
    public static func introOffersPerXYears(_ p1: Any) -> String {
      return L10n.tr("Core", "introOffers_perXYears", String(describing: p1), fallback: "_")
    }
    public static func introOffersPromoDiscountFirstMonth(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_discountFirstMonth", String(describing: p1), fallback: "_")
    }
    public static func introOffersPromoDiscountFirstXMonths(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_discountFirstXMonths", String(describing: p1),
        String(describing: p2), fallback: "_")
    }
    public static func introOffersPromoDiscountFirstXYears(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_discountFirstXYears", String(describing: p1),
        String(describing: p2), fallback: "_")
    }
    public static func introOffersPromoDiscountFirstYear(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_discountFirstYear", String(describing: p1), fallback: "_")
    }
    public static let introOffersPromoFirstDayFree = L10n.tr(
      "Core", "introOffers_promo_firstDayFree", fallback: "First day free")
    public static let introOffersPromoFirstMonthFree = L10n.tr(
      "Core", "introOffers_promo_firstMonthFree", fallback: "First month free")
    public static let introOffersPromoFirstWeekFree = L10n.tr(
      "Core", "introOffers_promo_firstWeekFree", fallback: "First week free")
    public static func introOffersPromoFirstXDaysFree(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_firstXDaysFree", String(describing: p1), fallback: "_")
    }
    public static func introOffersPromoFirstXMonthsFree(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_firstXMonthsFree", String(describing: p1), fallback: "_")
    }
    public static func introOffersPromoFirstXWeeksFree(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_firstXWeeksFree", String(describing: p1), fallback: "_")
    }
    public static func introOffersPromoFirstXYearsFree(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_firstXYearsFree", String(describing: p1), fallback: "_")
    }
    public static let introOffersPromoFirstYearFree = L10n.tr(
      "Core", "introOffers_promo_firstYearFree", fallback: "First year free")
    public static let introOffersPromoSaveFirstMonth = L10n.tr(
      "Core", "introOffers_promo_saveFirstMonth", fallback: "Save on first month")
    public static func introOffersPromoSaveFirstXMonths(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_saveFirstXMonths", String(describing: p1), fallback: "_")
    }
    public static func introOffersPromoSaveFirstXYears(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "introOffers_promo_saveFirstXYears", String(describing: p1), fallback: "_")
    }
    public static let introOffersPromoSaveFirstYear = L10n.tr(
      "Core", "introOffers_promo_saveFirstYear", fallback: "Save on first year")
    public static let introOffersSpecialOffer = L10n.tr(
      "Core", "introOffers_specialOffer", fallback: "Special offer")
    public static let invalidRecoveryPhoneNumberErrorMessage = L10n.tr(
      "Core", "invalidRecoveryPhoneNumberErrorMessage",
      fallback: "Your mobile phone number is invalid.")
    public static let ios13SupportDropAnnouncementBody = L10n.tr(
      "Core", "iOS13SupportDropAnnouncementBody",
      fallback:
        "You need to update to the latest version of iOS in order to continue receiving updates for this app. You can do this by going to the Settings app, then General ⇾ Software Update"
    )
    public static let ios13SupportDropAnnouncementCTA = L10n.tr(
      "Core", "iOS13SupportDropAnnouncementCTA", fallback: "Open Settings")
    public static let itemsTitle = L10n.tr("Core", "ITEMS_TITLE", fallback: "All Items")
    public static let itemSharingTeamOnlyWarning = L10n.tr(
      "Core", "itemSharing_teamOnlyWarning",
      fallback:
        "Items can only be shared with users in your organization. Please check the email address and try again."
    )
    public static let keyboardShortcutSearch = L10n.tr(
      "Core", "KEYBOARD_SHORTCUT_SEARCH", fallback: "Search")
    public static let kwAccountCreationExistingAccount = L10n.tr(
      "Core", "KW_ACCOUNT_CREATION_EXISTING_ACCOUNT",
      fallback: "A Dashlane account exists for this email address.")
    public static let kwAccountErrorTimeOut = L10n.tr(
      "Core", "KW_ACCOUNT_ERROR_TIME_OUT", fallback: "The login request has timed out.")
    public static let kwActions = L10n.tr("Core", "KW_ACTIONS", fallback: "Actions")
    public static let kwAddButton = L10n.tr("Core", "KW_ADD_BUTTON", fallback: "Add")
    public static let kwadddatakwAddressIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWAddressIOS", fallback: "Add an address")
    public static let kwadddatakwAuthentifiantIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWAuthentifiantIOS", fallback: "Add a login")
    public static let kwadddatakwBankStatementIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWBankStatementIOS", fallback: "Add a bank account")
    public static let kwadddatakwCompanyIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWCompanyIOS", fallback: "Add a company")
    public static let kwadddatakwDriverLicenceIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWDriverLicenceIOS", fallback: "Add a driver's license")
    public static let kwadddatakwEmailIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWEmailIOS", fallback: "Add an email")
    public static let kwadddatakwFiscalStatementIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWFiscalStatementIOS", fallback: "Add a tax number")
    public static let kwadddatakwidCardIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWIDCardIOS", fallback: "Add an ID card")
    public static let kwadddatakwIdentityIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWIdentityIOS", fallback: "Add a name")
    public static let kwadddatakwPassportIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWPassportIOS", fallback: "Add a passport")
    public static let kwadddatakwPaymentMeanCreditCardIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWPaymentMean_creditCardIOS", fallback: "Add a credit/debit card")
    public static let kwadddatakwPersonalWebsiteIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWPersonalWebsiteIOS", fallback: "Add a website")
    public static let kwadddatakwPhoneIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWPhoneIOS", fallback: "Add a phone number")
    public static let kwadddatakwSecureNoteIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWSecureNoteIOS", fallback: "Add a secure note")
    public static let kwadddatakwSocialSecurityStatementIOS = L10n.tr(
      "Core", "KW_ADD_DATA_KWSocialSecurityStatementIOS", fallback: "Add a social security number")
    public static let kwAttachPremiumMessage = L10n.tr(
      "Core", "KW_ATTACH_PREMIUM_MESSAGE",
      fallback:
        "Upgrade to Premium to get 1GB file storage. Encrypt your most important documents and access them anywhere."
    )
    public static let kwAttachPremiumTitle = L10n.tr(
      "Core", "KW_ATTACH_PREMIUM_TITLE", fallback: "Premium Feature")
    public static let kwAttachementsTitle = L10n.tr(
      "Core", "KW_ATTACHEMENTS_TITLE", fallback: "Attached files")
    public static let kwAuthoriseCameraAccess = L10n.tr(
      "Core", "KW_AUTHORISE_CAMERA_ACCESS", fallback: "Go to Settings")
    public static let kwBack = L10n.tr("Core", "KW_BACK", fallback: "Back")
    public static let kwButtonClose = L10n.tr("Core", "KW_BUTTON_CLOSE", fallback: "Close")
    public static let kwButtonOk = L10n.tr("Core", "KW_BUTTON_OK", fallback: "OK")
    public static let kwChangePinCode = L10n.tr(
      "Core", "KW_CHANGE_PIN_CODE", fallback: "Change PIN")
    public static let kwChoosePinCode = L10n.tr(
      "Core", "KW_CHOOSE_PIN_CODE", fallback: "Choose a PIN")
    public static let kwConfirmButton = L10n.tr("Core", "KW_CONFIRM_BUTTON", fallback: "Confirm")
    public static let kwConfirmPinCode = L10n.tr(
      "Core", "KW_CONFIRM_PIN_CODE", fallback: "Confirm your PIN")
    public static let kwCopied = L10n.tr("Core", "KW_COPIED", fallback: "Copied to Clipboard")
    public static let kwCopy = L10n.tr("Core", "KW_COPY", fallback: "Copy")
    public static let kwCopyButton = L10n.tr("Core", "KW_COPY_BUTTON", fallback: "Copy")
    public static let kwCorespotlightDescBankAccount = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_DESC_BANK_ACCOUNT", fallback: "See bank account details")
    public static let kwCorespotlightDescCreditcard = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_DESC_CREDITCARD", fallback: "See these card details")
    public static let kwCorespotlightDescPasswordgenerator = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_DESC_PASSWORDGENERATOR", fallback: "Generate a strong password")
    public static let kwCorespotlightKwdGenerateStrongPassword = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_KWD_GENERATE_STRONG_PASSWORD", fallback: "generate strong password")
    public static let kwCorespotlightKwdNewPassword = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_KWD_NEW_PASSWORD", fallback: "new password")
    public static let kwCorespotlightKwdPassword = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_KWD_PASSWORD", fallback: "password")
    public static let kwCorespotlightKwdPasswordGenerator = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_KWD_PASSWORD_GENERATOR", fallback: "password generator")
    public static let kwCorespotlightKwdPasswordSecurity = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_KWD_PASSWORD_SECURITY", fallback: "password security")
    public static let kwCorespotlightKwdRandomPassword = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_KWD_RANDOM_PASSWORD", fallback: "random password")
    public static let kwCorespotlightKwdStrongPasswords = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_KWD_STRONG_PASSWORDS", fallback: "strong passwords")
    public static func kwCorespotlightTitleAuth(_ p1: Any) -> String {
      return L10n.tr("Core", "KW_CORESPOTLIGHT_TITLE_AUTH", String(describing: p1), fallback: "_")
    }
    public static func kwCorespotlightTitleCreditcard(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "KW_CORESPOTLIGHT_TITLE_CREDITCARD", String(describing: p1), fallback: "_")
    }
    public static let kwCorespotlightTitlePasswordgenerator = L10n.tr(
      "Core", "KW_CORESPOTLIGHT_TITLE_PASSWORDGENERATOR", fallback: "Password generator")
    public static let kwCreateAccountPrivacy = L10n.tr(
      "Core", "KW_CREATE_ACCOUNT_PRIVACY", fallback: "Privacy Policy")
    public static let kwCreateAccountTermsConditions = L10n.tr(
      "Core", "KW_CREATE_ACCOUNT_TERMS_CONDITIONS", fallback: "Dashlane Terms of Service")
    public static let kwDefaultFilename = L10n.tr("Core", "KW_DEFAULT_FILENAME", fallback: "file")
    public static let kwDelete = L10n.tr("Core", "KW_DELETE", fallback: "Delete")
    public static let kwDeleteConfirm = L10n.tr(
      "Core", "KW_DELETE_CONFIRM",
      fallback: "Are you sure you want to permanently delete this item from Dashlane?")
    public static let kwDeleteConfirmAutoGroup = L10n.tr(
      "Core", "KW_DELETE_CONFIRM_AUTO_GROUP",
      fallback:
        "This item will be deleted from your account, and you will no longer have shared access to it."
    )
    public static let kwDeleteConfirmAutoGroupTitle = L10n.tr(
      "Core", "KW_DELETE_CONFIRM_AUTO_GROUP_TITLE",
      fallback: "Are you sure you want to delete this item?")
    public static let kwDeleteConfirmGroup = L10n.tr(
      "Core", "KW_DELETE_CONFIRM_GROUP", fallback: "Cannot delete, this item is shared in a group")
    public static let kwDeleteConfirmOnlyAdminMsg = L10n.tr(
      "Core", "KW_DELETE_CONFIRM_ONLY_ADMIN_MSG",
      fallback:
        "You cannot delete this shared item as no one else has full rights access.\n\nUnshare the item or give someone else full rights to try again."
    )
    public static let kwDeviceCurrentDevice = L10n.tr(
      "Core", "KW_DEVICE_CURRENT_DEVICE", fallback: "Current device")
    public static let kwDeviceRename = L10n.tr("Core", "KW_DEVICE_RENAME", fallback: "Rename")
    public static let kwDeviceRenamePlaceholder = L10n.tr(
      "Core", "KW_DEVICE_RENAME_PLACEHOLDER", fallback: "Enter a name")
    public static let kwDeviceRenameTitle = L10n.tr(
      "Core", "KW_DEVICE_RENAME_TITLE", fallback: "Rename")
    public static let kwDoneButton = L10n.tr("Core", "KW_DONE_BUTTON", fallback: "Done")
    public static let kwDownloadAttachment = L10n.tr(
      "Core", "KW_DOWNLOAD_ATTACHMENT", fallback: "Download")
    public static let kwEdit = L10n.tr("Core", "KW_EDIT", fallback: "Edit")
    public static let kwEditClose = L10n.tr("Core", "KW_EDIT_CLOSE", fallback: "Cancel")
    public static let kwEmailInvalid = L10n.tr(
      "Core", "KW_EMAIL_INVALID", fallback: "This email address is invalid. Please try again.")
    public static let kwEmailPlaceholder = L10n.tr(
      "Core", "KW_EMAIL_PLACEHOLDER", fallback: "Email")
    public static let kwEmailTitle = L10n.tr(
      "Core", "KW_EMAIL_TITLE", fallback: "Enter your email address")
    public static let kwEmptyContactAddAction = L10n.tr(
      "Core", "KW_EMPTY_CONTACT_ADD_ACTION", fallback: "Add personal information")
    public static let kwEmptyIdsAddAction = L10n.tr(
      "Core", "KW_EMPTY_IDS_ADD_ACTION", fallback: "Add an ID")
    public static let kwEmptyPaymentsAddAction = L10n.tr(
      "Core", "KW_EMPTY_PAYMENTS_ADD_ACTION", fallback: "Add a payment type")
    public static let kwEmptyPwdAddAction = L10n.tr(
      "Core", "KW_EMPTY_PWD_ADD_ACTION", fallback: "Add a login")
    public static let kwEnterYourMasterPassword = L10n.tr(
      "Core", "KW_ENTER_YOUR_MASTER_PASSWORD", fallback: "Enter Master Password")
    public static let kwEnterYourPinCode = L10n.tr(
      "Core", "KW_ENTER_YOUR_PIN_CODE", fallback: "Unlock with your PIN")
    public static let kwErrorTitle = L10n.tr("Core", "KW_ERROR_TITLE", fallback: "Error")
    public static let kwExtSomethingWentWrong = L10n.tr(
      "Core", "KW_EXT_SOMETHING_WENT_WRONG", fallback: "Something went wrong. Please retry.")
    public static func kwFeedbackEmailBody(_ p1: Any) -> String {
      return L10n.tr("Core", "KW_FEEDBACK_EMAIL_BODY", String(describing: p1), fallback: "\n\n_")
    }
    public static let kwFeedbackEmailSubject = L10n.tr(
      "Core", "KW_FEEDBACK_EMAIL_SUBJECT", fallback: "iOS App Feedback")
    public static let kwGenerate = L10n.tr("Core", "KW_GENERATE", fallback: "Generate")
    public static let kwGoToUrl = L10n.tr("Core", "KW_GO_TO_URL", fallback: "Open")
    public static let kwHide = L10n.tr("Core", "KW_HIDE", fallback: "Hide")
    public static let kwItemShared = L10n.tr("Core", "KW_ITEM_SHARED", fallback: "item shared")
    public static let kwItemsShared = L10n.tr("Core", "KW_ITEMS_SHARED", fallback: "items shared")
    public static let kwLimitedRightMessage = L10n.tr(
      "Core", "KW_LIMITED_RIGHT_MESSAGE",
      fallback:
        "You have limited rights to this login.\n\nYou can't view, copy or edit it, but you can use it with Dashlane extensions for auto-login."
    )
    public static let kwLinkedDefaultOther = L10n.tr(
      "Core", "KW_Linked_Default_Other", fallback: "Other")
    public static func kwLockBiometryTypeLoadingMsg(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "KW_LOCK_BIOMETRY_TYPE_LOADING_MSG", String(describing: p1), fallback: "_")
    }
    public static let kwLogOut = L10n.tr("Core", "KW_LOG_OUT", fallback: "Log out")
    public static let kwLoginNow = L10n.tr("Core", "KW_LOGIN_NOW", fallback: "Log in")
    public static let kwLoginVcLoginButton = L10n.tr(
      "Core", "KW_LOGIN_VC_LOGIN_BUTTON", fallback: "Log in")
    public static let kwNext = L10n.tr("Core", "KW_NEXT", fallback: "Next")
    public static let kwNo = L10n.tr("Core", "KW_NO", fallback: "No")
    public static let kwNoCategory = L10n.tr("Core", "KW_NO_CATEGORY", fallback: "No Category")
    public static let kwNoInternet = L10n.tr(
      "Core", "KW_NO_INTERNET", fallback: "Please check your internet connection and try again.")
    public static let kwNotSave = L10n.tr("Core", "KW_NOT_SAVE", fallback: "Don't save")
    public static let kwOpen = L10n.tr("Core", "KW_OPEN", fallback: "Open")
    public static let kwOtpDashlaneSecretRead = L10n.tr(
      "Core", "KW_OTP_DASHLANE_SECRET_READ",
      fallback:
        "Your Dashlane Password Manager app cannot be used as a mobile authenticator app for your Dashlane account."
    )
    public static let kwOtpMessage = L10n.tr(
      "Core", "KW_OTP_MESSAGE",
      fallback: "Enter the 6-digit token from your 2-factor authentication (2FA) app to log in")
    public static let kwOtpPlaceholderText = L10n.tr(
      "Core", "KW_OTP_PLACEHOLDER_TEXT", fallback: "Verification code")
    public static let kwOtpSecretDelete = L10n.tr(
      "Core", "KW_OTP_SECRET_DELETE", fallback: "Remove from Dashlane")
    public static let kwOtpSecretRead = L10n.tr(
      "Core", "KW_OTP_SECRET_READ",
      fallback:
        "You can now access 2-factor authentication (2FA) tokens for this account from your login view in Dashlane."
    )
    public static let kwOtpSecretScanQrCode = L10n.tr(
      "Core", "KW_OTP_SECRET_SCAN_QR_CODE",
      fallback:
        "Enable 2-factor authentication on your account for this website and scan the QR code")
    public static let kwOtpSecretUpdate = L10n.tr(
      "Core", "KW_OTP_SECRET_UPDATE", fallback: "Re-scan QR code")
    public static let kwOtpsecretWarningConfirmButton = L10n.tr(
      "Core", "KW_OTPSECRET_WARNING_CONFIRM_BUTTON", fallback: "Remove from Dashlane")
    public static let kwOtpsecretWarningDeletionMessage = L10n.tr(
      "Core", "KW_OTPSECRET_WARNING_DELETION_MESSAGE",
      fallback:
        "Removing this token from Dashlane will not turn off 2-factor authentication (2FA). \n\nBefore removing: \n- Ensure 2FA is turned off for your account on this website, or \n- Ensure that you have another means to generate tokens."
    )
    public static let kwOtpsecretWarningDeletionTitle = L10n.tr(
      "Core", "KW_OTPSECRET_WARNING_DELETION_TITLE", fallback: "Remove 6-digit token?")
    public static let kwPadExtensionGeneratorDigits = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_DIGITS", fallback: "Digits (e.g. 345)")
    public static let kwPadExtensionGeneratorDigitsAccessibility = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_DIGITS_ACCESSIBILITY", fallback: "Include digits")
    public static let kwPadExtensionGeneratorDigitsExample = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_DIGITS_EXAMPLE", fallback: "345")
    public static let kwPadExtensionGeneratorGeneratedAccessibility = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_GENERATED_ACCESSIBILITY", fallback: "Generated password")
    public static let kwPadExtensionGeneratorLength = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_LENGTH", fallback: "Length")
    public static let kwPadExtensionGeneratorLengthAccessibility = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_LENGTH_ACCESSIBILITY",
      fallback: "Length of the generated password")
    public static let kwPadExtensionGeneratorLetters = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_LETTERS", fallback: "Letters (e.g. Aa)")
    public static let kwPadExtensionGeneratorLettersAccessibility = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_LETTERS_ACCESSIBILITY", fallback: "Include letters")
    public static let kwPadExtensionGeneratorLettersExample = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_LETTERS_EXAMPLE", fallback: "Aa")
    public static let kwPadExtensionGeneratorRefresh = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_REFRESH", fallback: "Refresh")
    public static let kwPadExtensionGeneratorSimilar = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_SIMILAR", fallback: "Similar characters (e.g. 1l| O0 Z2)")
    public static let kwPadExtensionGeneratorSimilarAccessibility = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_SIMILAR_ACCESSIBILITY",
      fallback: "Include similar characters")
    public static let kwPadExtensionGeneratorSimilarExample = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_SIMILAR_EXAMPLE", fallback: "1l| O0 Z2")
    public static let kwPadExtensionGeneratorSymbols = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_SYMBOLS", fallback: "_")
    public static let kwPadExtensionGeneratorSymbolsAccessibility = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_SYMBOLS_ACCESSIBILITY", fallback: "Include symbols")
    public static let kwPadExtensionGeneratorSymbolsExample = L10n.tr(
      "Core", "KW_PAD_EXTENSION_GENERATOR_SYMBOLS_EXAMPLE", fallback: "_")
    public static let kwPadExtensionOptions = L10n.tr(
      "Core", "KW_PAD_EXTENSION_OPTIONS", fallback: "Options")
    public static let kwPasswordNotSoSafe = L10n.tr(
      "Core", "KW_PASSWORD_NOT_SO_SAFE", fallback: "Not so strong")
    public static let kwPasswordSafe = L10n.tr("Core", "KW_PASSWORD_SAFE", fallback: "Strong")
    public static let kwPasswordSuperSafe = L10n.tr(
      "Core", "KW_PASSWORD_SUPER_SAFE", fallback: "Super strong")
    public static let kwpasswordchangererrorAccountLocked = L10n.tr(
      "Core", "KW_PASSWORDCHANGER_ERROR_accountLocked",
      fallback:
        "This account was blocked after too many incorrect attempts. Check your login details and try again later."
    )
    public static let kwPcOnboardingNotNow = L10n.tr(
      "Core", "KW_PC_ONBOARDING_NOT_NOW", fallback: "Not now")
    public static let kwPickFile = L10n.tr("Core", "KW_PICK_FILE", fallback: "Choose a file")
    public static let kwPickPhoto = L10n.tr("Core", "KW_PICK_PHOTO", fallback: "Choose a photo")
    public static let kwReplaceTouchidCancel = L10n.tr(
      "Core", "KW_REPLACE_TOUCHID_CANCEL", fallback: "Cancel")
    public static let kwReplaceTouchidOk = L10n.tr("Core", "KW_REPLACE_TOUCHID_OK", fallback: "Yes")
    public static let kwRequiresCameraAccess = L10n.tr(
      "Core", "KW_REQUIRES_CAMERA_ACCESS",
      fallback:
        "To complete setup, allow Dashlane to access your camera to scan the website QR code")
    public static let kwReveal = L10n.tr("Core", "KW_REVEAL", fallback: "Reveal")
    public static let kwRevoke = L10n.tr("Core", "KW_REVOKE", fallback: "Revoke")
    public static func kwRevokeCollectionMessage(_ p1: Any) -> String {
      return L10n.tr("Core", "KW_REVOKE_COLLECTION_MESSAGE", String(describing: p1), fallback: "_")
    }
    public static let kwRevokeInvite = L10n.tr(
      "Core", "KW_REVOKE_INVITE", fallback: "Revoke invitation")
    public static let kwSave = L10n.tr("Core", "KW_SAVE", fallback: "Save")
    public static let kwSecureNoteLimitedRightMessage = L10n.tr(
      "Core", "KW_SECURE_NOTE_LIMITED_RIGHT_MESSAGE",
      fallback: "You have limited rights to this secure note.\n\nYou cannot edit or share it.")
    public static let kwSend = L10n.tr("Core", "KW_SEND", fallback: "Send")
    public static let kwSendFeedback = L10n.tr(
      "Core", "KW_SEND_FEEDBACK", fallback: "Share a problem")
    public static let kwSendLove = L10n.tr("Core", "KW_SEND_LOVE", fallback: "Rate 5 stars")
    public static let kwSendLoveFeedbackbuttonPasswordchanger = L10n.tr(
      "Core", "KW_SEND_LOVE_FEEDBACKBUTTON_PASSWORDCHANGER", fallback: "Share a problem")
    public static let kwSendLoveHeadingPasswordchanger = L10n.tr(
      "Core", "KW_SEND_LOVE_HEADING_PASSWORDCHANGER", fallback: "Are you happy with Dashlane?")
    public static let kwSendLoveNothanksbuttonPasswordchanger = L10n.tr(
      "Core", "KW_SEND_LOVE_NOTHANKSBUTTON_PASSWORDCHANGER", fallback: "Not now")
    public static let kwSendLoveSendlovebuttonPasswordchanger = L10n.tr(
      "Core", "KW_SEND_LOVE_SENDLOVEBUTTON_PASSWORDCHANGER", fallback: "Rate 5 Stars")
    public static let kwSendLoveSubheadingPasswordchanger = L10n.tr(
      "Core", "KW_SEND_LOVE_SUBHEADING_PASSWORDCHANGER",
      fallback: "If you love the app, tell us why! If you are having trouble, let us know.")
    public static let kwSettings = L10n.tr("Core", "KW_SETTINGS", fallback: "Settings")
    public static let kwShare = L10n.tr("Core", "KW_SHARE", fallback: "Share")
    public static let kwShareItem = L10n.tr("Core", "KW_SHARE_ITEM", fallback: "New share")
    public static let kwSharePermissionLabel = L10n.tr(
      "Core", "KW_SHARE_PERMISSION_LABEL", fallback: "Permission:")
    public static let kwSharedAccess = L10n.tr(
      "Core", "KW_SHARED_ACCESS", fallback: "Shared access")
    public static let kwSharedAccessSearchPlaceholder = L10n.tr(
      "Core", "KW_SHARED_ACCESS_SEARCH_PLACEHOLDER", fallback: "Search by email or group name...")
    public static let kwSharedAccessUpdatedToast = L10n.tr(
      "Core", "KW_SHARED_ACCESS_UPDATED_TOAST", fallback: "Shared access updated")
    public static let kwSharedItemNoAttachmentMessage = L10n.tr(
      "Core", "KW_SHARED_ITEM_NO_ATTACHMENT_MESSAGE",
      fallback: "You cannot attach a file to this Secure Note as it is shared with other people.")
    public static let kwSharedItemNoAttachmentTitle = L10n.tr(
      "Core", "KW_SHARED_ITEM_NO_ATTACHMENT_TITLE", fallback: "Cannot share attachments")
    public static let kwSharingAdmin = L10n.tr("Core", "KW_SHARING_ADMIN", fallback: "Full rights")
    public static let kwSharingCenterRecipientsPermissionText = L10n.tr(
      "Core", "KW_SHARING_CENTER_RECIPIENTS_PERMISSION_TEXT",
      fallback:
        "To adjust item access, you can remove them from the Collection or exclude the item from it."
    )
    public static let kwSharingCenterRecipientsPermissionTitle = L10n.tr(
      "Core", "KW_SHARING_CENTER_RECIPIENTS_PERMISSION_TITLE",
      fallback:
        "Certain users and groups may have access to this item both directly and via a Collection")
    public static let kwSharingCollectionPermissionText = L10n.tr(
      "Core", "KW_SHARING_COLLECTION_PERMISSION_TEXT",
      fallback:
        "Selected recipients can edit and manage access to the Collection. Items shared within the Collection will be granted Full Rights."
    )
    public static let kwSharingCollectionPermissionTitle = L10n.tr(
      "Core", "KW_SHARING_COLLECTION_PERMISSION_TITLE", fallback: "Permissions")
    public static let kwSharingCollectionTitle = L10n.tr(
      "Core", "KW_SHARING_COLLECTION_TITLE", fallback: "Share collection")
    public static let kwSharingComposeMessageToFieldPlaceholder = L10n.tr(
      "Core", "KW_SHARING_COMPOSE_MESSAGE_TO_FIELD_PLACEHOLDER",
      fallback: "Dashlane email address or Group")
    public static let kwSharingInvitePending = L10n.tr(
      "Core", "KW_SHARING_INVITE_PENDING", fallback: "Invite pending")
    public static let kwSharingMember = L10n.tr(
      "Core", "KW_SHARING_MEMBER", fallback: "Limited rights")
    public static let kwSharingNoEmailAccount = L10n.tr(
      "Core", "KW_SHARING_NO_EMAIL_ACCOUNT",
      fallback: "You don't have an email account configured on this device.")
    public static func kwSharingUsersPlural(_ p1: Int) -> String {
      return L10n.tr("Core", "KW_SHARING_USERS_PLURAL", p1, fallback: "%1$ld users")
    }
    public static func kwSharingUsersSingular(_ p1: Int) -> String {
      return L10n.tr("Core", "KW_SHARING_USERS_SINGULAR", p1, fallback: "%1$ld user")
    }
    public static let kwSignOut = L10n.tr("Core", "KW_SIGN_OUT", fallback: "Log out")
    public static let kwSkip = L10n.tr("Core", "KW_SKIP", fallback: "Skip")
    public static let kwTakePhoto = L10n.tr("Core", "KW_TAKE_PHOTO", fallback: "Take a photo")
    public static let kwThrottleMsg = L10n.tr(
      "Core", "KW_THROTTLE_MSG", fallback: "Account is locked, please retry in 5 minutes.")
    public static let kwTokenMsg = L10n.tr(
      "Core", "KW_TOKEN_MSG",
      fallback:
        "We just sent your verification code by email. (If you don't see it, check Spam/Junk)")
    public static let kwTokenPlaceholderText = L10n.tr(
      "Core", "KW_TOKEN_PLACEHOLDER_TEXT", fallback: "Verification code")
    public static func kwUploaded(_ p1: Any) -> String {
      return L10n.tr("Core", "KW_UPLOADED", String(describing: p1), fallback: "_")
    }
    public static let kwWrongMasterPasswordTryAgain = L10n.tr(
      "Core", "KW_WRONG_MASTER_PASSWORD_TRY_AGAIN", fallback: "Wrong master password, try again")
    public static let kwYes = L10n.tr("Core", "KW_YES", fallback: "Yes")
    public static let kwAddressIOS = L10n.tr("Core", "KWAddressIOS", fallback: "Address")
    public static let kwAuthentifiantIOS = L10n.tr(
      "Core", "KWAuthentifiantIOS", fallback: "Username")
    public static let kwBankStatementIOS = L10n.tr(
      "Core", "KWBankStatementIOS", fallback: "Bank account")
    public static let kwCompanyIOS = L10n.tr("Core", "KWCompanyIOS", fallback: "Company")
    public static let kwDriverLicenceIOS = L10n.tr(
      "Core", "KWDriverLicenceIOS", fallback: "Driver's License")
    public static let kwEmailIOS = L10n.tr("Core", "KWEmailIOS", fallback: "Email")
    public static let kwFiscalStatementIOS = L10n.tr(
      "Core", "KWFiscalStatementIOS", fallback: "Tax number")
    public static let kwidCardIOS = L10n.tr("Core", "KWIDCardIOS", fallback: "ID Card")
    public static let kwIdentityIOS = L10n.tr("Core", "KWIdentityIOS", fallback: "Name")
    public static let kwPassportIOS = L10n.tr("Core", "KWPassportIOS", fallback: "Passport")
    public static let kwPaymentMeanCreditCardIOS = L10n.tr(
      "Core", "KWPaymentMean_creditCardIOS", fallback: "Credit card")
    public static let kwPersonalWebsiteIOS = L10n.tr(
      "Core", "KWPersonalWebsiteIOS", fallback: "Website")
    public static let kwPhoneIOS = L10n.tr("Core", "KWPhoneIOS", fallback: "Phone")
    public static let kwSecureNoteIOS = L10n.tr("Core", "KWSecureNoteIOS", fallback: "Note")
    public static let kwSocialSecurityStatementIOS = L10n.tr(
      "Core", "KWSocialSecurityStatementIOS", fallback: "Social Security Number")
    public static func login(_ p1: Int) -> String {
      return L10n.tr("Core", "login", p1, fallback: "%1$d login")
    }
    public static let loginPinSetupCta = L10n.tr(
      "Core", "LOGIN_PIN_SETUP_CTA", fallback: "Get started")
    public static let loginPinSetupMessage = L10n.tr(
      "Core", "LOGIN_PIN_SETUP_MESSAGE",
      fallback: "You need to set up a PIN for each device that’s logged in to your account.")
    public static let loginPinSetupTitle = L10n.tr(
      "Core", "LOGIN_PIN_SETUP_TITLE", fallback: "Create a PIN for this device")
    public static func loginsPlural(_ p1: Int) -> String {
      return L10n.tr("Core", "loginsPlural", p1, fallback: "%1$d logins")
    }
    public static let m2WImportFromChromeConfirmationPopupNo = L10n.tr(
      "Core", "M2W_ImportFromChrome_ConfirmationPopup_No", fallback: "Not yet")
    public static let m2WImportFromChromeConfirmationPopupTitle = L10n.tr(
      "Core", "M2W_ImportFromChrome_ConfirmationPopup_Title",
      fallback: "Have you logged in to Dashlane on your computer?")
    public static let m2WImportFromChromeConfirmationPopupYes = L10n.tr(
      "Core", "M2W_ImportFromChrome_ConfirmationPopup_Yes", fallback: "Yes")
    public static let m2WImportFromChromeImportScreenBack = L10n.tr(
      "Core", "M2W_ImportFromChrome_ImportScreen_Back", fallback: "Back")
    public static let m2WImportFromChromeImportScreenDone = L10n.tr(
      "Core", "M2W_ImportFromChrome_ImportScreen_Done", fallback: "Done")
    public static let m2WImportFromChromeImportScreenPrimaryTitle = L10n.tr(
      "Core", "M2W_ImportFromChrome_ImportScreen_PrimaryTitle",
      fallback: "My Account > Import Passwords")
    public static let m2WImportFromChromeImportScreenSecondaryTitle = L10n.tr(
      "Core", "M2W_ImportFromChrome_ImportScreen_SecondaryTitle",
      fallback: "In the web app, you’ll find the import tool in the account menu:")
    public static let m2WImportFromChromeIntoScreenCancel = L10n.tr(
      "Core", "M2W_ImportFromChrome_IntoScreen_Cancel", fallback: "Cancel")
    public static let m2WImportFromChromeIntoScreenCTA = L10n.tr(
      "Core", "M2W_ImportFromChrome_IntoScreen_CTA", fallback: "Let’s begin")
    public static let m2WImportFromChromeIntoScreenPrimaryTitlePart1 = L10n.tr(
      "Core", "M2W_ImportFromChrome_IntoScreen_PrimaryTitle_Part1", fallback: "Import from")
    public static let m2WImportFromChromeIntoScreenPrimaryTitlePart2 = L10n.tr(
      "Core", "M2W_ImportFromChrome_IntoScreen_PrimaryTitle_Part2", fallback: "Chrome")
    public static let m2WImportFromChromeIntoScreenSecondaryTitle = L10n.tr(
      "Core", "M2W_ImportFromChrome_IntoScreen_SecondaryTitle",
      fallback: "We’ve built an easy way to import via your computer.")
    public static let m2WImportFromChromeIntroScreenPrimaryTitle = L10n.tr(
      "Core", "M2W_ImportFromChrome_IntroScreen_PrimaryTitle", fallback: "Import from Chrome")
    public static let m2WImportFromChromeURLScreenCTA = L10n.tr(
      "Core", "M2W_ImportFromChrome_URLScreen_CTA", fallback: "Continue")
    public static let m2WImportFromChromeURLScreenPrimaryTitle = L10n.tr(
      "Core", "M2W_ImportFromChrome_URLScreen_PrimaryTitle",
      fallback: "On your computer, go to the address above")
    public static let m2WImportFromDashIntroScreenBrowse = L10n.tr(
      "Core", "M2W_ImportFromDash_IntroScreen_Browse", fallback: "Browse Files")
    public static let m2WImportFromDashIntroScreenPrimaryTitle = L10n.tr(
      "Core", "M2W_ImportFromDash_IntroScreen_PrimaryTitle",
      fallback: "Import from a Dashlane backup file")
    public static let m2WImportFromDashIntroScreenSecondaryTitle = L10n.tr(
      "Core", "M2W_ImportFromDash_IntroScreen_SecondaryTitle",
      fallback:
        "Make sure your DASH file is saved in your iCloud Drive so you can access it on this device."
    )
    public static let m2WImportFromDashPasswordScreenFieldPlaceholder = L10n.tr(
      "Core", "M2W_ImportFromDash_PasswordScreen_FieldPlaceholder", fallback: "Enter password")
    public static let m2WImportFromDashPasswordScreenPrimaryTitle = L10n.tr(
      "Core", "M2W_ImportFromDash_PasswordScreen_PrimaryTitle", fallback: "Unlock your DASH file")
    public static let m2WImportFromDashPasswordScreenSecondaryTitle = L10n.tr(
      "Core", "M2W_ImportFromDash_PasswordScreen_SecondaryTitle",
      fallback: "Enter the password you created when exporting this DASH file.")
    public static let m2WImportFromDashPasswordScreenTroubleshooting = L10n.tr(
      "Core", "M2W_ImportFromDash_PasswordScreen_Troubleshooting",
      fallback:
        "This password may be different than your account Master Password. Learn more about importing DASH files."
    )
    public static let m2WImportFromDashPasswordScreenTroubleshootingLink = L10n.tr(
      "Core", "M2W_ImportFromDash_PasswordScreen_TroubleshootingLink",
      fallback: "Learn more about importing DASH files.")
    public static let m2WImportFromDashPasswordScreenUnlockImport = L10n.tr(
      "Core", "M2W_ImportFromDash_PasswordScreen_UnlockImport", fallback: "Unlock")
    public static let m2WImportFromDashPasswordScreenWrongPassword = L10n.tr(
      "Core", "M2W_ImportFromDash_PasswordScreen_WrongPassword",
      fallback: "Invalid password. Try again")
    public static let m2WImportFromKeychainIntroScreenBrowse = L10n.tr(
      "Core", "M2W_ImportFromKeychain_IntroScreen_Browse", fallback: "Browse Files")
    public static let m2WImportFromKeychainIntroScreenNotExported = L10n.tr(
      "Core", "M2W_ImportFromKeychain_IntroScreen_NotExported",
      fallback: "How do I export from Keychain?")
    public static let m2WImportFromKeychainIntroScreenPrimaryTitle = L10n.tr(
      "Core", "M2W_ImportFromKeychain_IntroScreen_PrimaryTitle", fallback: "Import from Keychain")
    public static let m2WImportFromKeychainIntroScreenSecondaryTitle = L10n.tr(
      "Core", "M2W_ImportFromKeychain_IntroScreen_SecondaryTitle",
      fallback:
        "Make sure you’ve exported your Apple Keychain content from your computer to your iCloud Drive so you can access it on this device."
    )
    public static let m2WImportFromKeychainURLScreenBrowse = L10n.tr(
      "Core", "M2W_ImportFromKeychain_URLScreen_Browse", fallback: "Browse Files")
    public static let m2WImportFromKeychainURLScreenClose = L10n.tr(
      "Core", "M2W_ImportFromKeychain_URLScreen_Close", fallback: "Cancel")
    public static let m2WImportFromKeychainURLScreenPrimaryTitle = L10n.tr(
      "Core", "M2W_ImportFromKeychain_URLScreen_PrimaryTitle",
      fallback: "How to export from Apple Keychain")
    public static let m2WImportFromKeychainURLScreenSecondaryTitle = L10n.tr(
      "Core", "M2W_ImportFromKeychain_URLScreen_SecondaryTitle",
      fallback:
        "On your computer, go to dashlane.com/keychain and follow the instructions. \n\nThen, return here and to choose the file you want to import."
    )
    public static let m2WImportGenericImportErrorScreenBrowse = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportErrorScreen_Browse", fallback: "Try another file")
    public static let m2WImportGenericImportErrorScreenGenericSecondaryTitle = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportErrorScreen_GenericSecondaryTitle",
      fallback: "An unexpected error occurred. Try again later or import a different file.")
    public static let m2WImportGenericImportErrorScreenPrimaryTitle = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportErrorScreen_PrimaryTitle", fallback: "Import failed")
    public static let m2WImportGenericImportErrorScreenSecondaryTitle = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportErrorScreen_SecondaryTitle",
      fallback:
        "We couldn’t read your file. Make sure it’s formatted correctly before trying again or import a different file."
    )
    public static let m2WImportGenericImportErrorScreenTroubleshooting = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportErrorScreen_Troubleshooting",
      fallback: "Troubleshoot common import errors in our Help Center")
    public static let m2WImportGenericImportErrorScreenTroubleshootingLink = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportErrorScreen_TroubleshootingLink",
      fallback: "Troubleshoot common import errors in our Help Center")
    public static let m2WImportGenericImportErrorScreenTryAgain = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportErrorScreen_TryAgain", fallback: "Try again")
    public static let m2WImportGenericImportScreenHeader = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportScreen_Header", fallback: "Import")
    public static let m2WImportGenericImportScreenImport = L10n.tr(
      "Core", "M2W_ImportGeneric_ImportScreen_Import", fallback: "Import selected items")
    public static func m2WImportGenericImportScreenPrimaryTitle(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "M2W_ImportGeneric_ImportScreen_PrimaryTitle", String(describing: p1), fallback: "_"
      )
    }
    public static let macOSSupportDropAnnouncementBody = L10n.tr(
      "Core", "macOSSupportDropAnnouncementBody",
      fallback:
        "You need to update to the latest version of macOS in order to continue receiving updates for this app. You can do this by opening System Preferences, then selecting Software Update."
    )
    public static let mainMenuContact = L10n.tr(
      "Core", "MainMenuContact", fallback: "Personal Info")
    public static let mainMenuHomePage = L10n.tr("Core", "MainMenuHomePage", fallback: "Home")
    public static let mainMenuIDs = L10n.tr("Core", "MainMenuIDs", fallback: "IDs")
    public static let mainMenuLoginsAndPasswords = L10n.tr(
      "Core", "MainMenuLoginsAndPasswords", fallback: "Logins")
    public static let mainMenuNotes = L10n.tr("Core", "MainMenuNotes", fallback: "Secure Notes")
    public static let mainMenuPasswordChanger = L10n.tr(
      "Core", "MainMenuPasswordChanger", fallback: "Password Changer")
    public static let mainMenuPasswordGenerator = L10n.tr(
      "Core", "MainMenuPasswordGenerator", fallback: "Password Generator")
    public static let mainMenuPayment = L10n.tr("Core", "MainMenuPayment", fallback: "Payments")
    public static let mainMenuSecrets = L10n.tr("Core", "mainMenuSecrets", fallback: "Secrets")
    public static let masterPassword = L10n.tr(
      "Core", "masterPassword", fallback: "Master Password")
    public static let masterpasswordCreationExplaination = L10n.tr(
      "Core", "masterpassword_creation_explaination",
      fallback:
        "Note: For your security, we don’t store your Master Password. Make sure you remember it!")
    public static let masterpasswordCreationPlaceholder = L10n.tr(
      "Core", "masterpassword_creation_placeholder", fallback: "Create your Master Password")
    public static let masterPasswordCreationSubtitle = L10n.tr(
      "Core", "masterPasswordCreation_subtitle", fallback: "Make sure it's strong but memorable.")
    public static let minimalisticOnboardingEmailPlaceholder = L10n.tr(
      "Core", "MinimalisticOnboarding_Email_Placeholder", fallback: "Your email address")
    public static let minimalisticOnboardingEmailSubtitle = L10n.tr(
      "Core", "MinimalisticOnboarding_Email_Subtitle",
      fallback: "We don’t need much to get the ball rolling.")
    public static let minimalisticOnboardingEmailFirstBack = L10n.tr(
      "Core", "MinimalisticOnboarding_EmailFirst_Back", fallback: "Back")
    public static let minimalisticOnboardingEmailFirstNext = L10n.tr(
      "Core", "MinimalisticOnboarding_EmailFirst_Next", fallback: "Next")
    public static let minimalisticOnboardingEmailFirstPlaceholder = L10n.tr(
      "Core", "MinimalisticOnboarding_EmailFirst_Placeholder", fallback: "Your email address")
    public static let minimalisticOnboardingEmailFirstSubtitle = L10n.tr(
      "Core", "MinimalisticOnboarding_EmailFirst_Subtitle",
      fallback: "We don’t need much to get the ball rolling.")
    public static let minimalisticOnboardingEmailFirstTitle = L10n.tr(
      "Core", "MinimalisticOnboarding_EmailFirst_Title", fallback: "Let's start with your email...")
    public static let minimalisticOnboardingMasterPasswordConfirmationPasswordsMatching = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordConfirmation_PasswordsMatching",
      fallback: "It’s a match!")
    public static let minimalisticOnboardingMasterPasswordConfirmationSubtitle = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordConfirmation_Subtitle",
      fallback: "Just making sure you're happy with it.")
    public static let minimalisticOnboardingMasterPasswordConfirmationTitle = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordConfirmation_Title",
      fallback: "Got it. Can you type it one more time?")
    public static let minimalisticOnboardingMasterPasswordSecondBack = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordSecond_Back", fallback: "Back")
    public static let minimalisticOnboardingMasterPasswordSecondConfirmationBack = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordSecond_Confirmation_Back", fallback: "Back")
    public static let minimalisticOnboardingMasterPasswordSecondConfirmationNext = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordSecond_Confirmation_Next", fallback: "Next")
    public static let minimalisticOnboardingMasterPasswordSecondConfirmationPasswordsNotMatching =
      L10n.tr(
        "Core", "MinimalisticOnboarding_MasterPasswordSecond_Confirmation_PasswordsNotMatching",
        fallback: "The passwords don’t match.")
    public static let minimalisticOnboardingMasterPasswordSecondConfirmationTitle = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordSecond_Confirmation_Title",
      fallback: "Got it. Can you type it one more time?")
    public static let minimalisticOnboardingMasterPasswordSecondNext = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordSecond_Next", fallback: "Next")
    public static let minimalisticOnboardingMasterPasswordSecondPlaceholder = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordSecond_Placeholder",
      fallback: "Create your Master Password")
    public static let minimalisticOnboardingMasterPasswordSecondTitle = L10n.tr(
      "Core", "MinimalisticOnboarding_MasterPasswordSecond_Title",
      fallback: "...and a Master Password. The one to rule them all.")
    public static let minimalisticOnboardingRecapCheckboxAccessibilityTitle = L10n.tr(
      "Core", "MinimalisticOnboarding_Recap_Checkbox_Accessibility_Title",
      fallback: "Select to agree to Terms of Service and Privacy Policy")
    public static func minimalisticOnboardingRecapCheckboxTerms(_ p1: Any, _ p2: Any, _ p3: Any)
      -> String
    {
      return L10n.tr(
        "Core", "MinimalisticOnboarding_Recap_Checkbox_Terms", String(describing: p1),
        String(describing: p2), String(describing: p3), fallback: "_")
    }
    public static let minimalisticOnboardingRecapCTA = L10n.tr(
      "Core", "MinimalisticOnboarding_Recap_CTA", fallback: "Jump in")
    public static let minimalisticOnboardingRecapSignUp = L10n.tr(
      "Core", "MinimalisticOnboarding_Recap_SignUp", fallback: "Jump in")
    public static let minimalisticOnboardingRecapTitle = L10n.tr(
      "Core", "MinimalisticOnboarding_Recap_Title", fallback: "That’s it! Here’s your recap:")
    public static let modalTryAgain = L10n.tr("Core", "modal_tryAgain", fallback: "Try again")
    public static let moreActionAccessibilityLabel = L10n.tr(
      "Core", "moreActionAccessibilityLabel", fallback: "More")
    public static let mpchangeNewMasterPassword = L10n.tr(
      "Core", "MPCHANGE_NEW_MASTER_PASSWORD", fallback: "Create your new Master Password")
    public static let newMasterPasswordConfirmationLabel = L10n.tr(
      "Core", "newMasterPasswordConfirmationLabel", fallback: "Master Password")
    public static let next = L10n.tr("Core", "Next", fallback: "Next")
    public static let noBackupSyncPremiumRenewalMsg = L10n.tr(
      "Core", "NoBackupSyncPremiumRenewal_Msg",
      fallback: "Renew this plan to have unlimited logins synced across unlimited devices.")
    public static let noBackupSyncPremiumRenewalTitle = L10n.tr(
      "Core", "NoBackupSyncPremiumRenewal_Title", fallback: "Your Premium benefits have expired")
    public static let noSecureFilesAttachedCta = L10n.tr(
      "Core", "noSecureFilesAttachedCta", fallback: "Attach a file")
    public static let notificationFrozenAccountDescription = L10n.tr(
      "Core", "notification_frozenAccount_description",
      fallback:
        "You have over 25 passwords saved. Remove passwords or upgrade to regain full access to your account."
    )
    public static let notificationFrozenAccountTitle = L10n.tr(
      "Core", "notification_frozenAccount_title", fallback: "Your account is read-only")
    public static func numberedSecureFilesAttachedCta(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "numberedSecureFilesAttachedCta", String(describing: p1), fallback: "_")
    }
    public static let onboardingV3AuthenticatorScreenDescription = L10n.tr(
      "Core", "OnboardingV3_AuthenticatorScreen_Description",
      fallback:
        "Sync your 2FA tokens across the Dashlane Authenticator and Password Manager apps, so you always have access to your accounts."
    )
    public static let onboardingV3AuthenticatorScreenTitle = L10n.tr(
      "Core", "OnboardingV3_AuthenticatorScreen_Title",
      fallback: "Create an account to finish your backup")
    public static let onboardingV3AutofillScreenDescription = L10n.tr(
      "Core", "OnboardingV3_AutofillScreen_Description",
      fallback: "Use your favorite websites and apps without typing a username or password.")
    public static let onboardingV3AutofillScreenTitle = L10n.tr(
      "Core", "OnboardingV3_AutofillScreen_Title", fallback: "End the tedious typing")
    public static let onboardingV3CTACreateAccount = L10n.tr(
      "Core", "OnboardingV3_CTA_CreateAccount", fallback: "Get started")
    public static let onboardingV3CTALogIn = L10n.tr(
      "Core", "OnboardingV3_CTA_LogIn", fallback: "Log in")
    public static let onboardingV3PrivacyScreenDescription = L10n.tr(
      "Core", "OnboardingV3_PrivacyScreen_Description",
      fallback:
        "Our patented zero-knowledge encryption means your data remains private, even from us.")
    public static let onboardingV3PrivacyScreenTitle = L10n.tr(
      "Core", "OnboardingV3_PrivacyScreen_Title", fallback: "We don’t want your data")
    public static let onboardingV3SecurityAlertsScreenDescription = L10n.tr(
      "Core", "OnboardingV3_SecurityAlertsScreen_Description",
      fallback: "Receive real-time alerts and customized action plans to stay one step ahead.")
    public static let onboardingV3SecurityAlertsScreenTitle = L10n.tr(
      "Core", "OnboardingV3_SecurityAlertsScreen_Title", fallback: "Purpose-built for privacy")
    public static let onboardingV3TrustScreenDescription = L10n.tr(
      "Core", "OnboardingV3_TrustScreen_Description",
      fallback: "Discover why we have 50,000 five-star reviews and counting.")
    public static let onboardingV3TrustScreenTitle = L10n.tr(
      "Core", "OnboardingV3_TrustScreen_Title", fallback: "The app that makes the internet easier")
    public static let onboardingV3VaultScreenDescription = L10n.tr(
      "Core", "OnboardingV3_VaultScreen_Description",
      fallback: "Store logins, IDs, and payment information in your secure vault.")
    public static let onboardingV3VaultScreenTitle = L10n.tr(
      "Core", "OnboardingV3_VaultScreen_Title", fallback: "Every login, everywhere")
    public static let oneSecureFileAttachedCta = L10n.tr(
      "Core", "oneSecureFileAttachedCta", fallback: "1 file attached")
    public static let openWebsite = L10n.tr("Core", "openWebsite", fallback: "Open website")
    public static let otpRecoveryCannotAccessCodes = L10n.tr(
      "Core", "OTP_RECOVERY_CANNOT_ACCESS_CODES", fallback: "Can’t access your app?")
    public static let otpRecoveryCannotAccessCodesDescription = L10n.tr(
      "Core", "OTP_RECOVERY_CANNOT_ACCESS_CODES_DESCRIPTION",
      fallback:
        "Use one of the 10 recovery codes that were generated when you set up 2FA. We can also send you codes by text message."
    )
    public static let otpRecoveryDisableCannotAccessCodesDescription = L10n.tr(
      "Core", "OTP_RECOVERY_DISABLE_CANNOT_ACCESS_CODES_DESCRIPTION",
      fallback: "Enter one of the recovery codes you received by text message.")
    public static let otpRecoveryDisableCannotAccessCodesTitle = L10n.tr(
      "Core", "OTP_RECOVERY_DISABLE_CANNOT_ACCESS_CODES_TITLE", fallback: "2FA recovery")
    public static let otpRecoveryDisableSendFallbackSmsMessage = L10n.tr(
      "Core", "OTP_RECOVERY_DISABLE_SEND_FALLBACK_SMS_MESSAGE",
      fallback:
        "We’ll send a text message with two recovery codes to the phone number associated with this account."
    )
    public static let otpRecoveryEnterBackupCode = L10n.tr(
      "Core", "OTP_RECOVERY_ENTER_BACKUP_CODE", fallback: "Enter a recovery code")
    public static let otpRecoveryReset2Fa = L10n.tr(
      "Core", "OTP_RECOVERY_RESET_2FA", fallback: "Receive a text message")
    public static let otpRecoverySendFallbackSmsCodeSentDescription = L10n.tr(
      "Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_CODE_SENT_DESCRIPTION",
      fallback:
        "Use the first code to log in to Dashlane. The second code removes 2FA so you can reset it."
    )
    public static let otpRecoverySendFallbackSmsCodeSentTitle = L10n.tr(
      "Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_CODE_SENT_TITLE",
      fallback: "Codes sent to your mobile phone")
    public static let otpRecoverySendFallbackSmsDescription = L10n.tr(
      "Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_DESCRIPTION",
      fallback:
        "This will send a text to the mobile phone number on this account. After logging in, you'll need to set up 2FA again."
    )
    public static let otpRecoverySendFallbackSmsNoPhoneNumber = L10n.tr(
      "Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_NO_PHONE_NUMBER",
      fallback: "There's no mobile phone number saved for this account.")
    public static let otpRecoverySendFallbackSmsTitle = L10n.tr(
      "Core", "OTP_RECOVERY_SEND_FALLBACK_SMS_TITLE", fallback: "2FA recovery")
    public static let otpRecoveryUseBackupCode = L10n.tr(
      "Core", "OTP_RECOVERY_USE_BACKUP_CODE", fallback: "Log in with recovery code")
    public static let otpRecoveryUseBackupCodeCta = L10n.tr(
      "Core", "OTP_RECOVERY_USE_BACKUP_CODE_CTA", fallback: "Log in")
    public static let otpRecoveryUseBackupCodeDescription = L10n.tr(
      "Core", "OTP_RECOVERY_USE_BACKUP_CODE_DESCRIPTION",
      fallback: "Enter one of the 10 recovery codes that were generated when you set up 2FA.")
    public static let otpRecoveryUseBackupCodeTitle = L10n.tr(
      "Core", "OTP_RECOVERY_USE_BACKUP_CODE_TITLE", fallback: "Use a recovery code")
    public static let passwordGeneratorCopyButton = L10n.tr(
      "Core", "PASSWORD_GENERATOR_COPY_BUTTON", fallback: "Copy this password")
    public static let passwordGeneratorStrengthSafelyUnguessable = L10n.tr(
      "Core", "PASSWORD_GENERATOR_STRENGTH_SAFELY_UNGUESSABLE",
      fallback: "Now that's a strong password!")
    public static let passwordGeneratorStrengthSomewhatGuessable = L10n.tr(
      "Core", "PASSWORD_GENERATOR_STRENGTH_SOMEWHAT_GUESSABLE",
      fallback: "It's just short of great.")
    public static let passwordGeneratorStrengthTooGuessable = L10n.tr(
      "Core", "PASSWORD_GENERATOR_STRENGTH_TOO_GUESSABLE",
      fallback: "Good, but we can make it stronger.")
    public static let passwordGeneratorStrengthVeryGuessabble = L10n.tr(
      "Core", "PASSWORD_GENERATOR_STRENGTH_VERY_GUESSABBLE",
      fallback: "Let's make this password stronger.")
    public static let passwordGeneratorStrengthVeryUnguessable = L10n.tr(
      "Core", "PASSWORD_GENERATOR_STRENGTH_VERY_UNGUESSABLE",
      fallback: "Ultimate password strength reached!")
    public static let passwordGeneratorUseButton = L10n.tr(
      "Core", "PASSWORD_GENERATOR_USE_BUTTON", fallback: "Use this password")
    public static let passwordTipsCloseButton = L10n.tr(
      "Core", "PasswordTips_CloseButton", fallback: "Close")
    public static let passwordTipsFirstCharactersMethodDescription = L10n.tr(
      "Core", "PasswordTips_FirstCharactersMethod_Description",
      fallback:
        "Use the main letters and numbers from a personal story. For example, *&quot;**T**he **f**irst **a**partment **I** **e**ver **l**ived **i**n **w**as **613** **G**rove **S**treet**.** **R**ent **w**as **$5**00 **p**er **m**onth&quot;*"
    )
    public static let passwordTipsFirstCharactersMethodExample = L10n.tr(
      "Core", "PasswordTips_FirstCharactersMethod_Example", fallback: "TfaIeliw613GS.Rw$5pm")
    public static let passwordTipsFirstCharactersMethodTitle = L10n.tr(
      "Core", "PasswordTips_FirstCharactersMethod_Title",
      fallback: "The main letters and numbers method")
    public static let passwordTipsMainTitle = L10n.tr(
      "Core", "PasswordTips_MainTitle", fallback: "How to create strong and memorable passwords ")
    public static let passwordTipsNavBarTitle = L10n.tr(
      "Core", "PasswordTips_NavBarTitle", fallback: "Password tips")
    public static let passwordTipsSeriesOfWordsMethodDescription = L10n.tr(
      "Core", "PasswordTips_SeriesOfWordsMethod_Description",
      fallback: "Choose a series of words that don’t make grammatical sense together.")
    public static let passwordTipsSeriesOfWordsMethodExample = L10n.tr(
      "Core", "PasswordTips_SeriesOfWordsMethod_Example", fallback: "WinterMomEverestWent")
    public static let passwordTipsSeriesOfWordsMethodTitle = L10n.tr(
      "Core", "PasswordTips_SeriesOfWordsMethod_Title", fallback: "The series of words method")
    public static let passwordTipsStoryMethodDescription = L10n.tr(
      "Core", "PasswordTips_StoryMethod_Description",
      fallback: "Create a story about an interesting person in an interesting place.")
    public static let passwordTipsStoryMethodExample = L10n.tr(
      "Core", "PasswordTips_StoryMethod_Example", fallback: "momwenttoEverestinwinter")
    public static let passwordTipsStoryMethodTitle = L10n.tr(
      "Core", "PasswordTips_StoryMethod_Title", fallback: "The story method")
    public static func payment(_ p1: Int) -> String {
      return L10n.tr("Core", "payment", p1, fallback: "%1$d payment")
    }
    public static func paymentsPlural(_ p1: Int) -> String {
      return L10n.tr("Core", "paymentsPlural", p1, fallback: "%1$d payments")
    }
    public static let paywallUpgradetag = L10n.tr("Core", "paywall_upgradetag", fallback: "Upgrade")
    public static let paywallsDWMAlerts = L10n.tr(
      "Core", "paywalls_DWM_alerts", fallback: "Receive security and breach alerts")
    public static let paywallsDwmMessage = L10n.tr(
      "Core", "paywalls_dwm_message",
      fallback:
        "Upgrade to our Premium plan to monitor and protect yourself against hacks and data breaches."
    )
    public static let paywallsDWMSecure = L10n.tr(
      "Core", "paywalls_DWM_secure", fallback: "Keep logins secured")
    public static let paywallsDWMTitle = L10n.tr(
      "Core", "paywalls_DWM_title", fallback: "Upgrade to get access to Dark Web Monitoring")
    public static let paywallsDwmTitle = L10n.tr(
      "Core", "paywalls_dwm_title", fallback: "Dark Web Monitoring is a Premium feature")
    public static let paywallsDWMWebScanning = L10n.tr(
      "Core", "paywalls_DWM_webScanning", fallback: "Stay protected with 24/7 dark web scanning")
    public static let paywallsPasswordChangerTitle = L10n.tr(
      "Core", "paywalls_passwordChanger_title", fallback: "Password Changer is a paid feature")
    public static let paywallsPasswordChangerPremiumMessage = L10n.tr(
      "Core", "paywalls_passwordChangerPremium_message",
      fallback: "Upgrade to our Premium plan to change multiple weak passwords—in just one click.")
    public static let paywallsPasswordLimitTitle = L10n.tr(
      "Core", "paywalls_passwordLimit_title", fallback: "You've reached your login limit")
    public static let paywallsPasswordLimitPremiumMessage = L10n.tr(
      "Core", "paywalls_passwordLimitPremium_message",
      fallback:
        "Upgrade to our Premium plan to get unlimited logins and sync across unlimited devices.")
    public static let paywallsPlanOptionsCTA = L10n.tr(
      "Core", "paywalls_planOptions_CTA", fallback: "See plan options")
    public static let paywallsSecureNotesTitle = L10n.tr(
      "Core", "paywalls_secureNotes_title", fallback: "Secure Notes is a paid feature")
    public static let paywallsSecureNotesPremiumMessage = L10n.tr(
      "Core", "paywalls_secureNotesPremium_message",
      fallback: "Upgrade to our Premium plan to store and share encrypted documents.")
    public static let paywallsSharingLimitMessage = L10n.tr(
      "Core", "paywalls_sharingLimit_message",
      fallback:
        "You can share up to 5 items with Dashlane Free. Upgrade to our Essentials plan to share unlimited items with multiple contacts."
    )
    public static let paywallsSharingLimitTitle = L10n.tr(
      "Core", "paywalls_sharingLimit_title", fallback: "You've reached your sharing limit")
    public static let paywallsSharingLimitPremiumMessage = L10n.tr(
      "Core", "paywalls_sharingLimitPremium_message",
      fallback:
        "You can share up to {0} items with Dashlane Free. Upgrade to our Premium plan to share unlimited items with multiple contacts."
    )
    public static let paywallsUpgradeToAdvancedCTA = L10n.tr(
      "Core", "paywalls_upgradeToAdvanced_CTA", fallback: "Upgrade to Advanced")
    public static let paywallsUpgradeToEssentialsCTA = L10n.tr(
      "Core", "paywalls_upgradeToEssentials_CTA", fallback: "Upgrade to Essentials")
    public static let paywallsUpgradeToPremiumCTA = L10n.tr(
      "Core", "paywalls_upgradeToPremium_CTA", fallback: "Upgrade to Premium")
    public static let paywallsVPNEncryption = L10n.tr(
      "Core", "paywalls_VPN_encryption",
      fallback: "Stay anonymous and protected with military-grade encryption")
    public static let paywallsVPNHotspot = L10n.tr(
      "Core", "paywalls_VPN_hotspot",
      fallback: "Stream and download with Hotspot Shield, the “world’s fastest VPN\"")
    public static let paywallsVPNLink = L10n.tr(
      "Core", "paywalls_VPN_link", fallback: "Learn more about Hotspot Shield")
    public static let paywallsVPNLocations = L10n.tr(
      "Core", "paywalls_VPN_locations",
      fallback: "Unlock worldwide content with over 115+ virtual locations")
    public static let paywallsVpnMessage = L10n.tr(
      "Core", "paywalls_vpn_message",
      fallback: "Upgrade to our Premium plan to browse privately and securely online with VPN.")
    public static let paywallsVpnTitle = L10n.tr(
      "Core", "paywalls_vpn_title", fallback: "VPN is a paid feature")
    public static let paywallsVPNTitle = L10n.tr(
      "Core", "paywalls_VPN_title", fallback: "Get access to the fastest VPN on the market")
    public static let paywallsFrozenCTARegain = L10n.tr(
      "Core", "paywallsFrozenCTARegain", fallback: "Regain Premium benefits")
    public static let paywallsFrozenFeatureDWMandVPN = L10n.tr(
      "Core", "paywallsFrozenFeatureDWMandVPN",
      fallback: "Advanced features including Dark Web Monitoring and a VPN")
    public static let paywallsFrozenFeatureStorage = L10n.tr(
      "Core", "paywallsFrozenFeatureStorage", fallback: "Unlimited passwords & passkey storage")
    public static let paywallsFrozenFeatureSync = L10n.tr(
      "Core", "paywallsFrozenFeatureSync", fallback: "Syncing across unlimited devices")
    public static let paywallsFrozenLearnMore = L10n.tr(
      "Core", "paywallsFrozenLearnMore", fallback: "Learn what read-only means")
    public static let paywallsFrozenTitleReadOnly = L10n.tr(
      "Core", "paywallsFrozenTitleReadOnly",
      fallback: "Your account is read-only: Upgrade to unlock all features")
    public static let paywallsFrozenTitleTrialEnded = L10n.tr(
      "Core", "paywallsFrozenTitleTrialEnded",
      fallback: "Your trial ended and your account is now read-only. Upgrade to Premium for:")
    public static let paywallsPasswordLimit = L10n.tr(
      "Core", "paywallsPasswordLimit",
      fallback: "Upgrade for unlimited password management across all your devices")
    public static let paywallsPasswordLimitAddManually = L10n.tr(
      "Core", "paywallsPasswordLimitAddManually",
      fallback: "Add passwords manually or import them from other password managers and browsers")
    public static let paywallsPasswordLimitOtherFeatures = L10n.tr(
      "Core", "paywallsPasswordLimitOtherFeatures",
      fallback:
        "Unlock other Premium features, including Dark Web Monitoring and a secure global VPN")
    public static let paywallsPasswordLimitSync = L10n.tr(
      "Core", "paywallsPasswordLimitSync",
      fallback:
        "Access and sync your Dashlane account across multiple smartphones, tablets, and computers at the same time"
    )
    public static func personalInfo(_ p1: Int) -> String {
      return L10n.tr("Core", "personalInfo", p1, fallback: "%1$d personal info")
    }
    public static func personalInfoPlural(_ p1: Int) -> String {
      return L10n.tr("Core", "personalInfoPlural", p1, fallback: "%1$d personal info")
    }
    public static let plansActionBarTitle = L10n.tr(
      "Core", "plans_action_bar_title", fallback: "Plan options")
    public static let plansAdvancedDescription = L10n.tr(
      "Core", "plans_advanced_description",
      fallback: "Manage unlimited passwords on all your devices, plus get advanced security tools.")
    public static let plansAdvancedTitle = L10n.tr(
      "Core", "plans_advanced_title", fallback: "Advanced")
    public static let plansCgu = L10n.tr(
      "Core", "plans_cgu",
      fallback:
        "• Annual subscriptions renew automatically. Cancel at any time.\n• Subscriptions may be changed in your iCloud account."
    )
    public static let plansCguAppleId = L10n.tr(
      "Core", "plans_cgu_apple_id",
      fallback:
        "• Annual subscriptions renew automatically. Cancel at any time.\n• Subscriptions may be changed via your Apple ID."
    )
    public static let plansCguAppleId2 = L10n.tr(
      "Core", "plans_cgu_apple_id_2",
      fallback:
        "• Annual subscriptions renew automatically. Cancel at any time.\n• Subscriptions may be changed via your Apple ID."
    )
    public static let plansCguMore = L10n.tr(
      "Core", "plans_cgu_more",
      fallback: "For more information on Dashlane, see our Privacy Policy and Terms of Service.")
    public static func plansCtaMonthly(_ p1: Any) -> String {
      return L10n.tr("Core", "plans_cta_monthly", String(describing: p1), fallback: "_for 1 month")
    }
    public static func plansCtaYearly(_ p1: Any) -> String {
      return L10n.tr("Core", "plans_cta_yearly", String(describing: p1), fallback: "_for 12 months")
    }
    public static let plansEmptystateSubtitle = L10n.tr(
      "Core", "plans_emptystate_subtitle",
      fallback: "Your purchase couldn’t be completed.\n Please try again later.")
    public static let plansEmptystateTitle = L10n.tr(
      "Core", "plans_emptystate_title", fallback: "Something went wrong")
    public static let plansEssentialsDescription = L10n.tr(
      "Core", "plans_essentials_description",
      fallback: "Get unlimited logins synced across **2 devices**.")
    public static let plansEssentialsTitle = L10n.tr(
      "Core", "plans_essentials_title", fallback: "Essentials")
    public static let plansFamilyDescription = L10n.tr(
      "Core", "plans_family_description",
      fallback:
        "Protect the whole family with **10 individual Premium accounts** for one low price.")
    public static let plansFamilyTitle = L10n.tr("Core", "plans_family_title", fallback: "Family")
    public static let plansFreeDescription = L10n.tr(
      "Core", "plans_free_description", fallback: "Free")
    public static let plansOnGoingPlan = L10n.tr(
      "Core", "plans_on_going_plan", fallback: "Your current plan")
    public static let plansPeriodicityToggleMonthly = L10n.tr(
      "Core", "plans_periodicity_toggle_monthly", fallback: "Monthly prices")
    public static let plansPeriodicityToggleYearly = L10n.tr(
      "Core", "plans_periodicity_toggle_yearly", fallback: "Annual prices")
    public static let plansPremiumDescription = L10n.tr(
      "Core", "plans_premium_description",
      fallback:
        "Get unlimited logins synced across **unlimited devices**, plus Dark Web Monitoring and VPN protection."
    )
    public static let plansPremiumTitle = L10n.tr(
      "Core", "plans_premium_title", fallback: "Premium")
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
    public static let planScreensActivateLabel = L10n.tr(
      "Core", "planScreens_activateLabel", fallback: "Activate new features")
    public static let planScreensFreeFrozenWarning = L10n.tr(
      "Core", "planScreens_freeFrozenWarning",
      fallback:
        "You are over this plan’s 25-password limit. Select a different plan for unlimited storage."
    )
    public static let planScreensFreePageFrozenWarningDescription = L10n.tr(
      "Core", "planScreens_freePage_frozenWarningDescription",
      fallback: "Remove passwords or select a different plan to regain full access to your account."
    )
    public static let planScreensFreePageFrozenWarningTitle = L10n.tr(
      "Core", "planScreens_freePage_frozenWarningTitle",
      fallback: "You're over the 25-password limit, so your account is read-only.")
    public static let planScreensFreePlanDescription = L10n.tr(
      "Core", "planScreens_freePlanDescription",
      fallback: "Simple, secure password manager on one device")
    public static let planScreensOK = L10n.tr("Core", "planScreens_OK", fallback: "OK")
    public static let planScreensPremiumFamilyAccounts = L10n.tr(
      "Core", "planScreens_premiumFamily_Accounts", fallback: "**10 individual** Premium accounts")
    public static let planScreensPremiumFamilyPlanTitle = L10n.tr(
      "Core", "planScreens_premiumFamilyPlanTitle", fallback: "Friends & Family")
    public static let planScreensPurchaseCompleteMessage = L10n.tr(
      "Core", "planScreens_purchaseCompleteMessage",
      fallback: "Your new features are ready to use on all of your devices")
    public static func planScreensPurchaseCompleteTitle(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "planScreens_purchaseCompleteTitle", String(describing: p1), fallback: "_")
    }
    public static let planScreensPurchaseErrorMessage = L10n.tr(
      "Core", "planScreens_purchaseErrorMessage",
      fallback: "Your purchase couldn't be completed. Please try again.")
    public static let planScreensPurchaseErrorTitle = L10n.tr(
      "Core", "planScreens_purchaseErrorTitle", fallback: "Oops")
    public static func planScreensPurchaseScreenTitle(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "planScreens_purchaseScreenTitle", String(describing: p1), fallback: "_")
    }
    public static let planScreensTitleFreePlan = L10n.tr(
      "Core", "planScreens_title_freePlan", fallback: "You're on a Free plan")
    public static let planScreensTitlePremium = L10n.tr(
      "Core", "planScreens_title_premium", fallback: "You’re on a Premium plan")
    public static let planScreensTitleTrialPlan = L10n.tr(
      "Core", "planScreens_title_trialPlan", fallback: "You’re on a Premium trial")
    public static let planScreensTrialTitle = L10n.tr(
      "Core", "planScreens_trialTitle", fallback: "Premium Trial")
    public static let planScreensVerifyLabel = L10n.tr(
      "Core", "planScreens_verifyLabel", fallback: "Register account upgrade")
    public static func planScreensYourPlan(_ p1: Any) -> String {
      return L10n.tr("Core", "planScreens_yourPlan", String(describing: p1), fallback: "_")
    }
    public static let premiumPasswordLimitNearlyReachedAction = L10n.tr(
      "Core", "premiumPasswordLimitNearlyReachedAction", fallback: "Upgrade to Premium")
    public static func premiumPasswordLimitNearlyReachedTitle(_ p1: Any) -> String {
      return L10n.tr(
        "Core", "premiumPasswordLimitNearlyReachedTitle", String(describing: p1), fallback: "_")
    }
    public static let premiumPasswordLimitNearlyReachedTitleSingular = L10n.tr(
      "Core", "premiumPasswordLimitNearlyReachedTitleSingular",
      fallback: "1 password left in your Free plan")
    public static let premiumPasswordLimitReachedAction = L10n.tr(
      "Core", "premiumPasswordLimitReachedAction", fallback: "Upgrade to Premium")
    public static let premiumPasswordLimitReachedTitle = L10n.tr(
      "Core", "premiumPasswordLimitReachedTitle",
      fallback: "You've reached your Free plan password limit")
    public static let recoveryKeyActivationConfirmationError = L10n.tr(
      "Core", "RECOVERY_KEY_ACTIVATION_CONFIRMATION_ERROR",
      fallback: "This doesn't look right. Please check the key and try again.")
    public static let recoveryKeyActivationFailureMessage = L10n.tr(
      "Core", "RECOVERY_KEY_ACTIVATION_FAILURE_MESSAGE",
      fallback: "An unexpected error occurred. Please try again.")
    public static let recoveryKeyLoginMessage = L10n.tr(
      "Core", "RECOVERY_KEY_LOGIN_MESSAGE",
      fallback:
        "Enter your single-use recovery key to recover access to your account and change your Master Password."
    )
    public static let recoveryKeyLoginMessageNonMp = L10n.tr(
      "Core", "RECOVERY_KEY_LOGIN_MESSAGE_NON_MP",
      fallback: "Enter your single-use recovery key to recover access to your account.")
    public static let recoveryKeyLoginProgressMessage = L10n.tr(
      "Core", "RECOVERY_KEY_LOGIN_PROGRESS_MESSAGE", fallback: "Processing your recovery request..."
    )
    public static let recoveryKeyLoginSuccessMessage = L10n.tr(
      "Core", "RECOVERY_KEY_LOGIN_SUCCESS_MESSAGE",
      fallback: "You successfully recovered access to your account!")
    public static let recoveryKeyLoginTitle = L10n.tr(
      "Core", "RECOVERY_KEY_LOGIN_TITLE", fallback: "Enter your recovery key")
    public static let recoveryKeySettingsLabel = L10n.tr(
      "Core", "RECOVERY_KEY_SETTINGS_LABEL", fallback: "Recovery key")
    public static let renewalNoticeReminderDminus1Msg = L10n.tr(
      "Core", "RenewalNoticeReminderDminus1_Msg",
      fallback:
        "Sync expires soon. Renew Premium to keep your passwords in sync across your devices and accessible everywhere. \n"
    )
    public static let renewalNoticeReminderDminus1Title = L10n.tr(
      "Core", "RenewalNoticeReminderDminus1_Title", fallback: "Alert - Sync expiring soon")
    public static func renewalNoticeReminderDminus25Msg(_ p1: Int) -> String {
      return L10n.tr(
        "Core", "RenewalNoticeReminderDminus25_Msg", p1,
        fallback: "Your Premium benefits, including sync across devices, expire in %1$d days. ")
    }
    public static let renewalNoticeReminderDminus25Title = L10n.tr(
      "Core", "RenewalNoticeReminderDminus25_Title", fallback: "Notice - Premium expires soon")
    public static func renewalNoticeReminderDminus5Msg(_ p1: Int) -> String {
      return L10n.tr(
        "Core", "RenewalNoticeReminderDminus5_Msg", p1,
        fallback: "Your Premium benefits, including sync across devices, expire in %1$d days. ")
    }
    public static let renewalNoticeReminderDminus5Title = L10n.tr(
      "Core", "RenewalNoticeReminderDminus5_Title", fallback: "Reminder - Premium expires soon")
    public static let resetMasterPasswordConfirmationDialogConfirm = L10n.tr(
      "Core", "ResetMasterPassword_ConfirmationDialog_Confirm", fallback: "Reset Master Password")
    public static let resetMasterPasswordForget = L10n.tr(
      "Core", "ResetMasterPassword_Forget", fallback: "Forgot?")
    public static let resetMasterPasswordIncorrectMasterPassword1 = L10n.tr(
      "Core", "ResetMasterPassword_IncorrectMasterPassword_1",
      fallback: "Wrong Master Password. We can help you")
    public static let resetMasterPasswordIncorrectMasterPassword2 = L10n.tr(
      "Core", "ResetMasterPassword_IncorrectMasterPassword_2",
      fallback: "reset your Master Password.")
    public static let resetMasterPasswordInterstitialCancel = L10n.tr(
      "Core", "ResetMasterPassword_Interstitial_Cancel", fallback: "Cancel")
    public static let resetMasterPasswordInterstitialCTA = L10n.tr(
      "Core", "ResetMasterPassword_Interstitial_CTA", fallback: "Enable reset")
    public static let resetMasterPasswordInterstitialDescription = L10n.tr(
      "Core", "ResetMasterPassword_Interstitial_Description",
      fallback:
        "Enable this feature to make sure you can reset your Master Password if you ever forget it.\n\nYou can always do it later in the security section of the settings."
    )
    public static let resetMasterPasswordInterstitialSkip = L10n.tr(
      "Core", "ResetMasterPassword_Interstitial_Skip", fallback: "Maybe later")
    public static let resetMasterPasswordInterstitialTitle = L10n.tr(
      "Core", "ResetMasterPassword_Interstitial_Title",
      fallback: "Reset your Master Password easily")
    public static let savePasswordMessageNewpassword = L10n.tr(
      "Core", "SAVE_PASSWORD_MESSAGE_NEWPASSWORD",
      fallback: "Would you like to save your login to Dashlane for later use?")
    public static let scanDocuments = L10n.tr("Core", "scan_documents", fallback: "Scan documents")
    public static let scannedDocumentName = L10n.tr(
      "Core", "scannedDocumentName", fallback: "Scanned_Document")
    public static func secret(_ p1: Int) -> String {
      return L10n.tr("Core", "secret", p1, fallback: "%1$d secret")
    }
    public static let secretContent = L10n.tr("Core", "secretContent", fallback: "Secret value")
    public static let secretCopyActionCTA = L10n.tr(
      "Core", "secretCopyActionCTA", fallback: "Copy value")
    public static let secretCopyActionListCTA = L10n.tr(
      "Core", "secretCopyActionListCTA", fallback: "Copy secret")
    public static let secretIDCopyActionListCTA = L10n.tr(
      "Core", "secretIDCopyActionListCTA", fallback: "Copy secret ID")
    public static func secretsPlural(_ p1: Int) -> String {
      return L10n.tr("Core", "secretsPlural", p1, fallback: "%1$d secrets")
    }
    public static let secretTitle = L10n.tr("Core", "secretTitle", fallback: "Secret name")
    public static func secureNote(_ p1: Int) -> String {
      return L10n.tr("Core", "secureNote", p1, fallback: "%1$d Secure Note")
    }
    public static func secureNotesPlural(_ p1: Int) -> String {
      return L10n.tr("Core", "secureNotesPlural", p1, fallback: "%1$d Secure Notes")
    }
    public static let securityAlertUnresolvedJustnow = L10n.tr(
      "Core", "SECURITY_ALERT_UNRESOLVED_JUSTNOW", fallback: "Just now")
    public static let securityDashboardStrengthTrivial = L10n.tr(
      "Core", "SECURITY_DASHBOARD_STRENGTH_TRIVIAL", fallback: "Extremely weak")
    public static let securityDashboardStrengthWeak = L10n.tr(
      "Core", "SECURITY_DASHBOARD_STRENGTH_WEAK", fallback: "Very weak")
    public static let selectNoneOptionLabel = L10n.tr(
      "Core", "selectNoneOptionLabel", fallback: "None")
    public static let settingsHeaderFrozenAcountLearnMore = L10n.tr(
      "Core", "settingsHeader_frozenAcount_learnMore", fallback: "Learn what read-only means")
    public static let settingsHeaderFrozenAcountWarning = L10n.tr(
      "Core", "settingsHeader_frozenAcount_warning", fallback: "Your account is read-only.")
    public static func sharingAcceptedMessage(_ p1: Any) -> String {
      return L10n.tr("Core", "sharing_accepted_message", String(describing: p1), fallback: "_")
    }
    public static let sharingPermissionsEditorDescription = L10n.tr(
      "Core", "sharing_permissions_editor_description",
      fallback: "Can share and edit all items in the collection")
    public static let sharingPermissionsManagerDescription = L10n.tr(
      "Core", "sharing_permissions_manager_description",
      fallback: "Can share, edit, and manage access to the collection and its items")
    public static let sharingPermissionsRevokeDescription = L10n.tr(
      "Core", "sharing_permissions_revoke_description",
      fallback:
        "People who have had their access revoked will no longer have access to shared collection and its items"
    )
    public static let sharingPermissionsRevokeInviteDescription = L10n.tr(
      "Core", "sharing_permissions_revoke_invite_description",
      fallback: "This wasn't accepted yet by the user")
    public static let sharingPermissionsSubtitle = L10n.tr(
      "Core", "sharing_permissions_subtitle",
      fallback: "To change permissions you need to do it in the extension using a Desktop browser.")
    public static let sharingPermissionsTitle = L10n.tr(
      "Core", "sharing_permissions_title", fallback: "Permissions")
    public static let signoutAskMasterPassword = L10n.tr(
      "Core", "signoutAskMasterPassword",
      fallback:
        "Make sure you remember your Master Password. We’ll ask for it when you log back in.")
    public static let specialOfferAnnouncementBody = L10n.tr(
      "Core", "SpecialOffer_Announcement_body", fallback: "Half-price for 1 year!")
    public static let specialOfferAnnouncementTitle = L10n.tr(
      "Core", "SpecialOffer_Announcement_title", fallback: "Special Premium Offer")
    public static let ssoBlockedError = L10n.tr(
      "Core", "ssoBlockedError",
      fallback: "Please contact your company admin to get access to this account creation.")
    public static let starterLimitationAdminSharingLimitReachedDescription = L10n.tr(
      "Core", "starterLimitation_admin_sharingLimitReached_description",
      fallback:
        "To share unlimited Collections, go to the Admin Console on the web app and upgrade your account."
    )
    public static let starterLimitationAdminSharingLimitReachedEditingDescription = L10n.tr(
      "Core", "starterLimitation_admin_sharingLimitReached_editing_description",
      fallback:
        "You can still edit and share this collection. To share unlimited Collections, go to the Admin Console on the web app and upgrade your account."
    )
    public static let starterLimitationAdminSharingLimitReachedTitle = L10n.tr(
      "Core", "starterLimitation_admin_sharingLimitReached_title",
      fallback: "You have reached the Collection sharing limit for the Starter plan.")
    public static let starterLimitationAdminSharingWarningDescription = L10n.tr(
      "Core", "starterLimitation_admin_sharingWarning_description",
      fallback:
        "To share unlimited Collections, go to the Admin Console on the Web App and upgrade your account."
    )
    public static let starterLimitationAdminSharingWarningTitle = L10n.tr(
      "Core", "starterLimitation_admin_sharingWarning_title",
      fallback: "You can only share one Collection with your Starter plan.")
    public static let starterLimitationBusinessAdminTrialSharingWarningDescription = L10n.tr(
      "Core", "starterLimitation_businessAdminTrial_sharingWarning_description",
      fallback:
        "Unlimited Collections sharing is only available for Business plans\nStarter plan customers can only share one Collection."
    )
    public static let starterLimitationBusinessAdminTrialSharingWarningTitle = L10n.tr(
      "Core", "starterLimitation_businessAdminTrial_sharingWarning_title",
      fallback: "Unlimited Collections sharing is only available for Business plans")
    public static let starterLimitationUserSharingUnavailableButton = L10n.tr(
      "Core", "starterLimitation_user_sharingUnavailable_button", fallback: "Ok, got it")
    public static let starterLimitationUserSharingUnavailableDescription = L10n.tr(
      "Core", "starterLimitation_user_sharingUnavailable_description",
      fallback:
        "Collection sharing is limited to one Collection share for Starter.\nContact your admin to upgrade and share unlimited Collections."
    )
    public static let starterLimitationUserSharingUnavailableTitle = L10n.tr(
      "Core", "starterLimitation_user_sharingUnavailable_title",
      fallback: "Collection sharing is only available for your Starter plan admin")
    public static let tabGeneratorTitle = L10n.tr(
      "Core", "tabGeneratorTitle", fallback: "Generator")
    public static let teamSpacesAllSpaces = L10n.tr(
      "Core", "TEAM_SPACES_ALL_SPACES", fallback: "All Spaces")
    public static let teamSpacesPersonalSpaceInitial = L10n.tr(
      "Core", "TEAM_SPACES_PERSONAL_SPACE_INITIAL", fallback: "P")
    public static let teamSpacesPersonalSpaceName = L10n.tr(
      "Core", "TEAM_SPACES_PERSONAL_SPACE_NAME", fallback: "Personal")
    public static let teamSpacesSharingAcceptPrompt = L10n.tr(
      "Core", "TEAM_SPACES_SHARING_ACCEPT_PROMPT", fallback: "Store in:")
    public static let teamSpacesSharingCollectionsDisabledMessageBody = L10n.tr(
      "Core", "TEAM_SPACES_SHARING_COLLECTIONS_DISABLED_MESSAGE_BODY",
      fallback:
        "Your company policy prevents sharing collections stored in Dashlane. For more information, contact your account admin."
    )
    public static let teamSpacesSharingCollectionsDisabledMessageTitle = L10n.tr(
      "Core", "TEAM_SPACES_SHARING_COLLECTIONS_DISABLED_MESSAGE_TITLE",
      fallback: "Sharing is disabled")
    public static let teamSpacesSharingDisabledMessageBody = L10n.tr(
      "Core", "TEAM_SPACES_SHARING_DISABLED_MESSAGE_BODY",
      fallback:
        "Your company policy prevents sharing items stored in Dashlane. For more information, contact your account admin."
    )
    public static let teamSpacesSharingDisabledMessageTitle = L10n.tr(
      "Core", "TEAM_SPACES_SHARING_DISABLED_MESSAGE_TITLE", fallback: "Sharing is disabled")
    public static let textInputRequired = L10n.tr(
      "Core", "TEXT_INPUT_REQUIRED", fallback: "required")
    public static let tokenNotWorkingBody = L10n.tr(
      "Core", "TOKEN_NOT_WORKING_BODY",
      fallback:
        "Verification codes are sent to your contact email address and valid for 3h, so that only you can connect your account on a new device.\n\nMake sure to check spam for the correct email address (this may be different to your Dashlane account email).\n\nIf you use Dashlane on another mobile device, you can also access the code in your app."
    )
    public static let tokenNotWorkingTitle = L10n.tr(
      "Core", "TOKEN_NOT_WORKING_TITLE", fallback: "Trouble with this code?")
    public static let tooManyTokenAttempts = L10n.tr(
      "Core", "TooManyTokenAttempts", fallback: "Too many attempts with this code.")
    public static let troubleLoggingIn = L10n.tr(
      "Core", "TROUBLE_LOGGING_IN", fallback: "Trouble logging in?")
    public static let troubleWithToken = L10n.tr(
      "Core", "TROUBLE_WITH_TOKEN", fallback: "Trouble with code?")
    public static let unlockDashlane = L10n.tr(
      "Core", "UnlockDashlane", fallback: "Unlock Dashlane")
    public static let unlockWithSSOTitle = L10n.tr(
      "Core", "unlockWithSSOTitle", fallback: "Unlock with SSO")
    public static let update = L10n.tr("Core", "update", fallback: "Update")
    public static let updateAppMessage = L10n.tr(
      "Core", "updateAppMessage",
      fallback:
        "There’s a new version available for download! Please update the app by visiting the App Store."
    )
    public static let updateAppTitle = L10n.tr(
      "Core", "updateAppTitle", fallback: "New version available")
    public static let vaultItemCreationDateLabel = L10n.tr(
      "Core", "vaultItemCreationDate_label", fallback: "Created")
    public static let vaultItemLastUsedDate = L10n.tr(
      "Core", "vaultItemLastUsedDate", fallback: "Last used")
    public static func vaultItemListSectionIndex(_ p1: Any) -> String {
      return L10n.tr("Core", "vaultItemList_SectionIndex", String(describing: p1), fallback: "_")
    }
    public static let vaultItemModificationDateLabel = L10n.tr(
      "Core", "vaultItemModificationDate_label", fallback: "Last updated")
    public static let vaultItemModificationDateByYouLabel = L10n.tr(
      "Core", "vaultItemModificationDateByYou_label", fallback: "Modified by you")
    public static let vaultItemSyncStatusPendingUpload = L10n.tr(
      "Core", "vaultItemSyncStatus_PendingUpload", fallback: "Syncing...")
    public static let zxcvbnDefaultPopupTitle = L10n.tr(
      "Core", "ZXCVBN_DEFAULT_POPUP_TITLE", fallback: "General password creation rules")
    public static let zxcvbnSuggestionDefaultCommonPhrases = L10n.tr(
      "Core", "ZXCVBN_SUGGESTION_DEFAULT_COMMON_PHRASES",
      fallback: "Avoid common phrases and sequences like \"atthebeach\" or \"12345\"")
    public static let zxcvbnSuggestionDefaultObviousSubstitutions = L10n.tr(
      "Core", "ZXCVBN_SUGGESTION_DEFAULT_OBVIOUS_SUBSTITUTIONS",
      fallback: "Avoid obvious substitutions (e.g. Pas$w0rd)")
    public static let zxcvbnSuggestionDefaultPasswordLength = L10n.tr(
      "Core", "ZXCVBN_SUGGESTION_DEFAULT_PASSWORD_LENGTH",
      fallback: "Aim for at least 10 characters")
    public static let zxcvbnSuggestionDefaultPersonalInfo = L10n.tr(
      "Core", "ZXCVBN_SUGGESTION_DEFAULT_PERSONAL_INFO",
      fallback: "Avoid including personal information like dates of birth or pet names")
    public enum KWAddressIOS {
      public static let addressFull = L10n.tr(
        "Core", "KWAddressIOS.addressFull", fallback: "Address")
      public static let addressName = L10n.tr(
        "Core", "KWAddressIOS.addressName", fallback: "Item name")
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
      public static let streetName = L10n.tr(
        "Core", "KWAddressIOS.streetName", fallback: "Street name")
      public static let streetNumber = L10n.tr(
        "Core", "KWAddressIOS.streetNumber", fallback: "Number")
      public static let zipCode = L10n.tr("Core", "KWAddressIOS.zipCode", fallback: "Zip Code")
    }
    public enum KWAuthentifiantIOS {
      public static let autoLogin = L10n.tr(
        "Core", "KWAuthentifiantIOS.autoLogin", fallback: "Auto-login")
      public static let category = L10n.tr(
        "Core", "KWAuthentifiantIOS.category", fallback: "Category")
      public static let email = L10n.tr("Core", "KWAuthentifiantIOS.email", fallback: "Email")
      public static let login = L10n.tr("Core", "KWAuthentifiantIOS.login", fallback: "Username")
      public static let note = L10n.tr("Core", "KWAuthentifiantIOS.note", fallback: "Notes")
      public static let otp = L10n.tr("Core", "KWAuthentifiantIOS.otp", fallback: "2FA token")
      public static let password = L10n.tr(
        "Core", "KWAuthentifiantIOS.password", fallback: "Password")
      public static let passwordStrength = L10n.tr(
        "Core", "KWAuthentifiantIOS.passwordStrength", fallback: "password strength")
      public static let secondaryLogin = L10n.tr(
        "Core", "KWAuthentifiantIOS.secondaryLogin", fallback: "Alternate username")
      public static let sharing = L10n.tr(
        "Core", "KWAuthentifiantIOS.sharing", fallback: "sharing with")
      public static let spaceId = L10n.tr("Core", "KWAuthentifiantIOS.spaceId", fallback: "Space")
      public static let subdomainOnly = L10n.tr(
        "Core", "KWAuthentifiantIOS.subdomainOnly", fallback: "Subdomain Only")
      public static let title = L10n.tr("Core", "KWAuthentifiantIOS.title", fallback: "Item name")
      public static let url = L10n.tr("Core", "KWAuthentifiantIOS.url", fallback: "Website")
      public static let urlStringForUI = L10n.tr(
        "Core", "KWAuthentifiantIOS.urlStringForUI", fallback: "Website")
      public enum AutoLogin {
        public static let `false` = L10n.tr(
          "Core", "KWAuthentifiantIOS.autoLogin.false", fallback: "No")
        public static let `true` = L10n.tr(
          "Core", "KWAuthentifiantIOS.autoLogin.true", fallback: "Yes")
      }
      public enum Domains {
        public static let add = L10n.tr(
          "Core", "KWAuthentifiantIOS.domains.add", fallback: "Add another website")
        public static let addedByYou = L10n.tr(
          "Core", "KWAuthentifiantIOS.domains.addedByYou", fallback: "Added by you")
        public static let automaticallyAdded = L10n.tr(
          "Core", "KWAuthentifiantIOS.domains.automaticallyAdded", fallback: "Added by Dashlane")
        public static func duplicate(_ p1: Any) -> String {
          return L10n.tr(
            "Core", "KWAuthentifiantIOS.domains.duplicate", String(describing: p1), fallback: "_")
        }
        public static let main = L10n.tr(
          "Core", "KWAuthentifiantIOS.domains.main", fallback: "Primary")
        public static let placeholder = L10n.tr(
          "Core", "KWAuthentifiantIOS.domains.placeholder", fallback: "Web address")
        public static let title = L10n.tr(
          "Core", "KWAuthentifiantIOS.domains.title", fallback: "Websites")
        public static let update = L10n.tr(
          "Core", "KWAuthentifiantIOS.domains.update", fallback: "Changes saved")
        public enum Duplicate {
          public static func title(_ p1: Any) -> String {
            return L10n.tr(
              "Core", "KWAuthentifiantIOS.domains.duplicate.title", String(describing: p1),
              fallback: "_")
          }
        }
      }
      public enum Title {
        public static let `default` = L10n.tr(
          "Core", "KWAuthentifiantIOS.title.default", fallback: "Untitled login")
        public static let placeholder = L10n.tr(
          "Core", "KWAuthentifiantIOS.title.placeholder", fallback: "My website")
      }
    }
    public enum KWBankStatementIOS {
      public static let accountNumber = L10n.tr(
        "Core", "KWBankStatementIOS.accountNumber", fallback: "Account number")
      public static let bankAccountBank = L10n.tr(
        "Core", "KWBankStatementIOS.bankAccountBank", fallback: "Bank")
      public static let bankAccountBIC = L10n.tr(
        "Core", "KWBankStatementIOS.bankAccountBIC", fallback: "BIC/SWIFT")
      public static let bankAccountClabe = L10n.tr(
        "Core", "KWBankStatementIOS.bankAccountClabe", fallback: "CLABE")
      public static let bankAccountIBAN = L10n.tr(
        "Core", "KWBankStatementIOS.bankAccountIBAN", fallback: "IBAN")
      public static let bankAccountName = L10n.tr(
        "Core", "KWBankStatementIOS.bankAccountName", fallback: "Item name")
      public static let bankAccountOwner = L10n.tr(
        "Core", "KWBankStatementIOS.bankAccountOwner", fallback: "Account holder")
      public static let bankAccountSortCode = L10n.tr(
        "Core", "KWBankStatementIOS.bankAccountSortCode", fallback: "Sort code")
      public static let localeFormat = L10n.tr(
        "Core", "KWBankStatementIOS.localeFormat", fallback: "Country")
      public static let routingNumber = L10n.tr(
        "Core", "KWBankStatementIOS.routingNumber", fallback: "Routing number")
      public enum BankAccountName {
        public static let placeholder = L10n.tr(
          "Core", "KWBankStatementIOS.bankAccountName.placeholder", fallback: "My Bank account")
      }
    }
    public enum KWCompanyIOS {
      public static let jobTitle = L10n.tr("Core", "KWCompanyIOS.jobTitle", fallback: "Job title")
      public static let name = L10n.tr("Core", "KWCompanyIOS.name", fallback: "Item name")
    }
    public enum KWDriverLicenceIOS {
      public static let deliveryDate = L10n.tr(
        "Core", "KWDriverLicenceIOS.deliveryDate", fallback: "Issue date")
      public static let fullname = L10n.tr(
        "Core", "KWDriverLicenceIOS.fullname", fallback: "Full name")
      public static let linkedIdentity = L10n.tr(
        "Core", "KWDriverLicenceIOS.linkedIdentity", fallback: "Item name")
      public static let localeFormat = L10n.tr(
        "Core", "KWDriverLicenceIOS.localeFormat", fallback: "Country")
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
      public static let fiscalNumber = L10n.tr(
        "Core", "KWFiscalStatementIOS.fiscalNumber", fallback: "Tax number")
      public static let localeFormat = L10n.tr(
        "Core", "KWFiscalStatementIOS.localeFormat", fallback: "Country")
      public static let teledeclarantNumber = L10n.tr(
        "Core", "KWFiscalStatementIOS.teledeclarantNumber", fallback: "Online number")
    }
    public enum KWIDCardIOS {
      public static let dateOfBirth = L10n.tr(
        "Core", "KWIDCardIOS.dateOfBirth", fallback: "Date of birth")
      public static let deliveryDate = L10n.tr(
        "Core", "KWIDCardIOS.deliveryDate", fallback: "Issue date")
      public static let expireDate = L10n.tr(
        "Core", "KWIDCardIOS.expireDate", fallback: "Expiry date")
      public static let fullname = L10n.tr("Core", "KWIDCardIOS.fullname", fallback: "Full name")
      public static let linkedIdentity = L10n.tr(
        "Core", "KWIDCardIOS.linkedIdentity", fallback: "Name")
      public static let localeFormat = L10n.tr(
        "Core", "KWIDCardIOS.localeFormat", fallback: "Country")
      public static let number = L10n.tr("Core", "KWIDCardIOS.number", fallback: "Number")
      public static let sex = L10n.tr("Core", "KWIDCardIOS.sex", fallback: "Gender")
      public enum Sex {
        public static let female = L10n.tr("Core", "KWIDCardIOS.sex.FEMALE", fallback: "Female")
        public static let male = L10n.tr("Core", "KWIDCardIOS.sex.MALE", fallback: "Male")
      }
    }
    public enum KWIdentityIOS {
      public static let birthDate = L10n.tr(
        "Core", "KWIdentityIOS.birthDate", fallback: "Date of birth")
      public static let birthPlace = L10n.tr(
        "Core", "KWIdentityIOS.birthPlace", fallback: "Place of birth")
      public static let firstName = L10n.tr(
        "Core", "KWIdentityIOS.firstName", fallback: "First name")
      public static let lastName = L10n.tr("Core", "KWIdentityIOS.lastName", fallback: "Last name")
      public static let middleName = L10n.tr(
        "Core", "KWIdentityIOS.middleName", fallback: "Middle name")
      public static let pseudo = L10n.tr(
        "Core", "KWIdentityIOS.pseudo", fallback: "Default username")
      public static let title = L10n.tr("Core", "KWIdentityIOS.title", fallback: "Title")
      public enum Title {
        public static let mlle = L10n.tr("Core", "KWIdentityIOS.title.MLLE", fallback: "Miss")
        public static let mme = L10n.tr("Core", "KWIdentityIOS.title.MME", fallback: "Mrs.")
        public static let mr = L10n.tr("Core", "KWIdentityIOS.title.MR", fallback: "Mr.")
        public static let ms = L10n.tr("Core", "KWIdentityIOS.title.MS", fallback: "Ms.")
        public static let mx = L10n.tr("Core", "KWIdentityIOS.title.MX", fallback: "Mx.")
        public static let noneOfThese = L10n.tr(
          "Core", "KWIdentityIOS.title.NONE_OF_THESE", fallback: "None of these")
      }
    }
    public enum KWPassportIOS {
      public static let au = L10n.tr("Core", "KWPassportIOS.AU", fallback: "Passport")
      public static let ca = L10n.tr("Core", "KWPassportIOS.CA", fallback: "Passport")
      public static let ch = L10n.tr("Core", "KWPassportIOS.CH", fallback: "Passport")
      public static let dateOfBirth = L10n.tr(
        "Core", "KWPassportIOS.dateOfBirth", fallback: "Date of birth")
      public static let deliveryDate = L10n.tr(
        "Core", "KWPassportIOS.deliveryDate", fallback: "Issue date")
      public static let deliveryPlace = L10n.tr(
        "Core", "KWPassportIOS.deliveryPlace", fallback: "Place of issue")
      public static let expireDate = L10n.tr(
        "Core", "KWPassportIOS.expireDate", fallback: "Expiry date")
      public static let fullname = L10n.tr("Core", "KWPassportIOS.fullname", fallback: "Full name")
      public static let ie = L10n.tr("Core", "KWPassportIOS.IE", fallback: "Passport")
      public static let linkedIdentity = L10n.tr(
        "Core", "KWPassportIOS.linkedIdentity", fallback: "Name")
      public static let localeFormat = L10n.tr(
        "Core", "KWPassportIOS.localeFormat", fallback: "Country")
      public static let lu = L10n.tr("Core", "KWPassportIOS.LU", fallback: "Passport")
      public static let number = L10n.tr("Core", "KWPassportIOS.number", fallback: "Number")
      public static let sex = L10n.tr("Core", "KWPassportIOS.sex", fallback: "Gender")
      public static let us = L10n.tr("Core", "KWPassportIOS.US", fallback: "Passport")
    }
    public enum KWPaymentMeanCreditCardIOS {
      public static let bank = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.bank", fallback: "Issuing bank")
      public static let cardNumber = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.cardNumber", fallback: "Number")
      public static let ccNote = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.cCNote", fallback: "Notes")
      public static let color = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.color", fallback: "Card color")
      public static let expiryDateForUi = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.expiryDateForUi", fallback: "Expiry date")
      public static let linkedBillingAddress = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.linkedBillingAddress", fallback: "Billing address")
      public static let localeFormat = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.localeFormat", fallback: "Country")
      public static let name = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.name", fallback: "Item name")
      public static let ownerName = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.ownerName", fallback: "Name on card")
      public static let securityCode = L10n.tr(
        "Core", "KWPaymentMean_creditCardIOS.securityCode", fallback: "CVV code")
      public static let type = L10n.tr("Core", "KWPaymentMean_creditCardIOS.type", fallback: "Type")
      public enum Color {
        public static let black = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.BLACK", fallback: "Black")
        public static let blue1 = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.BLUE_1", fallback: "Blue")
        public static let blue2 = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.BLUE_2", fallback: "Dark Blue")
        public static let gold = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.GOLD", fallback: "Gold")
        public static let green1 = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.GREEN_1", fallback: "Green")
        public static let green2 = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.GREEN_2", fallback: "AmEx Green")
        public static let orange = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.ORANGE", fallback: "Orange")
        public static let red = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.RED", fallback: "Red")
        public static let silver = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.SILVER", fallback: "Silver")
        public static let white = L10n.tr(
          "Core", "KWPaymentMean_creditCardIOS.color.WHITE", fallback: "White")
      }
    }
    public enum KWPersonalWebsiteIOS {
      public static let name = L10n.tr("Core", "KWPersonalWebsiteIOS.name", fallback: "Item name")
      public static let website = L10n.tr(
        "Core", "KWPersonalWebsiteIOS.website", fallback: "Website")
    }
    public enum KWPhoneIOS {
      public static let localeFormat = L10n.tr(
        "Core", "KWPhoneIOS.localeFormat", fallback: "Country code")
      public static let number = L10n.tr("Core", "KWPhoneIOS.number", fallback: "Number")
      public static let phoneName = L10n.tr("Core", "KWPhoneIOS.phoneName", fallback: "Item name")
      public static let type = L10n.tr("Core", "KWPhoneIOS.type", fallback: "Type")
      public enum `Type` {
        public static let phoneTypeFax = L10n.tr(
          "Core", "KWPhoneIOS.type.PHONE_TYPE_FAX", fallback: "Fax")
        public static let phoneTypeLandline = L10n.tr(
          "Core", "KWPhoneIOS.type.PHONE_TYPE_LANDLINE", fallback: "Home")
        public static let phoneTypeMobile = L10n.tr(
          "Core", "KWPhoneIOS.type.PHONE_TYPE_MOBILE", fallback: "Cell phone")
        public static let phoneTypeWorkFax = L10n.tr(
          "Core", "KWPhoneIOS.type.PHONE_TYPE_WORK_FAX", fallback: "Work fax")
        public static let phoneTypeWorkLandline = L10n.tr(
          "Core", "KWPhoneIOS.type.PHONE_TYPE_WORK_LANDLINE", fallback: "Work")
        public static let phoneTypeWorkMobile = L10n.tr(
          "Core", "KWPhoneIOS.type.PHONE_TYPE_WORK_MOBILE", fallback: "Work cell phone")
      }
    }
    public enum KWSecureNoteCategoriesManager {
      public static let categoryNoteAppPasswords = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_APP_PASSWORDS",
        fallback: "Application logins")
      public static let categoryNoteDatabase = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_DATABASE", fallback: "Database")
      public static let categoryNoteFinance = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_FINANCE", fallback: "Personal Finance")
      public static let categoryNoteLegal = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_LEGAL", fallback: "Legal Documents")
      public static let categoryNoteMemberships = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_MEMBERSHIPS", fallback: "Memberships")
      public static let categoryNoteOther = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_OTHER", fallback: "Other")
      public static let categoryNotePersonal = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_PERSONAL", fallback: "Personal")
      public static let categoryNoteServer = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_SERVER", fallback: "Server")
      public static let categoryNoteSoftwareLicenses = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_SOFTWARE_LICENSES",
        fallback: "Software Licenses")
      public static let categoryNoteWifiPasswords = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_WIFI_PASSWORDS",
        fallback: "Wi-Fi Passwords")
      public static let categoryNoteWork = L10n.tr(
        "Core", "KWSecureNoteCategoriesManager.CATEGORY_NOTE_WORK", fallback: "Work-Related")
    }
    public enum KWSecureNoteIOS {
      public static let category = L10n.tr("Core", "KWSecureNoteIOS.category", fallback: "Category")
      public static let colorTitle = L10n.tr(
        "Core", "KWSecureNoteIOS.colorTitle", fallback: "Color")
      public static let content = L10n.tr(
        "Core", "KWSecureNoteIOS.content", fallback: "Note content")
      public static let emptyContent = L10n.tr(
        "Core", "KWSecureNoteIOS.emptyContent", fallback: "Type note here...")
      public static let locked = L10n.tr("Core", "KWSecureNoteIOS.locked", fallback: "Locked")
      public static let protectedMessage = L10n.tr(
        "Core", "KWSecureNoteIOS.protectedMessage", fallback: "This note is password-protected")
      public static let spaceId = L10n.tr("Core", "KWSecureNoteIOS.spaceId", fallback: "Space")
      public static let title = L10n.tr("Core", "KWSecureNoteIOS.title", fallback: "Title")
      public static let type = L10n.tr("Core", "KWSecureNoteIOS.type", fallback: "Color")
      public enum MarkdownToggle {
        public static let title = L10n.tr(
          "Core", "KWSecureNoteIOS.markdownToggle.title", fallback: "Markdown content")
      }
      public enum `Type` {
        public static let blue = L10n.tr("Core", "KWSecureNoteIOS.type.BLUE", fallback: "Blue")
        public static let brown = L10n.tr("Core", "KWSecureNoteIOS.type.BROWN", fallback: "Brown")
        public static let gray = L10n.tr("Core", "KWSecureNoteIOS.type.GRAY", fallback: "Grey")
        public static let green = L10n.tr("Core", "KWSecureNoteIOS.type.GREEN", fallback: "Green")
        public static let orange = L10n.tr(
          "Core", "KWSecureNoteIOS.type.ORANGE", fallback: "Orange")
        public static let pink = L10n.tr("Core", "KWSecureNoteIOS.type.PINK", fallback: "Pink")
        public static let purple = L10n.tr(
          "Core", "KWSecureNoteIOS.type.PURPLE", fallback: "Purple")
        public static let red = L10n.tr("Core", "KWSecureNoteIOS.type.RED", fallback: "Red")
        public static let yellow = L10n.tr(
          "Core", "KWSecureNoteIOS.type.YELLOW", fallback: "Yellow")
      }
    }
    public enum KWSocialSecurityStatementIOS {
      public static let dateOfBirth = L10n.tr(
        "Core", "KWSocialSecurityStatementIOS.dateOfBirth", fallback: "Date of birth")
      public static let linkedIdentity = L10n.tr(
        "Core", "KWSocialSecurityStatementIOS.linkedIdentity", fallback: "Name")
      public static let localeFormat = L10n.tr(
        "Core", "KWSocialSecurityStatementIOS.localeFormat", fallback: "Country")
      public static let sex = L10n.tr(
        "Core", "KWSocialSecurityStatementIOS.sex", fallback: "Gender")
      public static let socialSecurityFullname = L10n.tr(
        "Core", "KWSocialSecurityStatementIOS.socialSecurityFullname", fallback: "Full name")
      public static let socialSecurityNumber = L10n.tr(
        "Core", "KWSocialSecurityStatementIOS.socialSecurityNumber", fallback: "Number")
    }
    public enum KWVault {
      public enum Search {
        public enum Collections {
          public static let title = L10n.tr(
            "Core", "KWVault.search.collections.title", fallback: "Collection")
        }
        public enum Items {
          public enum Title {
            public static let plural = L10n.tr(
              "Core", "KWVault.search.items.title.plural", fallback: "Items")
            public static let singular = L10n.tr(
              "Core", "KWVault.search.items.title.singular", fallback: "Item")
          }
        }
      }
    }
    public enum KWVaultItem {
      public enum Attachments {
        public enum CollectionLimitation {
          public enum Message {
            public static let credential = L10n.tr(
              "Core", "KWVaultItem.attachments.collectionLimitation.message.credential",
              fallback: "Files cannot be attached to Logins that are part of a Collection.")
            public static let secureNote = L10n.tr(
              "Core", "KWVaultItem.attachments.collectionLimitation.message.secureNote",
              fallback: "Files cannot be attached to Secure Notes that are part of a Collection.")
          }
        }
        public enum SharingLimitation {
          public enum Message {
            public static let credential = L10n.tr(
              "Core", "KWVaultItem.attachments.sharingLimitation.message.credential",
              fallback: "Files cannot be attached to Logins that have been shared.")
            public static let secret = L10n.tr(
              "Core", "KWVaultItem.attachments.sharingLimitation.message.secret",
              fallback: "Files cannot be attached to Secrets that have been shared.")
            public static let secureNote = L10n.tr(
              "Core", "KWVaultItem.attachments.sharingLimitation.message.secureNote",
              fallback: "Files cannot be attached to Secure Notes that have been shared.")
          }
        }
      }
      public enum Changes {
        public static let saved = L10n.tr(
          "Core", "KWVaultItem.changes.saved", fallback: "Changes saved")
      }
      public enum Collections {
        public static let add = L10n.tr(
          "Core", "KWVaultItem.collections.add", fallback: "Add a collection")
        public static let addAnother = L10n.tr(
          "Core", "KWVaultItem.collections.addAnother", fallback: "Add another collection")
        public static let create = L10n.tr(
          "Core", "KWVaultItem.collections.create", fallback: "Create")
        public static func created(_ p1: Any) -> String {
          return L10n.tr(
            "Core", "KWVaultItem.collections.created", String(describing: p1), fallback: "_")
        }
        public static func deleted(_ p1: Any) -> String {
          return L10n.tr(
            "Core", "KWVaultItem.collections.deleted", String(describing: p1), fallback: "_")
        }
        public static let toolsTitle = L10n.tr(
          "Core", "KWVaultItem.collections.toolsTitle", fallback: "Collections")
        public enum Actions {
          public static let addToACollection = L10n.tr(
            "Core", "KWVaultItem.collections.actions.addToACollection",
            fallback: "Add to a collection")
          public static let removeFromACollection = L10n.tr(
            "Core", "KWVaultItem.collections.actions.removeFromACollection",
            fallback: "Remove from a collection")
          public static let removeFromThisCollection = L10n.tr(
            "Core", "KWVaultItem.collections.actions.removeFromThisCollection",
            fallback: "Remove from collection")
        }
        public enum AttachmentsLimitation {
          public enum Message {
            public static let credential = L10n.tr(
              "Core", "KWVaultItem.collections.attachmentsLimitation.message.credential",
              fallback: "Logins with attachments cannot be added to a Collection.")
            public static let secureNote = L10n.tr(
              "Core", "KWVaultItem.collections.attachmentsLimitation.message.secureNote",
              fallback: "Secure Notes with attachments cannot be added to a Collection.")
            public static let share = L10n.tr(
              "Core", "KWVaultItem.collections.attachmentsLimitation.message.share",
              fallback: "Unable to share collections containing secure notes with attachments.")
          }
        }
        public enum DeleteAlert {
          public static let message = L10n.tr(
            "Core", "KWVaultItem.collections.deleteAlert.message",
            fallback:
              "This will permanently delete the collection from your Vault. We won't delete any of the items inside this collection."
          )
          public static let title = L10n.tr(
            "Core", "KWVaultItem.collections.deleteAlert.title", fallback: "Delete collection?")
          public enum Error {
            public enum Shared {
              public static let message = L10n.tr(
                "Core", "KWVaultItem.collections.deleteAlert.error.shared.message",
                fallback:
                  "You are unable to delete this Shared Collection since it is shared with other users and groups. Please revoke access from the other users and groups before deleting the Shared Collection."
              )
              public static let title = L10n.tr(
                "Core", "KWVaultItem.collections.deleteAlert.error.shared.title",
                fallback: "Can't delete Shared Collection")
            }
          }
        }
        public enum Detail {
          public enum EmptyState {
            public static let message = L10n.tr(
              "Core", "KWVaultItem.collections.detail.emptyState.message",
              fallback: "This collection doesn't have any items yet.")
          }
        }
        public enum ItemsCount {
          public static func plural(_ p1: Any) -> String {
            return L10n.tr(
              "Core", "KWVaultItem.collections.itemsCount.plural", String(describing: p1),
              fallback: "_")
          }
          public static func singular(_ p1: Any) -> String {
            return L10n.tr(
              "Core", "KWVaultItem.collections.itemsCount.singular", String(describing: p1),
              fallback: "_")
          }
        }
        public enum List {
          public enum EmptyState {
            public static let button = L10n.tr(
              "Core", "KWVaultItem.collections.list.emptyState.button",
              fallback: "Create collection")
            public static let message = L10n.tr(
              "Core", "KWVaultItem.collections.list.emptyState.message",
              fallback: "Create your first collection to start organizing the items in your vault.")
          }
        }
        public enum Naming {
          public enum Addition {
            public static let title = L10n.tr(
              "Core", "KWVaultItem.collections.naming.addition.title",
              fallback: "Create new collection")
          }
          public enum Field {
            public static let placeholder = L10n.tr(
              "Core", "KWVaultItem.collections.naming.field.placeholder",
              fallback: "Add collection name...")
            public static let title = L10n.tr(
              "Core", "KWVaultItem.collections.naming.field.title", fallback: "Collection name")
          }
          public enum ForcedPersonalSpace {
            public static let message = L10n.tr(
              "Core", "KWVaultItem.collections.naming.forcedPersonalSpace.message",
              fallback: "All items in this collection belong to the Personal Space.")
          }
          public enum ForcedSpace {
            public static func message(_ p1: Any) -> String {
              return L10n.tr(
                "Core", "KWVaultItem.collections.naming.forcedSpace.message",
                String(describing: p1), fallback: "_")
            }
          }
          public enum SameName {
            public static let message = L10n.tr(
              "Core", "KWVaultItem.collections.naming.sameName.message",
              fallback: "A collection with this name already exists. Please enter a different name."
            )
          }
          public enum SameNameInSpace {
            public static let message = L10n.tr(
              "Core", "KWVaultItem.collections.naming.sameNameInSpace.message",
              fallback:
                "A collection with this name already exists in this Space. Please enter a different name."
            )
          }
        }
        public enum Removal {
          public static let title = L10n.tr(
            "Core", "KWVaultItem.collections.removal.title", fallback: "Remove from a collection")
          public enum EmptyState {
            public static let message = L10n.tr(
              "Core", "KWVaultItem.collections.removal.emptyState.message",
              fallback: "This item doesn't belong to any collection.")
          }
        }
        public enum Sharing {
          public enum AdditionAlert {
            public static let button = L10n.tr(
              "Core", "KWVaultItem.collections.sharing.additionAlert.button",
              fallback: "Add to a collection")
            public static func message(_ p1: Any) -> String {
              return L10n.tr(
                "Core", "KWVaultItem.collections.sharing.additionAlert.message",
                String(describing: p1), fallback: "_")
            }
            public static func title(_ p1: Any) -> String {
              return L10n.tr(
                "Core", "KWVaultItem.collections.sharing.additionAlert.title",
                String(describing: p1), fallback: "_")
            }
            public enum Message {
              public static func plural(_ p1: Any) -> String {
                return L10n.tr(
                  "Core", "KWVaultItem.collections.sharing.additionAlert.message.plural",
                  String(describing: p1), fallback: "_")
              }
            }
            public enum Title {
              public static let plural = L10n.tr(
                "Core", "KWVaultItem.collections.sharing.additionAlert.title.plural",
                fallback: "Add items to a shared Collection")
            }
          }
          public enum LimitedRights {
            public enum Addition {
              public enum Error {
                public static let message = L10n.tr(
                  "Core", "KWVaultItem.collections.sharing.limitedRights.addition.error.message",
                  fallback:
                    "You only have limited rights permissions to this item. Adding this item to a shared Collection requires full rights on the item."
                )
                public static let title = L10n.tr(
                  "Core", "KWVaultItem.collections.sharing.limitedRights.addition.error.title",
                  fallback: "Insufficient Permissions")
              }
            }
          }
          public enum Roles {
            public enum Editor {
              public static let title = L10n.tr(
                "Core", "KWVaultItem.collections.sharing.roles.editor.title", fallback: "Editor")
            }
            public enum Manager {
              public static let title = L10n.tr(
                "Core", "KWVaultItem.collections.sharing.roles.manager.title", fallback: "Manager")
            }
          }
        }
        public enum Title {
          public static let plural = L10n.tr(
            "Core", "KWVaultItem.collections.title.plural", fallback: "Collections")
          public static let singular = L10n.tr(
            "Core", "KWVaultItem.collections.title.singular", fallback: "Collection")
          public enum BusinessSpace {
            public static func plural(_ p1: Any) -> String {
              return L10n.tr(
                "Core", "KWVaultItem.collections.title.businessSpace.plural",
                String(describing: p1), fallback: "_")
            }
            public static func singular(_ p1: Any) -> String {
              return L10n.tr(
                "Core", "KWVaultItem.collections.title.businessSpace.singular",
                String(describing: p1), fallback: "_")
            }
          }
          public enum PersonalSpace {
            public static let plural = L10n.tr(
              "Core", "KWVaultItem.collections.title.personalSpace.plural",
              fallback: "Personal collections")
            public static let singular = L10n.tr(
              "Core", "KWVaultItem.collections.title.personalSpace.singular",
              fallback: "Personal collection")
          }
        }
        public enum Toast {
          public static func itemRemoved(_ p1: Any) -> String {
            return L10n.tr(
              "Core", "KWVaultItem.collections.toast.itemRemoved", String(describing: p1),
              fallback: "_")
          }
          public enum ItemAdded {
            public static func plural(_ p1: Any, _ p2: Any) -> String {
              return L10n.tr(
                "Core", "KWVaultItem.collections.toast.itemAdded.plural", String(describing: p1),
                String(describing: p2), fallback: "_")
            }
            public static func singular(_ p1: Any, _ p2: Any) -> String {
              return L10n.tr(
                "Core", "KWVaultItem.collections.toast.itemAdded.singular", String(describing: p1),
                String(describing: p2), fallback: "_")
            }
          }
        }
      }
      public enum Infobox {
        public enum AttachmentsLimitation {
          public enum Message {
            public static let credential = L10n.tr(
              "Core", "KWVaultItem.infobox.attachmentsLimitation.message.credential",
              fallback: "Logins with attachments cannot be shared or added to a Collection.")
            public static let secureNote = L10n.tr(
              "Core", "KWVaultItem.infobox.attachmentsLimitation.message.secureNote",
              fallback: "Secure Notes with attachments cannot be shared or added to a Collection.")
          }
        }
        public enum CollectionSharingLimitation {
          public enum Message {
            public static let credential = L10n.tr(
              "Core", "KWVaultItem.infobox.collectionSharingLimitation.message.credential",
              fallback:
                "Attachments cannot be added to Logins that have been shared or added to a Collection."
            )
            public static let secret = L10n.tr(
              "Core", "KWVaultItem.infobox.collectionSharingLimitation.message.secret",
              fallback: "Attachments cannot be added to Secrets that have been shared.")
            public static let secureNote = L10n.tr(
              "Core", "KWVaultItem.infobox.collectionSharingLimitation.message.secureNote",
              fallback:
                "Attachments cannot be added to Secure Notes that have been shared or added to a Collection."
            )
          }
        }
        public enum LimitedRightsLimitation {
          public static let message = L10n.tr(
            "Core", "KWVaultItem.infobox.limitedRightsLimitation.message",
            fallback: "You can only view the content or remove it from your vault.")
          public static let title = L10n.tr(
            "Core", "KWVaultItem.infobox.limitedRightsLimitation.title",
            fallback: "This item is shared with limited rights")
        }
      }
      public enum Organization {
        public enum Section {
          public static let title = L10n.tr(
            "Core", "KWVaultItem.organization.section.title", fallback: "Item organization")
        }
      }
      public enum Preferences {
        public enum Section {
          public static let title = L10n.tr(
            "Core", "KWVaultItem.preferences.section.title", fallback: "Preferences")
        }
        public enum SecureToggle {
          public static let message = L10n.tr(
            "Core", "KWVaultItem.preferences.secureToggle.message",
            fallback: "Ask for your Biometrics or Master Password to unlock this item.")
          public static let title = L10n.tr(
            "Core", "KWVaultItem.preferences.secureToggle.title", fallback: "Lock item")
        }
      }
      public enum Sharing {
        public enum AttachmentsLimitation {
          public enum Message {
            public static let credential = L10n.tr(
              "Core", "KWVaultItem.sharing.attachmentsLimitation.message.credential",
              fallback: "Login with attachments cannot be shared.")
            public static let secureNote = L10n.tr(
              "Core", "KWVaultItem.sharing.attachmentsLimitation.message.secureNote",
              fallback: "Secure Notes with attachments cannot be shared.")
          }
        }
        public enum Deletion {
          public enum Error {
            public static let message = L10n.tr(
              "Core", "KWVaultItem.sharing.deletion.error.message",
              fallback:
                "You can't delete this item because you have shared it with a group or a Collection."
            )
          }
        }
        public enum LimitedRights {
          public static let message = L10n.tr(
            "Core", "KWVaultItem.sharing.limitedRights.message",
            fallback:
              "This item is shared with limited rights. You can only view the content or remove it from your vault."
          )
        }
        public enum Section {
          public static let title = L10n.tr(
            "Core", "KWVaultItem.sharing.section.title", fallback: "Shared access")
        }
      }
      public enum UnsavedChanges {
        public static let keepEditing = L10n.tr(
          "Core", "KWVaultItem.unsavedChanges.keepEditing", fallback: "Keep editing")
        public static let leave = L10n.tr(
          "Core", "KWVaultItem.unsavedChanges.leave", fallback: "Leave page")
        public static let message = L10n.tr(
          "Core", "KWVaultItem.unsavedChanges.message",
          fallback: "If you leave this page before selecting Save, your changes will be discarded.")
        public static let title = L10n.tr(
          "Core", "KWVaultItem.unsavedChanges.title", fallback: "You have unsaved changes")
      }
    }
    public enum Mpless {
      public enum D2d {
        public enum Trusted {
          public static let cancelAlertCancelCta = L10n.tr(
            "Core", "Mpless.d2d.trusted.cancel_alert_cancel_cta", fallback: "Dismiss")
          public static let cancelAlertCta = L10n.tr(
            "Core", "Mpless.d2d.trusted.cancel_alert_cta", fallback: "Yes, cancel")
          public static let cancelAlertMessage = L10n.tr(
            "Core", "Mpless.d2d.trusted.cancel_alert_message",
            fallback: "If you cancel, you will have to start the new device setup again.")
          public static let cancelAlertTitle = L10n.tr(
            "Core", "Mpless.d2d.trusted.cancel_alert_title", fallback: "Cancel login?")
        }
        public enum Universal {
          public static let untrustedIntroCta = L10n.tr(
            "Core", "Mpless.d2d.universal.untrusted_intro_cta",
            fallback: "Can't take the challenge?")
          public static let untrustedIntroInfoboxTitle = L10n.tr(
            "Core", "Mpless.d2d.universal.untrusted_intro_infobox_title",
            fallback: "Always use the Dashlane browser extension or mobile app to add a new device."
          )
          public static let untrustedIntroMessage1 = L10n.tr(
            "Core", "Mpless.d2d.universal.untrusted_intro_message1",
            fallback: "Open Dashlane on one of your logged in devices")
          public static let untrustedIntroMessage2 = L10n.tr(
            "Core", "Mpless.d2d.universal.untrusted_intro_message2",
            fallback: "Go to Dashlane settings and select **Add new device**")
          public static let untrustedIntroMessage3 = L10n.tr(
            "Core", "Mpless.d2d.universal.untrusted_intro_message3",
            fallback:
              "Validate the new device request, then a security challenge will be displayed here")
          public static let untrustedIntroTitle = L10n.tr(
            "Core", "Mpless.d2d.universal.untrusted_intro_title",
            fallback: "Log in to Dashlane with a security challenge")
          public enum Untrusted {
            public static let loadingAccount = L10n.tr(
              "Core", "Mpless.d2d.universal.untrusted.loading_account",
              fallback: "Loading your account...")
            public static let loadingChallenge = L10n.tr(
              "Core", "Mpless.d2d.universal.untrusted.loading_challenge",
              fallback: "Loading challenge...")
            public static let passphraseCancelCta = L10n.tr(
              "Core", "Mpless.d2d.universal.untrusted.passphrase_cancel_cta", fallback: "Cancel")
            public static let passphraseMessage = L10n.tr(
              "Core", "Mpless.d2d.universal.untrusted.passphrase_message",
              fallback: "Use this word list to complete the challenge on your logged in device.")
            public static let passphraseTitle = L10n.tr(
              "Core", "Mpless.d2d.universal.untrusted.passphrase_title",
              fallback: "Identify missing word")
          }
        }
        public enum Untrusted {
          public static let chooseTypeComputerCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.choose_type_computer_cta", fallback: "Computer")
          public static let chooseTypeMobileCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.choose_type_mobile_cta", fallback: "Mobile")
          public static let chooseTypeNoDeviceCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.choose_type_no_device_cta",
            fallback: "Don’t have a logged in device?")
          public static let chooseTypeTitle = L10n.tr(
            "Core", "Mpless.d2d.untrusted.choose_type_title",
            fallback: "Use a logged in device to access Dashlane")
          public static let genericErrorCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.generic_error_cta", fallback: "Go to login")
          public static let genericErrorMessage = L10n.tr(
            "Core", "Mpless.d2d.untrusted.generic_error_message",
            fallback: "Please retry login or visit our Help Center.")
          public static let genericErrorSupportCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.generic_error_support_cta", fallback: "Contact Support")
          public static let genericErrorTitle = L10n.tr(
            "Core", "Mpless.d2d.untrusted.generic_error_title",
            fallback: "Error loading your account")
          public static let otherLoginOptionsCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.other_login_options_cta",
            fallback: "Log in with another method")
          public static let pinAlertCancelCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.pin_alert_cancel_cta", fallback: "Yes, cancel")
          public static let pinAlertDismissCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.pin_alert_dismiss_cta", fallback: "Dismiss")
          public static let pinAlertMessage = L10n.tr(
            "Core", "Mpless.d2d.untrusted.pin_alert_message",
            fallback: "You will be returned to login screen and would need to restart login process"
          )
          public static let pinAlertTitle = L10n.tr(
            "Core", "Mpless.d2d.untrusted.pin_alert_title", fallback: "Cancel login?")
          public static let recoveryIntroMessage = L10n.tr(
            "Core", "Mpless.d2d.untrusted.recovery_intro_message",
            fallback:
              "If you don’t have a logged in device available, you can use your recovery key to log in to Dashlane.\n\nBefore you start the recovery process, make sure you have your single-use recovery key. Depending on your security settings, additional verification may be required to complete the recovery process."
          )
          public static let recoveryIntroPrimaryCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.recovery_intro_primary_cta", fallback: "Start recovery")
          public static let recoveryIntroSecondaryCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.recovery_intro_secondary_cta", fallback: "Lost your key?")
          public static let recoveryIntroTitle = L10n.tr(
            "Core", "Mpless.d2d.untrusted.recovery_intro_title",
            fallback: "Use your recovery key to log in to Dashlane")
          public static let resetIntroMessage = L10n.tr(
            "Core", "Mpless.d2d.untrusted.reset_intro_message",
            fallback:
              "You need a logged in device or your recovery key to access your account on this device. If none of these methods are available, you can start the process of resetting your account."
          )
          public static let resetIntroPrimaryCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.reset_intro_primary_cta", fallback: "Reset account")
          public static let resetIntroSecondaryCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.reset_intro_secondary_cta", fallback: "Learn more")
          public static let resetIntroTitle = L10n.tr(
            "Core", "Mpless.d2d.untrusted.reset_intro_title",
            fallback: "If you don’t have a recovery method available")
          public static let sheetSecurityChallengeCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.sheet_security_challenge_cta",
            fallback: "Take security challenge")
          public static let sheetTitle = L10n.tr(
            "Core", "Mpless.d2d.untrusted.sheet_title", fallback: "How do you want to log in?")
          public static let timeoutErrorCta = L10n.tr(
            "Core", "Mpless.d2d.untrusted.timeout_error_cta", fallback: "Go to login")
          public static let timeoutErrorMessage = L10n.tr(
            "Core", "Mpless.d2d.untrusted.timeout_error_message",
            fallback: "Please attempt to log in again from new device.")
          public static let timeoutErrorTitle = L10n.tr(
            "Core", "Mpless.d2d.untrusted.timeout_error_title",
            fallback: "New device request has timed out")
        }
      }
    }
    public enum NewMasterPassword {
      public static let skipMasterPasswordButton = L10n.tr(
        "Core", "NewMasterPassword.skipMasterPasswordButton",
        fallback: "Create passwordless account")
      public static let title = L10n.tr(
        "Core", "NewMasterPassword.title", fallback: "...and a Master Password")
    }
    public enum Passkey {
      public static let title = L10n.tr("Core", "Passkey.title", fallback: "Passkey")
    }
    public enum PasswordlessAccountCreation {
      public enum Biometry {
        public static func message(_ p1: Any) -> String {
          return L10n.tr(
            "Core", "PasswordlessAccountCreation.Biometry.message", String(describing: p1),
            fallback: "_")
        }
        public static let navigationTitle = L10n.tr(
          "Core", "PasswordlessAccountCreation.Biometry.navigationTitle",
          fallback: "Set up biometrics")
        public static let skipButton = L10n.tr(
          "Core", "PasswordlessAccountCreation.Biometry.skipButton", fallback: "Skip for now")
        public static func title(_ p1: Any) -> String {
          return L10n.tr(
            "Core", "PasswordlessAccountCreation.Biometry.title", String(describing: p1),
            fallback: "_")
        }
        public static func useButton(_ p1: Any) -> String {
          return L10n.tr(
            "Core", "PasswordlessAccountCreation.Biometry.useButton", String(describing: p1),
            fallback: "_")
        }
      }
    }
    public enum Secrets {
      public static let protectedMessage = L10n.tr(
        "Core", "Secrets.protectedMessage", fallback: "This secret is password-protected")
      public enum Sharing {
        public static let ctaLabel = L10n.tr(
          "Core", "Secrets.sharing.ctaLabel", fallback: "Share secret")
        public static let limitedRightsMessage = L10n.tr(
          "Core", "Secrets.sharing.limitedRightsMessage",
          fallback: "You have limited rights to this secret.\n\nYou cannot edit or share it.")
      }
    }
    public enum Unlock {
      public enum PasswordlessRecovery {
        public static let alternativeMessage = L10n.tr(
          "Core", "Unlock.PasswordlessRecovery.alternativeMessage",
          fallback:
            "If none of these methods are available to you, visit the Help Center to learn how to reset your account."
        )
        public static let contactUserSupportButton = L10n.tr(
          "Core", "Unlock.PasswordlessRecovery.contactUserSupportButton",
          fallback: "Visit our Help Center.")
        public static let goToLoginButton = L10n.tr(
          "Core", "Unlock.PasswordlessRecovery.goToLoginButton", fallback: "Go to login")
        public static let message = L10n.tr(
          "Core", "Unlock.PasswordlessRecovery.message",
          fallback:
            "Re-authenticate this device using another logged-in device or your recovery key. Then you can reset your PIN."
        )
        public static let title = L10n.tr(
          "Core", "Unlock.PasswordlessRecovery.title", fallback: "Forgot your PIN?")
      }
      public enum Pincode {
        public static let forgotButton = L10n.tr(
          "Core", "Unlock.Pincode.forgotButton", fallback: "Forgot your PIN?")
      }
    }
    public enum Announcement {
      public enum UpdateSystem {
        public static let message = L10n.tr(
          "Core", "announcement.updateSystem.message",
          fallback: "You can check for a software update in your device settings.")
        public static let notNow = L10n.tr(
          "Core", "announcement.updateSystem.notNow", fallback: "Dismiss")
        public enum Ios {
          public static let openSettings = L10n.tr(
            "Core", "announcement.updateSystem.iOS.openSettings", fallback: "Go to settings")
          public static let title = L10n.tr(
            "Core", "announcement.updateSystem.iOS.title",
            fallback: "Update your iOS to use the latest version of Dashlane")
        }
        public enum MacOS {
          public static let openSettings = L10n.tr(
            "Core", "announcement.updateSystem.macOS.openSettings",
            fallback: "Go to System Preferences")
          public static let title = L10n.tr(
            "Core", "announcement.updateSystem.macOS.title",
            fallback: "Update your macOS to use the latest version of Dashlane")
        }
      }
    }
    public enum AntiPhishing {
      public enum Actions {
        public static let doNotTrust = L10n.tr(
          "Core", "antiPhishing.actions.doNotTrust", fallback: "Don’t trust")
        public static let trust = L10n.tr(
          "Core", "antiPhishing.actions.trust", fallback: "Trust and fill")
      }
      public enum Intro {
        public static let description = L10n.tr(
          "Core", "antiPhishing.intro.description",
          fallback:
            "Please check the web address before filling your login details. If you trust this website, it will be added as a linked website."
        )
        public static let title = L10n.tr(
          "Core", "antiPhishing.intro.title", fallback: "Do you trust this website?")
      }
      public enum Websites {
        public static let current = L10n.tr(
          "Core", "antiPhishing.websites.current", fallback: "Current URL")
        public static let trusted = L10n.tr(
          "Core", "antiPhishing.websites.trusted", fallback: "Trusted URL")
      }
    }
    public enum Login {
      public static let deactivatedUserErrorTitle = L10n.tr(
        "Core", "login.deactivated_user_error_title",
        fallback:
          "We're sorry, this account is no longer available. Please refer to the Help Center article for more information."
      )
      public enum Team {
        public static let genericError = L10n.tr(
          "Core", "login.team.genericError",
          fallback:
            "An unexpected error occurred. Please reach out to your plan admin for more info.")
      }
    }
  }
  public enum CoreContext {
    public static let cancel = L10n.tr(
      "Core-context", "Cancel", fallback: "⁣⁢Cancel⁡⁠⁯‍⁯؜؜⁮⁯؜⁡⁮؜‍؜⁪⁠⁬⁮⁣⁤")
    public static let next = L10n.tr(
      "Core-context", "Next", fallback: "⁣⁢Next⁫⁫‌⁮⁮⁫⁠‍⁯⁬⁠⁪⁪⁫⁯⁫⁭⁮‌‍‌⁮⁮⁠⁭⁡⁮⁡⁣⁤")
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
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String)
    -> String
  {
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
