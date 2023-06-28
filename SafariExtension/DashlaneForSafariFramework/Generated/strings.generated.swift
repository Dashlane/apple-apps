import Foundation

internal enum L10n {
  internal enum InfoPlist {
        internal static let nsCameraUsageDescription = L10n.tr("InfoPlist", "NSCameraUsageDescription", fallback: "Enable camera access to send information to Dashlane ")
        internal static let nsContactsUsageDescription = L10n.tr("InfoPlist", "NSContactsUsageDescription", fallback: "Easily send sharing requests to contacts")
        internal static let nsFaceIDUsageDescription = L10n.tr("InfoPlist", "NSFaceIDUsageDescription", fallback: "Face ID can be used to unlock your Dashlane account.")
        internal static let nsHumanReadableDescription = L10n.tr("InfoPlist", "NSHumanReadableDescription", fallback: "Password Manager and Secure Digital Wallet")
        internal static let nsPhotoLibraryAddUsageDescription = L10n.tr("InfoPlist", "NSPhotoLibraryAddUsageDescription", fallback: "Enable access to save photos in Dashlane")
        internal static let nsUserTrackingUsageDescription = L10n.tr("InfoPlist", "NSUserTrackingUsageDescription", fallback: "Your data will be used to measure advertising efficiency")
  }
  internal enum Localizable {
        internal static let _02Settings = L10n.tr("Localizable", "02Settings", fallback: "Security")
        internal static let _2faSetupFailure = L10n.tr("Localizable", "2faSetup_failure", fallback: "We couldn’t set up 2FA for Amazon")
        internal static func _2faSetupFailureFor(_ p1: Any) -> String {
      return L10n.tr("Localizable", "2faSetup_failure_for", String(describing: p1), fallback: "_")
    }
        internal static let _2faSetupIntroExplainationLeadSection1 = L10n.tr("Localizable", "2faSetup_Intro_explaination_lead_section1", fallback: "1.")
        internal static let _2faSetupIntroHelpStep1 = L10n.tr("Localizable", "2faSetup_Intro_Help_step1", fallback: "Go to the security settings of the 3rd-party site or app you want to add")
        internal static let _2faSetupIntroHelpStep2 = L10n.tr("Localizable", "2faSetup_Intro_Help_step2", fallback: "Turn on 2FA (some sites may call this 2-step verification)")
        internal static let _2faSetupIntroHelpStep3 = L10n.tr("Localizable", "2faSetup_Intro_Help_step3", fallback: "Scan the QR code or enter the setup code they provide")
        internal static let _2faSetupIntroLearnMore = L10n.tr("Localizable", "2faSetup_Intro_learnMore", fallback: "Learn more about 2FA")
        internal static let _2faSetupIntroScanQRCode = L10n.tr("Localizable", "2faSetup_Intro_scanQRCode", fallback: "Scan QR Code")
        internal static let _2faSetupIntroSetupWithCode = L10n.tr("Localizable", "2faSetup_Intro_setupWithCode", fallback: "Enter setup code")
        internal static let _2faSetupIntroSubtitle = L10n.tr("Localizable", "2faSetup_Intro_subtitle", fallback: "Setting up 2-factor authentication (2FA) adds an extra layer of protection to your account.")
        internal static func _2faSetupIntroTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "2faSetup_Intro_title", String(describing: p1), fallback: "_")
    }
        internal static func _2faSetupScanPrompt(_ p1: Any) -> String {
      return L10n.tr("Localizable", "2faSetup_scan_prompt", String(describing: p1), fallback: "_")
    }
        internal static let _2fasetupSuccessSubtitle = L10n.tr("Localizable", "2fasetup_success_subtitle", fallback: "We’ll generate the authentication codes you need to log in.")
        internal static func _2faSetupSuccessTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "2faSetup_success_title", String(describing: p1), fallback: "_")
    }
        internal static func _2faSetupTokenPrompt(_ p1: Any) -> String {
      return L10n.tr("Localizable", "2faSetup_token_prompt", String(describing: p1), fallback: "_")
    }
        internal static func accessibilityActionCenterSeeAll(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ACCESSIBILITY_ACTION_CENTER_SEE_ALL", String(describing: p1), fallback: "_")
    }
        internal static func accessibilityDwmEmailDelete(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ACCESSIBILITY_DWM_EMAIL_DELETE", String(describing: p1), fallback: "_")
    }
        internal static let accessibilityDwmEmailNew = L10n.tr("Localizable", "ACCESSIBILITY_DWM_EMAIL_NEW", fallback: "Monitor new email")
        internal static let accessibilityToolsBadgeNew = L10n.tr("Localizable", "Accessibility_Tools_Badge_New", fallback: "New feature")
        internal static let accessibilityToolsBadgeUpgrade = L10n.tr("Localizable", "Accessibility_Tools_Badge_Upgrade", fallback: "Paid feature")
        internal static let accessibilityViewAlerts = L10n.tr("Localizable", "ACCESSIBILITY_VIEW_ALERTS", fallback: "View security alerts")
        internal static let accessibilityAddToVault = L10n.tr("Localizable", "accessibilityAddToVault", fallback: "Add item")
        internal static func accessibilityNewCredentialListCount(_ p1: Any) -> String {
      return L10n.tr("Localizable", "accessibilityNewCredentialListCount", String(describing: p1), fallback: "_")
    }
        internal static let accessibilityOnboardingChecklistDismissed = L10n.tr("Localizable", "accessibilityOnboardingChecklistDismissed", fallback: "Onboarding checklist has been dismissed.")
        internal static let accessibilitySecureNoteLock = L10n.tr("Localizable", "accessibilitySecureNoteLock", fallback: "Lock")
        internal static let accessibilitySecureNoteUnlock = L10n.tr("Localizable", "accessibilitySecureNoteUnlock", fallback: "Unlock")
        internal static func accessibilityTraitTab(_ p1: Any) -> String {
      return L10n.tr("Localizable", "accessibilityTraitTab", String(describing: p1), fallback: "_")
    }
        internal static func accessibilityVaultFilterItemSelected(_ p1: Any) -> String {
      return L10n.tr("Localizable", "accessibilityVaultFilterItemSelected", String(describing: p1), fallback: "_")
    }
        internal static let accessibilityVaultSearchViewNoResult = L10n.tr("Localizable", "accessibilityVaultSearchViewNoResult", fallback: "No items found")
        internal static func accessibilityVaultSearchViewResultCount(_ p1: Any) -> String {
      return L10n.tr("Localizable", "accessibilityVaultSearchViewResultCount", String(describing: p1), fallback: "_")
    }
        internal static let accountCreationPasswordStrengthHigh = L10n.tr("Localizable", "ACCOUNT_CREATION_PASSWORD_STRENGTH_HIGH", fallback: "Boom! Now that’s strong")
        internal static let accountCreationPasswordStrengthLow = L10n.tr("Localizable", "ACCOUNT_CREATION_PASSWORD_STRENGTH_LOW", fallback: "Keep it up")
        internal static let accountCreationPasswordStrengthMedium = L10n.tr("Localizable", "ACCOUNT_CREATION_PASSWORD_STRENGTH_MEDIUM", fallback: "Good progress")
        internal static let accountCreationPasswordStrengthSafe = L10n.tr("Localizable", "ACCOUNT_CREATION_PASSWORD_STRENGTH_SAFE", fallback: "Loving this")
        internal static let accountCreationPasswordStrengthVeryLow = L10n.tr("Localizable", "ACCOUNT_CREATION_PASSWORD_STRENGTH_VERY_LOW", fallback: "Nice start")
        internal static let accountMigrationProgressDownLoading = L10n.tr("Localizable", "accountMigrationProgressDownLoading", fallback: "Downloading your data")
        internal static let accountMigrationProgressEncrypting = L10n.tr("Localizable", "accountMigrationProgressEncrypting", fallback: "Encrypting your account")
        internal static let accountMigrationProgressFinalizing = L10n.tr("Localizable", "accountMigrationProgressFinalizing", fallback: "Finalizing your settings")
        internal static let accountMigrationProgressFinished = L10n.tr("Localizable", "accountMigrationProgressFinished", fallback: "You're all set up!")
        internal static func actionItemBreachDetail(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ACTION_ITEM_BREACH_DETAIL", String(describing: p1), fallback: "_")
    }
        internal static let actionItemBreachTitle = L10n.tr("Localizable", "ACTION_ITEM_BREACH_TITLE", fallback: "Security Alert")
        internal static let actionItemCenterEmptyMessage = L10n.tr("Localizable", "ACTION_ITEM_CENTER_EMPTY_MESSAGE", fallback: "This is the home for the important items that you need to act on. We’ll notify you when there’s something new here.")
        internal static let actionItemCenterUndoButton = L10n.tr("Localizable", "ACTION_ITEM_CENTER_UNDO_BUTTON", fallback: "Undo")
        internal static let actionItemCenterUndoDetail = L10n.tr("Localizable", "ACTION_ITEM_CENTER_UNDO_DETAIL", fallback: "Item deleted.")
        internal static let actionItemDarkwebDetail = L10n.tr("Localizable", "ACTION_ITEM_DARKWEB_DETAIL", fallback: "We found some of your information on the dark web. Take action to resolve the alert.")
        internal static let actionItemDarkwebTitle = L10n.tr("Localizable", "ACTION_ITEM_DARKWEB_TITLE", fallback: "Dark Web Alert")
        internal static let actionItemFreeTrialStartedDescription = L10n.tr("Localizable", "action_item_free_trial_started_description", fallback: "Try out Dashlane Premium for free.")
        internal static let actionItemFreeTrialStartedTitle = L10n.tr("Localizable", "action_item_free_trial_started_title", fallback: "Your free trial has started!")
        internal static let actionItemSecureLockDetailFaceid = L10n.tr("Localizable", "ACTION_ITEM_SECURE_LOCK_DETAIL_FACEID", fallback: "Access your account the safe and simple way by using FaceID.")
        internal static let actionItemSecureLockDetailPin = L10n.tr("Localizable", "ACTION_ITEM_SECURE_LOCK_DETAIL_PIN", fallback: "Access your account the safe and simple way by using PIN.")
        internal static let actionItemSecureLockDetailTouchid = L10n.tr("Localizable", "ACTION_ITEM_SECURE_LOCK_DETAIL_TOUCHID", fallback: "Access your account the safe and simple way by using TouchID.")
        internal static func actionItemSharingDetail(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "ACTION_ITEM_SHARING_DETAIL", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static func actionItemSharingDetailGroup(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ACTION_ITEM_SHARING_DETAIL_GROUP", String(describing: p1), fallback: "_")
    }
        internal static func actionItemSharingDetailSecurenote(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ACTION_ITEM_SHARING_DETAIL_SECURENOTE", String(describing: p1), fallback: "_")
    }
        internal static let actionItemSharingTitle = L10n.tr("Localizable", "ACTION_ITEM_SHARING_TITLE", fallback: "Sharing invitation")
        internal static let actionItemTrialUpgradeRecommendationDescriptionEssentials = L10n.tr("Localizable", "action_item_trial_upgrade_recommendation_description_essentials", fallback: "Based on app usage, our Essentials plan looks like a good fit for you. Upgrade today.")
        internal static let actionItemsCenterTitle = L10n.tr("Localizable", "ACTION_ITEMS_CENTER_TITLE", fallback: "Notification Center")
        internal static let activateSSOButtonTitle = L10n.tr("Localizable", "activateSSOButtonTitle", fallback: "Log in with SSO")
        internal static let addNewDeviceCompleted = L10n.tr("Localizable", "ADD_NEW_DEVICE_COMPLETED", fallback: "We loaded your account info on your new device!")
        internal static let addNewDeviceInProgress = L10n.tr("Localizable", "ADD_NEW_DEVICE_IN_PROGRESS", fallback: "Loading account info on new device...")
        internal static let addNewDeviceMessage1 = L10n.tr("Localizable", "ADD_NEW_DEVICE_MESSAGE_1", fallback: "Open Dashlane on your new device and select **Log in with QR code**")
        internal static let addNewDeviceMessage2 = L10n.tr("Localizable", "ADD_NEW_DEVICE_MESSAGE_2", fallback: "Return here, then scan the QR code on your new device")
        internal static let addNewDeviceMessage3 = L10n.tr("Localizable", "ADD_NEW_DEVICE_MESSAGE_3", fallback: "Follow the prompts on your new device to finish logging in")
        internal static let addNewDeviceScanCta = L10n.tr("Localizable", "ADD_NEW_DEVICE_SCAN_CTA", fallback: "Scan QR code")
        internal static let addNewDeviceSettingsTitle = L10n.tr("Localizable", "ADD_NEW_DEVICE_SETTINGS_TITLE", fallback: "Add new mobile device")
        internal static let addNewDeviceTitle = L10n.tr("Localizable", "ADD_NEW_DEVICE_TITLE", fallback: "Log in on your new mobile device with a QR code")
        internal static let addNewPassword = L10n.tr("Localizable", "addNewPassword", fallback: "Add new login")
        internal static let alternateIconSettingsTitle = L10n.tr("Localizable", "alternateIconSettingsTitle", fallback: "Change app icon")
        internal static let alternateIconViewTitle = L10n.tr("Localizable", "alternateIconViewTitle", fallback: "Choose icon")
        internal static func announceBiometryTypeCta(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ANNOUNCE_BIOMETRY_TYPE_CTA", String(describing: p1), fallback: "_")
    }
        internal static let announcePinCta = L10n.tr("Localizable", "ANNOUNCE_PIN_CTA", fallback: "Set up secure PIN unlock")
        internal static let announcePremiumExpiringCta = L10n.tr("Localizable", "ANNOUNCE_PREMIUM_EXPIRING_CTA", fallback: "Renew Premium")
        internal static let announceWelcomeM2DNoItemCta = L10n.tr("Localizable", "ANNOUNCE_WELCOME_M2D_NO_ITEM_CTA", fallback: "Add an item")
        internal static let authenticationBiometricsReactivationDialogCancel = L10n.tr("Localizable", "Authentication_BiometricsReactivationDialog_Cancel", fallback: "Close")
        internal static let authenticationBiometricsReactivationDialogCTA = L10n.tr("Localizable", "Authentication_BiometricsReactivationDialog_CTA", fallback: "Re-enable")
        internal static func authenticationBiometricsReactivationDialogDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Authentication_BiometricsReactivationDialog_Description", String(describing: p1), fallback: "_")
    }
        internal static func authenticationBiometricsReactivationDialogTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Authentication_BiometricsReactivationDialog_Title", String(describing: p1), fallback: "_")
    }
        internal static let authenticationIncorrectMasterPasswordHelp = L10n.tr("Localizable", "Authentication_IncorrectMasterPassword_Help", fallback: "That Master Password isn't right. Need help logging in?")
        internal static let authenticatorToolOnboardingActionItemDescription = L10n.tr("Localizable", "authenticatorToolOnboardingActionItemDescription", fallback: "Use Dashlane’s Authenticator tool to add an extra layer of security to your accounts with 2-factor authentication (2FA).")
        internal static let authenticatorToolOnboardingActionItemTitle = L10n.tr("Localizable", "authenticatorToolOnboardingActionItemTitle", fallback: "Secure your account with our Authenticator tool")
        internal static let authenticatorToolOnboardingSheetDescription = L10n.tr("Localizable", "authenticatorToolOnboardingSheetDescription", fallback: "Use Dashlane’s Authenticator tool to add an extra layer of security to your accounts with 2-factor authentication (2FA).")
        internal static let authenticatorToolOnboardingSheetTitle = L10n.tr("Localizable", "authenticatorToolOnboardingSheetTitle", fallback: "Secure your account with our Authenticator tool")
        internal static let authentifiantDetailSafetyPasswordBreached = L10n.tr("Localizable", "AUTHENTIFIANT_DETAIL_SAFETY_PASSWORD_BREACHED", fallback: "It has been compromised")
        internal static func authentifiantDetailSafetyPasswordComplexity(_ p1: Any) -> String {
      return L10n.tr("Localizable", "AUTHENTIFIANT_DETAIL_SAFETY_PASSWORD_COMPLEXITY", String(describing: p1), fallback: "_")
    }
        internal static func authentifiantDetailSafetyPasswordReused(_ p1: Int) -> String {
      return L10n.tr("Localizable", "AUTHENTIFIANT_DETAIL_SAFETY_PASSWORD_REUSED", p1, fallback: "Reused: %1$d times")
    }
        internal static let authentifiantDetailSafetyTitle = L10n.tr("Localizable", "AUTHENTIFIANT_DETAIL_SAFETY_TITLE", fallback: "Password strength")
        internal static func autoFillDemoAccessoryView(_ p1: Any) -> String {
      return L10n.tr("Localizable", "autoFillDemo_accessoryView", String(describing: p1), fallback: "_")
    }
        internal static let autofillDemoFieldsSubtitle = L10n.tr("Localizable", "autofillDemoFields_subtitle", fallback: "Your logins will appear like magic—but we call it Autofill.")
        internal static let autofillDemoFieldsTitle = L10n.tr("Localizable", "autofillDemoFields_title", fallback: "Tap the email field")
        internal static let autofillDemoModalPrimaryAction = L10n.tr("Localizable", "autofillDemoModal_primaryAction", fallback: "Try demo")
        internal static let autofillDemoModalSecondaryAction = L10n.tr("Localizable", "autofillDemoModal_secondaryAction", fallback: "Return home")
        internal static let autofillDemoModalSubtitle = L10n.tr("Localizable", "autofillDemoModal_subtitle", fallback: "Now see how you’ll be able to use that login in your browser.")
        internal static let autofillDemoModalTitle = L10n.tr("Localizable", "autofillDemoModal_title", fallback: "Securely stored")
        internal static let begin = L10n.tr("Localizable", "Begin", fallback: "Begin")
        internal static let breachViewSolvedEmptyView = L10n.tr("Localizable", "breachViewSolvedEmptyView", fallback: "No solved alerts yet")
        internal static let breachViewSolvedEmptyViewButton = L10n.tr("Localizable", "breachViewSolvedEmptyViewButton", fallback: "Check pending alerts")
        internal static let breachViewSolvedEmptyViewTitle = L10n.tr("Localizable", "breachViewSolvedEmptyViewTitle", fallback: "No solved alerts yet")
        internal static let business = L10n.tr("Localizable", "business", fallback: "Business")
        internal static let changeMasterPasswordErrorMessage = L10n.tr("Localizable", "ChangeMasterPassword_error_message", fallback: "We couldn't change your Master Password. Please try again.")
        internal static let changeMasterPasswordErrorTitle = L10n.tr("Localizable", "ChangeMasterPassword_error_title", fallback: "We couldn't change this password")
        internal static let changeMasterPasswordReaskPrompt = L10n.tr("Localizable", "ChangeMasterPassword_reask_prompt", fallback: "We’ll ask you to enter this Master Password in 14 days for your security")
        internal static let changeMasterPasswordSuccessHeadline = L10n.tr("Localizable", "ChangeMasterPassword_success_headline", fallback: "Nice job on the new Master Password!")
        internal static let changeMasterPasswordWarningCancel = L10n.tr("Localizable", "ChangeMasterPassword_Warning_Cancel", fallback: "Cancel")
        internal static let changeMasterPasswordWarningContinue = L10n.tr("Localizable", "ChangeMasterPassword_Warning_Continue", fallback: "Change Master Password")
        internal static let changeMasterPasswordWarningFreeDescription = L10n.tr("Localizable", "ChangeMasterPassword_Warning_Free_Description", fallback: "Changing your Master Password on this device will remove any data stored on your other devices.")
        internal static let changeMasterPasswordWarningFreeTitle = L10n.tr("Localizable", "ChangeMasterPassword_Warning_Free_Title", fallback: "Only the data on this device will be saved")
        internal static let changeMasterPasswordWarningPremiumDescription = L10n.tr("Localizable", "ChangeMasterPassword_Warning_Premium_Description", fallback: "All your data will be safe, but you'll need to log in to each device again with your new Master Password. You'll also see the introduction steps, but feel free to skip them.")
        internal static let changeMasterPasswordWarningPremiumTitle = L10n.tr("Localizable", "ChangeMasterPassword_Warning_Premium_Title", fallback: "This change will deauthorize your other devices")
        internal static let changeMasterPasswordWarningPremiumStatusUpdateErrorDescription = L10n.tr("Localizable", "ChangeMasterPassword_Warning_PremiumStatusUpdateError_Description", fallback: "We need a strong internet connection to change your Master Password. Please check it and try again.")
        internal static let changeMasterPasswordWarningPremiumStatusUpdateErrorOK = L10n.tr("Localizable", "ChangeMasterPassword_Warning_PremiumStatusUpdateError_OK", fallback: "OK")
        internal static let changeMasterPasswordWarningPremiumStatusUpdateErrorTitle = L10n.tr("Localizable", "ChangeMasterPassword_Warning_PremiumStatusUpdateError_Title", fallback: "Can you try that again?")
        internal static let changeMasterPasswordMustBeDifferentError = L10n.tr("Localizable", "changeMasterPasswordMustBeDifferentError", fallback: "Your new password must be different from your current password.")
        internal static let changingMasterPasswordHeadline = L10n.tr("Localizable", "ChangingMasterPassword_headline", fallback: "Encrypting your data with this Master Password")
        internal static let changingMasterPasswordSubtitle = L10n.tr("Localizable", "ChangingMasterPassword_subtitle", fallback: "It may take a minute.")
        internal static let clipboardSettingsShouldBeOverriden = L10n.tr("Localizable", "clipboardSettings_shouldBeOverriden", fallback: "Copy 2FA token automatically")
        internal static let clipboardSettingsShouldBeOverridenFooter = L10n.tr("Localizable", "clipboardSettings_shouldBeOverriden_footer", fallback: "Copy 2-factor authentication (2FA) tokens generated by Dashlane automatically.")
        internal static let contactsTitle = L10n.tr("Localizable", "CONTACTS_TITLE", fallback: "Contacts")
        internal static let continentAfrica = L10n.tr("Localizable", "CONTINENT_AFRICA", fallback: "Africa")
        internal static let continentAntartica = L10n.tr("Localizable", "CONTINENT_ANTARTICA", fallback: "Antarctica")
        internal static let continentAsia = L10n.tr("Localizable", "CONTINENT_ASIA", fallback: "Asia")
        internal static let continentEurope = L10n.tr("Localizable", "CONTINENT_EUROPE", fallback: "Europe")
        internal static let continentNorthAmerica = L10n.tr("Localizable", "CONTINENT_NORTH_AMERICA", fallback: "North America")
        internal static let continentOceania = L10n.tr("Localizable", "CONTINENT_OCEANIA", fallback: "Oceania")
        internal static let continentSouthAmerica = L10n.tr("Localizable", "CONTINENT_SOUTH_AMERICA", fallback: "South America")
        internal static func copyEmailFeedback(_ p1: Any) -> String {
      return L10n.tr("Localizable", "COPY_EMAIL_FEEDBACK", String(describing: p1), fallback: "_")
    }
        internal static func copyLoginFeedback(_ p1: Any) -> String {
      return L10n.tr("Localizable", "COPY_LOGIN_FEEDBACK", String(describing: p1), fallback: "_")
    }
        internal static func copyNoteFeedback(_ p1: Any) -> String {
      return L10n.tr("Localizable", "COPY_NOTE_FEEDBACK", String(describing: p1), fallback: "_")
    }
        internal static func copyPasswordFeedback(_ p1: Any) -> String {
      return L10n.tr("Localizable", "COPY_PASSWORD_FEEDBACK", String(describing: p1), fallback: "_")
    }
        internal static func copySecondaryLoginFeedback(_ p1: Any) -> String {
      return L10n.tr("Localizable", "COPY_SECONDARY_LOGIN_FEEDBACK", String(describing: p1), fallback: "_")
    }
        internal static func copySecurityCodeFeedback(_ p1: Any) -> String {
      return L10n.tr("Localizable", "COPY_SECURITY_CODE_FEEDBACK", String(describing: p1), fallback: "_")
    }
        internal static let copyAccountNumber = L10n.tr("Localizable", "copyAccountNumber", fallback: "Copy account number")
        internal static let copyAddress = L10n.tr("Localizable", "copyAddress", fallback: "Copy address")
        internal static let copyBic = L10n.tr("Localizable", "copyBic", fallback: "Copy BIC/SWIFT")
        internal static let copyCardNumber = L10n.tr("Localizable", "copyCardNumber", fallback: "Copy card number")
        internal static let copyCity = L10n.tr("Localizable", "copyCity", fallback: "Copy city")
        internal static let copyClabe = L10n.tr("Localizable", "copyClabe", fallback: "Copy CLABE")
        internal static let copyEmail = L10n.tr("Localizable", "copyEmail", fallback: "Copy email")
        internal static let copyFirstname = L10n.tr("Localizable", "copyFirstname", fallback: "Copy first name")
        internal static let copyFullName = L10n.tr("Localizable", "copyFullName", fallback: "Copy full name")
        internal static let copyIBAN = L10n.tr("Localizable", "copyIBAN", fallback: "Copy IBAN")
        internal static let copyLastname = L10n.tr("Localizable", "copyLastname", fallback: "Copy last name")
        internal static let copyLogin = L10n.tr("Localizable", "copyLogin", fallback: "Copy username")
        internal static let copyMiddlename = L10n.tr("Localizable", "copyMiddlename", fallback: "Copy middle name")
        internal static let copyName = L10n.tr("Localizable", "copyName", fallback: "Copy name")
        internal static let copyNumber = L10n.tr("Localizable", "copyNumber", fallback: "Copy number")
        internal static let copyOneTimePassword = L10n.tr("Localizable", "copyOneTimePassword", fallback: "Copy 2FA token")
        internal static let copyPassword = L10n.tr("Localizable", "copyPassword", fallback: "Copy password")
        internal static let copyRouting = L10n.tr("Localizable", "copyRouting", fallback: "Copy routing")
        internal static let copySecondaryLogin = L10n.tr("Localizable", "copySecondaryLogin", fallback: "Copy alternate username")
        internal static let copySecurityCode = L10n.tr("Localizable", "copySecurityCode", fallback: "Copy security code")
        internal static let copySortCode = L10n.tr("Localizable", "copySortCode", fallback: "Copy sort code")
        internal static let copyTeledeclarantNumber = L10n.tr("Localizable", "copyTeledeclarantNumber", fallback: "Copy online number")
        internal static let copyTitle = L10n.tr("Localizable", "copyTitle", fallback: "Copy title")
        internal static let copyWebsite = L10n.tr("Localizable", "copyWebsite", fallback: "Copy website")
        internal static let copyZip = L10n.tr("Localizable", "copyZip", fallback: "Copy ZIP code")
        internal static let createAccountNeedHelp = L10n.tr("Localizable", "createAccount_needHelp", fallback: "Need help?")
        internal static let createaccountprivacysettingsError = L10n.tr("Localizable", "CREATEACCOUNT_PRIVACYSETTINGS_Error", fallback: "Please agree to our Terms of Service and Privacy Policy to continue.")
        internal static let createaccountPrivacysettingsHeadline = L10n.tr("Localizable", "CREATEACCOUNT_PRIVACYSETTINGS_HEADLINE", fallback: "Privacy and data settings")
        internal static let createaccountPrivacysettingsMailsForTips = L10n.tr("Localizable", "CREATEACCOUNT_PRIVACYSETTINGS_MAILS_FOR_TIPS", fallback: "I’d like to receive emails with tips and special offers for Dashlane.")
        internal static let createaccountPrivacysettingsMailsForTipsAccessibility = L10n.tr("Localizable", "CREATEACCOUNT_PRIVACYSETTINGS_MAILS_FOR_TIPS_ACCESSIBILITY", fallback: "Select to receive emails with tips and special offers")
        internal static let createaccountPrivacysettingsRequiredLabel = L10n.tr("Localizable", "CREATEACCOUNT_PRIVACYSETTINGS_REQUIRED_LABEL", fallback: "*")
        internal static let createaccountPrivacysettingsTermsConditions = L10n.tr("Localizable", "CREATEACCOUNT_PRIVACYSETTINGS_TERMS_CONDITIONS", fallback: "Terms of Service")
        internal static let createAccountReEnterPassword = L10n.tr("Localizable", "createAccount_re-enterPassword", fallback: "New Master Password")
        internal static let createAccountSeeTips = L10n.tr("Localizable", "createAccount_seeTips", fallback: "See our tips")
        internal static let credentialAutofillSetupActivatedDescription = L10n.tr("Localizable", "CREDENTIAL_AUTOFILL_SETUP_ACTIVATED_DESCRIPTION", fallback: "You can now autofill logins with Dashlane in applications.")
        internal static let credentialAutofillSetupActivatedOk = L10n.tr("Localizable", "CREDENTIAL_AUTOFILL_SETUP_ACTIVATED_OK", fallback: "Ok, got it")
        internal static let credentialAutofillSetupActivatedTitle = L10n.tr("Localizable", "CREDENTIAL_AUTOFILL_SETUP_ACTIVATED_TITLE", fallback: "Dashlane Autofill is activated")
        internal static let credentialDetailViewAddDomain = L10n.tr("Localizable", "CredentialDetailView_AddDomain", fallback: "Add another website")
        internal static let credentialDetailViewDeleteDomain = L10n.tr("Localizable", "CredentialDetailView_DeleteDomain", fallback: "Delete")
        internal static let credentialProviderOnboardingActivatedBackButtonTitle = L10n.tr("Localizable", "CredentialProviderOnboarding_ActivatedBackButtonTitle", fallback: "Back to Settings")
        internal static let credentialProviderOnboardingActivatedBody = L10n.tr("Localizable", "CredentialProviderOnboarding_ActivatedBody", fallback: "To make Dashlane your default password manager, uncheck Keychain.")
        internal static let credentialProviderOnboardingActivatedTitle = L10n.tr("Localizable", "CredentialProviderOnboarding_ActivatedTitle", fallback: "Uncheck Keychain")
        internal static let credentialProviderOnboardingIntroBody = L10n.tr("Localizable", "CredentialProviderOnboarding_IntroBody", fallback: "Log in to your accounts with a tap—it's that easy!")
        internal static let credentialProviderOnboardingIntroCTA = L10n.tr("Localizable", "CredentialProviderOnboarding_IntroCTA", fallback: "Activate Password AutoFill")
        internal static let currentPlanCtaEssentials = L10n.tr("Localizable", "current_plan_cta_essentials", fallback: "Get Essentials")
        internal static let customizeSecureNote = L10n.tr("Localizable", "CUSTOMIZE_SECURE_NOTE", fallback: "Customize this note")
        internal static let darkWebMonitoringBreachViewDateUnknown = L10n.tr("Localizable", "darkWebMonitoring_BreachView_Date_Unknown", fallback: "Unknown date")
        internal static let darkWebMonitoringBreachViewDomainPlaceholder = L10n.tr("Localizable", "darkWebMonitoring_BreachView_Domain_Placeholder", fallback: "Unknown")
        internal static let darkWebMonitoringEmailHeaderViewDataLeakMonitoringActive = L10n.tr("Localizable", "darkWebMonitoring_EmailHeaderView_DataLeakMonitoringActive", fallback: "Regularly scanning")
        internal static let darkWebMonitoringEmailHeaderViewDataLeakMonitoringInactive = L10n.tr("Localizable", "darkWebMonitoring_EmailHeaderView_DataLeakMonitoringInactive", fallback: "Upgrade to start monitoring")
        internal static let darkWebMonitoringEmailHeaderViewDataLeakMonitoringOnHold = L10n.tr("Localizable", "DarkWebMonitoring_EmailHeaderView_DataLeakMonitoringOnHold", fallback: "Go to your inbox to verify your email.")
        internal static func darkWebMonitoringEmailHeaderViewMultiEmailInactive(_ p1: Int) -> String {
      return L10n.tr("Localizable", "darkWebMonitoring_EmailHeaderView_MultiEmailInactive", p1, fallback: "%1$d inactive emails")
    }
        internal static func darkWebMonitoringEmailHeaderViewMultiEmailMonitored(_ p1: Int) -> String {
      return L10n.tr("Localizable", "darkWebMonitoring_EmailHeaderView_MultiEmailMonitored", p1, fallback: "Monitoring %1$d emails")
    }
        internal static func darkWebMonitoringEmailHeaderViewOneEmailInactive(_ p1: Int) -> String {
      return L10n.tr("Localizable", "darkWebMonitoring_EmailHeaderView_OneEmailInactive", p1, fallback: "%1$d inactive email")
    }
        internal static func darkWebMonitoringEmailHeaderViewOneEmailMonitored(_ p1: Int) -> String {
      return L10n.tr("Localizable", "darkWebMonitoring_EmailHeaderView_OneEmailMonitored", p1, fallback: "Monitoring %1$d email")
    }
        internal static let darkWebMonitoringEmailListViewAddEmail = L10n.tr("Localizable", "darkWebMonitoring_EmailListView_AddEmail", fallback: "Add email")
        internal static let darkWebMonitoringEmailRegistrationErrorConnection = L10n.tr("Localizable", "DarkWebMonitoring_EmailRegistration_Error_Connection", fallback: "Please check your internet connection and try again.")
        internal static let darkWebMonitoringEmailRegistrationErrorInvalidEmail = L10n.tr("Localizable", "DarkWebMonitoring_EmailRegistration_Error_InvalidEmail", fallback: "The email is invalid.")
        internal static let darkWebMonitoringEmailRegistrationErrorUnknown = L10n.tr("Localizable", "DarkWebMonitoring_EmailRegistration_Error_Unknown", fallback: "Something went wrong. Please try again later.")
        internal static let darkWebMonitoringListViewSectionHeaderTitle = L10n.tr("Localizable", "darkWebMonitoring_ListView_SectionHeaderTitle", fallback: "Discovered on the dark web")
        internal static func darkWebMonitoringOnboardingChecklistEmailConfirmationBody(_ p1: Any) -> String {
      return L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_Checklist_EmailConfirmation_Body", String(describing: p1), fallback: "_")
    }
        internal static let darkWebMonitoringOnboardingChecklistEmailConfirmationTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_Checklist_EmailConfirmation_Title", fallback: "Confirm your email and come back to fix the breaches")
        internal static let darkWebMonitoringOnboardingChecklistSeeScanResult = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_Checklist_SeeScanResult", fallback: "See scan result")
        internal static let darkWebMonitoringOnboardingEmailAppsAppleMail = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailApps_AppleMail", fallback: "Apple Mail")
        internal static let darkWebMonitoringOnboardingEmailAppsCancel = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailApps_Cancel", fallback: "Cancel")
        internal static let darkWebMonitoringOnboardingEmailAppsGmail = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailApps_Gmail", fallback: "Gmail")
        internal static let darkWebMonitoringOnboardingEmailAppsOutlook = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailApps_Outlook", fallback: "Outlook")
        internal static let darkWebMonitoringOnboardingEmailAppsSpark = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailApps_Spark", fallback: "Spark")
        internal static let darkWebMonitoringOnboardingEmailAppsTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailApps_Title", fallback: "Choose an app")
        internal static let darkWebMonitoringOnboardingEmailAppsYahooMail = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailApps_YahooMail", fallback: "Yahoo Mail")
        internal static let darkWebMonitoringOnboardingEmailConfirmationConfirmedContinue = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Confirmed_Continue", fallback: "Continue")
        internal static let darkWebMonitoringOnboardingEmailConfirmationConfirmedSubtitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Confirmed_Subtitle", fallback: "We’ve prepared a plan to help you take back control.")
        internal static let darkWebMonitoringOnboardingEmailConfirmationConfirmedSwipeUp = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Confirmed_Swipe_Up", fallback: "Swipe up to reveal")
        internal static let darkWebMonitoringOnboardingEmailConfirmationConfirmedTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Confirmed_Title", fallback: "Email confirmed")
        internal static let darkWebMonitoringOnboardingEmailConfirmationFailureSkip = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Failure_Skip", fallback: "Skip")
        internal static let darkWebMonitoringOnboardingEmailConfirmationFailureTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Failure_Title", fallback: "We haven’t received the email confirmation yet")
        internal static let darkWebMonitoringOnboardingEmailConfirmationFailureTryAgain = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Failure_TryAgain", fallback: "Try again")
        internal static let darkWebMonitoringOnboardingEmailConfirmationFetchingCancel = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Fetching_Cancel", fallback: "Cancel")
        internal static let darkWebMonitoringOnboardingEmailConfirmationFetchingTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_Fetching_Title", fallback: "Fetching email confirmation")
        internal static let darkWebMonitoringOnboardingEmailConfirmationNoBreachesSubtitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_NoBreaches_Subtitle", fallback: "Our Dark Web Monitoring feature is active, so we’ll let you know if we find anything in the future.")
        internal static let darkWebMonitoringOnboardingEmailConfirmationNoBreachesSwipeUp = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_NoBreaches_Swipe_Up", fallback: "Swipe up to reveal")
        internal static let darkWebMonitoringOnboardingEmailConfirmationNoBreachesTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailConfirmation_NoBreaches_Title", fallback: "Everything looks great. Let’s begin!")
        internal static let darkWebMonitoringOnboardingEmailViewBack = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_Back", fallback: "Back")
        internal static let darkWebMonitoringOnboardingEmailViewConfirmedMyEmail = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_ConfirmedMyEmail", fallback: "I’ve confirmed my email")
        internal static let darkWebMonitoringOnboardingEmailViewConfirmEmail = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_ConfirmEmail", fallback: "Confirm your email and come back here to fix the breaches")
        internal static let darkWebMonitoringOnboardingEmailViewCTA = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_CTA", fallback: "Check for breaches")
        internal static let darkWebMonitoringOnboardingEmailViewOpenEmailApp = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_OpenEmailApp", fallback: "Open my email app")
        internal static let darkWebMonitoringOnboardingEmailViewSent = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_Sent", fallback: "Email sent!")
        internal static let darkWebMonitoringOnboardingEmailViewSkip = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_Skip", fallback: "Skip")
        internal static let darkWebMonitoringOnboardingEmailViewSubtitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_Subtitle", fallback: "We’ll search for breaches associated with your email, then help you secure your accounts.")
        internal static let darkWebMonitoringOnboardingEmailViewTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_EmailView_Title", fallback: "Find out if your info has been part of a breach")
        internal static let darkWebMonitoringOnboardingResultsNoBreachesBody = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_Results_NoBreaches_Body", fallback: "We’ll keep monitoring the dark web and let you know if we find anything in the future. In the meantime, you can start adding some logins.")
        internal static let darkWebMonitoringOnboardingResultsNoBreachesTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_Results_NoBreaches_Title", fallback: "No breaches found!")
        internal static let darkWebMonitoringOnboardingScanPromptDescription = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_ScanPrompt_Description", fallback: "We’ll search for breaches associated with your email, then help you secure your accounts.")
        internal static let darkWebMonitoringOnboardingScanPromptIgnore = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_ScanPrompt_Ignore", fallback: "Ignore")
        internal static let darkWebMonitoringOnboardingScanPromptScan = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_ScanPrompt_Scan", fallback: "Run a scan")
        internal static let darkWebMonitoringOnboardingScanPromptTitle = L10n.tr("Localizable", "DarkWebMonitoring_Onboarding_ScanPrompt_Title", fallback: "Find out if your info has been part of a breach")
        internal static let darkWebMonitoringPremiumViewTitleFreeUser = L10n.tr("Localizable", "darkWebMonitoring_PremiumView_Title_FreeUser", fallback: "Upgrade to Premium to get Dark Web Monitoring")
        internal static let darkWebMonitoringPremiumViewTitlePremiumUser = L10n.tr("Localizable", "darkWebMonitoring_PremiumView_Title_PremiumUser", fallback: "Get alerts for breaches and hacks")
        internal static let darkWebMonitoringVerifyToBeginMonitoring = L10n.tr("Localizable", "DarkWebMonitoring_VerifyToBeginMonitoring", fallback: "Pending your verification")
        internal static let dataleakEmailDelete = L10n.tr("Localizable", "DATALEAK_EMAIL_DELETE", fallback: "Delete")
        internal static let dataleakEmailPopupMessage = L10n.tr("Localizable", "DATALEAK_EMAIL_POPUP_MESSAGE", fallback: "Are you sure you deactivate Dark Web Monitoring for this email?")
        internal static let dataleakEmailPopupTitle = L10n.tr("Localizable", "DATALEAK_EMAIL_POPUP_TITLE", fallback: "Remove")
        internal static let dataleakEmailStatusActive = L10n.tr("Localizable", "DATALEAK_EMAIL_STATUS_ACTIVE", fallback: "Active")
        internal static let dataleakEmailStatusInactive = L10n.tr("Localizable", "DATALEAK_EMAIL_STATUS_INACTIVE", fallback: "Inactive")
        internal static let dataleakEmailStatusPending = L10n.tr("Localizable", "DATALEAK_EMAIL_STATUS_PENDING", fallback: "Pending")
        internal static let dataleakModuleTitle = L10n.tr("Localizable", "DATALEAK_MODULE_TITLE", fallback: "Dark Web Monitoring")
        internal static let dataleakNotificationCta = L10n.tr("Localizable", "DATALEAK_NOTIFICATION_CTA", fallback: "Start scan")
        internal static let dataleakNotificationMessage = L10n.tr("Localizable", "DATALEAK_NOTIFICATION_MESSAGE", fallback: "Scan the web instantly to learn if your personal information was part of a breach.")
        internal static let dataleakNotificationTitle = L10n.tr("Localizable", "DATALEAK_NOTIFICATION_TITLE", fallback: "Dark Web Monitoring")
        internal static let dataleakmonitoringEmailAlreadyActive = L10n.tr("Localizable", "DATALEAKMONITORING_EMAIL_ALREADY_ACTIVE", fallback: "Dark Web Monitoring is already active for this email.")
        internal static let dataleakmonitoringEnterEmailTitle = L10n.tr("Localizable", "DATALEAKMONITORING_ENTER_EMAIL_TITLE", fallback: "Enter the email you'd like to scan and monitor")
        internal static let dataleakmonitoringEnteredBadEmail = L10n.tr("Localizable", "DATALEAKMONITORING_ENTERED_BAD_EMAIL", fallback: "Please enter a valid email address.")
        internal static let dataleakmonitoringErrorOptinInProgress = L10n.tr("Localizable", "DATALEAKMONITORING_ERROR_OPTIN_IN_PROGRESS", fallback: "We've already sent an email to this address, and the link to your results has not yet expired. Please check your inbox.")
        internal static let dataleakmonitoringErrorTooManyAddresses = L10n.tr("Localizable", "DATALEAKMONITORING_ERROR_TOO_MANY_ADDRESSES", fallback: "You can scan and monitor up to 5 email addresses. If you'd like to add a new email, please remove an existing email address first.")
        internal static let dataleakmonitoringNoEmailBenefitsExpertDescription = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_BENEFITS_EXPERT_DESCRIPTION", fallback: "We help you change your compromised passwords and instruct you on how to bolster your digital security.")
        internal static let dataleakmonitoringNoEmailBenefitsExpertTitle = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_BENEFITS_EXPERT_TITLE", fallback: "Get expert advice")
        internal static let dataleakmonitoringNoEmailBenefitsFirstDescription = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_BENEFITS_FIRST_DESCRIPTION", fallback: "We send you a report of current breaches and detailed alerts as soon as we discover new information.")
        internal static let dataleakmonitoringNoEmailBenefitsFirstTitle = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_BENEFITS_FIRST_TITLE", fallback: "Be the first to know")
        internal static let dataleakmonitoringNoEmailBenefitsSurveillanceDescription = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_BENEFITS_SURVEILLANCE_DESCRIPTION", fallback: "A team of cybersecurity experts monitor up to 5 of your email addresses to check if your passwords, IDs, or financial information are involved in a breach.")
        internal static let dataleakmonitoringNoEmailBenefitsSurveillanceTitle = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_BENEFITS_SURVEILLANCE_TITLE", fallback: "Have 24/7 surveillance")
        internal static let dataleakmonitoringNoEmailDescription = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_DESCRIPTION", fallback: "Dark Web Monitoring scans the web for leaked or stolen personal information and sends you alerts, so you can take action to protect your accounts.")
        internal static let dataleakmonitoringNoEmailLessCta = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_LESS_CTA", fallback: "Show less")
        internal static let dataleakmonitoringNoEmailSeeCta = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_SEE_CTA", fallback: "See all the benefits")
        internal static let dataleakmonitoringNoEmailStartCta = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_START_CTA", fallback: "Start monitoring")
        internal static let dataleakmonitoringNoEmailTitle = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_TITLE", fallback: "Dark Web Monitoring")
        internal static let dataleakmonitoringNoEmailUpgradeCta = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_UPGRADE_CTA", fallback: "Upgrade to Premium")
        internal static let dataleakmonitoringNoEmailUpgradeLearnMore = L10n.tr("Localizable", "DATALEAKMONITORING_NO_EMAIL_UPGRADE_LEARN_MORE", fallback: "Upgrade to Premium to start monitoring")
        internal static let dataleakmonitoringSetupDescription = L10n.tr("Localizable", "DATALEAKMONITORING_SETUP_DESCRIPTION", fallback: "Dashlane will scan the web for leaked or stolen personal data associated with any of your email addresses. This email will be automatically monitored from now on.")
        internal static let dataleakmonitoringSetupNextButton = L10n.tr("Localizable", "DATALEAKMONITORING_SETUP_NEXT_BUTTON", fallback: "Next")
        internal static let dataleakmonitoringSetupOnlyPremiumCta = L10n.tr("Localizable", "DATALEAKMONITORING_SETUP_ONLY_PREMIUM_CTA", fallback: "Go Premium")
        internal static let dataleakmonitoringSetupOnlyPremiumDescription = L10n.tr("Localizable", "DATALEAKMONITORING_SETUP_ONLY_PREMIUM_DESCRIPTION", fallback: "Upgrade to Premium to reactivate monitoring and receive dark web alerts when a breach of your personal information occurs.")
        internal static let dataleakmonitoringSetupOnlyPremiumTitle = L10n.tr("Localizable", "DATALEAKMONITORING_SETUP_ONLY_PREMIUM_TITLE", fallback: "Dark Web Monitoring is a Premium feature")
        internal static let dataleakmonitoringSetupTitleNew = L10n.tr("Localizable", "DATALEAKMONITORING_SETUP_TITLE_NEW", fallback: "Start a dark web scan ")
        internal static let dataleakmonitoringSuccessCloseButton = L10n.tr("Localizable", "DATALEAKMONITORING_SUCCESS_CLOSE_BUTTON", fallback: "Close")
                internal static func dataleakmonitoringSuccessDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "DATALEAKMONITORING_SUCCESS_DESCRIPTION", String(describing: p1), fallback: "_\nThis link will expire in 24 hours.")
    }
        internal static let dataleakmonitoringSuccessTitle = L10n.tr("Localizable", "DATALEAKMONITORING_SUCCESS_TITLE", fallback: "Check your email to view your scan results")
        internal static let deleteQuickAction = L10n.tr("Localizable", "deleteQuickAction", fallback: "Delete")
        internal static func documentStorageDetailViewButtonTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "documentStorageDetailViewButtonTitle", String(describing: p1), fallback: "_")
    }
        internal static let downloadAuthAppCta = L10n.tr("Localizable", "DOWNLOAD_AUTH_APP_CTA", fallback: "Open App Store")
        internal static let downloadAuthAppHelpCta = L10n.tr("Localizable", "DOWNLOAD_AUTH_APP_HELP_CTA", fallback: "Learn more about Dashlane Authenticator")
        internal static let downloadAuthAppMessage1 = L10n.tr("Localizable", "DOWNLOAD_AUTH_APP_MESSAGE1", fallback: "1. Download Dashlane Authenticator from the App Store")
        internal static let downloadAuthAppMessage2 = L10n.tr("Localizable", "DOWNLOAD_AUTH_APP_MESSAGE2", fallback: "2. Return to the security settings in this app to finish setting up 2FA")
        internal static let downloadAuthAppSubtitle = L10n.tr("Localizable", "DOWNLOAD_AUTH_APP_SUBTITLE", fallback: "The Authenticator app will automatically pair with your Dashlane account.")
        internal static let downloadAuthAppTitle = L10n.tr("Localizable", "DOWNLOAD_AUTH_APP_TITLE", fallback: "Use our Authenticator app to set up 2FA")
        internal static let dwmDeleteAlertCta = L10n.tr("Localizable", "dwm_DeleteAlert_Cta", fallback: "Delete alert")
        internal static let dwmDetailViewBreachDate = L10n.tr("Localizable", "dwm_DetailView_BreachDate", fallback: "Breach date")
        internal static let dwmDetailViewDeleteConfirmTitle = L10n.tr("Localizable", "dwm_DetailView_DeleteConfirmTitle", fallback: "Delete this alert?")
        internal static let dwmDetailViewEmailAffected = L10n.tr("Localizable", "dwm_DetailView_EmailAffected", fallback: "Email affected")
        internal static let dwmDetailViewOtherDataAffected = L10n.tr("Localizable", "dwm_DetailView_OtherDataAffected", fallback: "Other data affected")
        internal static let dwmDetailViewSubtitle = L10n.tr("Localizable", "dwm_DetailView_Subtitle", fallback: "This account is affected by a hack or breach.")
        internal static func dwmHeaderViewSpotsAvailable(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dwm_HeaderView_SpotsAvailable", p1, fallback: "**%1$d spots** available")
    }
        internal static func dwmHeaderViewSpotsAvailableHighlighted(_ p1: Int) -> String {
      return L10n.tr("Localizable", "dwm_HeaderView_SpotsAvailable_highlighted", p1, fallback: "%1$d spots")
    }
        internal static let dwmOurAdviceButton = L10n.tr("Localizable", "dwm_OurAdvice_Button", fallback: "Change password")
        internal static let dwmOurAdviceContent = L10n.tr("Localizable", "dwm_OurAdvice_Content", fallback: "Change your password and avoid reusing it for other accounts.")
        internal static let dwmOurAdviceTitle = L10n.tr("Localizable", "dwm_OurAdvice_Title", fallback: "Our advice")
        internal static let dwmAdviceSectionSavePasswordContent = L10n.tr("Localizable", "dwmAdviceSection_SavePassword_Content", fallback: "We replaced your old password with the new one you generated.")
        internal static let dwmAdviceSectionSavePasswordTitle = L10n.tr("Localizable", "dwmAdviceSection_SavePassword_Title", fallback: "Generated password saved")
        internal static let dwmAlertSolvedTitle = L10n.tr("Localizable", "dwmAlertSolvedTitle", fallback: "Solved")
        internal static let dwmOnboardingCardPWGTabGeneratorSubtitle = L10n.tr("Localizable", "DWMOnboarding_Card_PWG_Tab_Generator_Subtitle", fallback: "Don’t worry about memorizing it! Once it’s saved in Dashlane, we’ll type it for you, on any device.")
        internal static let dwmOnboardingCardPWGTabLessOptions = L10n.tr("Localizable", "DWMOnboarding_Card_PWG_Tab_LessOptions", fallback: "Less options")
        internal static let dwmOnboardingCardPWGTabMoreOptions = L10n.tr("Localizable", "DWMOnboarding_Card_PWG_Tab_MoreOptions", fallback: "More options")
        internal static let dwmOnboardingCardPWGTabNewPasswordTitle = L10n.tr("Localizable", "DWMOnboarding_Card_PWG_Tab_NewPassword_Title", fallback: "Here’s a new, secure password")
        internal static let dwmOnboardingCardPWGTabTitle = L10n.tr("Localizable", "DWMOnboarding_Card_PWG_Tab_Title", fallback: "Password Generator")
        internal static let dwmOnboardingCardWSIDHideDetailedInstructions = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_HideDetailedInstructions", fallback: "Hide instructions")
        internal static let dwmOnboardingCardWSIDListAccountSettings = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_List_AccountSettings", fallback: "Go to the account settings to change your password. You can use our Password Generator to make a strong one.")
        internal static let dwmOnboardingCardWSIDListGoBackToDashlane = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_List_GoBackToDashlane", fallback: "Come back to Dashlane and save your new password. Next time we’ll log you in!")
            internal static func dwmOnboardingCardWSIDListLogInDomain(_ p1: Any) -> String {
      return L10n.tr("Localizable", "DWMOnboarding_Card_WSID_List_LogInDomain", String(describing: p1), fallback: "_Log in if you’re not already.")
    }
        internal static let dwmOnboardingCardWSIDLoginTitle = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_LoginTitle", fallback: "YOUR LOGIN INFO")
        internal static let dwmOnboardingCardWSIDShowDetailedInstructions = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_ShowDetailedInstructions", fallback: "Show instructions")
        internal static let dwmOnboardingCardWSIDTabChangePwd = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_Tab_ChangePwd", fallback: "Change your password")
        internal static let dwmOnboardingCardWSIDTabEmailCopied = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_Tab_Email_Copied", fallback: "Email copied!")
        internal static let dwmOnboardingCardWSIDTabMissingPwdContent = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_Tab_MissingPwd_Content", fallback: "If you don’t remember it, try resetting with \"forgot password\"")
        internal static let dwmOnboardingCardWSIDTabMissingPwdTitle = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_Tab_MissingPwd_Title", fallback: "Missing password")
        internal static let dwmOnboardingCardWSIDTabTitle = L10n.tr("Localizable", "DWMOnboarding_Card_WSID_Tab_Title", fallback: "What should I do?")
        internal static let dwmOnboardingChecklistItemCaption = L10n.tr("Localizable", "DWMOnboarding_ChecklistItem_Caption", fallback: "We’ll help you secure your accounts to prevent further breaches.")
        internal static let dwmOnboardingChecklistItemTitle = L10n.tr("Localizable", "DWMOnboarding_ChecklistItem_Title", fallback: "Address your previous breaches")
        internal static let dwmOnboardingFixBreachesDetailCancel = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Cancel", fallback: "Cancel")
        internal static let dwmOnboardingFixBreachesDetailEmail = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Email", fallback: "Email")
        internal static let dwmOnboardingFixBreachesDetailLetsSaveDescription = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_LetsSave_Description", fallback: "Next time we’ll log in for you!")
        internal static let dwmOnboardingFixBreachesDetailLetsSaveTitle = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_LetsSave_Title", fallback: "Let’s save that new password")
        internal static let dwmOnboardingFixBreachesDetailMessageNoPasswordDescription = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Message_NoPassword_Description", fallback: "Your password wasn’t found in the breach, but we recommend you change it to make sure your account is secure.")
        internal static let dwmOnboardingFixBreachesDetailMessageNoPasswordNoDateTitle = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Message_NoPassword_NoDate_Title", fallback: "This account is compromised")
        internal static func dwmOnboardingFixBreachesDetailMessageNoPasswordTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Message_NoPassword_Title", String(describing: p1), fallback: "_")
    }
        internal static let dwmOnboardingFixBreachesDetailName = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Name", fallback: "Item name")
        internal static let dwmOnboardingFixBreachesDetailNavigationTitle = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_NavigationTitle", fallback: "Edit")
        internal static let dwmOnboardingFixBreachesDetailPassword = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Password", fallback: "Password")
        internal static let dwmOnboardingFixBreachesDetailPasswordCompromisedChangeNow = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_PasswordCompromised_ChangeNow", fallback: "Change password")
        internal static let dwmOnboardingFixBreachesDetailPasswordCompromisedDescription = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_PasswordCompromised_Description", fallback: "This password was involved in a breach. We suggest you change it to secure your account.")
        internal static let dwmOnboardingFixBreachesDetailPasswordCompromisedDone = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_PasswordCompromised_Done", fallback: "I’ve changed it")
        internal static let dwmOnboardingFixBreachesDetailPasswordCompromisedTitle = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_PasswordCompromised_Title", fallback: "This password is compromised")
        internal static let dwmOnboardingFixBreachesDetailSave = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Save", fallback: "Save")
        internal static let dwmOnboardingFixBreachesDetailSecuredDescription = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Secured_Description", fallback: "You’re on your way to a better life online.")
        internal static let dwmOnboardingFixBreachesDetailSecuredTitle = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Secured_Title", fallback: "You just secured your account!")
        internal static let dwmOnboardingFixBreachesDetailWebsite = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Detail_Website", fallback: "Website")
        internal static let dwmOnboardingFixBreachesMainAllClear = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_AllClear", fallback: "All clear, you’re done here")
        internal static let dwmOnboardingFixBreachesMainBack = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_Back", fallback: "Back")
        internal static let dwmOnboardingFixBreachesMainBreached = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_Breached", fallback: "Breached")
        internal static let dwmOnboardingFixBreachesMainDescription = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_Description", fallback: "Let’s start by securing these accounts:")
        internal static let dwmOnboardingFixBreachesMainInYourVault = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_InYourVault", fallback: "In your Vault")
        internal static let dwmOnboardingFixBreachesMainPasswordFound = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_PasswordFound", fallback: "Breached – password found")
        internal static let dwmOnboardingFixBreachesMainSecured = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_Secured", fallback: "Secured")
        internal static let dwmOnboardingFixBreachesMainSwipeToIgnoreNotice = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_SwipeToIgnoreNotice", fallback: "You can swipe to ignore if an account is not important to you.")
        internal static let dwmOnboardingFixBreachesMainTitle = L10n.tr("Localizable", "DWMOnboarding_FixBreaches_Main_Title", fallback: "Breached accounts")
        internal static let dwmOnboardingMiniBrowserBack = L10n.tr("Localizable", "DWMOnboarding_MiniBrowser_Back", fallback: "Back")
        internal static let dwmOnboardingMiniBrowserDone = L10n.tr("Localizable", "DWMOnboarding_MiniBrowser_Done", fallback: "Done")
        internal static let editMenuShowLargeCharacters = L10n.tr("Localizable", "EDIT_MENU_SHOW_LARGE_CHARACTERS", fallback: "Large display")
        internal static let emptySharingListText = L10n.tr("Localizable", "EMPTY_SHARING_LIST_TEXT", fallback: "Share items securely with friends, family, or colleagues.")
        internal static let entertainment = L10n.tr("Localizable", "entertainment", fallback: "Entertainment")
        internal static let euro = L10n.tr("Localizable", "EURO", fallback: "Euro")
        internal static let exporterUnlockAlertWrongMpMessage = L10n.tr("Localizable", "EXPORTER_UNLOCK_ALERT_WRONG_MP_MESSAGE", fallback: "You entered the wrong Master Password")
        internal static let exporterUnlockAlertWrongMpTitle = L10n.tr("Localizable", "EXPORTER_UNLOCK_ALERT_WRONG_MP_TITLE", fallback: "Wrong Master Password")
        internal static let extensionsOnboardingAllBrowsersDescription = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_ALL_BROWSERS_DESCRIPTION", fallback: "Download the Dashlane extension in your favorite browser for a better Dashlane experience.")
        internal static let extensionsOnboardingAllBrowsersTitle = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_ALL_BROWSERS_TITLE", fallback: "Use Dashlane in your favorite browser")
        internal static func extensionsOnboardingDashlaneOn(_ p1: Any) -> String {
      return L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_DASHLANE_ON", String(describing: p1), fallback: "_")
    }
        internal static func extensionsOnboardingOtherBrowserDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_OTHER_BROWSER_DESCRIPTION", String(describing: p1), fallback: "_")
    }
        internal static let extensionsOnboardingOtherBrowserGetExtensionCta = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_OTHER_BROWSER_GET_EXTENSION_CTA", fallback: "Get extension")
        internal static let extensionsOnboardingOtherBrowserOpenExtensionCta = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_OTHER_BROWSER_OPEN_EXTENSION_CTA", fallback: "Open extension")
        internal static let extensionsOnboardingOtherBrowserOthersCta = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_OTHER_BROWSER_OTHERS_CTA", fallback: "Use a different browser?")
        internal static func extensionsOnboardingOtherBrowserTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_OTHER_BROWSER_TITLE", String(describing: p1), fallback: "_")
    }
        internal static func extensionsOnboardingSafariDisableLegacy(_ p1: Any) -> String {
      return L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_DISABLE_LEGACY", String(describing: p1), fallback: "_")
    }
        internal static let extensionsOnboardingSafariEnable = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_ENABLE", fallback: "Check the box next to **Dashlane**")
        internal static let extensionsOnboardingSafariEnableBold = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_ENABLE_BOLD", fallback: "Dashlane")
        internal static let extensionsOnboardingSafariEnableExtensionCta = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_ENABLE_EXTENSION_CTA", fallback: "Enable extension")
        internal static let extensionsOnboardingSafariNavigateExample = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_NAVIGATE_EXAMPLE", fallback: "Navigate to the **Extensions** tab")
        internal static let extensionsOnboardingSafariNavigateExampleBold = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_NAVIGATE_EXAMPLE_BOLD", fallback: "Extensions")
        internal static let extensionsOnboardingSafariOpenSafariCta = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_OPEN_SAFARI_CTA", fallback: "Open Safari")
        internal static let extensionsOnboardingSafariOpenSafariExample = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_OPEN_SAFARI_EXAMPLE", fallback: "Open Safari **Preferences (⌘ ,)**")
        internal static let extensionsOnboardingSafariOpenSafariExampleBold = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_OPEN_SAFARI_EXAMPLE_BOLD", fallback: "Preferences (⌘ ,)")
        internal static let extensionsOnboardingSafariTitle = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SAFARI_TITLE", fallback: "Enable the new Dashlane for Safari")
        internal static let extensionsOnboardingSkipCta = L10n.tr("Localizable", "EXTENSIONS_ONBOARDING_SKIP_CTA", fallback: "Skip")
        internal static let fastLocalSetupBack = L10n.tr("Localizable", "FastLocalSetup_Back", fallback: "Back")
        internal static func fastLocalSetupBiometryRequiredForMasterPasswordReset(_ p1: Any) -> String {
      return L10n.tr("Localizable", "FastLocalSetup_BiometryRequiredForMasterPasswordReset", String(describing: p1), fallback: "_")
    }
        internal static let fastLocalSetupContinue = L10n.tr("Localizable", "FastLocalSetup_Continue", fallback: "Continue")
        internal static let fastLocalSetupFaceIDDescription = L10n.tr("Localizable", "FastLocalSetup_FaceID_Description", fallback: "Unlock Dashlane with one look.")
        internal static let fastLocalSetupHowItWorksBack = L10n.tr("Localizable", "FastLocalSetup_HowItWorks_Back", fallback: "Back")
        internal static func fastLocalSetupHowItWorksNote(_ p1: Any) -> String {
      return L10n.tr("Localizable", "FastLocalSetup_HowItWorks_Note", String(describing: p1), fallback: "_")
    }
        internal static func fastLocalSetupHowItWorksResetAvailableDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "FastLocalSetup_HowItWorks_ResetAvailable_Description", String(describing: p1), fallback: "_")
    }
        internal static let fastLocalSetupHowItWorksTitle = L10n.tr("Localizable", "FastLocalSetup_HowItWorks_Title", fallback: "How it works")
        internal static let fastLocalSetupMasterPasswordReset = L10n.tr("Localizable", "FastLocalSetup_MasterPasswordReset", fallback: "Biometric recovery")
        internal static let fastLocalSetupMasterPasswordResetDescription = L10n.tr("Localizable", "FastLocalSetup_MasterPasswordReset_Description", fallback: "In case you forget it.")
        internal static let fastLocalSetupRememberMPDescription = L10n.tr("Localizable", "FastLocalSetup_RememberMP_Description", fallback: "Unlock Dashlane automatically for 14 days.")
        internal static let fastLocalSetupRememberMPTitle = L10n.tr("Localizable", "FastLocalSetup_RememberMP_Title", fallback: "Keep me logged in")
        internal static let fastLocalSetupTitle = L10n.tr("Localizable", "FastLocalSetup_Title", fallback: "Make Dashlane fast and easy")
        internal static let fastLocalSetupTouchIDDescription = L10n.tr("Localizable", "FastLocalSetup_TouchID_Description", fallback: "Unlock Dashlane with one touch.")
        internal static let fetchFail = L10n.tr("Localizable", "FetchFail", fallback: "Failed to load information from Apple's servers")
        internal static let fetchFailTryAgain = L10n.tr("Localizable", "FetchFailTryAgain", fallback: "Try again")
        internal static let generatedPasswordGeneratedNoDomain = L10n.tr("Localizable", "GENERATED_PASSWORD_GENERATED_NO_DOMAIN", fallback: "Generated")
        internal static func generatedPasswordGeneratedOn(_ p1: Any) -> String {
      return L10n.tr("Localizable", "GENERATED_PASSWORD_GENERATED_ON", String(describing: p1), fallback: "_")
    }
        internal static let generatedPasswordHeaderDay = L10n.tr("Localizable", "GENERATED_PASSWORD_HEADER_DAY", fallback: "Generated in the last 24 hours")
        internal static let generatedPasswordHeaderMonth = L10n.tr("Localizable", "GENERATED_PASSWORD_HEADER_MONTH", fallback: "Generated last month")
        internal static let generatedPasswordHeaderOlder = L10n.tr("Localizable", "GENERATED_PASSWORD_HEADER_OLDER", fallback: "Generated over 1 year ago")
        internal static let generatedPasswordHeaderYear = L10n.tr("Localizable", "GENERATED_PASSWORD_HEADER_YEAR", fallback: "Generated last year")
        internal static let generatedPasswordListEmptyTitle = L10n.tr("Localizable", "GENERATED_PASSWORD_LIST_EMPTY_TITLE", fallback: "You haven’t generated any password yet")
        internal static func generatedPasswordSavedOn(_ p1: Any) -> String {
      return L10n.tr("Localizable", "GENERATED_PASSWORD_SAVED_ON", String(describing: p1), fallback: "_")
    }
        internal static let guidedOnboardingAnotherManagerAltAction = L10n.tr("Localizable", "GuidedOnboarding_AnotherManager_AltAction", fallback: "How secure is Dashlane?")
        internal static let guidedOnboardingAnotherManagerDescription = L10n.tr("Localizable", "GuidedOnboarding_AnotherManager_Description", fallback: "Glad to have you here! We’ll start you off by helping you import your passwords and login details from your other password manager to Dashlane.")
        internal static let guidedOnboardingAnotherManagerTitle = L10n.tr("Localizable", "GuidedOnboarding_AnotherManager_Title", fallback: "I use a password manager")
        internal static let guidedOnboardingAutofillDescription = L10n.tr("Localizable", "GuidedOnboarding_Autofill_Description", fallback: "Gladly! Our Autofill feature will help you log in to sites and apps instantly.")
        internal static let guidedOnboardingAutofillTitle = L10n.tr("Localizable", "GuidedOnboarding_Autofill_Title", fallback: "Type my logins for me")
        internal static let guidedOnboardingBrowserAltAction = L10n.tr("Localizable", "GuidedOnboarding_Browser_AltAction", fallback: "Is Dashlane really better?")
        internal static let guidedOnboardingBrowserDescription = L10n.tr("Localizable", "GuidedOnboarding_Browser_Description", fallback: "You’re in safe hands. We’ll start you off by helping you import your passwords and login details from your browser to Dashlane.")
        internal static let guidedOnboardingBrowserTitle = L10n.tr("Localizable", "GuidedOnboarding_Browser_Title", fallback: "My browser does it for me")
        internal static let guidedOnboardingCreatingPlan = L10n.tr("Localizable", "GuidedOnboarding_CreatingPlan", fallback: "We’re building your setup plan")
        internal static let guidedOnboardingFAQDashlaneHackedDescription = L10n.tr("Localizable", "GuidedOnboarding_FAQ_DashlaneHacked_Description", fallback: "Hackers won’t be able to see your passwords. We don’t save your Master Password in any form. Without it, your data remains safely indecipherable. This means that even in the unlikely event that Dashlane is hacked, everything in your account will remain securely encrypted.")
        internal static let guidedOnboardingFAQDashlaneHackedTitle = L10n.tr("Localizable", "GuidedOnboarding_FAQ_DashlaneHacked_Title", fallback: "What if Dashlane gets hacked?")
        internal static let guidedOnboardingFAQDashlaneMakeMoneyDescription = L10n.tr("Localizable", "GuidedOnboarding_FAQ_DashlaneMakeMoney_Description", fallback: "We have a Premium plan. We never sell or share any data. You can learn more about our plans in your account section in the app.")
        internal static let guidedOnboardingFAQDashlaneMakeMoneyTitle = L10n.tr("Localizable", "GuidedOnboarding_FAQ_DashlaneMakeMoney_Title", fallback: "How does Dashlane make money?")
                internal static let guidedOnboardingFAQDashlaneMoreSecureDescription = L10n.tr("Localizable", "GuidedOnboarding_FAQ_DashlaneMoreSecure_Description", fallback: "The simple answer is yes. We designed Dashlane to be decentralized, which means that every user’s account is completely separate. So, even in the highly unlikely event that someone broke into Dashlane’s server and an account was compromised, all others would remain safe.\n\nIn contrast, Login with Facebook and other similar features from Big Tech are centralized systems. Which means all accounts are at risk when they get hacked.")
        internal static let guidedOnboardingFAQDashlaneMoreSecureTitle = L10n.tr("Localizable", "GuidedOnboarding_FAQ_DashlaneMoreSecure_Title", fallback: "Is Dashlane really more secure?")
        internal static let guidedOnboardingFAQDashlaneSeePasswordDescription = L10n.tr("Localizable", "GuidedOnboarding_FAQ_DashlaneSeePassword_Description", fallback: "We can’t. Everything you store in Dashlane is encrypted (converted to a scrambled code). The key to access this data is your Master Password, and only you know that.")
        internal static let guidedOnboardingFAQDashlaneSeePasswordTitle = L10n.tr("Localizable", "GuidedOnboarding_FAQ_DashlaneSeePassword_Title", fallback: "Can Dashlane see my passwords?")
        internal static let guidedOnboardingFAQLeaveAndTakeDataDescription = L10n.tr("Localizable", "GuidedOnboarding_FAQ_LeaveAndTakeData_Description", fallback: "Yes, you can. We built a feature that allows you to export your data whenever you like.")
        internal static let guidedOnboardingFAQLeaveAndTakeDataTitle = L10n.tr("Localizable", "GuidedOnboarding_FAQ_LeaveAndTakeData_Title", fallback: "Can I leave and take my data?")
        internal static let guidedOnboardingFAQTitle = L10n.tr("Localizable", "GuidedOnboarding_FAQ_Title", fallback: "Here are the questions we get asked most often:")
        internal static let guidedOnboardingHowDescription = L10n.tr("Localizable", "GuidedOnboarding_How_Description", fallback: "Pick the main method you use today.")
        internal static let guidedOnboardingHowTitle = L10n.tr("Localizable", "GuidedOnboarding_How_Title", fallback: "How do you keep track of your logins?")
        internal static let guidedOnboardingImportMethodBest = L10n.tr("Localizable", "GuidedOnboarding_ImportMethod_Best", fallback: "Best for you")
        internal static let guidedOnboardingImportMethodChrome = L10n.tr("Localizable", "GuidedOnboarding_ImportMethod_Chrome", fallback: "Import from Chrome")
        internal static let guidedOnboardingImportMethodDash = L10n.tr("Localizable", "GuidedOnboarding_ImportMethod_Dash", fallback: "Import from a Dashlane backup file ")
        internal static let guidedOnboardingImportMethodFastest = L10n.tr("Localizable", "GuidedOnboarding_ImportMethod_Fastest", fallback: "Fastest")
        internal static let guidedOnboardingImportMethodKeychain = L10n.tr("Localizable", "GuidedOnboarding_ImportMethod_Keychain", fallback: "Add from Apple Keychain")
        internal static let guidedOnboardingImportMethodKeychainCSV = L10n.tr("Localizable", "GuidedOnboarding_ImportMethod_KeychainCSV", fallback: "Import from Apple Keychain")
        internal static let guidedOnboardingImportMethodManual = L10n.tr("Localizable", "GuidedOnboarding_ImportMethod_Manual", fallback: "Add manually")
        internal static let guidedOnboardingImportMethodOther = L10n.tr("Localizable", "GuidedOnboarding_ImportMethod_Other", fallback: "Other methods")
        internal static let guidedOnboardingMemorizePasswordsAltAction = L10n.tr("Localizable", "GuidedOnboarding_MemorizePasswords_AltAction", fallback: "What about hacks?")
        internal static let guidedOnboardingMemorizePasswordsDescription = L10n.tr("Localizable", "GuidedOnboarding_MemorizePasswords_Description", fallback: "Allow us to free up some of your precious brain space! We’ll start you off by helping you transfer your passwords and login details from your memory to Dashlane.")
        internal static let guidedOnboardingMemorizePasswordsTitle = L10n.tr("Localizable", "GuidedOnboarding_MemorizePasswords_Title", fallback: "I memorize them")
        internal static let guidedOnboardingNext = L10n.tr("Localizable", "GuidedOnboarding_Next", fallback: "Continue")
        internal static func guidedOnboardingNumberingLabel(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "GuidedOnboarding_NumberingLabel", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let guidedOnboardingPlanReady = L10n.tr("Localizable", "GuidedOnboarding_PlanReady", fallback: "Your plan is ready!")
        internal static let guidedOnboardingProtectAccountsDescription = L10n.tr("Localizable", "GuidedOnboarding_ProtectAccounts_Description", fallback: "You’ve come to the right place. We’ll give you a dedicated vault for all your stuff and help you make your passwords strong and unique.")
        internal static let guidedOnboardingProtectAccountsTitle = L10n.tr("Localizable", "GuidedOnboarding_ProtectAccounts_Title", fallback: "Protect my logins")
        internal static let guidedOnboardingSomethingElseAltAction = L10n.tr("Localizable", "GuidedOnboarding_SomethingElse_AltAction", fallback: "What about hacks?")
        internal static let guidedOnboardingSomethingElseDescription = L10n.tr("Localizable", "GuidedOnboarding_SomethingElse_Description", fallback: "Ok, nice! We’ll start you off by helping you transfer the passwords and login details from your memory to Dashlane. You can always try the other import methods too.")
        internal static let guidedOnboardingSomethingElseTitle = L10n.tr("Localizable", "GuidedOnboarding_SomethingElse_Title", fallback: "I do something else")
        internal static let guidedOnboardingStoreAccountsSecurelyDescription = L10n.tr("Localizable", "GuidedOnboarding_StoreAccountsSecurely_Description", fallback: "Consider it done. We’ll help you bring all your logins under one roof, and only you have the key.")
        internal static let guidedOnboardingStoreAccountsSecurelyTitle = L10n.tr("Localizable", "GuidedOnboarding_StoreAccountsSecurely_Title", fallback: "Store my logins securely")
        internal static let guidedOnboardingSwipeToReveal = L10n.tr("Localizable", "GuidedOnboarding_SwipeToReveal", fallback: "Swipe up to reveal")
        internal static let guidedOnboardingSyncPasswordsDescription = L10n.tr("Localizable", "GuidedOnboarding_SyncPasswords_Description", fallback: "Consider it done. We’ll help you install Dashlane everywhere you use the internet so you'll always have access to your passwords and login details.")
        internal static let guidedOnboardingSyncPasswordsTitle = L10n.tr("Localizable", "GuidedOnboarding_SyncPasswords_Title", fallback: "Sync logins across my devices")
        internal static let guidedOnboardingWarnAboutHacksDescription = L10n.tr("Localizable", "GuidedOnboarding_WarnAboutHacks_Description", fallback: "We’ve got your back. We’ll notify you when a website you have an account with gets hacked, and then help you protect your account.")
        internal static let guidedOnboardingWarnAboutHacksTitle = L10n.tr("Localizable", "GuidedOnboarding_WarnAboutHacks_Title", fallback: "Warn me about hacks")
        internal static let guidedOnboardingWhyDashlaneDescription = L10n.tr("Localizable", "GuidedOnboarding_WhyDashlane_Description", fallback: "Pick the thing you want most. ")
        internal static let guidedOnboardingWhyDashlaneTitle = L10n.tr("Localizable", "GuidedOnboarding_WhyDashlane_Title", fallback: "How can we make your life easier?")
        internal static let health = L10n.tr("Localizable", "health", fallback: "Health")
        internal static let helpCenterDeleteAccountTitle = L10n.tr("Localizable", "HELP_CENTER_DELETE_ACCOUNT_TITLE", fallback: "Delete my account")
        internal static let helpCenterFeedbackSubtitle = L10n.tr("Localizable", "HELP_CENTER_FEEDBACK_SUBTITLE", fallback: "Share an idea to improve Dashlane")
        internal static let helpCenterFeedbackTitle = L10n.tr("Localizable", "HELP_CENTER_FEEDBACK_TITLE", fallback: "Suggest a feature")
        internal static let helpCenterGetStartedSubtitle = L10n.tr("Localizable", "HELP_CENTER_GET_STARTED_SUBTITLE", fallback: "Learn more about Dashlane's features")
        internal static let helpCenterGetStartedTitle = L10n.tr("Localizable", "HELP_CENTER_GET_STARTED_TITLE", fallback: "How-to Guide")
        internal static let helpCenterHavingTroubleSubtitle = L10n.tr("Localizable", "HELP_CENTER_HAVING_TROUBLE_SUBTITLE", fallback: "Consult the Help Center to answer your questions")
        internal static let helpCenterHavingTroubleTitle = L10n.tr("Localizable", "HELP_CENTER_HAVING_TROUBLE_TITLE", fallback: "Troubleshooting")
        internal static let helpCenterTitle = L10n.tr("Localizable", "HELP_CENTER_TITLE", fallback: "Help")
        internal static let identityDashboardTitle = L10n.tr("Localizable", "IDENTITY_DASHBOARD_TITLE", fallback: "Password Health")
        internal static let identityDashboardToolsSubtitle = L10n.tr("Localizable", "IDENTITY_DASHBOARD_TOOLS_SUBTITLE", fallback: "See Password Health and alerts")
        internal static let identityDashboardToolsTitle = L10n.tr("Localizable", "IDENTITY_DASHBOARD_TOOLS_TITLE", fallback: "Password Health")
        internal static func identityDashboardUnresolvedIssuesTitle(_ p1: Int) -> String {
      return L10n.tr("Localizable", "IDENTITY_DASHBOARD_UNRESOLVED_ISSUES_TITLE", p1, fallback: "You have %1$d security alerts")
    }
        internal static let identityDashboardUnresolvedIssuesView = L10n.tr("Localizable", "IDENTITY_DASHBOARD_UNRESOLVED_ISSUES_VIEW", fallback: "View")
        internal static let identityProtectionEnabledCreditMonitoring = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_CREDIT_MONITORING", fallback: "Credit Monitoring")
        internal static let identityProtectionEnabledCreditMonitoringCta = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_CREDIT_MONITORING_CTA", fallback: "Check my CreditView")
        internal static let identityProtectionEnabledCreditMonitoringMessage1 = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_CREDIT_MONITORING_MESSAGE_1", fallback: "Monitor your credit score and history from your CreditView Dashboard.")
        internal static let identityProtectionEnabledCreditMonitoringMessage2 = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_CREDIT_MONITORING_MESSAGE_2", fallback: "Receive email alerts when your credit may change.")
        internal static let identityProtectionEnabledCreditMonitoringMessage3 = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_CREDIT_MONITORING_MESSAGE_3", fallback: "Compare your score to the national average.")
        internal static let identityProtectionEnabledIdRestoration = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_RESTORATION", fallback: "Identity Restoration")
        internal static let identityProtectionEnabledIdRestorationCta = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_RESTORATION_CTA", fallback: "Learn more")
        internal static func identityProtectionEnabledIdRestorationMessage1(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_RESTORATION_MESSAGE_1", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let identityProtectionEnabledIdRestorationMessage2 = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_RESTORATION_MESSAGE_2", fallback: "Your dedicated TransUnion representative will assess the extent of your identity theft.")
        internal static let identityProtectionEnabledIdRestorationMessage3 = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_RESTORATION_MESSAGE_3", fallback: "A specialized team of identity theft experts will create a customized action plan to streamline the process of restoring your identity.")
        internal static let identityProtectionEnabledIdTheftInsurance = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_THEFT_INSURANCE", fallback: "Identity Theft Insurance")
        internal static let identityProtectionEnabledIdTheftInsuranceCta = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_THEFT_INSURANCE_CTA", fallback: "Learn more")
        internal static func identityProtectionEnabledIdTheftInsuranceMessage1(_ p1: Any) -> String {
      return L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_THEFT_INSURANCE_MESSAGE_1", String(describing: p1), fallback: "_")
    }
        internal static let identityProtectionEnabledIdTheftInsuranceMessage2 = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_THEFT_INSURANCE_MESSAGE_2", fallback: "Provide the email address you use to log in to Dashlane. No code is required.")
        internal static let identityProtectionEnabledIdTheftInsuranceMessage3 = L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_ID_THEFT_INSURANCE_MESSAGE_3", fallback: "Claim up to $1 million in identity theft damages.")
        internal static func identityProtectionEnabledPoweredBy(_ p1: Any) -> String {
      return L10n.tr("Localizable", "IDENTITY_PROTECTION_ENABLED_POWERED_BY", String(describing: p1), fallback: "_")
    }
        internal static let identityProtectionPremiumOnlyCta = L10n.tr("Localizable", "IDENTITY_PROTECTION_PREMIUM_ONLY_CTA", fallback: "Go Premium Plus")
        internal static let identityProtectionPremiumOnlyDescription = L10n.tr("Localizable", "IDENTITY_PROTECTION_PREMIUM_ONLY_DESCRIPTION", fallback: "Upgrade to Premium Plus to protect your identity with credit monitoring and Identity Theft Insurance.")
        internal static let identityProtectionPremiumOnlyTitle = L10n.tr("Localizable", "IDENTITY_PROTECTION_PREMIUM_ONLY_TITLE", fallback: "These are Premium Plus features.")
        internal static let identityRestorationErrorLink = L10n.tr("Localizable", "IDENTITY_RESTORATION_ERROR_LINK", fallback: "Unable to retrieve Dashboard. Please try again.")
        internal static let importerImporting = L10n.tr("Localizable", "IMPORTER_IMPORTING", fallback: "Importing your data...")
        internal static let importerSuccessCta = L10n.tr("Localizable", "IMPORTER_SUCCESS_CTA", fallback: "Done")
        internal static let importerSuccessText = L10n.tr("Localizable", "IMPORTER_SUCCESS_TEXT", fallback: "Data imported")
        internal static let importerUnlockAlertErrorMessage = L10n.tr("Localizable", "IMPORTER_UNLOCK_ALERT_ERROR_MESSAGE", fallback: "We were unable to import the data. Please check that the file is correct.")
        internal static let importerUnlockAlertErrorTitle = L10n.tr("Localizable", "IMPORTER_UNLOCK_ALERT_ERROR_TITLE", fallback: "Unable to import")
        internal static let importerUnlockAlertMessage = L10n.tr("Localizable", "IMPORTER_UNLOCK_ALERT_MESSAGE", fallback: "Please enter the password that has been used to encrypt this data.")
        internal static let importerUnlockAlertPlaceholder = L10n.tr("Localizable", "IMPORTER_UNLOCK_ALERT_PLACEHOLDER", fallback: "password")
        internal static let importerUnlockAlertTitle = L10n.tr("Localizable", "IMPORTER_UNLOCK_ALERT_TITLE", fallback: "Unlock your data")
        internal static let importerUnlockAlertUnableDecipherMessage = L10n.tr("Localizable", "IMPORTER_UNLOCK_ALERT_UNABLE_DECIPHER_MESSAGE", fallback: "We were unable to decrypt the data. Please check that you entered the right password to decrypt it.")
        internal static let importerUnlockAlertUnableDecipherTitle = L10n.tr("Localizable", "IMPORTER_UNLOCK_ALERT_UNABLE_DECIPHER_TITLE", fallback: "Unable to decrypt")
        internal static let importerUnlockAlertUnlockCta = L10n.tr("Localizable", "IMPORTER_UNLOCK_ALERT_UNLOCK_CTA", fallback: "Unlock data")
        internal static let importFileButtonTitle = L10n.tr("Localizable", "importFileButtonTitle", fallback: "Import file")
        internal static let internalDashlaneLabsInfoFeedbackCta = L10n.tr("Localizable", "internal_dashlaneLabs_info_feedback_cta", fallback: "Share your feedback")
        internal static let internalDashlaneLabsInfoText = L10n.tr("Localizable", "internal_dashlaneLabs_info_text", fallback: "Dashlane Labs lets you see what features are on and off on your session.")
        internal static let internalDashlaneLabsSettingsButton = L10n.tr("Localizable", "internal_dashlaneLabs_settings_button", fallback: "Dashlane Labs")
        internal static let internalDashlaneLabsTitle = L10n.tr("Localizable", "internal_dashlaneLabs_title", fallback: "Dashlane Labs")
        internal static let itemAccessUnlockPrompt = L10n.tr("Localizable", "ITEM_ACCESS_UNLOCK_PROMPT", fallback: "Unlock this secure item")
        internal static let itemsConfidentialCardsFilterPlaceholder = L10n.tr("Localizable", "ITEMS_CONFIDENTIAL_CARDS_FILTER_PLACEHOLDER", fallback: "Search IDs")
        internal static let itemsCredentialsFilterPlaceholder = L10n.tr("Localizable", "ITEMS_CREDENTIALS_FILTER_PLACEHOLDER", fallback: "Search logins")
        internal static let itemsNotesFilterPlaceholder = L10n.tr("Localizable", "ITEMS_NOTES_FILTER_PLACEHOLDER", fallback: "Search secure notes")
        internal static let itemsPaymentMeansFilterPlaceholder = L10n.tr("Localizable", "ITEMS_PAYMENT_MEANS_FILTER_PLACEHOLDER", fallback: "Search payments")
        internal static let itemsPersonalInfoFilterPlaceholder = L10n.tr("Localizable", "ITEMS_PERSONAL_INFO_FILTER_PLACEHOLDER", fallback: "Search personal info")
        internal static let itemsTabSearchPlaceholder = L10n.tr("Localizable", "ITEMS_TAB_SEARCH_PLACEHOLDER", fallback: "Search all items")
        internal static let keyboardShortcutDashlaneHelp = L10n.tr("Localizable", "KEYBOARD_SHORTCUT_DASHLANE_HELP", fallback: "Dashlane Help")
        internal static func keyboardShortcutLastSync(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KEYBOARD_SHORTCUT_LAST_SYNC", String(describing: p1), fallback: "_")
    }
        internal static let keyboardShortcutSync = L10n.tr("Localizable", "KEYBOARD_SHORTCUT_SYNC", fallback: "Sync")
        internal static let keyboardShortcutSyncNow = L10n.tr("Localizable", "KEYBOARD_SHORTCUT_SYNC_NOW", fallback: "Sync now")
        internal static let keyboardShortcutSyncing = L10n.tr("Localizable", "KEYBOARD_SHORTCUT_SYNCING", fallback: "Syncing...")
        internal static let keychainInstructionsCancel = L10n.tr("Localizable", "KeychainInstructions_Cancel", fallback: "Cancel")
        internal static let keychainInstructionsChoosePasswordToCopy = L10n.tr("Localizable", "KeychainInstructions_ChoosePasswordToCopy", fallback: "From there, choose a password and login details to copy, then return to Dashlane to add it as a new login.")
        internal static let keychainInstructionsCTA = L10n.tr("Localizable", "KeychainInstructions_CTA", fallback: "Open Settings")
        internal static let keychainInstructionsHowToFindSearchBar = L10n.tr("Localizable", "KeychainInstructions_HowToFindSearchBar", fallback: "Scroll up to find the search bar in your device’s Settings app.")
        internal static let keychainInstructionsTitle = L10n.tr("Localizable", "KeychainInstructions_Title", fallback: "In your device settings, search for:")
        internal static let keychainInstructionsWebsitesAndAppPasswords = L10n.tr("Localizable", "KeychainInstructions_WebsitesAndAppPasswords", fallback: "Website & App Passwords")
        internal static let kwAcceptSharing = L10n.tr("Localizable", "KW_ACCEPT_SHARING", fallback: "Accept")
        internal static let kwAccessAttachment = L10n.tr("Localizable", "KW_ACCESS_ATTACHMENT", fallback: "Open")
        internal static let kwAccount = L10n.tr("Localizable", "KW_ACCOUNT", fallback: "Account")
        internal static let kwAccountCreationEmailConfirmationFailedMessage = L10n.tr("Localizable", "KW_ACCOUNT_CREATION_EMAIL_CONFIRMATION_FAILED_MESSAGE", fallback: "The email addresses don't match. Please try again.")
        internal static let kwAccountStatusFree = L10n.tr("Localizable", "KW_ACCOUNT_STATUS_FREE", fallback: "Free")
        internal static let kwAddButton = L10n.tr("Localizable", "KW_ADD_BUTTON", fallback: "Add")
        internal static let kwAddPwdsOnbdingEmailPlaceholder = L10n.tr("Localizable", "KW_ADD_PWDS_ONBDING_EMAIL_PLACEHOLDER", fallback: "Enter your email address")
        internal static let kwAutoLock = L10n.tr("Localizable", "KW_AUTO_LOCK", fallback: "Auto Lock")
        internal static let kwAutoLockTime = L10n.tr("Localizable", "KW_AUTO_LOCK_TIME", fallback: "Auto-lock timeout")
        internal static let kwCannotSendToSelfMsg = L10n.tr("Localizable", "KW_CANNOT_SEND_TO_SELF_MSG", fallback: "You cannot share this item with yourself.")
        internal static let kwCategoriesListTitle = L10n.tr("Localizable", "KW_CATEGORIES_LIST_TITLE", fallback: "Categories")
        internal static let kwCategoryAddMsg = L10n.tr("Localizable", "KW_CATEGORY_ADD_MSG", fallback: "Enter a name for the new category")
        internal static let kwChangePassword = L10n.tr("Localizable", "KW_CHANGE_PASSWORD", fallback: "Change password")
        internal static let kwCmContinue = L10n.tr("Localizable", "KW_CM_CONTINUE", fallback: "Continue")
        internal static let kwComposeShareMessageAllItems = L10n.tr("Localizable", "KW_COMPOSE_SHARE_MESSAGE_ALL_ITEMS", fallback: "All logins and Secure Notes")
        internal static func kwComposeShareMessagePluralItem(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_COMPOSE_SHARE_MESSAGE_PLURAL_ITEM", p1, fallback: "%1$d items")
    }
        internal static func kwComposeShareMessageSingularItem(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_COMPOSE_SHARE_MESSAGE_SINGULAR_ITEM", p1, fallback: "%1$d item")
    }
        internal static let kwContinueAnyway = L10n.tr("Localizable", "KW_CONTINUE_ANYWAY", fallback: "Continue anyway")
        internal static let kwCopyDriverLicenseNumberButton = L10n.tr("Localizable", "KW_COPY_DRIVER_LICENSE_NUMBER_BUTTON", fallback: "Copy license number")
        internal static let kwCopyFiscalNumberButton = L10n.tr("Localizable", "KW_COPY_FISCAL_NUMBER_BUTTON", fallback: "Copy tax number")
        internal static let kwCopyIdentityCardNumberButton = L10n.tr("Localizable", "KW_COPY_IDENTITY_CARD_NUMBER_BUTTON", fallback: "Copy ID card number")
        internal static let kwCopyPassportNumberButton = L10n.tr("Localizable", "KW_COPY_PASSPORT_NUMBER_BUTTON", fallback: "Copy passport number")
        internal static let kwCopyPasswordButton = L10n.tr("Localizable", "KW_COPY_PASSWORD_BUTTON", fallback: "Copy password")
        internal static let kwCopySocialSecurityNumberButton = L10n.tr("Localizable", "KW_COPY_SOCIAL_SECURITY_NUMBER_BUTTON", fallback: "Copy number")
        internal static func kwCreateAccountTermsConditionsPrivacyNotice(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "KW_CREATE_ACCOUNT_TERMS_CONDITIONS_PRIVACY_NOTICE", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let kwCryptoDescription = L10n.tr("Localizable", "KW_CRYPTO_DESCRIPTION", fallback: "Go to your Security settings in the web application to edit your key derivation function.")
        internal static let kwCryptography = L10n.tr("Localizable", "KW_CRYPTOGRAPHY", fallback: "Cryptography")
        internal static let kwD2MCtaNotnow = L10n.tr("Localizable", "KW_D2M_CTA_NOTNOW", fallback: "Not now")
        internal static let kwDenySharingRequest = L10n.tr("Localizable", "KW_DENY_SHARING_REQUEST", fallback: "Decline")
        internal static let kwDeviceDeactivate = L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE", fallback: "Remove")
        internal static let kwDeviceDeactivateFailureMsg = L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE_FAILURE_MSG", fallback: "Failed to deactivate device")
        internal static let kwDeviceDeactivateFailureTitle = L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE_FAILURE_TITLE", fallback: "Deactivate")
        internal static let kwDeviceDeactivateMessage = L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE_MESSAGE", fallback: "To access Dashlane from a removed device, you’ll need to log in again and re-verify that device.")
        internal static let kwDeviceDeactivateMsg = L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE_MSG", fallback: "This will remove your account from the device, are you sure?")
        internal static func kwDeviceDeactivateMsgMultiple(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE_MSG_MULTIPLE", String(describing: p1), fallback: "_")
    }
        internal static let kwDeviceDeactivateTitle = L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE_TITLE", fallback: "Deactivate")
        internal static func kwDeviceDeactivateTitleMultiple(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE_TITLE_MULTIPLE", String(describing: p1), fallback: "_")
    }
        internal static let kwDeviceDeactivateTitleSingle = L10n.tr("Localizable", "KW_DEVICE_DEACTIVATE_TITLE_SINGLE", fallback: "Remove 1 device")
        internal static let kwDeviceHeaderDay = L10n.tr("Localizable", "KW_DEVICE_HEADER_DAY", fallback: "Active in the last 24 hours")
        internal static let kwDeviceHeaderMonth = L10n.tr("Localizable", "KW_DEVICE_HEADER_MONTH", fallback: "Active in the last month")
        internal static let kwDeviceHeaderOlder = L10n.tr("Localizable", "KW_DEVICE_HEADER_OLDER", fallback: "Previously active")
        internal static let kwDeviceHeaderYear = L10n.tr("Localizable", "KW_DEVICE_HEADER_YEAR", fallback: "Active in the last year")
        internal static let kwDeviceLastActive = L10n.tr("Localizable", "KW_DEVICE_LAST_ACTIVE", fallback: "Last active")
        internal static let kwDeviceListTitle = L10n.tr("Localizable", "KW_DEVICE_LIST_TITLE", fallback: "Manage activity")
        internal static let kwDeviceListToolbarSelectAll = L10n.tr("Localizable", "KW_DEVICE_LIST_TOOLBAR_SELECT_ALL", fallback: "Select all devices")
        internal static let kwDeviceListToolbarSelectOthers = L10n.tr("Localizable", "KW_DEVICE_LIST_TOOLBAR_SELECT_OTHERS", fallback: "Select all other devices")
        internal static let kwDeviceListToolbarTitle = L10n.tr("Localizable", "KW_DEVICE_LIST_TOOLBAR_TITLE", fallback: "Select devices")
        internal static let kwDeviceListToolbarUnselectAll = L10n.tr("Localizable", "KW_DEVICE_LIST_TOOLBAR_UNSELECT_ALL", fallback: "Unselect all devices")
        internal static let kwDeviceNotProtectedAlertBody = L10n.tr("Localizable", "KW_DEVICE_NOT_PROTECTED_ALERT_BODY", fallback: "For your security, you must have a passcode on this device.")
        internal static let kwDeviceNotProtectedAlertTitle = L10n.tr("Localizable", "KW_DEVICE_NOT_PROTECTED_ALERT_TITLE", fallback: "Add a passcode to use PIN")
        internal static let kwDismissButton = L10n.tr("Localizable", "KW_DISMISS_BUTTON", fallback: "Dismiss")
        internal static func kwDocumentBigMessage(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "KW_DOCUMENT_BIG_MESSAGE", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let kwDocumentBigTitle = L10n.tr("Localizable", "KW_DOCUMENT_BIG_TITLE", fallback: "This file is too big")
        internal static let kwEmailSeemsBad = L10n.tr("Localizable", "KW_EMAIL_SEEMS_BAD", fallback: "This email address seems incorrect.")
        internal static let kwEssentialsFeature = L10n.tr("Localizable", "KW_ESSENTIALS_FEATURE", fallback: "Dashlane Essentials")
        internal static let kwFileUploadedSuccessfully = L10n.tr("Localizable", "KW_FILE_UPLOADED_SUCCESSFULLY", fallback: "Upload complete")
        internal static let kwFreeUserPremiumPromptNo = L10n.tr("Localizable", "KW_FREE_USER_PREMIUM_PROMPT_NO", fallback: "Not now")
        internal static let kwFreeUserPremiumPromptYes = L10n.tr("Localizable", "KW_FREE_USER_PREMIUM_PROMPT_YES", fallback: "Upgrade to Premium")
        internal static let kwGeneral = L10n.tr("Localizable", "KW_GENERAL", fallback: "General")
        internal static let kwGoPremium = L10n.tr("Localizable", "KW_GO_PREMIUM", fallback: "Go Premium")
        internal static let kwGotoWebsite = L10n.tr("Localizable", "KW_GOTO_WEBSITE", fallback: "Go to website")
        internal static let kwGrantAdminRights = L10n.tr("Localizable", "KW_GRANT_ADMIN_RIGHTS", fallback: "Change to full rights")
        internal static let kwHelpCenter = L10n.tr("Localizable", "KW_HELP_CENTER", fallback: "Help Center")
        internal static let kwInvalidAddress = L10n.tr("Localizable", "KW_INVALID_ADDRESS", fallback: "Send")
        internal static func kwInvalidAddressMsg(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_INVALID_ADDRESS_MSG", String(describing: p1), fallback: "_")
    }
        internal static let kwInvalidAddressTitle = L10n.tr("Localizable", "KW_INVALID_ADDRESS_TITLE", fallback: "Invalid email address")
                        internal static func kwInviteEmailBody(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_INVITE_EMAIL_BODY", String(describing: p1), fallback: "Hi! I've been using Dashlane for a while and I like it a lot. Dashlane is a free password manager and secure digital wallet. It keeps track of all your passwords and login details, and autofills all forms including logins and checkouts. Check it out:\n\n_\nCheers!")
    }
        internal static let kwInviteFriends = L10n.tr("Localizable", "KW_INVITE_FRIENDS", fallback: "Invite friends")
        internal static let kwIosIntegrationSettingsSectionFooter = L10n.tr("Localizable", "KW_IOS_INTEGRATION_SETTINGS_SECTION_FOOTER", fallback: "Access Dashlane items from convenient places across your device such as Spotlight search, the Dashlane widget in your Today View, and get proactive suggestions. Your data is made available to you strictly locally, and is never shared with Apple or third party apps.  ")
        internal static let kwIosIntegrationSettingsSwitchTitle = L10n.tr("Localizable", "KW_IOS_INTEGRATION_SETTINGS_SWITCH_TITLE", fallback: "Advanced system integration")
        internal static let kwItemShared = L10n.tr("Localizable", "KW_ITEM_SHARED", fallback: "item shared")
        internal static let kwItemsShared = L10n.tr("Localizable", "KW_ITEMS_SHARED", fallback: "items shared")
        internal static let kwKeyDerivationAlgo = L10n.tr("Localizable", "KW_KEY_DERIVATION_ALGO", fallback: "Key derivation function")
        internal static func kwKeychainPasswordMsg(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_KEYCHAIN_PASSWORD_MSG", String(describing: p1), fallback: "_")
    }
        internal static let kwKeychainPasswordMsgPinOnly = L10n.tr("Localizable", "KW_KEYCHAIN_PASSWORD_MSG_PIN_ONLY", fallback: "When using a PIN, your Master Password is securely memorized on this device")
        internal static let kwLinkedDefaultNone = L10n.tr("Localizable", "KW_Linked_Default_None", fallback: "None")
        internal static let kwLock = L10n.tr("Localizable", "KW_LOCK", fallback: "Lock")
        internal static let kwLockNow = L10n.tr("Localizable", "KW_LOCK_NOW", fallback: "Lock app")
        internal static let kwLockOnExit = L10n.tr("Localizable", "KW_LOCK_ON_EXIT", fallback: "Lock on exit")
        internal static let kwLockOnExitForced = L10n.tr("Localizable", "KW_LOCK_ON_EXIT_FORCED", fallback: "Your company policy requires lock on exit to be enabled. For more information, contact your account admin.")
        internal static let kwM2DLetsGoButton = L10n.tr("Localizable", "KW_M2D_LETS_GO_BUTTON", fallback: "Connect my computer")
        internal static let kwM2DSpendFewTimeTitle = L10n.tr("Localizable", "KW_M2D_SPEND_FEW_TIME_TITLE", fallback: "Have your logins everywhere")
        internal static let kwMultiDevices = L10n.tr("Localizable", "KW_MULTI_DEVICES", fallback: "New Device Connector")
        internal static let kwNever = L10n.tr("Localizable", "KW_NEVER", fallback: "never")
        internal static let kwNewShareNoInternetTitle = L10n.tr("Localizable", "KW_NEW_SHARE_NO_INTERNET_TITLE", fallback: "No internet connection")
        internal static let kwOff = L10n.tr("Localizable", "KW_OFF", fallback: "OFF")
        internal static let kwOn = L10n.tr("Localizable", "KW_ON", fallback: "ON")
        internal static let kwOnboardingStartButton = L10n.tr("Localizable", "KW_ONBOARDING_START_BUTTON", fallback: "Go")
        internal static let kwOtpAddSecret = L10n.tr("Localizable", "KW_OTP_ADD_SECRET", fallback: "Generate with Dashlane")
        internal static let kwPadExtensionGenerator = L10n.tr("Localizable", "KW_PAD_EXTENSION_GENERATOR", fallback: "Generator")
        internal static let kwPadExtensionGeneratorGeneratedAccessibility = L10n.tr("Localizable", "KW_PAD_EXTENSION_GENERATOR_GENERATED_ACCESSIBILITY", fallback: "Generated password")
        internal static let kwPadFindAppNameOrUrl = L10n.tr("Localizable", "KW_PAD_FIND_APP_NAME_OR_URL", fallback: "Search for a website or app")
        internal static let kwPadFindAppNameOrUrlOnboarding = L10n.tr("Localizable", "KW_PAD_FIND_APP_NAME_OR_URL_ONBOARDING", fallback: "Enter website or app")
        internal static let kwPadNotesLockedNotice = L10n.tr("Localizable", "KW_PAD_NOTES_LOCKED_NOTICE", fallback: "Note locked")
        internal static let kwPadNotesUnlockedNotice = L10n.tr("Localizable", "KW_PAD_NOTES_UNLOCKED_NOTICE", fallback: "Note unlocked")
        internal static let kwPadOrSelectAService = L10n.tr("Localizable", "KW_PAD_OR_SELECT_A_SERVICE", fallback: "Pick a service...")
        internal static let kwPadOrSelectAServiceOnboarding = L10n.tr("Localizable", "KW_PAD_OR_SELECT_A_SERVICE_ONBOARDING", fallback: "Enter the service you want to add or pick one from this list:")
        internal static func kwPadOrSelectAServiceOnboardingElementAccessibility(_ p1: Any, _ p2: Int, _ p3: Int) -> String {
      return L10n.tr("Localizable", "KW_PAD_OR_SELECT_A_SERVICE_ONBOARDING_ELEMENT_ACCESSIBILITY", String(describing: p1), p2, p3, fallback: "_")
    }
        internal static let kwPremium2SinglePremiumTitle = L10n.tr("Localizable", "KW_PREMIUM2_SINGLE_PREMIUM_TITLE", fallback: "Premium")
        internal static let kwPremiumFeature = L10n.tr("Localizable", "KW_PREMIUM_FEATURE", fallback: "Dashlane Premium")
        internal static let kwPurchaseTotal = L10n.tr("Localizable", "KW_PURCHASE_TOTAL", fallback: "Total")
        internal static let kwRateDashlane = L10n.tr("Localizable", "KW_RATE_DASHLANE", fallback: "Rate Dashlane")
        internal static let kwReplace = L10n.tr("Localizable", "KW_REPLACE", fallback: "Replace")
        internal static func kwReplaceBiometryTypeConfirmMsg(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_REPLACE_BIOMETRY_TYPE_CONFIRM_MSG", String(describing: p1), fallback: "_")
    }
        internal static func kwReplacePinConfirmMsg(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_REPLACE_PIN_CONFIRM_MSG", String(describing: p1), fallback: "_")
    }
        internal static let kwRequiresCamera = L10n.tr("Localizable", "KW_REQUIRES_CAMERA", fallback: "")
        internal static let kwResendGroupInvite = L10n.tr("Localizable", "KW_RESEND_GROUP_INVITE", fallback: "Resend invite")
        internal static let kwResendGroupInviteFailure = L10n.tr("Localizable", "KW_RESEND_GROUP_INVITE_FAILURE", fallback: "Re-invite failed, please try again later.")
        internal static let kwResendGroupInviteSuccess = L10n.tr("Localizable", "KW_RESEND_GROUP_INVITE_SUCCESS", fallback: "Invite re-sent")
        internal static let kwRevealButton = L10n.tr("Localizable", "KW_REVEAL_BUTTON", fallback: "Reveal")
        internal static let kwRevokeAccess = L10n.tr("Localizable", "KW_REVOKE_ACCESS", fallback: "Revoke access")
        internal static let kwRevokeAdminRights = L10n.tr("Localizable", "KW_REVOKE_ADMIN_RIGHTS", fallback: "Change to limited rights")
        internal static let kwRevokeAlertMsg = L10n.tr("Localizable", "KW_REVOKE_ALERT_MSG", fallback: "This item will be deleted from the accounts of anyone it's shared with.")
        internal static let kwRevokeAlertTitle = L10n.tr("Localizable", "KW_REVOKE_ALERT_TITLE", fallback: "Are you sure you want to revoke access?")
        internal static let kwSecurity = L10n.tr("Localizable", "KW_SECURITY", fallback: "Security")
        internal static func kwSetClipboardExpiration(_ p1: Float) -> String {
      return L10n.tr("Localizable", "KW_SET_CLIPBOARD_EXPIRATION", p1, fallback: "Clear Clipboard after %1$.0f minutes")
    }
        internal static let kwSettingsClipboardFooter = L10n.tr("Localizable", "KW_SETTINGS_CLIPBOARD_FOOTER", fallback: "Universal Clipboard allows you to copy and paste across connected Apple devices. Disable to copy on this device only. ")
        internal static let kwSettingsClipboardSection = L10n.tr("Localizable", "KW_SETTINGS_CLIPBOARD_SECTION", fallback: "Clipboard")
        internal static func kwSettingsPinBiometryTypeFooter(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_SETTINGS_PIN_BIOMETRY_TYPE_FOOTER", String(describing: p1), fallback: "_")
    }
        internal static let kwSettingsPinTypeFooter = L10n.tr("Localizable", "KW_SETTINGS_PIN_TYPE_FOOTER", fallback: "Unlock Dashlane with a PIN. We'll occasionally ask you to log in with your Master Password for security reasons.")
        internal static let kwSettingsRestoreFooter = L10n.tr("Localizable", "KW_SETTINGS_RESTORE_FOOTER", fallback: "Restore your data from an encrypted Dashlane backup file.")
        internal static let kwSettingsRestoreSection = L10n.tr("Localizable", "KW_SETTINGS_RESTORE_SECTION", fallback: "Restore your vault")
        internal static let kwShare = L10n.tr("Localizable", "KW_SHARE", fallback: "Share")
        internal static let kwShareItem = L10n.tr("Localizable", "KW_SHARE_ITEM", fallback: "New share")
        internal static let kwSharePassword = L10n.tr("Localizable", "KW_SHARE_PASSWORD", fallback: "Share login")
        internal static let kwSharePermissionLabel = L10n.tr("Localizable", "KW_SHARE_PERMISSION_LABEL", fallback: "Permission:")
        internal static let kwSharingAdmin = L10n.tr("Localizable", "KW_SHARING_ADMIN", fallback: "Full rights")
        internal static let kwSharingAdminUserPermission = L10n.tr("Localizable", "KW_SHARING_ADMIN_USER_PERMISSION", fallback: "Admin")
        internal static let kwSharingCenterSectionGroups = L10n.tr("Localizable", "KW_SHARING_CENTER_SECTION_GROUPS", fallback: "Groups")
        internal static let kwSharingCenterSectionIndividuals = L10n.tr("Localizable", "KW_SHARING_CENTER_SECTION_INDIVIDUALS", fallback: "Individuals")
        internal static let kwSharingCenterSectionPendingItems = L10n.tr("Localizable", "KW_SHARING_CENTER_SECTION_PENDING_ITEMS", fallback: "Pending sharing requests")
        internal static let kwSharingCenterSectionPendingUserGroups = L10n.tr("Localizable", "KW_SHARING_CENTER_SECTION_PENDING_USER_GROUPS", fallback: "Pending group invitations")
        internal static let kwSharingCenterUnknownErrorAlertMessage = L10n.tr("Localizable", "KW_SHARING_CENTER_UNKNOWN_ERROR_ALERT_MESSAGE", fallback: "An error occurred. Please try again later.")
        internal static let kwSharingCenterUnknownErrorAlertTitle = L10n.tr("Localizable", "KW_SHARING_CENTER_UNKNOWN_ERROR_ALERT_TITLE", fallback: "An error occurred")
        internal static let kwSharingComposeMessageToFieldPlaceholder = L10n.tr("Localizable", "KW_SHARING_COMPOSE_MESSAGE_TO_FIELD_PLACEHOLDER", fallback: "Dashlane email address or Group")
        internal static let kwSharingDataLoading = L10n.tr("Localizable", "KW_SHARING_DATA_LOADING", fallback: "Loading your contacts...")
        internal static func kwSharingFrom(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_SHARING_FROM", String(describing: p1), fallback: "_")
    }
        internal static let kwSharingFromLabel = L10n.tr("Localizable", "KW_SHARING_FROM_LABEL", fallback: "From:")
        internal static let kwSharingItemEditAccess = L10n.tr("Localizable", "KW_SHARING_ITEM_EDIT_ACCESS", fallback: "Edit access")
        internal static let kwSharingLimitedUserPermission = L10n.tr("Localizable", "KW_SHARING_LIMITED_USER_PERMISSION", fallback: "Member")
        internal static let kwSharingMember = L10n.tr("Localizable", "KW_SHARING_MEMBER", fallback: "Limited rights")
                        internal static func kwSharingMissingPublicKeyErrorMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_SHARING_MISSING_PUBLIC_KEY_ERROR_MESSAGE", String(describing: p1), fallback: "Cannot share with:\n\n_\nIf your recipient(s) have Dashlane, please check the correct address and try again.")
    }
        internal static let kwSharingMissingPublicKeyErrorTitle = L10n.tr("Localizable", "KW_SHARING_MISSING_PUBLIC_KEY_ERROR_TITLE", fallback: "You can only share with existing Dashlane accounts")
        internal static func kwSharingPerson(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_SHARING_PERSON", p1, fallback: "%1$d user")
    }
                        internal static let kwSharingPersonalMessage = L10n.tr("Localizable", "KW_SHARING_PERSONAL_MESSAGE", fallback: "Hey,\n\nShare logins or Secure Notes with me in Dashlane, so we can sync updates with each other instead of having to send and resend them all the time. \n\nIf you don’t have Dashlane yet, you should get it. This app remembers all my passwords and login details and fills them in everywhere. ")
        internal static let kwSharingPremiumLimit = L10n.tr("Localizable", "KW_SHARING_PREMIUM_LIMIT", fallback: "Go Premium to share more than five logins or Secure Notes with other users.")
        internal static let kwSharingSuccess = L10n.tr("Localizable", "KW_SHARING_SUCCESS", fallback: "Success! Your invite to share was sent.")
        internal static let kwSharingToLabel = L10n.tr("Localizable", "KW_SHARING_TO_LABEL", fallback: "To:")
        internal static func kwSharingUserGroupMemberPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_SHARING_USER_GROUP_MEMBER_PLURAL", p1, fallback: "%1$d members")
    }
        internal static func kwSharingUserGroupMemberSingular(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_SHARING_USER_GROUP_MEMBER_SINGULAR", p1, fallback: "%1$d member")
    }
        internal static let kwSharingUserGroupNoItemInSection = L10n.tr("Localizable", "KW_SHARING_USER_GROUP_NO_ITEM_IN_SECTION", fallback: "No items shared with the group")
        internal static let kwSharingUserGroupNotAMember = L10n.tr("Localizable", "KW_SHARING_USER_GROUP_NOT_A_MEMBER", fallback: "You are not a member of this group")
        internal static let kwSharingUserGroupSectionSharedItems = L10n.tr("Localizable", "KW_SHARING_USER_GROUP_SECTION_SHARED_ITEMS", fallback: "Shared items")
        internal static func kwSharingUserGroupsPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_SHARING_USER_GROUPS_PLURAL", p1, fallback: "%1$d groups")
    }
        internal static func kwSharingUserGroupsSingular(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_SHARING_USER_GROUPS_SINGULAR", p1, fallback: "%1$d group")
    }
        internal static func kwSharingUsersPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_SHARING_USERS_PLURAL", p1, fallback: "%1$ld users")
    }
        internal static func kwSharingUsersSingular(_ p1: Int) -> String {
      return L10n.tr("Localizable", "KW_SHARING_USERS_SINGULAR", p1, fallback: "%1$ld user")
    }
        internal static let kwSignOutFromDevice = L10n.tr("Localizable", "KW_SIGN_OUT_FROM_DEVICE", fallback: "Log out from this device")
        internal static let kwSignupButton = L10n.tr("Localizable", "KW_SIGNUP_BUTTON", fallback: "Sign up")
        internal static let kwSkip = L10n.tr("Localizable", "KW_SKIP", fallback: "Skip")
        internal static let kwSortBy = L10n.tr("Localizable", "KW_SORT_BY", fallback: "Sort by")
        internal static let kwSortByCategory = L10n.tr("Localizable", "KW_SORT_BY_CATEGORY", fallback: "Category")
        internal static let kwSortByName = L10n.tr("Localizable", "KW_SORT_BY_NAME", fallback: "Item name")
        internal static let kwStorageDocTypeUnsupportedMessage = L10n.tr("Localizable", "KW_STORAGE_DOC_TYPE_UNSUPPORTED_MESSAGE", fallback: "The file you selected is not supported by Dashlane.")
        internal static let kwStorageDocTypeUnsupportedTitle = L10n.tr("Localizable", "KW_STORAGE_DOC_TYPE_UNSUPPORTED_TITLE", fallback: "File type not supported")
        internal static func kwStorageLimitMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_STORAGE_LIMIT_MESSAGE", String(describing: p1), fallback: "_")
    }
        internal static let kwStorageLimitTitle = L10n.tr("Localizable", "KW_STORAGE_LIMIT_TITLE", fallback: "You have reached your storage limit")
        internal static let kwTimeMinute = L10n.tr("Localizable", "KW_TIME_MINUTE", fallback: "minute")
        internal static let kwTimeMinutes = L10n.tr("Localizable", "KW_TIME_MINUTES", fallback: "minutes")
        internal static let kwTimeSecond = L10n.tr("Localizable", "KW_TIME_SECOND", fallback: "second")
        internal static let kwTimeSeconds = L10n.tr("Localizable", "KW_TIME_SECONDS", fallback: "seconds")
        internal static let kwTitle = L10n.tr("Localizable", "KW_TITLE", fallback: "Create account")
        internal static let kwTools = L10n.tr("Localizable", "KW_TOOLS", fallback: "Tools")
        internal static let kwUpgrade = L10n.tr("Localizable", "KW_UPGRADE", fallback: "Upgrade")
        internal static let kwUpgradeSettings = L10n.tr("Localizable", "KW_UPGRADE_SETTINGS", fallback: "Upgrade Protection")
        internal static func kwUseBiometryType(_ p1: Any) -> String {
      return L10n.tr("Localizable", "KW_USE_BIOMETRY_TYPE", String(describing: p1), fallback: "_")
    }
        internal static let kwUsePinCode = L10n.tr("Localizable", "KW_USE_PIN_CODE", fallback: "Use PIN")
        internal static let kwUseUniversalClipboard = L10n.tr("Localizable", "KW_USE_UNIVERSAL_CLIPBOARD", fallback: "Universal Clipboard")
        internal static let kwUserFullRights = L10n.tr("Localizable", "KW_USER_FULL_RIGHTS", fallback: "Full rights")
        internal static let kwUserLimitedRights = L10n.tr("Localizable", "KW_USER_LIMITED_RIGHTS", fallback: "Limited rights")
        internal static let kwUserPending = L10n.tr("Localizable", "KW_USER_PENDING", fallback: "Pending")
        internal static let kwWelcomeToSharingCenter = L10n.tr("Localizable", "KW_WELCOME_TO_SHARING_CENTER", fallback: "Our new Sharing Center")
        internal static let kwWelcomeToSharingCenterTitle = L10n.tr("Localizable", "KW_WELCOME_TO_SHARING_CENTER_TITLE", fallback: "Contacts")
        internal static let kwWrongMasterPassword = L10n.tr("Localizable", "KW_WRONG_MASTER_PASSWORD", fallback: "Error")
        internal static let kwWrongMasterPasswordMessage = L10n.tr("Localizable", "KW_WRONG_MASTER_PASSWORD_MESSAGE", fallback: "The Master Password you entered is incorrect.")
        internal static let kwWrongPinCode = L10n.tr("Localizable", "KW_WRONG_PIN_CODE", fallback: "Wrong PIN")
        internal static let kwWrongPinCodeMessage = L10n.tr("Localizable", "KW_WRONG_PIN_CODE_MESSAGE", fallback: "The PIN you entered is incorrect.")
        internal static let kwSecureNoteTitle = L10n.tr("Localizable", "KWSecureNote_title", fallback: "Title")
        internal static func linkedDomainsDetailViewMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "linked_domains_detail_view_message", String(describing: p1), fallback: "_")
    }
        internal static let linkedDomainsTitle = L10n.tr("Localizable", "linked_domains_title", fallback: "Associated sites")
        internal static let localPasswordChangerDumpAlertFailRetry = L10n.tr("Localizable", "LocalPasswordChanger_Dump_Alert_Fail_Retry", fallback: "Try again")
        internal static let localPasswordChangerDumpAlertFailTitle = L10n.tr("Localizable", "LocalPasswordChanger_Dump_Alert_Fail_Title", fallback: "Something went wrong while sending Password Changer's logs")
        internal static func localPasswordChangerDumpAlertMessage(_ p1: Int) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Dump_Alert_Message", p1, fallback: "This message is only for internal Dashlaners. We noticed %1$d errors with Password Changer. Would you like to send us the usage logs to help us improve Password Changer's reliability?")
    }
        internal static let localPasswordChangerDumpAlertTitle = L10n.tr("Localizable", "LocalPasswordChanger_Dump_Alert_Title", fallback: "Help us improve the Password Changer!")
        internal static let localPasswordChangerDumpDelete = L10n.tr("Localizable", "LocalPasswordChanger_Dump_Delete", fallback: "Delete logs")
        internal static let localPasswordChangerDumpSend = L10n.tr("Localizable", "LocalPasswordChanger_Dump_Send", fallback: "Send logs")
        internal static let localPasswordChangerErrorGeneric = L10n.tr("Localizable", "LocalPasswordChanger_Error_Generic", fallback: "Couldn't change password")
        internal static let localPasswordChangerErrorLogin = L10n.tr("Localizable", "LocalPasswordChanger_Error_Login", fallback: "Incorrect login info")
        internal static let localPasswordChangerErrorRetry = L10n.tr("Localizable", "LocalPasswordChanger_Error_Retry", fallback: "Retry")
        internal static let localPasswordChangerErrorTimeout = L10n.tr("Localizable", "LocalPasswordChanger_Error_Timeout", fallback: "Verification time out")
        internal static let localPasswordChangerErrorVerify = L10n.tr("Localizable", "LocalPasswordChanger_Error_Verify", fallback: "Verify")
        internal static let localPasswordChangerNotificationRecaptchaCaption = L10n.tr("Localizable", "LocalPasswordChanger_Notification_Recaptcha_Caption", fallback: "You’ve got 30s to pass the challenge. Are you ready?")
        internal static func localPasswordChangerNotificationRecaptchaTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Notification_Recaptcha_Title", String(describing: p1), fallback: "_")
    }
        internal static let localPasswordChangerNotificationUserPromptCaption = L10n.tr("Localizable", "LocalPasswordChanger_Notification_UserPrompt_Caption", fallback: "Enter the 2FA token you received or approve via your authentication app to continue.")
        internal static func localPasswordChangerNotificationUserPromptTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Notification_UserPrompt_Title", String(describing: p1), fallback: "_")
    }
        internal static func localPasswordChangerProgress2FAMessage(_ p1: UnsafePointer<CChar>) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Progress_2FA_Message", p1, fallback: "Please verify your identity by approving the notification or email to change your %1$s password.")
    }
        internal static let localPasswordChangerProgressChangeMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Change_Message", fallback: "You're one step closer to a strong, secure password (and peace of mind).")
        internal static let localPasswordChangerProgressChangeTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Change_Title", fallback: "Changing your password...")
        internal static let localPasswordChangerProgressFailureActionTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Failure_ActionTitle", fallback: "Close")
        internal static let localPasswordChangerProgressFailureLoginActionCancel = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Failure_Login_ActionCancel", fallback: "Cancel")
        internal static let localPasswordChangerProgressFailureLoginActionTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Failure_Login_ActionTitle", fallback: "Try again")
        internal static let localPasswordChangerProgressFailureLoginMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Failure_Login_Message", fallback: "Please make sure the information below is correct, then try again.")
        internal static let localPasswordChangerProgressFailureLoginTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Failure_Login_Title", fallback: "We couldn’t log in")
        internal static func localPasswordChangerProgressFailureMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Progress_Failure_Message", String(describing: p1), fallback: "_")
    }
        internal static let localPasswordChangerProgressFailureTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Failure_Title", fallback: "This password wasn’t changed")
        internal static func localPasswordChangerProgressReCaptchaMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Progress_ReCaptcha_Message", String(describing: p1), fallback: "_")
    }
        internal static let localPasswordChangerProgressReCaptchaTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_ReCaptcha_Title", fallback: "One last security check")
        internal static let localPasswordChangerProgressSigninMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Signin_Message", fallback: "This part won’t take long.")
        internal static let localPasswordChangerProgressSigninTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Signin_Title", fallback: "Connecting to your account...")
        internal static let localPasswordChangerProgressStartMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Start_Message", fallback: "We’re gearing up to change your current password.")
        internal static let localPasswordChangerProgressStartTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Start_Title", fallback: "Preparing to update...")
        internal static let localPasswordChangerProgressSuccessActionTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Success_ActionTitle", fallback: "Done")
        internal static func localPasswordChangerProgressSuccessMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Progress_Success_Message", String(describing: p1), fallback: "_")
    }
        internal static let localPasswordChangerProgressSuccessTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_Success_Title", fallback: "Good to go!")
        internal static let localPasswordChangerProgressUserPromptEmailMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_UserPrompt_Email_Message", fallback: "Please enter the code you received by email to verify your identity.")
        internal static let localPasswordChangerProgressUserPromptImageCaptchaMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_UserPrompt_ImageCaptcha_Message", fallback: "Verify that you're human.")
        internal static let localPasswordChangerProgressUserPromptSMSMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_UserPrompt_SMS_Message", fallback: "Please enter the code you received by text message to verify your identity.")
        internal static let localPasswordChangerProgressUserPromptTitle = L10n.tr("Localizable", "LocalPasswordChanger_Progress_UserPrompt_Title", fallback: "One last security check")
        internal static let localPasswordChangerProgressUserPromptTokenMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_UserPrompt_Token_Message", fallback: "Please enter the token you received on your authentication app to verify your identity.")
        internal static let localPasswordChangerProgressUserPromptUnknownMessage = L10n.tr("Localizable", "LocalPasswordChanger_Progress_UserPrompt_Unknown_Message", fallback: "Please enter the code you received to verify your identity.")
        internal static let localPasswordChangerSettingsNote = L10n.tr("Localizable", "LocalPasswordChanger_Settings_Note", fallback: "NEW")
        internal static let localPasswordChangerStandaloneChange = L10n.tr("Localizable", "LocalPasswordChanger_Standalone_Change", fallback: "Change")
        internal static let localPasswordChangerStandaloneChangeAll = L10n.tr("Localizable", "LocalPasswordChanger_Standalone_Change_All", fallback: "Change all")
        internal static let localPasswordChangerStandaloneNoPasswords = L10n.tr("Localizable", "LocalPasswordChanger_Standalone_No_Passwords", fallback: "You don’t have any compatible passwords yet. Some websites currently don’t support this feature, but we’re working hard to add more every day.")
        internal static func localPasswordChangerStandalonePasswordsCountPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Standalone_Passwords_Count_Plural", p1, fallback: "You have %1$d passwords we can auto-change")
    }
        internal static let localPasswordChangerStandalonePasswordsCountSingle = L10n.tr("Localizable", "LocalPasswordChanger_Standalone_Passwords_Count_Single", fallback: "You have 1 password we can auto-change")
        internal static let localPasswordChangerStandaloneTitle = L10n.tr("Localizable", "LocalPasswordChanger_Standalone_Title", fallback: "Password Changer")
        internal static let localPasswordChangerStartCurrentPassword = L10n.tr("Localizable", "LocalPasswordChanger_Start_CurrentPassword", fallback: "Current password")
        internal static func localPasswordChangerStartMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "LocalPasswordChanger_Start_Message", String(describing: p1), fallback: "_")
    }
        internal static let localPasswordChangerStartNewPassword = L10n.tr("Localizable", "LocalPasswordChanger_Start_NewPassword", fallback: "New password")
        internal static let localPasswordChangerStartTitle = L10n.tr("Localizable", "LocalPasswordChanger_Start_Title", fallback: "Let’s make this password super secure")
        internal static let lockAlreadyAcquired = L10n.tr("Localizable", "LockAlreadyAcquired", fallback: "An unknown error was encountered please try again later.")
        internal static let loginIsBadlyFormed = L10n.tr("Localizable", "LoginIsBadlyFormed", fallback: "The email address is invalid")
        internal static let logout = L10n.tr("Localizable", "Logout", fallback: "Logout")
        internal static let m2WConnectScreenCancel = L10n.tr("Localizable", "M2W_ConnectScreen_Cancel", fallback: "Cancel")
        internal static let m2WConnectScreenConfirmationPopupNo = L10n.tr("Localizable", "M2W_ConnectScreen_ConfirmationPopup_No", fallback: "Not yet")
        internal static let m2WConnectScreenConfirmationPopupTitle = L10n.tr("Localizable", "M2W_ConnectScreen_ConfirmationPopup_Title", fallback: "Have you logged in to Dashlane on your computer?")
        internal static let m2WConnectScreenConfirmationPopupYes = L10n.tr("Localizable", "M2W_ConnectScreen_ConfirmationPopup_Yes", fallback: "Yes")
        internal static let m2WConnectScreenDone = L10n.tr("Localizable", "M2W_ConnectScreen_Done", fallback: "Done")
        internal static let m2WConnectScreenSubtitle = L10n.tr("Localizable", "M2W_ConnectScreen_Subtitle", fallback: "We’ve built an easy way to install Dashlane on your browser")
        internal static let m2WConnectScreenTitle = L10n.tr("Localizable", "M2W_ConnectScreen_Title", fallback: "On your computer, go to the address above")
        internal static let m2WStartScreenCTA = L10n.tr("Localizable", "M2W_StartScreen_CTA", fallback: "Connect my computer")
        internal static let m2WStartScreenSkip = L10n.tr("Localizable", "M2W_StartScreen_Skip", fallback: "Do it later")
        internal static let m2WStartScreenSubtitle = L10n.tr("Localizable", "M2W_StartScreen_Subtitle", fallback: "Connect your computer to access your passwords on whichever device you’re using.")
        internal static let m2WStartScreenTitle = L10n.tr("Localizable", "M2W_StartScreen_Title", fallback: "Have your logins everywhere")
        internal static let masterpasswordCreationExplaination = L10n.tr("Localizable", "masterpassword_creation_explaination", fallback: "Note: For your security, we don’t store your Master Password. Make sure you remember it!")
        internal static let masterpasswordCreationPlaceholder = L10n.tr("Localizable", "masterpassword_creation_placeholder", fallback: "Create your Master Password")
        internal static let media = L10n.tr("Localizable", "media", fallback: "Media")
        internal static func menuCopyItem(_ p1: Any) -> String {
      return L10n.tr("Localizable", "MENU_COPY_ITEM", String(describing: p1), fallback: "_")
    }
        internal static let minimalisticOnboardingEmailPlaceholder = L10n.tr("Localizable", "MinimalisticOnboarding_Email_Placeholder", fallback: "Your email address")
        internal static let minimalisticOnboardingEmailSubtitle = L10n.tr("Localizable", "MinimalisticOnboarding_Email_Subtitle", fallback: "We don’t need much to get the ball rolling.")
        internal static let minimalisticOnboardingEmailFirstBack = L10n.tr("Localizable", "MinimalisticOnboarding_EmailFirst_Back", fallback: "Back")
        internal static let minimalisticOnboardingEmailFirstNext = L10n.tr("Localizable", "MinimalisticOnboarding_EmailFirst_Next", fallback: "Next")
        internal static let minimalisticOnboardingEmailFirstPlaceholder = L10n.tr("Localizable", "MinimalisticOnboarding_EmailFirst_Placeholder", fallback: "Your email address")
        internal static let minimalisticOnboardingEmailFirstSubtitle = L10n.tr("Localizable", "MinimalisticOnboarding_EmailFirst_Subtitle", fallback: "We don’t need much to get the ball rolling.")
        internal static let minimalisticOnboardingEmailFirstTitle = L10n.tr("Localizable", "MinimalisticOnboarding_EmailFirst_Title", fallback: "Let's start with your email...")
        internal static let minimalisticOnboardingMasterPasswordConfirmationPasswordsMatching = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordConfirmation_PasswordsMatching", fallback: "It’s a match!")
        internal static let minimalisticOnboardingMasterPasswordConfirmationSubtitle = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordConfirmation_Subtitle", fallback: "Just making sure you're happy with it.")
        internal static let minimalisticOnboardingMasterPasswordConfirmationTitle = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordConfirmation_Title", fallback: "Got it. Can you type it one more time?")
        internal static let minimalisticOnboardingMasterPasswordSecondBack = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordSecond_Back", fallback: "Back")
        internal static let minimalisticOnboardingMasterPasswordSecondConfirmationBack = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordSecond_Confirmation_Back", fallback: "Back")
        internal static let minimalisticOnboardingMasterPasswordSecondConfirmationNext = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordSecond_Confirmation_Next", fallback: "Next")
        internal static let minimalisticOnboardingMasterPasswordSecondConfirmationPasswordsNotMatching = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordSecond_Confirmation_PasswordsNotMatching", fallback: "The passwords don’t match.")
        internal static let minimalisticOnboardingMasterPasswordSecondConfirmationTitle = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordSecond_Confirmation_Title", fallback: "Got it. Can you type it one more time?")
        internal static let minimalisticOnboardingMasterPasswordSecondNext = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordSecond_Next", fallback: "Next")
        internal static let minimalisticOnboardingMasterPasswordSecondPlaceholder = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordSecond_Placeholder", fallback: "Create your Master Password")
        internal static let minimalisticOnboardingMasterPasswordSecondTitle = L10n.tr("Localizable", "MinimalisticOnboarding_MasterPasswordSecond_Title", fallback: "...and a Master Password. The one to rule them all.")
        internal static let minimalisticOnboardingRecapCheckboxAccessibilityTitle = L10n.tr("Localizable", "MinimalisticOnboarding_Recap_Checkbox_Accessibility_Title", fallback: "Select to agree to Terms of Service and Privacy Policy")
        internal static func minimalisticOnboardingRecapCheckboxTerms(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
      return L10n.tr("Localizable", "MinimalisticOnboarding_Recap_Checkbox_Terms", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "_")
    }
        internal static let minimalisticOnboardingRecapCTA = L10n.tr("Localizable", "MinimalisticOnboarding_Recap_CTA", fallback: "Jump in")
        internal static let minimalisticOnboardingRecapSignUp = L10n.tr("Localizable", "MinimalisticOnboarding_Recap_SignUp", fallback: "Jump in")
        internal static let minimalisticOnboardingRecapTitle = L10n.tr("Localizable", "MinimalisticOnboarding_Recap_Title", fallback: "That’s it! Here’s your recap:")
        internal static let mobileVpnNewProviderInfoboxDismiss = L10n.tr("Localizable", "Mobile_vpn_new_provider_infobox_dismiss", fallback: "Dismiss")
        internal static let mobileVpnNewProviderInfoboxHeaderTitle = L10n.tr("Localizable", "Mobile_vpn_new_provider_infobox_header_title", fallback: "Your Dashlane VPN is now provided by Hotspot Shield")
        internal static let mobileVpnNewProviderInfoboxLearnMore = L10n.tr("Localizable", "Mobile_vpn_new_provider_infobox_learnMore", fallback: "Learn more")
        internal static let mobileVpnNewProviderInfoModalButtonTitle = L10n.tr("Localizable", "Mobile_vpn_new_provider_infoModal_button_title", fallback: "Ok, got it")
        internal static let mobileVpnNewProviderInfoModalDescription = L10n.tr("Localizable", "Mobile_vpn_new_provider_infoModal_description", fallback: "We’ve partnered with Hotspot Shield to offer Premium users the fastest virtual private network (VPN) on the market.")
        internal static let mobileVpnNewProviderInfoModalTitle = L10n.tr("Localizable", "Mobile_vpn_new_provider_infoModal_title", fallback: "Your Dashlane VPN is now provided by Hotspot Shield")
                internal static let mobileVpnPageFaqGeneralDetails = L10n.tr("Localizable", "Mobile_vpn_page_faq_general_details", fallback: "A virtual private network (VPN) protects your identity and data online. It creates an encrypted connection to the internet which hides your IP address and personal, trackable data.\n\nThis is particularly important when you use unsecure public WiFi in places like airports and cafes because these connections are often very easy to hack. It can also allow you to anonymously access blocked content on streaming services and social networking sites.")
        internal static let mobileVpnPageFaqGeneralDetailsReadMore = L10n.tr("Localizable", "Mobile_vpn_page_faq_general_details_readMore", fallback: "Read more")
        internal static let mobileVpnPageFaqGeneralSummary = L10n.tr("Localizable", "Mobile_vpn_page_faq_general_summary", fallback: "What is a VPN?")
        internal static let mobileVpnPageFaqHotspotDetails = L10n.tr("Localizable", "Mobile_vpn_page_faq_hotspot_details", fallback: "It means you have a top-rated VPN included in your Dashlane Premium plan. You just need to set it up via Dashlane the first time. After that, you can use the VPN via the Hotspot Shield app itself.")
        internal static let mobileVpnPageFaqHotspotSummary = L10n.tr("Localizable", "Mobile_vpn_page_faq_hotspot_summary", fallback: "What does the partnership with Hotspot Shield mean for me?")
                internal static func mobileVpnPageFaqSupportDetails(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "Mobile_vpn_page_faq_support_details", String(describing: p1), String(describing: p2), fallback: "_\n_")
    }
        internal static let mobileVpnPageFaqSupportDetailsDashlaneFaq = L10n.tr("Localizable", "Mobile_vpn_page_faq_support_details_dashlane_faq", fallback: "Need help setting up your VPN?")
        internal static let mobileVpnPageFaqSupportDetailsFaq = L10n.tr("Localizable", "Mobile_vpn_page_faq_support_details_faq", fallback: "FAQ")
        internal static let mobileVpnPageFaqSupportDetailsHotspotSupport = L10n.tr("Localizable", "Mobile_vpn_page_faq_support_details_hotspot_support", fallback: "Need help with the Hotspot Shield app?")
        internal static let mobileVpnPageFaqSupportDetailsSupportCenter = L10n.tr("Localizable", "Mobile_vpn_page_faq_support_details_supportCenter", fallback: "Support Center")
        internal static let mobileVpnPageFaqSupportDetailsVisitDashlane = L10n.tr("Localizable", "Mobile_vpn_page_faq_support_details_visit_dashlane", fallback: "Visit the Dashlane Help Center")
        internal static let mobileVpnPageFaqSupportDetailsVisitHotspot = L10n.tr("Localizable", "Mobile_vpn_page_faq_support_details_visit_hotspot", fallback: "Go to the Hotspot Shield Support Center")
        internal static let mobileVpnPageFaqSupportSummary = L10n.tr("Localizable", "Mobile_vpn_page_faq_support_summary", fallback: "I need help")
        internal static let mobileVpnPageFaqTitle = L10n.tr("Localizable", "Mobile_vpn_page_faq_title", fallback: "Frequently asked questions")
        internal static let mobileVpnPaywallFullContentDescription = L10n.tr("Localizable", "Mobile_vpn_paywall_full_content_description", fallback: "Watch, browse, play, and download without location restrictions.")
        internal static let mobileVpnPaywallFullContentTitle = L10n.tr("Localizable", "Mobile_vpn_paywall_full_content_title", fallback: "Access worldwide content")
        internal static let mobileVpnPaywallProtectionDescription = L10n.tr("Localizable", "Mobile_vpn_paywall_protection_description", fallback: "Connect to the internet securely wherever you are, even on unsecure public WiFi.")
        internal static let mobileVpnPaywallProtectionTitle = L10n.tr("Localizable", "Mobile_vpn_paywall_protection_title", fallback: "Stay private and protected")
        internal static let mobileVpnPaywallSeePlanOptions = L10n.tr("Localizable", "Mobile_vpn_paywall_see_plan_options", fallback: "See plan options")
        internal static let mobileVpnPaywallTrialHeaderDescription = L10n.tr("Localizable", "Mobile_vpn_paywall_trial_header_description", fallback: "Premium plan members get access to one of the highest rated virtual private networks (VPNs) available.")
        internal static let mobileVpnPaywallTrialHeaderTitle = L10n.tr("Localizable", "Mobile_vpn_paywall_trial_header_title", fallback: "VPN isn’t available during your trial")
        internal static let mobileVpnPaywallUpgradeHeaderDescription = L10n.tr("Localizable", "Mobile_vpn_paywall_upgrade_header_description", fallback: "Upgrade to our Premium plan to browse privately and securely online with a virtual private network (VPN).")
        internal static let mobileVpnPaywallUpgradeHeaderTitle = L10n.tr("Localizable", "Mobile_vpn_paywall_upgrade_header_title", fallback: "VPN is a Premium feature")
        internal static let mobileVpnPaywallUpgradeToPremium = L10n.tr("Localizable", "Mobile_vpn_paywall_upgrade_to_premium", fallback: "Upgrade to Premium")
        internal static let mobileVpnTitle = L10n.tr("Localizable", "Mobile_vpn_title", fallback: "Virtual private network")
        internal static let modalOkGotIt = L10n.tr("Localizable", "modal_okGotIt", fallback: "OK, got it")
        internal static let moreTips = L10n.tr("Localizable", "moreTips", fallback: "More tips")
        internal static let mpchangeNewMasterPassword = L10n.tr("Localizable", "MPCHANGE_NEW_MASTER_PASSWORD", fallback: "Create your new Master Password")
        internal static let mplessLogoutAlertMessage = L10n.tr("Localizable", "MPLESS_LOGOUT_ALERT_MESSAGE", fallback: "If you don’t have another logged in device or your recovery key, you could lose access to your account.")
        internal static let mplessLogoutAlertTitle = L10n.tr("Localizable", "MPLESS_LOGOUT_ALERT_TITLE", fallback: "Are you sure you want to log out?")
        internal static let mplessRecoveryIntroMessage = L10n.tr("Localizable", "MPLESS_RECOVERY_INTRO_MESSAGE", fallback: "This is a single-use spare key to your vault. If you lose your device or forget your PIN, you can use it to access your account.")
        internal static let mplessRecoverySkipAlertCta = L10n.tr("Localizable", "MPLESS_RECOVERY_SKIP_ALERT_CTA", fallback: "Yes, skip")
        internal static let mplessRecoverySkipAlertMessage = L10n.tr("Localizable", "MPLESS_RECOVERY_SKIP_ALERT_MESSAGE", fallback: "If you lose your device or forget your PIN, this key is the only way you can access your account.")
        internal static let mplessRecoverySkipAlertTitle = L10n.tr("Localizable", "MPLESS_RECOVERY_SKIP_ALERT_TITLE", fallback: "Skip recovery key set up?")
        internal static let mplessRecoverySkipCta = L10n.tr("Localizable", "MPLESS_RECOVERY_SKIP_CTA", fallback: "Skip for now")
        internal static func n1(_ p1: Any) -> String {
      return L10n.tr("Localizable", "N1", String(describing: p1), fallback: "_")
    }
        internal static func n2(_ p1: Any) -> String {
      return L10n.tr("Localizable", "N2", String(describing: p1), fallback: "_")
    }
        internal static let n3 = L10n.tr("Localizable", "N3", fallback: "You received a verification code")
        internal static let n4 = L10n.tr("Localizable", "N4", fallback: "New device")
        internal static func n5(_ p1: Any) -> String {
      return L10n.tr("Localizable", "N5", String(describing: p1), fallback: "_")
    }
        internal static let navigationRevampAnnouncementCta4 = L10n.tr("Localizable", "navigationRevampAnnouncementCta4", fallback: "Let's dive in")
        internal static let navigationRevampAnnouncementDescription1 = L10n.tr("Localizable", "navigationRevampAnnouncementDescription1", fallback: "We improved the navigation of your Home screen and gave it a modern look.")
        internal static let navigationRevampAnnouncementDescription1Bold = L10n.tr("Localizable", "navigationRevampAnnouncementDescription1_bold", fallback: "Swipe to see what changed.")
        internal static let navigationRevampAnnouncementDescription2 = L10n.tr("Localizable", "navigationRevampAnnouncementDescription2", fallback: "You can now access your items without leaving your Home screen. Filter by item type or use the search bar to find exactly what you need.")
        internal static let navigationRevampAnnouncementDescription3 = L10n.tr("Localizable", "navigationRevampAnnouncementDescription3", fallback: "We added a Notifications tab so you can stay on top of any updates. And you can quickly generate passwords on the go using the Generator tab.")
        internal static let navigationRevampAnnouncementDescription4 = L10n.tr("Localizable", "navigationRevampAnnouncementDescription4", fallback: "We made sure everything you need is just a tap away. Ready to explore your new Home screen?")
        internal static let navigationRevampAnnouncementTitle1 = L10n.tr("Localizable", "navigationRevampAnnouncementTitle1", fallback: "Welcome to your new Home screen")
        internal static let navigationRevampAnnouncementTitle2 = L10n.tr("Localizable", "navigationRevampAnnouncementTitle2", fallback: "Easier access to your items")
        internal static let navigationRevampAnnouncementTitle3 = L10n.tr("Localizable", "navigationRevampAnnouncementTitle3", fallback: "Improved menu navigation")
        internal static let navigationRevampAnnouncementTitle4 = L10n.tr("Localizable", "navigationRevampAnnouncementTitle4", fallback: "Enjoy the new experience")
        internal static let noAccountCreatedAlertAction = L10n.tr("Localizable", "noAccountCreated_alertAction", fallback: "OK")
        internal static let noBackupSyncPremiumRenewalMsg = L10n.tr("Localizable", "NoBackupSyncPremiumRenewal_Msg", fallback: "Renew this plan to have unlimited logins synced across unlimited devices.")
        internal static let noBackupSyncPremiumRenewalTitle = L10n.tr("Localizable", "NoBackupSyncPremiumRenewal_Title", fallback: "Your Premium benefits have expired")
        internal static let notificationCenterDelete = L10n.tr("Localizable", "NotificationCenter_delete", fallback: "Delete")
        internal static let notificationCenterSectionTitleGettingStarted = L10n.tr("Localizable", "NotificationCenter_sectionTitle_gettingStarted", fallback: "Getting Started")
        internal static let notificationCenterSectionTitlePromotion = L10n.tr("Localizable", "NotificationCenter_sectionTitle_promotion", fallback: "Promotions")
        internal static let notificationCenterSectionTitleSecurityAlert = L10n.tr("Localizable", "NotificationCenter_sectionTitle_securityAlert", fallback: "Security")
        internal static let notificationCenterSectionTitleSharing = L10n.tr("Localizable", "NotificationCenter_sectionTitle_sharing", fallback: "Sharing")
        internal static let notificationCenterSectionTitleWhatIsNew = L10n.tr("Localizable", "NotificationCenter_sectionTitle_whatIsNew", fallback: "What's New")
        internal static let notificationCenterSectionTitleYourAccount = L10n.tr("Localizable", "NotificationCenter_sectionTitle_yourAccount", fallback: "Your account")
        internal static func notificationCenterSeeAll(_ p1: Int) -> String {
      return L10n.tr("Localizable", "NotificationCenter_seeAll", p1, fallback: "See all (%1$d)")
    }
        internal static let onboardingFirstPasswordAction = L10n.tr("Localizable", "ONBOARDING_FIRST_PASSWORD_ACTION", fallback: "Ok, start browsing")
        internal static let onboardingFirstPasswordCaption = L10n.tr("Localizable", "ONBOARDING_FIRST_PASSWORD_CAPTION", fallback: "As you save logins in Dashlane, they'll be stored here, in your vault.")
        internal static let onboardingFirstPasswordFirstStep = L10n.tr("Localizable", "ONBOARDING_FIRST_PASSWORD_FIRST_STEP", fallback: "Open any website.")
            internal static let onboardingFirstPasswordSecondStep = L10n.tr("Localizable", "ONBOARDING_FIRST_PASSWORD_SECOND_STEP", fallback: "Log in by entering your username and password.\n**If you're logged in, log out just once.**")
        internal static let onboardingFirstPasswordSecondStepLogout = L10n.tr("Localizable", "ONBOARDING_FIRST_PASSWORD_SECOND_STEP_LOGOUT", fallback: "If you’re logged in, log out just once.")
        internal static let onboardingFirstPasswordThirdStep = L10n.tr("Localizable", "ONBOARDING_FIRST_PASSWORD_THIRD_STEP", fallback: "Click **Save** when Dashlane prompts to save your login. And that’s it!")
        internal static let onboardingFirstPasswordThirdStepSave = L10n.tr("Localizable", "ONBOARDING_FIRST_PASSWORD_THIRD_STEP_SAVE", fallback: "Save")
        internal static let onboardingFirstPasswordTitle = L10n.tr("Localizable", "ONBOARDING_FIRST_PASSWORD_TITLE", fallback: "Welcome! Let’s get you going.")
        internal static let onboardingSafariDisabledCta = L10n.tr("Localizable", "onboarding_safari_disabled_cta", fallback: "Visit Help Center")
        internal static let onboardingSafariDisabledSubtitle = L10n.tr("Localizable", "onboarding_safari_disabled_subtitle", fallback: "We’ve changed how Autofill works on Safari. Update your device's preferences to use Dashlane’s Autofill for your logins. Visit our Help Center for step-by-step instructions.")
        internal static let onboardingSafariDisabledSubtitleLink = L10n.tr("Localizable", "onboarding_safari_disabled_subtitle_link", fallback: "Help Center")
        internal static let onboardingSafariDisabledTitle = L10n.tr("Localizable", "onboarding_safari_disabled_title", fallback: "We’ve updated our Autofill")
        internal static let onboardingChecklistAccessibilityAnotherCard = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_AnotherCard", fallback: "Another onboarding card")
        internal static let onboardingChecklistAccessibilityDone = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_Done", fallback: "Done")
        internal static let onboardingChecklistAccessibilityFirstCard = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_FirstCard", fallback: "First onboarding card")
        internal static let onboardingChecklistAccessibilityHintActivateAutofill = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_Hint_ActivateAutofill", fallback: "Shows instructions on how to activate autofill")
        internal static let onboardingChecklistAccessibilityHintAddPasswords = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_Hint_AddPasswords", fallback: "Opens a menu to add logins")
        internal static let onboardingChecklistAccessibilityHintFixBreachedAccounts = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_Hint_FixBreachedAccounts", fallback: "Shows a menu to do a Dark Web Monitoring scan")
        internal static let onboardingChecklistAccessibilityHintImportFromBrowser = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_Hint_ImportFromBrowser", fallback: "Shows instructions on how to add passwords and login details from your browser.")
        internal static let onboardingChecklistAccessibilityHintM2W = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_Hint_M2W", fallback: "Shows instructions on how to install Dashlane on your browser")
        internal static let onboardingChecklistAccessibilityHintSeeScanResult = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_Hint_SeeScanResult", fallback: "Shows results of the Dark Web Monitoring scan")
        internal static let onboardingChecklistAccessibilitySecondCard = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_SecondCard", fallback: "Second onboarding card")
        internal static let onboardingChecklistAccessibilityThirdAndLastCard = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_ThirdAndLastCard", fallback: "Third (and last) onboarding card")
        internal static let onboardingChecklistAccessibilityTodo = L10n.tr("Localizable", "OnboardingChecklist_Accessibility_Todo", fallback: "To-do")
        internal static let onboardingChecklistV2ActionButtonActivateAutofill = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionButton_ActivateAutofill", fallback: "Activate Autofill")
        internal static let onboardingChecklistV2ActionButtonAddAccounts = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionButton_AddAccounts", fallback: "Add logins")
        internal static let onboardingChecklistV2ActionButtonImportFromBrowser = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionButton_ImportFromBrowser", fallback: "Add logins")
        internal static let onboardingChecklistV2ActionButtonM2D = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionButton_M2D", fallback: "Connect computer")
        internal static let onboardingChecklistV2ActionCaptionActivateAutofill = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionCaption_ActivateAutofill", fallback: "We’ll help you log in automatically whenever you want, securely")
        internal static let onboardingChecklistV2ActionCaptionAddAccounts = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionCaption_AddAccounts", fallback: "We’ll help you retrieve your passwords and login details and put them where they belong—here.")
        internal static let onboardingChecklistV2ActionCaptionImportFromBrowser = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionCaption_ImportFromBrowser", fallback: "We’ll help you retrieve your passwords and login details and put them where they belong—here.")
        internal static let onboardingChecklistV2ActionCaptionM2D = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionCaption_M2D", fallback: "We’ll help you connect your computer so you’ll always be able to use your logins")
        internal static let onboardingChecklistV2ActionTitleActivateAutofill = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionTitle_ActivateAutofill", fallback: "Forget about typing your logins")
        internal static let onboardingChecklistV2ActionTitleAddAccounts = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionTitle_AddAccounts", fallback: "Get your logins in a safe place")
        internal static let onboardingChecklistV2ActionTitleImportFromBrowser = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionTitle_ImportFromBrowser", fallback: "Import from your browser")
        internal static let onboardingChecklistV2ActionTitleM2D = L10n.tr("Localizable", "OnboardingChecklist_V2_ActionTitle_M2D", fallback: "Access your logins on your computer")
        internal static let onboardingChecklistV2Dismiss = L10n.tr("Localizable", "OnboardingChecklist_V2_Dismiss", fallback: "Continue")
        internal static let onboardingChecklistV2DismissAction = L10n.tr("Localizable", "OnboardingChecklist_V2_Dismiss_Action", fallback: "Continue")
        internal static let onboardingChecklistV2DismissTimeOver = L10n.tr("Localizable", "OnboardingChecklist_V2_Dismiss_TimeOver", fallback: "Dismiss checklist")
        internal static let onboardingChecklistTitle = L10n.tr("Localizable", "onboardingChecklistTitle", fallback: "Get started")
        internal static let openWebsite = L10n.tr("Localizable", "openWebsite", fallback: "Open website")
        internal static let other = L10n.tr("Localizable", "other", fallback: "Other")
            internal static let otpRecoveryCannotAccessCodesDescription = L10n.tr("Localizable", "OTP_RECOVERY_CANNOT_ACCESS_CODES_DESCRIPTION", fallback: "If you can't access your 2-factor authentication (2FA) app, use one of the 10 recovery codes that were generated when you set up 2FA.\nIf you don't have the recovery codes, you can reset 2FA.")
        internal static let otpRecoveryReset2Fa = L10n.tr("Localizable", "OTP_RECOVERY_RESET_2FA", fallback: "Reset 2FA")
        internal static let otpRecoverySendFallbackSmsTitle = L10n.tr("Localizable", "OTP_RECOVERY_SEND_FALLBACK_SMS_TITLE", fallback: "Reset 2FA")
        internal static let otpNotificationBody = L10n.tr("Localizable", "otpNotification_body", fallback: "This code will expire in 30 seconds. Tap to get a new code.")
        internal static let otpNotificationBodyClipboard = L10n.tr("Localizable", "otpNotification_body_clipboard", fallback: "This code is ready to paste. It will expire in 30 seconds. Tap to get a new one.")
        internal static func otpNotificationTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "otpNotification_title", String(describing: p1), fallback: "_")
    }
            internal static func otptollItemDeletionAlertTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "otptoll_item_deletion_alert_title", String(describing: p1), fallback: "__")
    }
        internal static let otptollItemDeletionAlertYes = L10n.tr("Localizable", "otptoll_item_deletion_alert_yes", fallback: "Yes, remove login")
        internal static let otpTool2faCompatibleLoginsTitle = L10n.tr("Localizable", "otpTool_2faCompatibleLogins_title", fallback: "2FA-compatible logins")
        internal static let otptool2faLoginsHeader = L10n.tr("Localizable", "otptool_2faLoginsHeader", fallback: "Logins with 2FA")
        internal static let otptool2fasetup = L10n.tr("Localizable", "otptool_2fasetup", fallback: "Set up 2FA")
        internal static let otpTool2fasetupForAll = L10n.tr("Localizable", "otpTool_2fasetupForAll", fallback: "2FA set up for all compatible logins")
        internal static let otpTool2fasetupForAllSubtitle = L10n.tr("Localizable", "otpTool_2fasetupForAllSubtitle", fallback: "Nice work—you’ve reinforced all compatible logins with 2FA. Add more logins to see if they’re 2FA compatible.")
        internal static let otpToolAddCredentialCta = L10n.tr("Localizable", "otpTool_add_credential_cta", fallback: "Add new login")
                internal static func otpToolAddOtpErrorMultiloginSubtitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "otpTool_add_otp_error_multilogin_subtitle", String(describing: p1), fallback: "_\nChoose the correct login from your home screen. Then select Edit to set up this authentication.")
    }
        internal static func otpToolAddOtpErrorMultiloginTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "otpTool_add_otp_error_multilogin_title", String(describing: p1), fallback: "_")
    }
        internal static func otpToolAddOtpErrorSubtitle(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "otpTool_add_otp_error_subtitle", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let otpToolAddOtpSuccessSubtitle = L10n.tr("Localizable", "otpTool_add_otp_success_subtitle", fallback: "We’ll generate the 6-digit tokens you need to log in.")
        internal static let otptoolAddLoginCta = L10n.tr("Localizable", "otptool_addLogin_cta", fallback: "Add login")
        internal static let otptoolDeletionAlertTitle = L10n.tr("Localizable", "otptool_DeletionAlertTitle", fallback: "Wait, are you sure?")
        internal static let otpToolExploreAuthenticator = L10n.tr("Localizable", "otpTool_explore_authenticator", fallback: "Explore Authenticator")
        internal static let otpToolFaq = L10n.tr("Localizable", "otpTool_faq", fallback: "Frequently asked questions")
        internal static let otpToolFaq2faDescription = L10n.tr("Localizable", "otpTool_faq_2fa_description", fallback: "Setting up 2FA for your services adds an extra layer of security by asking to authenticate with a second factor in order to log in.")
        internal static let otpToolFaq2faTitle = L10n.tr("Localizable", "otpTool_faq_2fa_title", fallback: "What is 2FA for?")
        internal static let otpToolFaqAuthenticatorDescription = L10n.tr("Localizable", "otpTool_faq_authenticator_description", fallback: "It generates 6-digit tokens every time you log in to an app or site you’ve set up 2FA for.")
        internal static let otpToolFaqAuthenticatorTitle = L10n.tr("Localizable", "otpTool_faq_authenticator_title", fallback: "What is the Authenticator?")
        internal static let otpToolFaqHelpDescription = L10n.tr("Localizable", "otpTool_faq_help_description", fallback: "If you need more help, visit our Help Center or contact our Support team.")
        internal static let otpToolFaqHelpTitle = L10n.tr("Localizable", "otpTool_faq_help_title", fallback: "I need help")
        internal static let otpToolFaqLearnMoreLink = L10n.tr("Localizable", "otpTool_faq_learn_more_link", fallback: "Learn more")
        internal static let otpToolName = L10n.tr("Localizable", "otpTool_name", fallback: "Authenticator")
        internal static let otpToolNo2faLogins = L10n.tr("Localizable", "otpTool_no2faLogins", fallback: "No 2FA-compatible logins")
        internal static let otpToolNo2faLoginsSubtitle = L10n.tr("Localizable", "otpTool_no2faLogins_subtitle", fallback: "Logins that support 2FA will be listed here.")
        internal static let otpToolSeeAll = L10n.tr("Localizable", "otpTool_seeAll", fallback: "See all")
        internal static let otpToolSeeLess = L10n.tr("Localizable", "otpTool_seeLess", fallback: "See less")
        internal static let otpToolSetupCta = L10n.tr("Localizable", "otpTool_setup_cta", fallback: "Add 2FA token")
        internal static let passwordCopiedToClipboard = L10n.tr("Localizable", "password_copied_to_clipboard", fallback: "Your password has been copied")
        internal static let passwordGeneratorCopiedPassword = L10n.tr("Localizable", "PASSWORD_GENERATOR_COPIED_PASSWORD", fallback: "Password copied")
        internal static let passwordGeneratorSaveAsDefault = L10n.tr("Localizable", "PASSWORD_GENERATOR_SAVE_AS_DEFAULT", fallback: "Save settings as default")
        internal static let passwordGeneratorSavedAsDefault = L10n.tr("Localizable", "PASSWORD_GENERATOR_SAVED_AS_DEFAULT", fallback: "Settings saved")
        internal static let passwordHealthModuleActionButton = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_ACTION_BUTTON", fallback: "Explore")
        internal static let passwordHealthModuleCompromised = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_COMPROMISED", fallback: "Compromised")
        internal static let passwordHealthModuleReused = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_REUSED", fallback: "Reused")
        internal static let passwordHealthModuleSafe = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_SAFE", fallback: "Strong")
        internal static let passwordHealthModuleScore = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_SCORE", fallback: "Score")
        internal static let passwordHealthModuleTitle = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_TITLE", fallback: "Password Health")
        internal static let passwordHealthModuleTitleBreakdownDescription = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_TITLE_BREAKDOWN_DESCRIPTION", fallback: "Password breakdown")
        internal static let passwordHealthModuleTotal = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_TOTAL", fallback: "Total passwords")
        internal static let passwordHealthModuleWeak = L10n.tr("Localizable", "PASSWORD_HEALTH_MODULE_WEAK", fallback: "Weak")
        internal static let passwordChangerActionItemContent = L10n.tr("Localizable", "passwordChangerActionItemContent", fallback: "Securely change your passwords with one tap.")
        internal static let passwordChangerActionItemTitle = L10n.tr("Localizable", "passwordChangerActionItemTitle", fallback: "Password Changer has landed")
        internal static let passwordChangerActionRequired = L10n.tr("Localizable", "passwordChangerActionRequired", fallback: "Your action is needed")
        internal static let passwordChangerChangingPassword = L10n.tr("Localizable", "passwordChangerChangingPassword", fallback: "Changing password...")
        internal static let passwordChangerStatusUpdated = L10n.tr("Localizable", "passwordChangerStatusUpdated", fallback: "Updated")
        internal static let passwordChangerSunsetCTA = L10n.tr("Localizable", "passwordChangerSunsetCTA", fallback: "Learn more")
        internal static let passwordChangerSunsetTitle = L10n.tr("Localizable", "passwordChangerSunsetTitle", fallback: "Password Changer will no longer be available starting in mid-September.")
        internal static func passwordHealthDetailedCompromisedListHeadlinePlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "passwordHealthDetailedCompromisedListHeadlinePlural", p1, fallback: "You have %1$d compromised passwords that need to be replaced.")
    }
        internal static let passwordHealthDetailedCompromisedListHeadlineSingular = L10n.tr("Localizable", "passwordHealthDetailedCompromisedListHeadlineSingular", fallback: "You have 1 compromised password that needs to be replaced.")
        internal static func passwordHealthDetailedListHeadlinePlural(_ p1: Int, _ p2: Any) -> String {
      return L10n.tr("Localizable", "passwordHealthDetailedListHeadlinePlural", p1, String(describing: p2), fallback: "_")
    }
        internal static func passwordHealthDetailedListHeadlineSingular(_ p1: Int, _ p2: Any) -> String {
      return L10n.tr("Localizable", "passwordHealthDetailedListHeadlineSingular", p1, String(describing: p2), fallback: "_")
    }
        internal static func passwordHealthDetailedListTitlePlural(_ p1: Any) -> String {
      return L10n.tr("Localizable", "passwordHealthDetailedListTitlePlural", String(describing: p1), fallback: "_")
    }
        internal static func passwordHealthDetailedListTitleSingular(_ p1: Any) -> String {
      return L10n.tr("Localizable", "passwordHealthDetailedListTitleSingular", String(describing: p1), fallback: "_")
    }
        internal static func passwordHealthDetailedReusedListHeadlinePlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "passwordHealthDetailedReusedListHeadlinePlural", p1, fallback: "You have %1$d reused passwords that need to be replaced.")
    }
        internal static let passwordHealthDetailedReusedListHeadlineSingular = L10n.tr("Localizable", "passwordHealthDetailedReusedListHeadlineSingular", fallback: "You have 1 reused password that needs to be replaced.")
        internal static func passwordHealthDetailedWeakListHeadlinePlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "passwordHealthDetailedWeakListHeadlinePlural", p1, fallback: "You have %1$d weak passwords that need to be replaced.")
    }
        internal static let passwordHealthDetailedWeakListHeadlineSingular = L10n.tr("Localizable", "passwordHealthDetailedWeakListHeadlineSingular", fallback: "You have 1 weak password that needs to be replaced.")
        internal static let passwordHealthEmptyState = L10n.tr("Localizable", "passwordHealthEmptyState", fallback: "Add at least 5 accounts to Dashlane to get a Password Health score.")
        internal static func passwordHealthNotEnoughAccountsPlural(_ p1: Int) -> String {
      return L10n.tr("Localizable", "passwordHealthNotEnoughAccountsPlural", p1, fallback: "Add %1$d more accounts to Dashlane to get a Password Health score.")
    }
        internal static func passwordHealthNotEnoughAccountsSingular(_ p1: Int) -> String {
      return L10n.tr("Localizable", "passwordHealthNotEnoughAccountsSingular", p1, fallback: "Add %1$d more account to Dashlane to get a Password Health score.")
    }
        internal static func passwordHealthSeeAll(_ p1: Int) -> String {
      return L10n.tr("Localizable", "passwordHealthSeeAll", p1, fallback: "See all (%1$d)")
    }
        internal static let passwordHistoryHideGenerated = L10n.tr("Localizable", "passwordHistoryHideGenerated", fallback: "Hide password")
        internal static let passwordHistoryShowGenerated = L10n.tr("Localizable", "passwordHistoryShowGenerated", fallback: "Show password")
        internal static let passwordIncorrect = L10n.tr("Localizable", "PasswordIncorrect", fallback: "The password is incorrect")
        internal static let passwordlimitAnnouncementAction = L10n.tr("Localizable", "PASSWORDLIMIT_ANNOUNCEMENT_ACTION", fallback: "Upgrade to Premium")
        internal static let passwordlimitAnnouncementBody = L10n.tr("Localizable", "PASSWORDLIMIT_ANNOUNCEMENT_BODY", fallback: "Upgrade to Premium to store unlimited logins.")
        internal static let passwordlimitAnnouncementEssentialsAction = L10n.tr("Localizable", "PASSWORDLIMIT_ANNOUNCEMENT_ESSENTIALS_ACTION", fallback: "Upgrade")
        internal static let passwordlimitAnnouncementEssentialsBody = L10n.tr("Localizable", "PASSWORDLIMIT_ANNOUNCEMENT_ESSENTIALS_BODY", fallback: "Upgrade to our Essentials plan to get unlimited logins.")
        internal static let passwordlimitAnnouncementPremiumBody = L10n.tr("Localizable", "PASSWORDLIMIT_ANNOUNCEMENT_PREMIUM_BODY", fallback: "Upgrade to our Premium plan to get unlimited logins.")
        internal static func passwordlimitAnnouncementTitle(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Localizable", "PASSWORDLIMIT_ANNOUNCEMENT_TITLE", p1, p2, fallback: "You've added %1$d out of %2$d logins")
    }
        internal static func passwordlimitAnnouncementTitleApproachingLimit(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Localizable", "PASSWORDLIMIT_ANNOUNCEMENT_TITLE_APPROACHING_LIMIT", p1, p2, fallback: "You've added %1$d out of %2$d logins")
    }
        internal static func passwordlimitAnnouncementTitleLimitReached(_ p1: Int) -> String {
      return L10n.tr("Localizable", "PASSWORDLIMIT_ANNOUNCEMENT_TITLE_LIMIT_REACHED", p1, fallback: "You've reached the %1$d-login limit")
    }
        internal static let passwordNumberLimitationContinue = L10n.tr("Localizable", "passwordNumberLimitation_continue", fallback: "Go Premium")
        internal static let passwordNumberLimitationLimitedMessage = L10n.tr("Localizable", "passwordNumberLimitation_limitedMessage", fallback: "You cannot add any more logins with your Free Dashlane account.")
        internal static let passwordNumberLimitationLimitedTitle = L10n.tr("Localizable", "passwordNumberLimitation_limitedTitle", fallback: "Login limit reached")
        internal static let passwordNumberLimitationWarningMessage = L10n.tr("Localizable", "passwordNumberLimitation_warningMessage", fallback: "You're approaching your Free login storage limit. Upgrade to store unlimited logins.")
        internal static func passwordNumberLimitationWarningTitle(_ p1: Int, _ p2: Int) -> String {
      return L10n.tr("Localizable", "passwordNumberLimitation_warningTitle", p1, p2, fallback: "%1$d/%2$d logins stored")
    }
        internal static let passwordResetViewAction = L10n.tr("Localizable", "PasswordReset_ViewAction", fallback: "View")
        internal static let passwordTipsCloseButton = L10n.tr("Localizable", "PasswordTips_CloseButton", fallback: "Close")
        internal static let passwordTipsFirstCharactersMethodDescription = L10n.tr("Localizable", "PasswordTips_FirstCharactersMethod_Description", fallback: "Use the main letters and numbers from a personal story. For example, *&quot;**T**he **f**irst **a**partment **I** **e**ver **l**ived **i**n **w**as **613** **G**rove **S**treet**.** **R**ent **w**as **$5**00 **p**er **m**onth&quot;*")
        internal static let passwordTipsFirstCharactersMethodExample = L10n.tr("Localizable", "PasswordTips_FirstCharactersMethod_Example", fallback: "TfaIeliw613GS.Rw$5pm")
        internal static let passwordTipsFirstCharactersMethodTitle = L10n.tr("Localizable", "PasswordTips_FirstCharactersMethod_Title", fallback: "The main letters and numbers method")
        internal static let passwordTipsMainTitle = L10n.tr("Localizable", "PasswordTips_MainTitle", fallback: "How to create strong and memorable passwords ")
        internal static let passwordTipsNavBarTitle = L10n.tr("Localizable", "PasswordTips_NavBarTitle", fallback: "Password tips")
        internal static let passwordTipsSeriesOfWordsMethodDescription = L10n.tr("Localizable", "PasswordTips_SeriesOfWordsMethod_Description", fallback: "Choose a series of words that don’t make grammatical sense together.")
        internal static let passwordTipsSeriesOfWordsMethodExample = L10n.tr("Localizable", "PasswordTips_SeriesOfWordsMethod_Example", fallback: "WinterMomEverestWent")
        internal static let passwordTipsSeriesOfWordsMethodTitle = L10n.tr("Localizable", "PasswordTips_SeriesOfWordsMethod_Title", fallback: "The series of words method")
        internal static let passwordTipsStoryMethodDescription = L10n.tr("Localizable", "PasswordTips_StoryMethod_Description", fallback: "Create a story about an interesting person in an interesting place.")
        internal static let passwordTipsStoryMethodExample = L10n.tr("Localizable", "PasswordTips_StoryMethod_Example", fallback: "momwenttoEverestinwinter")
        internal static let passwordTipsStoryMethodTitle = L10n.tr("Localizable", "PasswordTips_StoryMethod_Title", fallback: "The story method")
        internal static let pasteboardCopyBic = L10n.tr("Localizable", "pasteboardCopy_bic", fallback: "BIC copied")
        internal static let pasteboardCopyCardNumber = L10n.tr("Localizable", "pasteboardCopy_cardNumber", fallback: "Card number copied")
        internal static let pasteboardCopyEmail = L10n.tr("Localizable", "pasteboardCopy_email", fallback: "Email copied")
        internal static let pasteboardCopyFiscalNumber = L10n.tr("Localizable", "pasteboardCopy_fiscalNumber", fallback: "Fiscal number copied")
        internal static let pasteboardCopyIban = L10n.tr("Localizable", "pasteboardCopy_iban", fallback: "IBAN copied")
        internal static let pasteboardCopyLogin = L10n.tr("Localizable", "pasteboardCopy_login", fallback: "Username copied")
        internal static let pasteboardCopyNumber = L10n.tr("Localizable", "pasteboardCopy_number", fallback: "Number copied")
        internal static let pasteboardCopyOtpCode = L10n.tr("Localizable", "pasteboardCopy_otpCode", fallback: "2FA token copied")
        internal static let pasteboardCopyPassword = L10n.tr("Localizable", "pasteboardCopy_password", fallback: "Password copied")
        internal static let pasteboardCopySecondaryLogin = L10n.tr("Localizable", "pasteboardCopy_secondaryLogin", fallback: "Alternate username copied")
        internal static let pasteboardCopySecurityCode = L10n.tr("Localizable", "pasteboardCopy_securityCode", fallback: "Security code copied")
        internal static let postLoginRecoveryKeyDisabledCancel = L10n.tr("Localizable", "POST_LOGIN_RECOVERY_KEY_DISABLED_CANCEL", fallback: "Dismiss")
        internal static let postLoginRecoveryKeyDisabledCta = L10n.tr("Localizable", "POST_LOGIN_RECOVERY_KEY_DISABLED_CTA", fallback: "Go to settings")
        internal static let postLoginRecoveryKeyDisabledMessage = L10n.tr("Localizable", "POST_LOGIN_RECOVERY_KEY_DISABLED_MESSAGE", fallback: "To generate a new recovery key, turn this on again in your security settings.")
        internal static let postLoginRecoveryKeyDisabledMpMessage = L10n.tr("Localizable", "POST_LOGIN_RECOVERY_KEY_DISABLED_MP_MESSAGE", fallback: "For your security, we turned this off when your Master Password changed. This means your existing recovery key is no longer valid.")
        internal static let postLoginRecoveryKeyDisabledMplessMessage = L10n.tr("Localizable", "POST_LOGIN_RECOVERY_KEY_DISABLED_MPLESS_MESSAGE", fallback: "For your security, we turned this off when you used your recovery key.")
        internal static let postLoginRecoveryKeyDisabledTitle = L10n.tr("Localizable", "POST_LOGIN_RECOVERY_KEY_DISABLED_TITLE", fallback: "Your recovery key setting was turned off")
        internal static let pwmMatchingCredentialsListDescription = L10n.tr("Localizable", "PWM_MATCHING_CREDENTIALS_LIST_DESCRIPTION", fallback: "Select the account you want to set up 2FA for.")
        internal static func pwmMatchingCredentialsListMultipleLoginsAvailable(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "PWM_MATCHING_CREDENTIALS_LIST_MULTIPLE_LOGINS_AVAILABLE", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let recentTitle = L10n.tr("Localizable", "RECENT_TITLE", fallback: "Recent")
        internal static let recentSearchTitle = L10n.tr("Localizable", "recentSearchTitle", fallback: "Last searched")
        internal static let recoveryKeyActivationConfirmationMessage = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_CONFIRMATION_MESSAGE", fallback: "If you didn’t make a copy of your key in the last step, go back and do that now.")
        internal static let recoveryKeyActivationConfirmationTitle = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_CONFIRMATION_TITLE", fallback: "Confirm your recovery key")
        internal static let recoveryKeyActivationIntroCta = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_INTRO_CTA", fallback: "Generate key")
        internal static let recoveryKeyActivationIntroMessage = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_INTRO_MESSAGE", fallback: "This is a single-use spare key to your vault. If you need to, you can use it to get back into your account and reset your Master Password.")
        internal static let recoveryKeyActivationIntroTitle = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_INTRO_TITLE", fallback: "Your recovery key is a spare key to your vault")
        internal static let recoveryKeyActivationPreviewCta = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_PREVIEW_CTA", fallback: "Continue")
        internal static let recoveryKeyActivationPreviewMessage1 = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_PREVIEW_MESSAGE_1", fallback: "We recommend writing down your recovery key and keeping it with other important documents.")
        internal static let recoveryKeyActivationPreviewMessage2 = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_PREVIEW_MESSAGE_2", fallback: "To double-check that you saved it, we’ll ask you to confirm your key in the next step.")
        internal static let recoveryKeyActivationPreviewTitle = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_PREVIEW_TITLE", fallback: "Store this somewhere safe")
        internal static let recoveryKeyActivationSuccessMessage = L10n.tr("Localizable", "RECOVERY_KEY_ACTIVATION_SUCCESS_MESSAGE", fallback: "Your recovery key is ready if you need it!")
        internal static let recoveryKeyDeactivationAlertCta = L10n.tr("Localizable", "RECOVERY_KEY_DEACTIVATION_ALERT_CTA", fallback: "Yes, turn off")
        internal static let recoveryKeyDeactivationAlertMessage = L10n.tr("Localizable", "RECOVERY_KEY_DEACTIVATION_ALERT_MESSAGE", fallback: "If you turn this off, your existing recovery key will no longer be valid.")
        internal static let recoveryKeyDeactivationAlertTitle = L10n.tr("Localizable", "RECOVERY_KEY_DEACTIVATION_ALERT_TITLE", fallback: "Are you sure you want to turn off this recovery method?")
        internal static let recoveryKeySettingsFooter = L10n.tr("Localizable", "RECOVERY_KEY_SETTINGS_FOOTER", fallback: "Your recovery key lets you access your vault if you forget your Master Password.")
        internal static let recoveryKeySettingsLabel = L10n.tr("Localizable", "RECOVERY_KEY_SETTINGS_LABEL", fallback: "Recovery Key")
        internal static let recoveryKeySettingsOffLabel = L10n.tr("Localizable", "RECOVERY_KEY_SETTINGS_OFF_LABEL", fallback: "Off")
        internal static let recoveryKeySettingsOnLabel = L10n.tr("Localizable", "RECOVERY_KEY_SETTINGS_ON_LABEL", fallback: "On")
        internal static let rememberMpSettings = L10n.tr("Localizable", "REMEMBER_MP_SETTINGS", fallback: "Keep me logged in for 14 days")
        internal static let remindMe = L10n.tr("Localizable", "RemindMe", fallback: "Remind me")
        internal static let renewalExtendPremium = L10n.tr("Localizable", "Renewal_ExtendPremium", fallback: "Renew Premium")
            internal static let renewalNoticeReminderDminus1Msg = L10n.tr("Localizable", "RenewalNoticeReminderDminus1_Msg", fallback: "Sync expires soon. Renew Premium to keep your passwords in sync across your devices and accessible everywhere. \n")
        internal static let renewalNoticeReminderDminus1Title = L10n.tr("Localizable", "RenewalNoticeReminderDminus1_Title", fallback: "Alert - Sync expiring soon")
        internal static func renewalNoticeReminderDminus25Msg(_ p1: Int) -> String {
      return L10n.tr("Localizable", "RenewalNoticeReminderDminus25_Msg", p1, fallback: "Your Premium benefits, including sync across devices, expire in %1$d days. ")
    }
        internal static let renewalNoticeReminderDminus25Title = L10n.tr("Localizable", "RenewalNoticeReminderDminus25_Title", fallback: "Notice - Premium expires soon")
        internal static func renewalNoticeReminderDminus5Msg(_ p1: Int) -> String {
      return L10n.tr("Localizable", "RenewalNoticeReminderDminus5_Msg", p1, fallback: "Your Premium benefits, including sync across devices, expire in %1$d days. ")
    }
        internal static let renewalNoticeReminderDminus5Title = L10n.tr("Localizable", "RenewalNoticeReminderDminus5_Title", fallback: "Reminder - Premium expires soon")
        internal static let resetMasterPasswordActivationMasterPasswordChallengeCancel = L10n.tr("Localizable", "ResetMasterPassword_Activation_MasterPasswordChallenge_Cancel", fallback: "Cancel")
        internal static let resetMasterPasswordActivationMasterPasswordChallengeEnable = L10n.tr("Localizable", "ResetMasterPassword_Activation_MasterPasswordChallenge_Enable", fallback: "Enable")
        internal static let resetMasterPasswordActivationMasterPasswordChallengeErrorOK = L10n.tr("Localizable", "ResetMasterPassword_Activation_MasterPasswordChallenge_Error_OK", fallback: "OK")
        internal static let resetMasterPasswordActivationMasterPasswordChallengeErrorTitle = L10n.tr("Localizable", "ResetMasterPassword_Activation_MasterPasswordChallenge_Error_Title", fallback: "That Master Password doesn't look right. Please check it and try again.")
        internal static let resetMasterPasswordActivationMasterPasswordChallengeMessage = L10n.tr("Localizable", "ResetMasterPassword_Activation_MasterPasswordChallenge_Message", fallback: "This feature lets you reset your Master Password if you forget it.")
        internal static let resetMasterPasswordActivationMasterPasswordChallengeTitle = L10n.tr("Localizable", "ResetMasterPassword_Activation_MasterPasswordChallenge_Title", fallback: "Enter your current Master Password to enable")
        internal static let resetMasterPasswordBiometricsDeactivationDialogCancel = L10n.tr("Localizable", "ResetMasterPassword_BiometricsDeactivationDialog_Cancel", fallback: "Keep enabled")
        internal static let resetMasterPasswordBiometricsDeactivationDialogDisable = L10n.tr("Localizable", "ResetMasterPassword_BiometricsDeactivationDialog_Disable", fallback: "Disable both")
        internal static func resetMasterPasswordBiometricsDeactivationDialogTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ResetMasterPassword_BiometricsDeactivationDialog_Title", String(describing: p1), fallback: "_")
    }
        internal static let resetMasterPasswordBiometricsRequiredDialogAccept = L10n.tr("Localizable", "ResetMasterPassword_BiometricsRequiredDialog_Accept", fallback: "Enable both")
        internal static let resetMasterPasswordBiometricsRequiredDialogCancel = L10n.tr("Localizable", "ResetMasterPassword_BiometricsRequiredDialog_Cancel", fallback: "Cancel")
        internal static func resetMasterPasswordBiometricsRequiredDialogDescription(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ResetMasterPassword_BiometricsRequiredDialog_Description", String(describing: p1), fallback: "_")
    }
        internal static func resetMasterPasswordBiometricsRequiredDialogTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ResetMasterPassword_BiometricsRequiredDialog_Title", String(describing: p1), fallback: "_")
    }
        internal static let resetMasterPasswordIncorrectMasterPassword = L10n.tr("Localizable", "ResetMasterPassword_IncorrectMasterPassword", fallback: "Wrong Master Password. We can help you reset your Master Password.")
        internal static let resetMasterPasswordNotificationCenterItemDescription = L10n.tr("Localizable", "ResetMasterPassword_NotificationCenter_Item_Description", fallback: "Make sure you can reset your Master Password if you ever forget it.")
        internal static let resetMasterPasswordNotificationCenterItemTitle = L10n.tr("Localizable", "ResetMasterPassword_NotificationCenter_Item_Title", fallback: "Turn on biometric recovery")
        internal static let resetMasterPasswordReactivationDialogCancel = L10n.tr("Localizable", "ResetMasterPassword_ReactivationDialog_Cancel", fallback: "Close")
        internal static let resetMasterPasswordReactivationDialogCTA = L10n.tr("Localizable", "ResetMasterPassword_ReactivationDialog_CTA", fallback: "Re-enable")
        internal static let resetMasterPasswordReactivationDialogDescription = L10n.tr("Localizable", "ResetMasterPassword_ReactivationDialog_Description", fallback: "We disabled these features when your device’s security settings changed.")
        internal static let resetMasterPasswordReactivationDialogTitle = L10n.tr("Localizable", "ResetMasterPassword_ReactivationDialog_Title", fallback: "Turn Face ID and biometric recovery back on?")
        internal static let resetMasterPasswordResetDeactivationDialogCancel = L10n.tr("Localizable", "ResetMasterPassword_ResetDeactivationDialog_Cancel", fallback: "Keep enabled")
        internal static let resetMasterPasswordResetDeactivationDialogDisable = L10n.tr("Localizable", "ResetMasterPassword_ResetDeactivationDialog_Disable", fallback: "Disable")
        internal static let resetMasterPasswordResetDeactivationDialogTitle = L10n.tr("Localizable", "ResetMasterPassword_ResetDeactivationDialog_Title", fallback: "You will not be able to access your account and data if you forget your Master Password.")
        internal static let resetMasterPasswordResetSuggestedDialogTitle = L10n.tr("Localizable", "ResetMasterPassword_ResetSuggestedDialog_Title", fallback: "Also turn on biometric recovery?")
        internal static let resetMasterPasswordResetSuggestedRequiredDialogAccept = L10n.tr("Localizable", "ResetMasterPassword_ResetSuggestedRequiredDialog_Accept", fallback: "Enable")
        internal static let resetMasterPasswordResetSuggestedRequiredDialogDescription = L10n.tr("Localizable", "ResetMasterPassword_ResetSuggestedRequiredDialog_Description", fallback: "This lets you reset your Master Password if you ever forget it.")
        internal static let resetMasterPasswordSettingsItemTitle = L10n.tr("Localizable", "ResetMasterPassword_Settings_Item_Title", fallback: "Biometric recovery")
        internal static let safariTabAutofill = L10n.tr("Localizable", "SAFARI_TAB_AUTOFILL", fallback: "Autofill")
        internal static let safariTabGenerator = L10n.tr("Localizable", "SAFARI_TAB_GENERATOR", fallback: "Generator")
        internal static let safariTabVault = L10n.tr("Localizable", "SAFARI_TAB_VAULT", fallback: "Passwords")
        internal static let safariAutofillDisabledAdmin = L10n.tr("Localizable", "safariAutofillDisabledAdmin", fallback: "Your company admin has disabled this setting.")
        internal static let safariAutofillDisableManuallyConfirmationCTA = L10n.tr("Localizable", "safariAutofillDisableManuallyConfirmationCTA", fallback: "Turn off")
        internal static let safariAutofillDisableManuallyConfirmationMessage = L10n.tr("Localizable", "safariAutofillDisableManuallyConfirmationMessage", fallback: "This will turn off Autofill and our suggestions to save and generate passwords.")
        internal static let safariAutofillDisableManuallyConfirmationTitle = L10n.tr("Localizable", "safariAutofillDisableManuallyConfirmationTitle", fallback: "Turn off Autofill on this website?")
        internal static let safariAutofillDisableManuallyConfirmationTitlePage = L10n.tr("Localizable", "safariAutofillDisableManuallyConfirmationTitlePage", fallback: "Turn off Autofill on this page?")
        internal static let safariAutofillEverything = L10n.tr("Localizable", "safariAutofillEverything", fallback: "Everything")
        internal static let safariAutofillLoginPasswords = L10n.tr("Localizable", "safariAutofillLoginPasswords", fallback: "Only username and passwords")
        internal static let safariAutofillNothing = L10n.tr("Localizable", "safariAutofillNothing", fallback: "Don't autofill on this website")
        internal static let safariAutofillPageText = L10n.tr("Localizable", "safariAutofillPageText", fallback: "This page only")
        internal static let safariAutofillTurnedOff = L10n.tr("Localizable", "safariAutofillTurnedOff", fallback: "Autofill is turned off on this page.")
        internal static let safariAutofillTurnedOffLoginPasswords = L10n.tr("Localizable", "safariAutofillTurnedOffLoginPasswords", fallback: "Autofill is turned off on this website except for usernames and passwords.")
        internal static let safariAutofillTurnOn = L10n.tr("Localizable", "safariAutofillTurnOn", fallback: "Turn on.")
        internal static let safariAutofillWebsiteText = L10n.tr("Localizable", "safariAutofillWebsiteText", fallback: "This entire website")
        internal static let safariAutofillWhatTo = L10n.tr("Localizable", "safariAutofillWhatTo", fallback: "What to autofill:")
        internal static let safariCredentialRowTooltipCopyInfo = L10n.tr("Localizable", "safariCredentialRowTooltipCopyInfo", fallback: "Copy info")
        internal static let safariOtherLoggedInAs = L10n.tr("Localizable", "safariOtherLoggedInAs", fallback: "Logged in as")
        internal static let safariOtherOpenApp = L10n.tr("Localizable", "safariOtherOpenApp", fallback: "Open the application")
        internal static let safariOtherOpenSupport = L10n.tr("Localizable", "safariOtherOpenSupport", fallback: "Go to Dashlane Support")
        internal static let safariPasswordGeneratedHistoryTitle = L10n.tr("Localizable", "safariPasswordGeneratedHistoryTitle", fallback: "Generator history")
        internal static let safariPreLoginButtonText = L10n.tr("Localizable", "safariPreLoginButtonText", fallback: "Open the app")
        internal static let safariPreLoginText = L10n.tr("Localizable", "safariPreLoginText", fallback: "Open the app to log in to your account")
        internal static let safariShowHistory = L10n.tr("Localizable", "safariShowHistory", fallback: "Show history")
        internal static let saveRecoverycodesAlertCancelCta = L10n.tr("Localizable", "SAVE_RECOVERYCODES_ALERT_CANCEL_CTA", fallback: "Not yet")
        internal static let saveRecoverycodesAlertDoneCta = L10n.tr("Localizable", "SAVE_RECOVERYCODES_ALERT_DONE_CTA", fallback: "Yes")
        internal static let saveRecoverycodesAlertMessage = L10n.tr("Localizable", "SAVE_RECOVERYCODES_ALERT_MESSAGE", fallback: "If you can’t access your other authentication methods, you’ll need these codes to log in to Dashlane.")
        internal static let saveRecoverycodesAlertTitle = L10n.tr("Localizable", "SAVE_RECOVERYCODES_ALERT_TITLE", fallback: "Did you save your codes?")
        internal static let searchVaultNoResultFoundDescription = L10n.tr("Localizable", "SEARCH_VAULT_NO_RESULT_FOUND_DESCRIPTION", fallback: "Double-check your spelling, or try a different term.")
        internal static let searchVaultNoResultFoundTitle = L10n.tr("Localizable", "SEARCH_VAULT_NO_RESULT_FOUND_TITLE", fallback: "No results found")
        internal static let searchVaultPlaceholder = L10n.tr("Localizable", "SEARCH_VAULT_PLACEHOLDER", fallback: "Search Dashlane")
        internal static let secureWifiOnboardingOneSubtitle = L10n.tr("Localizable", "secureWifi_onboardingOne_subtitle", fallback: "We recommend that you connect to your VPN whenever you use WiFi in public places like cafés or airports.")
        internal static let secureWifiOnboardingOneTitle = L10n.tr("Localizable", "secureWifi_onboardingOne_title", fallback: "You're ready to protect your WiFi")
        internal static let secureWifiProtectYourWifiModalFreetrialCta = L10n.tr("Localizable", "secureWifi_protectYourWifiModal_freetrial_cta", fallback: "Upgrade to Premium")
        internal static let secureWifiToolsTitle = L10n.tr("Localizable", "secureWifi_toolsTitle", fallback: "VPN")
            internal static func securityAlertDataLeakPopupAffectedPasswords(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERT_DATA_LEAK_POPUP_AFFECTED_PASSWORDS", String(describing: p1), fallback: "Affected passwords:\n_")
    }
        internal static let securityAlertDataLeakPremiumplusUpsellDescription = L10n.tr("Localizable", "SECURITY_ALERT_DATA_LEAK_PREMIUMPLUS_UPSELL_DESCRIPTION", fallback: "Dashlane helps you change your passwords when your information is found on the dark web, but for enhanced protection against identity theft, consider Premium Plus. Visit your Identity Dashboard to learn more.")
        internal static let securityAlertDataLeakPremiumplusUpsellDescriptionOnlyPiis = L10n.tr("Localizable", "SECURITY_ALERT_DATA_LEAK_PREMIUMPLUS_UPSELL_DESCRIPTION_ONLY_PIIS", fallback: "Dashlane helps you change your passwords when your information is found on the dark web, but for enhanced protection against identity theft, consider Premium Plus. Visit your Identity Dashboard to learn more.")
            internal static func securityAlertDataLeakTrayAffectedPasswords(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERT_DATA_LEAK_TRAY_AFFECTED_PASSWORDS", String(describing: p1), fallback: "Affected passwords:\n_")
    }
        internal static let securityAlertDismissButton = L10n.tr("Localizable", "SECURITY_ALERT_DISMISS_BUTTON", fallback: "Dismiss")
        internal static let securityAlertLaterButton = L10n.tr("Localizable", "SECURITY_ALERT_LATER_BUTTON", fallback: "Close")
        internal static let securityAlertUnresolvedCloseCta = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_CLOSE_CTA", fallback: "Close")
        internal static let securityAlertUnresolvedDarkWebNewTitle = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_DARK_WEB_NEW_TITLE", fallback: "We found some of your information on the dark web")
        internal static func securityAlertUnresolvedDate(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_DATE", String(describing: p1), fallback: "_")
    }
        internal static let securityAlertUnresolvedGoPremium = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_GO_PREMIUM", fallback: "Upgrade to Dashlane Premium to view the details of this alert and take action")
        internal static let securityAlertUnresolvedImpactedDomains = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_IMPACTED_DOMAINS", fallback: "Affected websites:")
            internal static func securityAlertUnresolvedImpactedDomainsParameters(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_IMPACTED_DOMAINS_PARAMETERS", String(describing: p1), fallback: "Affected websites:\n_")
    }
        internal static let securityAlertUnresolvedImpactedEmails = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_IMPACTED_EMAILS", fallback: "Affected email address:")
            internal static func securityAlertUnresolvedImpactedEmailsParameters(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_IMPACTED_EMAILS_PARAMETERS", String(describing: p1), fallback: "Affected email address:\n_")
    }
        internal static let securityAlertUnresolvedImpactedUsernames = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_IMPACTED_USERNAMES", fallback: "Affected usernames:")
            internal static func securityAlertUnresolvedImpactedUsernamesParameters(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_IMPACTED_USERNAMES_PARAMETERS", String(describing: p1), fallback: "Affected usernames:\n_")
    }
        internal static let securityAlertUnresolvedTakeActionCta = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_TAKE_ACTION_CTA", fallback: "Take action")
        internal static let securityAlertUnresolvedToday = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_TODAY", fallback: "Today")
        internal static let securityAlertUnresolvedUpgradeCta = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_UPGRADE_CTA", fallback: "Upgrade to take action")
        internal static let securityAlertUnresolvedView = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_VIEW", fallback: "View")
        internal static func securityAlertUnresolvedWhatIncluded(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_WHAT_INCLUDED", String(describing: p1), fallback: "_")
    }
        internal static let securityAlertUnresolvedYesterday = L10n.tr("Localizable", "SECURITY_ALERT_UNRESOLVED_YESTERDAY", fallback: "Yesterday")
        internal static let securityAlertViewButton = L10n.tr("Localizable", "SECURITY_ALERT_VIEW_BUTTON", fallback: "View")
        internal static let securityAlertViewDetailsButton = L10n.tr("Localizable", "SECURITY_ALERT_VIEW_DETAILS_BUTTON", fallback: "View details")
        internal static func securityAlertsUnresolvedDataleakDescription(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERTS_UNRESOLVED_DATALEAK_DESCRIPTION", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static func securityAlertsUnresolvedDataleakTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERTS_UNRESOLVED_DATALEAK_TITLE", String(describing: p1), fallback: "_")
    }
        internal static func securityAlertsUnresolvedRecommendationMultiple(_ p1: Int) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERTS_UNRESOLVED_RECOMMENDATION_MULTIPLE", p1, fallback: "%1$d accounts remain affected by this breach. We recommend updating them immediately.")
    }
        internal static func securityAlertsUnresolvedRecommendationMultipleObjectParameter(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERTS_UNRESOLVED_RECOMMENDATION_MULTIPLE_OBJECT_PARAMETER", String(describing: p1), fallback: "_")
    }
        internal static func securityAlertsUnresolvedRecommendationNoPassword(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERTS_UNRESOLVED_RECOMMENDATION_NO_PASSWORD", String(describing: p1), fallback: "_")
    }
        internal static let securityAlertsUnresolvedRecommendationPiis = L10n.tr("Localizable", "SECURITY_ALERTS_UNRESOLVED_RECOMMENDATION_PIIS", fallback: "You may have updated your password after the breach, but if you aren't sure, make sure to update it and any other similar passwords.")
        internal static func securityAlertsUnresolvedRegularTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_ALERTS_UNRESOLVED_REGULAR_TITLE", String(describing: p1), fallback: "_")
    }
        internal static func securityBreachAllWhatIncluded(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_ALL_WHAT_INCLUDED", String(describing: p1), fallback: "_")
    }
        internal static let securityBreachCancelCta = L10n.tr("Localizable", "SECURITY_BREACH_CANCEL_CTA", fallback: "Cancel")
        internal static func securityBreachChangeRecommendation(_ p1: Int) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_CHANGE_RECOMMENDATION", p1, fallback: "%1$d account remains affected by this breach. We recommend updating it immediately.")
    }
        internal static func securityBreachChangeRecommendationMultiple(_ p1: Int) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_CHANGE_RECOMMENDATION_MULTIPLE", p1, fallback: "Reusing similar or exact passwords across certain accounts means %1$d accounts are affected by this breach. We recommend you update those passwords immediately.")
    }
        internal static func securityBreachChangeRecommendationMultipleObjectParameter(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_CHANGE_RECOMMENDATION_MULTIPLE_OBJECT_PARAMETER", String(describing: p1), fallback: "_")
    }
        internal static func securityBreachChangeRecommendationNoPassword(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_CHANGE_RECOMMENDATION_NO_PASSWORD", String(describing: p1), fallback: "_")
    }
        internal static func securityBreachChangeRecommendationObjectParameter(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_CHANGE_RECOMMENDATION_OBJECT_PARAMETER", String(describing: p1), fallback: "_")
    }
        internal static func securityBreachChangeRecommendationSingle(_ p1: Int) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_CHANGE_RECOMMENDATION_SINGLE", p1, fallback: "%1$d account is affected by this breach. We recommend you update the password for that account immediately.")
    }
        internal static func securityBreachChangeRecommendationSingleObjectParameter(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_CHANGE_RECOMMENDATION_SINGLE_OBJECT_PARAMETER", String(describing: p1), fallback: "_")
    }
        internal static func securityBreachDarkwebAlertTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_DARKWEB_ALERT_TITLE", String(describing: p1), fallback: "_")
    }
        internal static let securityBreachDarkwebAlertTitleGeneric = L10n.tr("Localizable", "SECURITY_BREACH_DARKWEB_ALERT_TITLE_GENERIC", fallback: "We found some of your information on the dark web")
        internal static let securityBreachDarkwebAlertTitleNoMatchNoDomain = L10n.tr("Localizable", "SECURITY_BREACH_DARKWEB_ALERT_TITLE_NO_MATCH_NO_DOMAIN", fallback: "We found some passwords on the dark web that you haven’t stored in Dashlane")
        internal static let securityBreachDarkwebHiddenDescription = L10n.tr("Localizable", "SECURITY_BREACH_DARKWEB_HIDDEN_DESCRIPTION", fallback: "Date of alert:")
        internal static func securityBreachDarkwebInformation(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_DARKWEB_INFORMATION", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "_")
    }
        internal static func securityBreachDarkwebRecommandationNoDomainIsMatchingCredentials(_ p1: Int) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_DARKWEB_RECOMMANDATION_NO_DOMAIN_IS_MATCHING_CREDENTIALS", p1, fallback: "You’re using this password for %1$d of the logins stored in Dashlane. We recommend that you update all logins with unique passwords.")
    }
        internal static func securityBreachDarkwebRecommandationNoDomainNoPasswordLeaked(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_DARKWEB_RECOMMANDATION_NO_DOMAIN_NO_PASSWORD_LEAKED", String(describing: p1), fallback: "_")
    }
        internal static let securityBreachDescription = L10n.tr("Localizable", "SECURITY_BREACH_DESCRIPTION", fallback: "Date of alert:")
        internal static let securityBreachExplanationDataleakDescription = L10n.tr("Localizable", "SECURITY_BREACH_EXPLANATION_DATALEAK_DESCRIPTION", fallback: "Dark Web Monitoring scans the web for leaked or stolen personal data and alerts you instantly if your information is found where it doesn’t belong, so you can take action fast.")
        internal static let securityBreachExplanationDataleakTitle = L10n.tr("Localizable", "SECURITY_BREACH_EXPLANATION_DATALEAK_TITLE", fallback: "What is Dark Web Monitoring?")
        internal static let securityBreachIdentityStillAtRisk = L10n.tr("Localizable", "SECURITY_BREACH_IDENTITY_STILL_AT_RISK", fallback: "You may have updated your password after the breach, but if you aren't sure, make sure to update it and any other similar passwords.")
        internal static let securityBreachImpactedDomains = L10n.tr("Localizable", "SECURITY_BREACH_IMPACTED_DOMAINS", fallback: "Affected websites:")
            internal static func securityBreachImpactedDomainsParameters(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_IMPACTED_DOMAINS_PARAMETERS", String(describing: p1), fallback: "Affected websites:\n_")
    }
        internal static let securityBreachImpactedEmails = L10n.tr("Localizable", "SECURITY_BREACH_IMPACTED_EMAILS", fallback: "Affected email address:")
            internal static func securityBreachImpactedEmailsParameters(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_IMPACTED_EMAILS_PARAMETERS", String(describing: p1), fallback: "Affected email address:\n_")
    }
        internal static let securityBreachImpactedUsernames = L10n.tr("Localizable", "SECURITY_BREACH_IMPACTED_USERNAMES", fallback: "Affected usernames:")
            internal static func securityBreachImpactedUsernamesParameters(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_IMPACTED_USERNAMES_PARAMETERS", String(describing: p1), fallback: "Affected usernames:\n_")
    }
        internal static let securityBreachLaterCta = L10n.tr("Localizable", "SECURITY_BREACH_LATER_CTA", fallback: "Dismiss")
        internal static let securityBreachLeakedAddress = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_ADDRESS", fallback: "addresses")
        internal static let securityBreachLeakedCreditCard = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_CREDIT_CARD", fallback: "credit cards")
        internal static let securityBreachLeakedEmail = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_EMAIL", fallback: "emails")
        internal static let securityBreachLeakedGeolocation = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_GEOLOCATION", fallback: "location data")
        internal static let securityBreachLeakedIp = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_IP", fallback: "IP address")
        internal static let securityBreachLeakedLogin = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_LOGIN", fallback: "usernames")
        internal static let securityBreachLeakedPassword = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_PASSWORD", fallback: "password")
        internal static let securityBreachLeakedPersonalInfo = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_PERSONAL_INFO", fallback: "personal information")
        internal static let securityBreachLeakedPhoneNumber = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_PHONE_NUMBER", fallback: "phone numbers")
        internal static let securityBreachLeakedSocial = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_SOCIAL", fallback: "social network information")
        internal static let securityBreachLeakedSsn = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_SSN", fallback: "social security numbers")
        internal static let securityBreachLeakedUsername = L10n.tr("Localizable", "SECURITY_BREACH_LEAKED_USERNAME", fallback: "usernames")
        internal static let securityBreachMultipleAlertCloseCta = L10n.tr("Localizable", "SECURITY_BREACH_MULTIPLE_ALERT_CLOSE_CTA", fallback: "Close")
        internal static func securityBreachMultipleAlertDescription(_ p1: Int) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_MULTIPLE_ALERT_DESCRIPTION", p1, fallback: "You have %1$d new security alerts. View them now to see the details for each alert and take action.")
    }
        internal static let securityBreachMultipleAlertTitle = L10n.tr("Localizable", "SECURITY_BREACH_MULTIPLE_ALERT_TITLE", fallback: "New security alerts")
        internal static let securityBreachMultipleAlertViewCta = L10n.tr("Localizable", "SECURITY_BREACH_MULTIPLE_ALERT_VIEW_CTA", fallback: "View")
        internal static func securityBreachRegularAlertTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_REGULAR_ALERT_TITLE", String(describing: p1), fallback: "_")
    }
        internal static func securityBreachRegularInformation(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_BREACH_REGULAR_INFORMATION", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let securityBreachTakeactionCta = L10n.tr("Localizable", "SECURITY_BREACH_TAKEACTION_CTA", fallback: "Take action")
        internal static let securityBreachUpgradeCta = L10n.tr("Localizable", "SECURITY_BREACH_UPGRADE_CTA", fallback: "Upgrade to take action")
        internal static let securityDashboardActionExclude = L10n.tr("Localizable", "SECURITY_DASHBOARD_ACTION_EXCLUDE", fallback: "Exclude")
        internal static let securityDashboardActionInclude = L10n.tr("Localizable", "SECURITY_DASHBOARD_ACTION_INCLUDE", fallback: "Include")
        internal static let securityDashboardActionReplace = L10n.tr("Localizable", "SECURITY_DASHBOARD_ACTION_REPLACE", fallback: "Replace")
                internal static let securityDashboardAdviceEmptyState = L10n.tr("Localizable", "SECURITY_DASHBOARD_ADVICE_EMPTY_STATE", fallback: "Add at least 5 logins to Dashlane to get a Password Health score.\n\nYour score will indicate the overall safety of your online accounts.")
                internal static let securityDashboardAdviceNormal = L10n.tr("Localizable", "SECURITY_DASHBOARD_ADVICE_NORMAL", fallback: "Password Health Score\n\nIncrease your score by updating your passwords.")
        internal static func securityDashboardCompromisedGroupTitle(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "SECURITY_DASHBOARD_COMPROMISED_GROUP_TITLE", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let securityDashboardEmptyCompromised = L10n.tr("Localizable", "SECURITY_DASHBOARD_EMPTY_COMPROMISED", fallback: "Fantastic! You don't have any compromised passwords.")
                internal static let securityDashboardEmptyExcluded = L10n.tr("Localizable", "SECURITY_DASHBOARD_EMPTY_EXCLUDED", fallback: "Logins that you choose to exclude from your Password Health score will appear here.\n\nOnly exclude logins that you know are secure or duplicate items.")
        internal static let securityDashboardEmptyReused = L10n.tr("Localizable", "SECURITY_DASHBOARD_EMPTY_REUSED", fallback: "Excellent! You don't have any reused passwords.")
        internal static let securityDashboardEmptyWeak = L10n.tr("Localizable", "SECURITY_DASHBOARD_EMPTY_WEAK", fallback: "Great job! You don't have any weak passwords.")
        internal static let securityDashboardMenuChecked = L10n.tr("Localizable", "SECURITY_DASHBOARD_MENU_CHECKED", fallback: "Excluded")
        internal static let securityDashboardMenuCompromised = L10n.tr("Localizable", "SECURITY_DASHBOARD_MENU_COMPROMISED", fallback: "Compromised")
        internal static let securityDashboardMenuReused = L10n.tr("Localizable", "SECURITY_DASHBOARD_MENU_REUSED", fallback: "Reused")
        internal static let securityDashboardMenuWeak = L10n.tr("Localizable", "SECURITY_DASHBOARD_MENU_WEAK", fallback: "Weak")
        internal static func securityDashboardReusedGroupTitle(_ p1: Int) -> String {
      return L10n.tr("Localizable", "SECURITY_DASHBOARD_REUSED_GROUP_TITLE", p1, fallback: "Password used %1$d times")
    }
        internal static let securityDashboardSensitiveOnlyText = L10n.tr("Localizable", "SECURITY_DASHBOARD_SENSITIVE_ONLY_TEXT", fallback: "Only show critical accounts")
        internal static let securityDashboardToolsTitle = L10n.tr("Localizable", "SECURITY_DASHBOARD_TOOLS_TITLE", fallback: "Password Health")
        internal static let securityAlertNotificationBody = L10n.tr("Localizable", "SecurityAlertNotificationBody", fallback: "You have a new security alert requiring your attention.")
        internal static let securityAlertNotificationTitle = L10n.tr("Localizable", "SecurityAlertNotificationTitle", fallback: "Security Alert")
        internal static let settingsDataPrivacy = L10n.tr("Localizable", "Settings_DataPrivacy", fallback: "Privacy and data settings")
        internal static let settingsHelpFeedbackSection = L10n.tr("Localizable", "settings_help_feedbackSection", fallback: "Feedback")
        internal static let settingsHelpLegalSection = L10n.tr("Localizable", "settings_help_legalSection", fallback: "Legal")
        internal static let settingsMasterPassword = L10n.tr("Localizable", "Settings_MasterPassword", fallback: "Change Master Password")
        internal static let settingsMasterPasswordPrompt = L10n.tr("Localizable", "Settings_MasterPasswordPrompt", fallback: "Enter your current Master Password, then you can create a new one")
        internal static let settingsTitle = L10n.tr("Localizable", "SETTINGS_TITLE", fallback: "Settings")
        internal static let shareQuickAction = L10n.tr("Localizable", "shareQuickAction", fallback: "Share")
        internal static let shopping = L10n.tr("Localizable", "shopping", fallback: "Shopping")
        internal static func shushDashlaneDisabledFieldsInfoPlural(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SHUSH_DASHLANE_DISABLED_FIELDS_INFO_PLURAL", String(describing: p1), fallback: "_")
    }
        internal static func shushDashlaneDisabledFieldsInfoSingular(_ p1: Any) -> String {
      return L10n.tr("Localizable", "SHUSH_DASHLANE_DISABLED_FIELDS_INFO_SINGULAR", String(describing: p1), fallback: "_")
    }
        internal static let shushDashlaneDisabledFieldsRevert = L10n.tr("Localizable", "SHUSH_DASHLANE_DISABLED_FIELDS_REVERT", fallback: "Revert")
        internal static let shushDashlaneLearnMore = L10n.tr("Localizable", "SHUSH_DASHLANE_LEARN_MORE", fallback: "Learn more.")
        internal static let shushDashlaneLearnMoreAccessibilityLabel = L10n.tr("Localizable", "SHUSH_DASHLANE_LEARN_MORE_ACCESSIBILITY_LABEL", fallback: "Learn more about turning off autofill for a website, webpage, or field")
        internal static let shushDashlaneNoDisabledFieldsSubtitle = L10n.tr("Localizable", "SHUSH_DASHLANE_NO_DISABLED_FIELDS_SUBTITLE", fallback: "You can turn off Autofill for specific fields on this website. Learn more.")
        internal static let shushDashlaneNoDisabledFieldsSubtitleWithoutLink = L10n.tr("Localizable", "SHUSH_DASHLANE_NO_DISABLED_FIELDS_SUBTITLE_WITHOUT_LINK", fallback: "You can turn off Autofill for specific fields on this website.")
        internal static let shushDashlaneNoDisabledFieldsTitle = L10n.tr("Localizable", "SHUSH_DASHLANE_NO_DISABLED_FIELDS_TITLE", fallback: "Did you know?")
        internal static let sidebarToolsTitle = L10n.tr("Localizable", "SIDEBAR_TOOLS_TITLE", fallback: "Tools")
        internal static let social = L10n.tr("Localizable", "social", fallback: "Social")
        internal static let ssoMigrationAboutTitle = L10n.tr("Localizable", "ssoMigrationAboutTitle", fallback: "Learn more about SSO.")
        internal static let ssoMigrationMessage = L10n.tr("Localizable", "ssoMigrationMessage", fallback: "Authenticate securely with multiple websites by logging in just once with your company SSO login.")
        internal static let ssoMigrationMessage2 = L10n.tr("Localizable", "ssoMigrationMessage2", fallback: "Click below to log in with SSO while we'll do all the setup work.")
        internal static let ssoMigrationNote = L10n.tr("Localizable", "ssoMigrationNote", fallback: "Note: Your organization has enabled SSO for Dashlane. While typically prohibited by internal policies, your IT administrator may be able to access the information you store in Dashlane, including personal logins. Dashlane has no control over other organization's policies.")
        internal static let ssoMigrationTitle = L10n.tr("Localizable", "ssoMigrationTitle", fallback: "Your company has enabled single sign-on (SSO)")
        internal static let ssoToMPButton = L10n.tr("Localizable", "ssoToMPButton", fallback: "Create Master Password")
        internal static let ssoToMPSubtitle = L10n.tr("Localizable", "ssoToMPSubtitle", fallback: "Your account rights have changed. Create a strong Master Password to log in to Dashlane going forward.")
        internal static let ssoToMPTitle = L10n.tr("Localizable", "ssoToMPTitle", fallback: "Create a Master Password for Dashlane")
        internal static func ssoUseBiometricsButton(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ssoUseBiometricsButton", String(describing: p1), fallback: "_")
    }
        internal static func ssoUseBiometricsContent(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ssoUseBiometricsContent", String(describing: p1), fallback: "_")
    }
        internal static let ssoUseBiometricsTitle = L10n.tr("Localizable", "ssoUseBiometricsTitle", fallback: "Choose how to unlock Dashlane")
        internal static let ssoUsePinCodeButton = L10n.tr("Localizable", "ssoUsePinCodeButton", fallback: "Enter a PIN")
        internal static let ssoUsePinCodeContent = L10n.tr("Localizable", "ssoUsePinCodeContent", fallback: "Breeze through logins! Use your PIN to log in to Dashlane quickly and securely on this device.")
        internal static let ssoUsePinCodeTitle = L10n.tr("Localizable", "ssoUsePinCodeTitle", fallback: "Unlock Dashlane with your PIN")
        internal static let suggested = L10n.tr("Localizable", "suggested", fallback: "Suggested")
        internal static let suggestedItemsTitle = L10n.tr("Localizable", "suggestedItemsTitle", fallback: "Suggested items")
        internal static let suggestedTips = L10n.tr("Localizable", "suggestedTips", fallback: "Suggested tips")
        internal static let tabContactsTitle = L10n.tr("Localizable", "TAB_CONTACTS_TITLE", fallback: "Sharing")
        internal static let tabSettingsTitle = L10n.tr("Localizable", "TAB_SETTINGS_TITLE", fallback: "Settings")
        internal static let tabToolsTitle = L10n.tr("Localizable", "TAB_TOOLS_TITLE", fallback: "Tools")
        internal static let tabVaultTitle = L10n.tr("Localizable", "TAB_VAULT_TITLE", fallback: "Vault")
        internal static let tabNotificationsTitle = L10n.tr("Localizable", "tabNotificationsTitle", fallback: "Notifications")
        internal static let tachyonAuthenticationScreenDelete = L10n.tr("Localizable", "TachyonAuthenticationScreenDelete", fallback: "Delete")
        internal static let tachyonAuthenticationScreenEnterMasterPassword = L10n.tr("Localizable", "TachyonAuthenticationScreenEnterMasterPassword", fallback: "Enter Master Password")
        internal static let tachyonAuthenticationScreenEnterOTPCode = L10n.tr("Localizable", "TachyonAuthenticationScreenEnterOTPCode", fallback: "Enter OTP code")
        internal static let tachyonAuthenticationScreenLoginUsingDuoPush = L10n.tr("Localizable", "TachyonAuthenticationScreenLoginUsingDuoPush", fallback: "Log in using Duo Push")
        internal static let tachyonAuthenticationScreenMainCancel = L10n.tr("Localizable", "TachyonAuthenticationScreenMainCancel", fallback: "Cancel")
        internal static func tachyonAuthenticationScreenTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TachyonAuthenticationScreenTitle", String(describing: p1), fallback: "_")
    }
        internal static let tachyonAuthenticationScreenTitleStatic = L10n.tr("Localizable", "TachyonAuthenticationScreenTitleStatic", fallback: "Unlock your Dashlane Vault to use AutoFill")
        internal static let tachyonAuthenticationScreenUseFaceID = L10n.tr("Localizable", "TachyonAuthenticationScreenUseFaceID", fallback: "Use Face ID")
        internal static let tachyonAuthenticationScreenUsePinCode = L10n.tr("Localizable", "TachyonAuthenticationScreenUsePinCode", fallback: "Use PIN")
        internal static let tachyonAuthenticationScreenUseTouchID = L10n.tr("Localizable", "TachyonAuthenticationScreenUseTouchID", fallback: "Use Touch ID")
        internal static let tachyonConvenientLoginMethodRequiredScreenCTA = L10n.tr("Localizable", "TachyonConvenientLoginMethodRequiredScreenCTA", fallback: "Set up biometrics")
        internal static let tachyonConvenientLoginMethodRequiredScreenCTANoBiometrics = L10n.tr("Localizable", "TachyonConvenientLoginMethodRequiredScreenCTA_noBiometrics", fallback: "Set up PIN")
        internal static let tachyonCredentialsListSearchPlaceholder = L10n.tr("Localizable", "TachyonCredentialsListSearchPlaceholder", fallback: "Search")
        internal static let tachyonCredentialsListTitle = L10n.tr("Localizable", "TachyonCredentialsListTitle", fallback: "Your Dashlane Vault")
        internal static let tachyonLinkingCredentialCtaIgnore = L10n.tr("Localizable", "tachyonLinkingCredential_ctaIgnore", fallback: "Maybe later")
        internal static let tachyonLinkingCredentialCtaLink = L10n.tr("Localizable", "tachyonLinkingCredential_ctaLink", fallback: "Link website")
        internal static func tachyonLinkingCredentialMessage(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "tachyonLinkingCredential_message", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static func tachyonLinkingCredentialTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "tachyonLinkingCredential_title", String(describing: p1), fallback: "_")
    }
        internal static let tachyonLoginRequiredScreenCancel = L10n.tr("Localizable", "TachyonLoginRequiredScreenCancel", fallback: "Cancel")
        internal static let tachyonLoginRequiredScreenCTA = L10n.tr("Localizable", "TachyonLoginRequiredScreenCTA", fallback: "Go to the main app")
        internal static let tachyonLoginRequiredScreenDescription = L10n.tr("Localizable", "TachyonLoginRequiredScreenDescription", fallback: "You are logged out of Dashlane. Sign into the main Dashlane app to use AutoFill on apps and websites.")
        internal static let tachyonLoginRequiredScreenTitle = L10n.tr("Localizable", "TachyonLoginRequiredScreenTitle", fallback: "AutoFill with Dashlane")
        internal static let teamSpacesSectionTitle = L10n.tr("Localizable", "TEAM_SPACES_SECTION_TITLE", fallback: "Space")
        internal static let teamSpacesSharingDisabledMessageBody = L10n.tr("Localizable", "TEAM_SPACES_SHARING_DISABLED_MESSAGE_BODY", fallback: "Your company policy prevents sharing items stored in Dashlane. For more information, contact your account admin.")
        internal static let teamSpacesSharingDisabledMessageTitle = L10n.tr("Localizable", "TEAM_SPACES_SHARING_DISABLED_MESSAGE_TITLE", fallback: "Sharing is disabled")
        internal static let tech = L10n.tr("Localizable", "tech", fallback: "Tech")
        internal static let tipsForYou = L10n.tr("Localizable", "tipsForYou", fallback: "Tips for you")
        internal static let titleGotIt = L10n.tr("Localizable", "title_got_it", fallback: "Got it")
        internal static let toolsTitle = L10n.tr("Localizable", "TOOLS_TITLE", fallback: "Tools")
        internal static let twofaActivationErrorCta = L10n.tr("Localizable", "TWOFA_ACTIVATION_ERROR_CTA", fallback: "Return to settings")
        internal static let twofaActivationErrorMessage = L10n.tr("Localizable", "TWOFA_ACTIVATION_ERROR_MESSAGE", fallback: "We couldn’t set up 2FA for Dashlane. Please wait a few minutes then try again.")
        internal static let twofaActivationErrorTitle = L10n.tr("Localizable", "TWOFA_ACTIVATION_ERROR_TITLE", fallback: "Try setting up 2FA again in a few minutes")
        internal static let twofaActivationFinalMessage = L10n.tr("Localizable", "TWOFA_ACTIVATION_FINAL_MESSAGE", fallback: "You’re all set!")
        internal static let twofaActivationNoInternetErrorMessage = L10n.tr("Localizable", "TWOFA_ACTIVATION_NO_INTERNET_ERROR_MESSAGE", fallback: "We couldn’t set up 2FA due to an issue with your internet connection. Please check your connection then try again.")
        internal static let twofaActivationNoInternetErrorTitle = L10n.tr("Localizable", "TWOFA_ACTIVATION_NO_INTERNET_ERROR_TITLE", fallback: "There’s an issue with your internet connection")
        internal static let twofaActivationProgressMessage = L10n.tr("Localizable", "TWOFA_ACTIVATION_PROGRESS_MESSAGE", fallback: "Finishing 2FA setup...")
        internal static let twofaDeactivationAlertCta = L10n.tr("Localizable", "TWOFA_DEACTIVATION_ALERT_CTA", fallback: "Yes, turn off")
        internal static let twofaDeactivationAlertMessage = L10n.tr("Localizable", "TWOFA_DEACTIVATION_ALERT_MESSAGE", fallback: "2FA is an extra layer of security. If you turn it off, you won’t be sent a push request or asked for a 6-digit token when logging in to your account.")
        internal static let twofaDeactivationAlertTitle = L10n.tr("Localizable", "TWOFA_DEACTIVATION_ALERT_TITLE", fallback: "Turn off 2FA?")
        internal static let twofaDeactivationErrorMessage = L10n.tr("Localizable", "TWOFA_DEACTIVATION_ERROR_MESSAGE", fallback: "We couldn’t turn off 2FA for Dashlane. Please wait a few minutes then try again.")
        internal static let twofaDeactivationErrorTitle = L10n.tr("Localizable", "TWOFA_DEACTIVATION_ERROR_TITLE", fallback: "Try turning off 2FA again in a few minutes")
        internal static let twofaDeactivationFinalMessage = L10n.tr("Localizable", "TWOFA_DEACTIVATION_FINAL_MESSAGE", fallback: "2FA is turned off")
        internal static let twofaDeactivationHelpCta = L10n.tr("Localizable", "TWOFA_DEACTIVATION_HELP_CTA", fallback: "Use a recovery code.")
        internal static let twofaDeactivationHelpTitle = L10n.tr("Localizable", "TWOFA_DEACTIVATION_HELP_TITLE", fallback: "Can’t access your authenticator?")
        internal static let twofaDeactivationIncorrectTokenErrorMessage = L10n.tr("Localizable", "TWOFA_DEACTIVATION_INCORRECT_TOKEN_ERROR_MESSAGE", fallback: "Incorrect token")
        internal static let twofaDeactivationProgressMessage = L10n.tr("Localizable", "TWOFA_DEACTIVATION_PROGRESS_MESSAGE", fallback: "Turning off 2FA...")
        internal static let twofaDeactivationTitle = L10n.tr("Localizable", "TWOFA_DEACTIVATION_TITLE", fallback: "Enter the 6-digit token from your authenticator app.")
        internal static let twofaDisableCta = L10n.tr("Localizable", "TWOFA_DISABLE_CTA", fallback: "Continue")
        internal static let twofaDisableMessage1 = L10n.tr("Localizable", "TWOFA_DISABLE_MESSAGE_1", fallback: "Your admin requires 2FA. While it’s turned off, you won’t be able to access your vault.")
        internal static let twofaDisableMessage2 = L10n.tr("Localizable", "TWOFA_DISABLE_MESSAGE_2", fallback: "If you need to update your 2FA preferences, turn off 2FA. You’ll start the setup process again right away.")
        internal static let twofaDisableTitle = L10n.tr("Localizable", "TWOFA_DISABLE_TITLE", fallback: "Temporarily turn off 2FA")
        internal static let twofaEnforcementLogoutCta = L10n.tr("Localizable", "TWOFA_ENFORCEMENT_LOGOUT_CTA", fallback: "Log out")
        internal static let twofaEnforcementMessage1 = L10n.tr("Localizable", "TWOFA_ENFORCEMENT_MESSAGE_1", fallback: "Your company requires 2-factor authentication (2FA) for additional security.")
        internal static let twofaEnforcementMessage2 = L10n.tr("Localizable", "TWOFA_ENFORCEMENT_MESSAGE_2", fallback: "You can set up 2FA on this mobile device using Dashlane Authenticator. To use a different authenticator app, log in from your computer browser.")
        internal static let twofaEnforcementSetupCta = L10n.tr("Localizable", "TWOFA_ENFORCEMENT_SETUP_CTA", fallback: "Set up 2FA")
        internal static let twofaEnforcementTitle = L10n.tr("Localizable", "TWOFA_ENFORCEMENT_TITLE", fallback: "Set up 2FA to access your vault")
        internal static let twofaOptionOtp1Title = L10n.tr("Localizable", "TWOFA_OPTION_OTP1_TITLE", fallback: "When you log in on a new device")
        internal static let twofaOptionOtp2Title = L10n.tr("Localizable", "TWOFA_OPTION_OTP2_TITLE", fallback: "Every time you log in")
        internal static let twofaOptionSubtitle = L10n.tr("Localizable", "TWOFA_OPTION_SUBTITLE", fallback: "How often should we send you an authentication request?")
        internal static let twofaOptionTitle = L10n.tr("Localizable", "TWOFA_OPTION_TITLE", fallback: "Set your preferences")
        internal static let twofaPhoneInfo = L10n.tr("Localizable", "TWOFA_PHONE_INFO", fallback: "Make sure you enter a valid phone number that’s able to receive texts.")
        internal static let twofaPhonePlaceholder = L10n.tr("Localizable", "TWOFA_PHONE_PLACEHOLDER", fallback: "Phone number")
        internal static let twofaPhoneSetupErrorMessage = L10n.tr("Localizable", "TWOFA_PHONE_SETUP_ERROR_MESSAGE", fallback: "There was an issue setting up your recovery method. Please try again.")
        internal static let twofaPhoneSetupErrorTitle = L10n.tr("Localizable", "TWOFA_PHONE_SETUP_ERROR_TITLE", fallback: "We couldn’t set up your recovery method")
        internal static let twofaPhoneSetupWrongErrorMessage = L10n.tr("Localizable", "TWOFA_PHONE_SETUP_WRONG_ERROR_MESSAGE", fallback: "Enter a valid mobile phone number")
        internal static let twofaPhoneTitle = L10n.tr("Localizable", "TWOFA_PHONE_TITLE", fallback: "Add a mobile phone number")
        internal static let twofaProgressMessage = L10n.tr("Localizable", "TWOFA_PROGRESS_MESSAGE", fallback: "Setting up your preferences")
        internal static let twofaRecoveryCodesCta = L10n.tr("Localizable", "TWOFA_RECOVERY_CODES_CTA", fallback: "Save recovery codes")
        internal static let twofaRecoveryCodesInfo = L10n.tr("Localizable", "TWOFA_RECOVERY_CODES_INFO", fallback: "Store these outside of Dashlane. That way they’re available if you can’t log in with other authentication methods.")
        internal static let twofaRecoveryCodesSubtitle = L10n.tr("Localizable", "TWOFA_RECOVERY_CODES_SUBTITLE", fallback: "Your recovery codes")
        internal static let twofaRecoveryCodesTitle = L10n.tr("Localizable", "TWOFA_RECOVERY_CODES_TITLE", fallback: "Store these recovery codes somewhere secure")
        internal static let twofaRecoverySetupCta = L10n.tr("Localizable", "TWOFA_RECOVERY_SETUP_CTA", fallback: "Start setup")
        internal static let twofaRecoverySetupHeader = L10n.tr("Localizable", "TWOFA_RECOVERY_SETUP_HEADER", fallback: "How to access your recovery codes:")
        internal static let twofaRecoverySetupMessage1 = L10n.tr("Localizable", "TWOFA_RECOVERY_SETUP_MESSAGE1", fallback: "Receive them via text to your mobile phone")
        internal static let twofaRecoverySetupMessage2 = L10n.tr("Localizable", "TWOFA_RECOVERY_SETUP_MESSAGE2", fallback: "Save the list generated during this setup in a secure place")
        internal static let twofaRecoverySetupSubtitle = L10n.tr("Localizable", "TWOFA_RECOVERY_SETUP_SUBTITLE", fallback: "If you can’t access your Authenticator app, you can log in to your Dashlane account with a recovery code.")
        internal static let twofaRecoverySetupTitle = L10n.tr("Localizable", "TWOFA_RECOVERY_SETUP_TITLE", fallback: "Set up a recovery method")
        internal static let twofaSettingsEnforcedMessageOtp1 = L10n.tr("Localizable", "TWOFA_SETTINGS_ENFORCED_MESSAGE_OTP1", fallback: "Your company requires you to turn on 2FA to access your vault. When logging in to Dashlane on a new device, you’ll need to enter a 6-digit token from your authenticator app.")
        internal static let twofaSettingsEnforcedMessageOtp2 = L10n.tr("Localizable", "TWOFA_SETTINGS_ENFORCED_MESSAGE_OTP2", fallback: "Your company requires you to turn on 2FA to access your vault. When logging into Dashlane, you'll need to enter a 6-digit token from your authenticator app.")
        internal static let twofaSettingsMessage = L10n.tr("Localizable", "TWOFA_SETTINGS_MESSAGE", fallback: "2FA is an extra layer of security for your account. When logging in or adding a new device, we’ll ask you to enter a 6-digit token from your authenticator app.")
        internal static let twofaSettingsTitle = L10n.tr("Localizable", "TWOFA_SETTINGS_TITLE", fallback: "2-factor authentication (2FA)")
        internal static func twofaSetupBiometryCta(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TWOFA_SETUP_BIOMETRY_CTA", String(describing: p1), fallback: "_")
    }
        internal static let twofaSetupPinCta = L10n.tr("Localizable", "TWOFA_SETUP_PIN_CTA", fallback: "Use PIN")
        internal static let twofaSetupUnpairedCta = L10n.tr("Localizable", "TWOFA_SETUP_UNPAIRED_CTA", fallback: "Open settings")
        internal static let twofaSetupUnpairedHelpCta = L10n.tr("Localizable", "TWOFA_SETUP_UNPAIRED_HELP_CTA", fallback: "Learn more about Dashlane Authenticator")
        internal static func twofaSetupUnpairedMessage1(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TWOFA_SETUP_UNPAIRED_MESSAGE1", String(describing: p1), fallback: "_")
    }
        internal static let twofaSetupUnpairedMessage2 = L10n.tr("Localizable", "TWOFA_SETUP_UNPAIRED_MESSAGE2", fallback: "You can update your unlock methods in your security settings.")
        internal static func twofaSetupUnpairedTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "TWOFA_SETUP_UNPAIRED_TITLE", String(describing: p1), fallback: "_")
    }
        internal static func twofaStepsCaption(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "TWOFA_STEPS_CAPTION", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let twofaStepsNavigationTitle = L10n.tr("Localizable", "TWOFA_STEPS_NAVIGATION_TITLE", fallback: "2FA")
        internal static let twofaSuccessCta = L10n.tr("Localizable", "TWOFA_SUCCESS_CTA", fallback: "View my token")
        internal static let twofaSuccessMessage1 = L10n.tr("Localizable", "TWOFA_SUCCESS_MESSAGE1", fallback: "Accept the authentication request in your Authenticator app")
        internal static let twofaSuccessMessage2 = L10n.tr("Localizable", "TWOFA_SUCCESS_MESSAGE2", fallback: "Or, enter the 6-digit token from your Authenticator")
        internal static let twofaSuccessSubtitle = L10n.tr("Localizable", "TWOFA_SUCCESS_SUBTITLE", fallback: "When you log in to Dashlane on a new device, you’ll be asked to:")
        internal static let twofaSuccessTitle = L10n.tr("Localizable", "TWOFA_SUCCESS_TITLE", fallback: "You added an extra layer of security to your account")
                internal static let twoFactorEnforcementBody = L10n.tr("Localizable", "twoFactorEnforcement_body", fallback: "Your company requires you to use 2-factor authentication (2FA) for additional security.\n\nTo set up 2FA, please log in to the Dashlane extension from your computer browser.")
        internal static let twoFactorEnforcementTitle = L10n.tr("Localizable", "twoFactorEnforcement_title", fallback: "Log in from your computer to set up 2FA")
        internal static let uiTitleForAlreadyPremium = L10n.tr("Localizable", "uiTitleForAlreadyPremium", fallback: "Dashlane Premium")
        internal static let validityStatusExpiredVersionNoUpdateClose = L10n.tr("Localizable", "ValidityStatus_ExpiredVersion_NoUpdate_Close", fallback: "Close")
        internal static let validityStatusExpiredVersionNoUpdateDesc = L10n.tr("Localizable", "ValidityStatus_ExpiredVersion_NoUpdate_Desc", fallback: "Visit the Help Center to learn more about what you can do to keep using Dashlane.")
        internal static let validityStatusExpiredVersionNoUpdateLearnMore = L10n.tr("Localizable", "ValidityStatus_ExpiredVersion_NoUpdate_LearnMore", fallback: "Learn more")
        internal static let validityStatusExpiredVersionNoUpdateTitle = L10n.tr("Localizable", "ValidityStatus_ExpiredVersion_NoUpdate_Title", fallback: "This version of the app is no longer supported")
        internal static let validityStatusExpiredVersionUpdatePossibleClose = L10n.tr("Localizable", "ValidityStatus_ExpiredVersion_UpdatePossible_Close", fallback: "Close")
        internal static let validityStatusExpiredVersionUpdatePossibleDesc = L10n.tr("Localizable", "ValidityStatus_ExpiredVersion_UpdatePossible_Desc", fallback: "Update the app via the App Store to continue using Dashlane.")
        internal static let validityStatusExpiredVersionUpdatePossibleTitle = L10n.tr("Localizable", "ValidityStatus_ExpiredVersion_UpdatePossible_Title", fallback: "This version of the app is no longer supported")
        internal static let validityStatusExpiredVersionUpdatePossibleUpdate = L10n.tr("Localizable", "ValidityStatus_ExpiredVersion_UpdatePossible_Update", fallback: "Update")
        internal static let validityStatusUpdateRecommendedUpdatePossibleClose = L10n.tr("Localizable", "ValidityStatus_UpdateRecommended_UpdatePossible_Close", fallback: "Close")
        internal static let validityStatusUpdateRecommendedUpdatePossibleTitle = L10n.tr("Localizable", "ValidityStatus_UpdateRecommended_UpdatePossible_Title", fallback: "Update your app to access the latest features")
        internal static let validityStatusUpdateRecommendedUpdatePossibleUpdate = L10n.tr("Localizable", "ValidityStatus_UpdateRecommended_UpdatePossible_Update", fallback: "Update")
        internal static let validityStatusUpdateRequiredNoUpdateClose = L10n.tr("Localizable", "ValidityStatus_UpdateRequired_NoUpdate_Close", fallback: "Close")
        internal static func validityStatusUpdateRequiredNoUpdateDesc(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ValidityStatus_UpdateRequired_NoUpdate_Desc", String(describing: p1), fallback: "_")
    }
        internal static let validityStatusUpdateRequiredNoUpdateLearnMore = L10n.tr("Localizable", "ValidityStatus_UpdateRequired_NoUpdate_LearnMore", fallback: "Learn more")
        internal static let validityStatusUpdateRequiredNoUpdateTitle = L10n.tr("Localizable", "ValidityStatus_UpdateRequired_NoUpdate_Title", fallback: "This version of the app will stop working soon")
        internal static let validityStatusUpdateRequiredUpdatePossibleClose = L10n.tr("Localizable", "ValidityStatus_UpdateRequired_UpdatePossible_Close", fallback: "Close")
        internal static func validityStatusUpdateRequiredUpdatePossibleDesc(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ValidityStatus_UpdateRequired_UpdatePossible_Desc", String(describing: p1), fallback: "_")
    }
        internal static let validityStatusUpdateRequiredUpdatePossibleTitle = L10n.tr("Localizable", "ValidityStatus_UpdateRequired_UpdatePossible_Title", fallback: "Reminder: Update your app now to keep using Dashlane")
        internal static let validityStatusUpdateRequiredUpdatePossibleUpdate = L10n.tr("Localizable", "ValidityStatus_UpdateRequired_UpdatePossible_Update", fallback: "Update")
        internal static let validityStatusUpdateStronglyEncouragedNoUpdateClose = L10n.tr("Localizable", "ValidityStatus_UpdateStronglyEncouraged_NoUpdate_Close", fallback: "Close")
        internal static let validityStatusUpdateStronglyEncouragedNoUpdateDesc = L10n.tr("Localizable", "ValidityStatus_UpdateStronglyEncouraged_NoUpdate_Desc", fallback: "This version of the app will stop working soon. There seems to be an issue updating the app on your device. Visit the Help Center to learn more.")
        internal static let validityStatusUpdateStronglyEncouragedNoUpdateLearnMore = L10n.tr("Localizable", "ValidityStatus_UpdateStronglyEncouraged_NoUpdate_LearnMore", fallback: "Learn more")
        internal static let validityStatusUpdateStronglyEncouragedNoUpdateTitle = L10n.tr("Localizable", "ValidityStatus_UpdateStronglyEncouraged_NoUpdate_Title", fallback: "This version of the app is out of date")
        internal static let validityStatusUpdateStronglyEncouragedUpdatePossibleClose = L10n.tr("Localizable", "ValidityStatus_UpdateStronglyEncouraged_UpdatePossible_Close", fallback: "Close")
        internal static let validityStatusUpdateStronglyEncouragedUpdatePossibleDesc = L10n.tr("Localizable", "ValidityStatus_UpdateStronglyEncouraged_UpdatePossible_Desc", fallback: "This version of the app is out of date. It will stop working soon.")
        internal static let validityStatusUpdateStronglyEncouragedUpdatePossibleTitle = L10n.tr("Localizable", "ValidityStatus_UpdateStronglyEncouraged_UpdatePossible_Title", fallback: "Update your app to keep using Dashlane")
        internal static let validityStatusUpdateStronglyEncouragedUpdatePossibleUpdate = L10n.tr("Localizable", "ValidityStatus_UpdateStronglyEncouraged_UpdatePossible_Update", fallback: "Update")
        internal static let vaultTitle = L10n.tr("Localizable", "VAULT_TITLE", fallback: "Vault")
        internal static let vpnTeamPaywallSubtitle = L10n.tr("Localizable", "vpn_team_paywall_subtitle", fallback: "This feature has been disabled by your IT Admin.")
        internal static let vpnTeamPaywallTitle = L10n.tr("Localizable", "vpn_team_paywall_title", fallback: "VPN is disabled")
        internal static let vpnActivationViewAccountCreated = L10n.tr("Localizable", "vpnActivationView_accountCreated", fallback: "Account created")
        internal static let vpnActivationViewEmailSubtitle = L10n.tr("Localizable", "vpnActivationView_emailSubtitle", fallback: "Hotspot Shield will use it to activate your account. We’ll generate a secure password for you.")
        internal static let vpnActivationViewEmailTitle = L10n.tr("Localizable", "vpnActivationView_emailTitle", fallback: "Enter an email for your account")
        internal static let vpnActivationViewErrorAlreadyUsedEmailDescription = L10n.tr("Localizable", "vpnActivationView_error_already_used_email_description", fallback: "Try another email or contact Hotspot Shield support for help.")
        internal static let vpnActivationViewErrorAlreadyUsedEmailTitle = L10n.tr("Localizable", "vpnActivationView_error_already_used_email_title", fallback: "This email is already in use")
        internal static let vpnActivationViewErrorContactSupport = L10n.tr("Localizable", "vpnActivationView_error_contactSupport", fallback: "Contact support")
        internal static let vpnActivationViewErrorWrongEmailFormat = L10n.tr("Localizable", "vpnActivationView_error_wrong_email_format", fallback: "That email format doesn't look right. Let’s try again.")
        internal static let vpnActivationViewFinalizing = L10n.tr("Localizable", "vpnActivationView_finalizing", fallback: "Finalizing your account...")
        internal static let vpnActivationViewGenericErrorSubtitle = L10n.tr("Localizable", "vpnActivationView_genericError_subtitle", fallback: "We’re having trouble activating your account right now. Please try again, and contact Customer Support if it doesn’t work.")
        internal static func vpnActivationViewTermsAgree(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "vpnActivationView_termsAgree", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let vpnActivationViewTermsOfService = L10n.tr("Localizable", "vpnActivationView_termsOfService", fallback: "Terms of Service")
        internal static let vpnMainViewButtonActivated = L10n.tr("Localizable", "vpnMainView_button_activated", fallback: "Launch Hotspot Shield")
        internal static let vpnMainViewButtonActivationNeeded = L10n.tr("Localizable", "vpnMainView_button_activationNeeded", fallback: "Activate account")
        internal static let vpnMainViewSubtitleActivated = L10n.tr("Localizable", "vpnMainView_subtitle_activated", fallback: "You can now log in to your Hotspot Shield account with the following username and password.")
        internal static let vpnMainViewSubtitleActivationNeeded = L10n.tr("Localizable", "vpnMainView_subtitle_activationNeeded", fallback: "You’ll need to use this account info to log in to the VPN for the first time.")
        internal static let vpnMainViewTitleActivated = L10n.tr("Localizable", "vpnMainView_title_activated", fallback: "You're all set!")
        internal static let vpnMainViewTitleActivationNeeded = L10n.tr("Localizable", "vpnMainView_title_activationNeeded", fallback: "Activate your Hotspot Shield account")
        internal static let widgetDescription = L10n.tr("Localizable", "widgetDescription", fallback: "This widget will display the health of your passwords.")
        internal static let widgetDisplayName = L10n.tr("Localizable", "widgetDisplayName", fallback: "Dashlane - Password Health Widget")
        internal static let widgetScoreSubtitle = L10n.tr("Localizable", "widgetScoreSubtitle", fallback: "Out of 100")
        internal static let widgetTitle = L10n.tr("Localizable", "widgetTitle", fallback: "Password Health Score")
        internal static let zxcvbnDefaultPopupTitle = L10n.tr("Localizable", "ZXCVBN_DEFAULT_POPUP_TITLE", fallback: "General password creation rules")
    internal enum AccountCreation {
      internal enum Finish {
                internal static let createButton = L10n.tr("Localizable", "AccountCreation.Finish.createButton", fallback: "Create your account")
      }
    }
    internal enum KWPaymentMeanPaypalIOS {
            internal static let login = L10n.tr("Localizable", "KWPaymentMean_paypalIOS.login", fallback: "Username")
            internal static let name = L10n.tr("Localizable", "KWPaymentMean_paypalIOS.name", fallback: "Item name")
            internal static let password = L10n.tr("Localizable", "KWPaymentMean_paypalIOS.password", fallback: "Password")
    }
    internal enum KWPurchasePaidBasketIOS {
            internal static let category = L10n.tr("Localizable", "KWPurchasePaidBasketIOS.category", fallback: "Category")
    }
    internal enum NewMasterPassword {
            internal static let skipMasterPasswordButton = L10n.tr("Localizable", "NewMasterPassword.skipMasterPasswordButton", fallback: "Skip the Master Password")
            internal static let title = L10n.tr("Localizable", "NewMasterPassword.title", fallback: "...and a Master Password")
    }
    internal enum PasswordlessAccountCreation {
      internal enum Complete {
                internal static let title = L10n.tr("Localizable", "PasswordlessAccountCreation.Complete.title", fallback: "Your Dashlane account is ready to go! ")
      }
      internal enum Finish {
                internal static let message = L10n.tr("Localizable", "PasswordlessAccountCreation.Finish.message", fallback: "Agree to Dashlane’s Terms of Service and Privacy Policy to create your account.")
                internal static let title = L10n.tr("Localizable", "PasswordlessAccountCreation.Finish.title", fallback: "Finish creating your account")
      }
      internal enum Intro {
                internal static let getStartedButton = L10n.tr("Localizable", "PasswordlessAccountCreation.Intro.getStartedButton", fallback: "Get started")
                internal static let infoBox = L10n.tr("Localizable", "PasswordlessAccountCreation.Intro.infoBox", fallback: "Passwordless authentication is only available on mobile devices and Dashlane's Safari app.")
                internal static let learnMoreButton = L10n.tr("Localizable", "PasswordlessAccountCreation.Intro.learnMoreButton", fallback: "Learn more")
                internal static let message = L10n.tr("Localizable", "PasswordlessAccountCreation.Intro.message", fallback: "Go passwordless and use a device-specific PIN to log in instead of a Master Password.")
                internal static let navigationTitle = L10n.tr("Localizable", "PasswordlessAccountCreation.Intro.navigationTitle", fallback: "Passwordless authentication")
                internal static let title = L10n.tr("Localizable", "PasswordlessAccountCreation.Intro.title", fallback: "Create an account without a Master Password")
      }
    }
    internal enum ActivePlan {
            internal static let advancedTitle = L10n.tr("Localizable", "activePlan.advancedTitle", fallback: "Advanced")
            internal static let dashlaneBusinessTitle = L10n.tr("Localizable", "activePlan.dashlaneBusinessTitle", fallback: "Dashlane Business")
            internal static let essentialsTitle = L10n.tr("Localizable", "activePlan.essentialsTitle", fallback: "Essentials")
            internal static let familyPlusTitle = L10n.tr("Localizable", "activePlan.familyPlusTitle", fallback: "Family Plus")
            internal static let familyTitle = L10n.tr("Localizable", "activePlan.familyTitle", fallback: "Family")
            internal static let freeTitle = L10n.tr("Localizable", "activePlan.freeTitle", fallback: "Free")
            internal static let premiumPlusTitle = L10n.tr("Localizable", "activePlan.premiumPlusTitle", fallback: "Premium Plus")
            internal static let premiumTitle = L10n.tr("Localizable", "activePlan.premiumTitle", fallback: "Premium")
            internal static let trialTitle = L10n.tr("Localizable", "activePlan.trialTitle", fallback: "Premium Trial")
    }
    internal enum Settings {
      internal enum ActivePlan {
                internal static let changePlanButton = L10n.tr("Localizable", "settings.activePlan.changePlanButton", fallback: "Change plan")
                internal static func expiresSubtitle(_ p1: Any) -> String {
          return L10n.tr("Localizable", "settings.activePlan.expiresSubtitle", String(describing: p1), fallback: "_")
        }
                internal static let legacyFreeUserSubtitle = L10n.tr("Localizable", "settings.activePlan.legacyFreeUserSubtitle", fallback: "Joined before Dashlane V2.0")
                internal static let premiumForLifeSubtitle = L10n.tr("Localizable", "settings.activePlan.premiumForLifeSubtitle", fallback: "Free of charge, for life.")
                internal static let premiumFreeOfChargeSubtitle = L10n.tr("Localizable", "settings.activePlan.premiumFreeOfChargeSubtitle", fallback: "Free of charge.")
                internal static func renewSubtitle(_ p1: Any) -> String {
          return L10n.tr("Localizable", "settings.activePlan.renewSubtitle", String(describing: p1), fallback: "_")
        }
                internal static func trialDaysLeftSubtitle(_ p1: Any) -> String {
          return L10n.tr("Localizable", "settings.activePlan.trialDaysLeftSubtitle", String(describing: p1), fallback: "_")
        }
                internal static let upgradeButton = L10n.tr("Localizable", "settings.activePlan.upgradeButton", fallback: "Upgrade")
      }
    }
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
