import Foundation

internal enum L10n {
  internal enum InfoPlist {
        internal static let nsCameraUsageDescription = L10n.tr("InfoPlist", "NSCameraUsageDescription", fallback: "To scan the QR code, Dashlane needs access to your camera.")
        internal static let nsFaceIDUsageDescription = L10n.tr("InfoPlist", "NSFaceIDUsageDescription", fallback: "This will let you unlock Dashlane Authenticator with Face ID.")
  }
  internal enum Localizable {
        internal static let accessibilityInfoSection = L10n.tr("Localizable", "Accessibility_InfoSection", fallback: "Information box")
        internal static let addAccountTitle = L10n.tr("Localizable", "Add_account_title", fallback: "Add login")
        internal static let addLoginDetailsAddCode = L10n.tr("Localizable", "ADD_LOGIN_DETAILS_ADD_CODE", fallback: "Add new")
        internal static let addLoginDetailsEmailOrUsername = L10n.tr("Localizable", "ADD_LOGIN_DETAILS_EMAIL_OR_USERNAME", fallback: "EMAIL OR USERNAME")
        internal static let addLoginDetailsEmailOrUsernamePlaceholder = L10n.tr("Localizable", "ADD_LOGIN_DETAILS_EMAIL_OR_USERNAME_PLACEHOLDER", fallback: "_")
        internal static let addLoginDetailsError = L10n.tr("Localizable", "ADD_LOGIN_DETAILS_ERROR", fallback: "That doesn’t look right. Please try again.")
        internal static let addLoginDetailsSetupCode = L10n.tr("Localizable", "ADD_LOGIN_DETAILS_SETUP_CODE", fallback: "SETUP CODE")
        internal static let addLoginDetailsSetupCodePlaceholder = L10n.tr("Localizable", "ADD_LOGIN_DETAILS_SETUP_CODE_PLACEHOLDER", fallback: "Example: HVWO ZWK4 EFXF QXLT ...")
        internal static let addLoginDetailsTitle = L10n.tr("Localizable", "ADD_LOGIN_DETAILS_TITLE", fallback: "Add account details")
        internal static let addLoginDetailsWebsiteOrApp = L10n.tr("Localizable", "ADD_LOGIN_DETAILS_WEBSITE_OR_APP", fallback: "WEBSITE OR APP")
        internal static let addOtpCardStepLocate = L10n.tr("Localizable", "ADD_OTP_CARD_STEP_LOCATE", fallback: "Log in to the account you want to add to the Authenticator")
        internal static let addOtpCardStepScan = L10n.tr("Localizable", "ADD_OTP_CARD_STEP_SCAN", fallback: "Scan the QR code or enter the setup code they provide")
        internal static let addOtpCardStepTurnOn = L10n.tr("Localizable", "ADD_OTP_CARD_STEP_TURN_ON", fallback: "In the security settings, turn on 2-factor authentication (2FA)")
        internal static let addOtpFlowAddNewCta = L10n.tr("Localizable", "ADD_OTP_FLOW_ADD_NEW_CTA", fallback: "Add 2FA token")
        internal static let addOtpFlowEnterManualCta = L10n.tr("Localizable", "ADD_OTP_FLOW_ENTER_MANUAL_CTA", fallback: "Enter setup code")
        internal static let addOtpFlowFirstSetupLabel = L10n.tr("Localizable", "ADD_OTP_FLOW_FIRST_SETUP_LABEL", fallback: "Add your first 2FA token")
        internal static let addOtpFlowHelpCta = L10n.tr("Localizable", "ADD_OTP_FLOW_HELP_CTA", fallback: "Help")
        internal static let addOtpFlowScanCodeCta = L10n.tr("Localizable", "ADD_OTP_FLOW_SCAN_CODE_CTA", fallback: "Scan QR Code")
        internal static let addOtpFlowSetupLabel = L10n.tr("Localizable", "ADD_OTP_FLOW_SETUP_LABEL", fallback: "Add 2FA token")
        internal static let addOtpPreviewCta = L10n.tr("Localizable", "ADD_OTP_PREVIEW_CTA", fallback: "Ok, that’s done")
        internal static func addOtpPreviewSubtitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ADD_OTP_PREVIEW_SUBTITLE", String(describing: p1), fallback: "_")
    }
        internal static let addOtpPreviewTitle = L10n.tr("Localizable", "ADD_OTP_PREVIEW_TITLE", fallback: "Almost done")
        internal static let authenticationRequestMessage = L10n.tr("Localizable", "AUTHENTICATION_REQUEST_MESSAGE", fallback: "Are you logging in to Dashlane?")
        internal static let authenticatorPushViewTimeOutError = L10n.tr("Localizable", "authenticatorPushViewTimeOutError", fallback: "Your request has expired.")
        internal static let authoriseCameraButtonTitle = L10n.tr("Localizable", "Authorise_camera_button_title", fallback: "Go to Settings")
        internal static let backupNotPairedDescription = L10n.tr("Localizable", "BACKUP_NOT_PAIRED_DESCRIPTION", fallback: "Turn on biometric unlock or add a PIN to finish your backup.")
        internal static let backupNotPairedFinishCta = L10n.tr("Localizable", "BACKUP_NOT_PAIRED_FINISH_CTA", fallback: "Finish backup")
        internal static let backupNotPairedTitle = L10n.tr("Localizable", "BACKUP_NOT_PAIRED_TITLE", fallback: "Your tokens aren’t backed up yet")
        internal static let backupYourAccountsAnnouncementTitle = L10n.tr("Localizable", "BACKUP_YOUR_ACCOUNTS_ANNOUNCEMENT_TITLE", fallback: "Back up your tokens")
        internal static let backupYourAccountsCardStepBenefit = L10n.tr("Localizable", "BACKUP_YOUR_ACCOUNTS_CARD_STEP_BENEFIT", fallback: "Access your tokens in both apps")
        internal static let backupYourAccountsCardStepCreateAccount = L10n.tr("Localizable", "BACKUP_YOUR_ACCOUNTS_CARD_STEP_CREATE_ACCOUNT", fallback: "Create your Dashlane account")
        internal static let backupYourAccountsCardStepDownload = L10n.tr("Localizable", "BACKUP_YOUR_ACCOUNTS_CARD_STEP_DOWNLOAD", fallback: "Download Dashlane Password Manager from the App Store")
        internal static let backupYourAccountsDescription = L10n.tr("Localizable", "BACKUP_YOUR_ACCOUNTS_DESCRIPTION", fallback: "With the Dashlane Password Manager mobile and web apps, you’ll always be able to access your 2FA tokens—even if you lose your phone.")
        internal static let backupYourAccountsDownloadAppCta = L10n.tr("Localizable", "BACKUP_YOUR_ACCOUNTS_DOWNLOAD_APP_CTA", fallback: "Open App Store")
        internal static let backupYourAccountsLearnMoreCta = L10n.tr("Localizable", "BACKUP_YOUR_ACCOUNTS_LEARN_MORE_CTA", fallback: "Learn more about Dashlane")
        internal static let backupYourAccountsTitle = L10n.tr("Localizable", "BACKUP_YOUR_ACCOUNTS_TITLE", fallback: "Back up your tokens")
        internal static func biometryUnlockErrorCta(_ p1: Any) -> String {
      return L10n.tr("Localizable", "BIOMETRY_UNLOCK_ERROR_CTA", String(describing: p1), fallback: "_")
    }
        internal static func biometryUnlockErrorMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "BIOMETRY_UNLOCK_ERROR_MESSAGE", String(describing: p1), fallback: "_")
    }
        internal static let biometryUnlockErrorMessage2 = L10n.tr("Localizable", "BIOMETRY_UNLOCK_ERROR_MESSAGE2", fallback: "We recommend setting up a backup PIN so you can always access this app.")
        internal static let biometryUnlockErrorPinButtonTitle = L10n.tr("Localizable", "BIOMETRY_UNLOCK_ERROR_PIN_BUTTON_TITLE", fallback: "Setup PIN")
        internal static let biometryUnlockErrorRetryButtonTitle = L10n.tr("Localizable", "BIOMETRY_UNLOCK_ERROR_RETRY_BUTTON_TITLE", fallback: "Try again")
        internal static let biometryUnlockErrorTitle = L10n.tr("Localizable", "BIOMETRY_UNLOCK_ERROR_TITLE", fallback: "Identity not verified")
        internal static let biometryUnlockRetryPinCta = L10n.tr("Localizable", "BIOMETRY_UNLOCK_RETRY_PIN_CTA", fallback: "Enter PIN")
        internal static let biometryUnlockRetrySetupPinCta = L10n.tr("Localizable", "BIOMETRY_UNLOCK_RETRY_SETUP_PIN_CTA", fallback: "Setup back up PIN")
        internal static func biometryUnlockRetryTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "BIOMETRY_UNLOCK_RETRY_TITLE", String(describing: p1), fallback: "_")
    }
        internal static func biometryUnlockTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "BIOMETRY_UNLOCK_TITLE", String(describing: p1), fallback: "_")
    }
        internal static let buttonClose = L10n.tr("Localizable", "BUTTON_CLOSE", fallback: "Close")
        internal static let buttonEdit = L10n.tr("Localizable", "BUTTON_EDIT", fallback: "Edit")
        internal static let buttonTitleNext = L10n.tr("Localizable", "BUTTON_TITLE_NEXT", fallback: "Next")
        internal static let buttonTitleOkGotIt = L10n.tr("Localizable", "BUTTON_TITLE_OK_GOT_IT", fallback: "Ok, got it")
        internal static let buttonTitleSkip = L10n.tr("Localizable", "BUTTON_TITLE_SKIP", fallback: "Skip")
        internal static let cancel = L10n.tr("Localizable", "Cancel", fallback: "Cancel")
        internal static let chooseServiceAddDetails = L10n.tr("Localizable", "CHOOSE_SERVICE_ADD_DETAILS", fallback: "Add account details")
        internal static let chooseServiceSearchPlaceholder = L10n.tr("Localizable", "CHOOSE_SERVICE_SEARCH_PLACEHOLDER", fallback: "Search websites")
        internal static let chooseServiceSuggestedSectionTitle = L10n.tr("Localizable", "CHOOSE_SERVICE_SUGGESTED_SECTION_TITLE", fallback: "Suggested")
        internal static let chooseServiceTitle = L10n.tr("Localizable", "CHOOSE_SERVICE_TITLE", fallback: "Select account")
        internal static let copiedCodeToastMessage = L10n.tr("Localizable", "COPIED_CODE_TOAST_MESSAGE", fallback: "Code copied")
        internal static let copyButtonTitle = L10n.tr("Localizable", "COPY_BUTTON_TITLE", fallback: "Copy")
        internal static let createYourAccountAnnouncementMessage = L10n.tr("Localizable", "CREATE_YOUR_ACCOUNT_ANNOUNCEMENT_MESSAGE", fallback: "To finish backing up your tokens, open the Dashlane Password Manager app and create your account.")
        internal static let createYourAccountAnnouncementTitle = L10n.tr("Localizable", "CREATE_YOUR_ACCOUNT_ANNOUNCEMENT_TITLE", fallback: "Create your account to finish backup")
        internal static let dashlane2FaOnboardingCta = L10n.tr("Localizable", "DASHLANE_2FA_ONBOARDING_CTA", fallback: "Complete 2FA setup")
        internal static let dashlane2FaOnboardingSubtitle = L10n.tr("Localizable", "DASHLANE_2FA_ONBOARDING_SUBTITLE", fallback: "Go back to Dashlane Password Manager to complete the setup.")
        internal static let dashlane2FaOnboardingTitle = L10n.tr("Localizable", "DASHLANE_2FA_ONBOARDING_TITLE", fallback: "Dashlane 2FA setup is almost done")
        internal static let dashlanePairedTitle = L10n.tr("Localizable", "DASHLANE_PAIRED_TITLE", fallback: "Paired")
        internal static let dashlaneTokenAddCta = L10n.tr("Localizable", "DASHLANE_TOKEN_ADD_CTA", fallback: "Ok, got it")
        internal static let dashlaneTokenAddHelpCta = L10n.tr("Localizable", "DASHLANE_TOKEN_ADD_HELP_CTA", fallback: "Learn more about recovery codes")
                internal static let dashlaneTokenAddMessage1 = L10n.tr("Localizable", "DASHLANE_TOKEN_ADD_MESSAGE1", fallback: "Dashlane is the only account we can’t back up for you.\n\n")
        internal static let dashlaneTokenAddMessage2 = L10n.tr("Localizable", "DASHLANE_TOKEN_ADD_MESSAGE2", fallback: "Make sure you save the recovery codes provided by the Dashlane Password Manager app in a safe place.")
        internal static let dashlaneTokenAddTitle = L10n.tr("Localizable", "DASHLANE_TOKEN_ADD_TITLE", fallback: "Keep your Dashlane recovery codes safe")
        internal static let dashlanePushMessage = L10n.tr("Localizable", "dashlanePushMessage", fallback: "If you’re logging in from a new device choose Accept. If not, Reject.")
        internal static let editSave = L10n.tr("Localizable", "EDIT_SAVE", fallback: "Save")
        internal static func editTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "EDIT_TITLE", String(describing: p1), fallback: "_")
    }
        internal static let editTokenDelete = L10n.tr("Localizable", "EDIT_TOKEN_DELETE", fallback: "Remove Token")
        internal static let editTokenLoginLabel = L10n.tr("Localizable", "EDIT_TOKEN_LOGIN_LABEL", fallback: "email or username")
        internal static let editTokenTitleLabel = L10n.tr("Localizable", "EDIT_TOKEN_TITLE_LABEL", fallback: "Item name")
        internal static let editTokenWebsiteLabel = L10n.tr("Localizable", "EDIT_TOKEN_WEBSITE_LABEL", fallback: "Website or app")
        internal static let enableCameraAlertCta = L10n.tr("Localizable", "ENABLE_CAMERA_ALERT_CTA", fallback: "Open Settings")
        internal static let enableCameraAlertTitle = L10n.tr("Localizable", "ENABLE_CAMERA_ALERT_TITLE", fallback: "Allow Dashlane to access your camera")
        internal static let enterPasscode = L10n.tr("Localizable", "enterPasscode", fallback: "Enter PIN code")
        internal static let errorAdd2FaCancel = L10n.tr("Localizable", "ERROR_ADD_2FA_CANCEL", fallback: "Cancel")
        internal static let errorAdd2FaHelp = L10n.tr("Localizable", "ERROR_ADD_2FA_HELP", fallback: "Contact Support")
        internal static func errorAdd2FaMessage(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "ERROR_ADD_2FA_MESSAGE", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let errorAdd2FaMessageModeManual = L10n.tr("Localizable", "ERROR_ADD_2FA_MESSAGE_MODE_MANUAL", fallback: "setup code")
        internal static let errorAdd2FaMessageModeManualTryScan = L10n.tr("Localizable", "ERROR_ADD_2FA_MESSAGE_MODE_MANUAL_TRY_SCAN", fallback: "scan the QR code")
        internal static let errorAdd2FaMessageModeScan = L10n.tr("Localizable", "ERROR_ADD_2FA_MESSAGE_MODE_SCAN", fallback: "QR code")
        internal static let errorAdd2FaMessageModeScanTryManual = L10n.tr("Localizable", "ERROR_ADD_2FA_MESSAGE_MODE_SCAN_TRY_MANUAL", fallback: "enter the setup code")
        internal static func errorAdd2FaTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "ERROR_ADD_2FA_TITLE", String(describing: p1), fallback: "_")
    }
        internal static let errorAdd2FaTryAgain = L10n.tr("Localizable", "ERROR_ADD_2FA_TRY_AGAIN", fallback: "Try again")
        internal static let firstTokenAddHelpCta = L10n.tr("Localizable", "FIRST_TOKEN_ADD_HELP_CTA", fallback: "How to use 2FA tokens")
        internal static func firstTokenAddHelpMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "FIRST_TOKEN_ADD_HELP_MESSAGE", String(describing: p1), fallback: "_")
    }
        internal static func firstTokenAddHelpTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "FIRST_TOKEN_ADD_HELP_TITLE", String(describing: p1), fallback: "_")
    }
        internal static let firstTokenAddViewTokenCta = L10n.tr("Localizable", "FIRST_TOKEN_ADD_VIEW_TOKEN_CTA", fallback: "View 2FA token")
        internal static let help2FaCta = L10n.tr("Localizable", "HELP_2FA_CTA", fallback: "How to set up 2FA")
        internal static let helpCenterCta = L10n.tr("Localizable", "HELP_CENTER_CTA", fallback: "Go to Help Center")
        internal static let helpDashlaneCta = L10n.tr("Localizable", "HELP_DASHLANE_CTA", fallback: "How does Dashlane Authenticator work?")
        internal static let helpTokenCta = L10n.tr("Localizable", "HELP_TOKEN_CTA", fallback: "How to use my tokens")
        internal static let helpTokenMessage = L10n.tr("Localizable", "HELP_TOKEN_MESSAGE", fallback: "Log in to your accounts securely with your password and a 6-digit token generated by Dashlane Authenticator.")
        internal static let helpTokenTitle = L10n.tr("Localizable", "HELP_TOKEN_TITLE", fallback: "Use 2FA tokens to securely log in to your accounts")
        internal static let introButtonTitle = L10n.tr("Localizable", "Intro_button_title", fallback: "Get started")
        internal static let introTitle = L10n.tr("Localizable", "Intro_title", fallback: "Welcome to")
        internal static let kwButtonOk = L10n.tr("Localizable", "KW_BUTTON_OK", fallback: "Ok")
        internal static let kwDelete = L10n.tr("Localizable", "kwDelete", fallback: "Delete")
        internal static let listFavoriteSectionTitle = L10n.tr("Localizable", "LIST_FAVORITE_SECTION_TITLE", fallback: "FAVORITE")
        internal static let listOtherSectionTitle = L10n.tr("Localizable", "LIST_OTHER_SECTION_TITLE", fallback: "ALL OTHERS")
        internal static let lockedStateButtonTitle = L10n.tr("Localizable", "locked_state_button_title", fallback: "Unlock")
        internal static let matchingCredentialsListCreateNew = L10n.tr("Localizable", "MATCHING_CREDENTIALS_LIST_CREATE_NEW", fallback: "Add new account")
        internal static let matchingCredentialsListDescription = L10n.tr("Localizable", "MATCHING_CREDENTIALS_LIST_DESCRIPTION", fallback: "Select the account you want to set up 2FA for.")
        internal static func matchingCredentialsListMultipleLoginsAvailable(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "MATCHING_CREDENTIALS_LIST_MULTIPLE_LOGINS_AVAILABLE", String(describing: p1), String(describing: p2), fallback: "_")
    }
        internal static let menuAddFavorite = L10n.tr("Localizable", "MENU_ADD_FAVORITE", fallback: "Add to favorites")
        internal static let menuRemoveFavorite = L10n.tr("Localizable", "MENU_REMOVE_FAVORITE", fallback: "Remove from favorites")
        internal static let onboardingPage1Message = L10n.tr("Localizable", "ONBOARDING_PAGE1_MESSAGE", fallback: "Dashlane Authenticator helps verify your identity when logging in to accounts that have 2-factor authentication (2FA) turned on.")
        internal static let onboardingPage1Title = L10n.tr("Localizable", "ONBOARDING_PAGE1_TITLE", fallback: "2FA is an extra layer of security for your accounts")
        internal static let onboardingPage2Message = L10n.tr("Localizable", "ONBOARDING_PAGE2_MESSAGE", fallback: "When logging in to your accounts, you'll use your password and a 6-digit token generated by Dashlane Authenticator to verify your identity.")
        internal static let onboardingPage2Title = L10n.tr("Localizable", "ONBOARDING_PAGE2_TITLE", fallback: "Use tokens to verify your identity when logging in")
        internal static let onboardingPage3Message = L10n.tr("Localizable", "ONBOARDING_PAGE3_MESSAGE", fallback: "Create a Dashlane account to sync your tokens with our Password Manager. That way you can access your tokens from any device, even if you lose your phone.")
        internal static let onboardingPage3Title = L10n.tr("Localizable", "ONBOARDING_PAGE3_TITLE", fallback: "Back up your tokens with our Password Manager")
        internal static let onboardingPageCta = L10n.tr("Localizable", "ONBOARDING_PAGE_CTA", fallback: "Add 2FA token")
        internal static let otpDeletionConfirmButton = L10n.tr("Localizable", "Otp_deletion_confirm_button", fallback: "Yes, remove token")
                internal static func otpDeletionMessage(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Otp_deletion_message", String(describing: p1), fallback: "_")
    }
        internal static func otpDeletionTitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Otp_deletion_title", String(describing: p1), fallback: "_")
    }
        internal static let otpVaultDeleteAlertButtonTitle = L10n.tr("Localizable", "otpVaultDeleteAlertButtonTitle", fallback: "Open Dashlane")
        internal static let otpVaultDeletionAlertMessage = L10n.tr("Localizable", "otpVaultDeletionAlertMessage", fallback: "To make sure your changes are in both apps, you need to edit in Dashlane.")
        internal static let passwordappOnboardingButtonTitle = L10n.tr("Localizable", "PASSWORDAPP_ONBOARDING_BUTTON_TITLE", fallback: "Ok, got it")
        internal static func passwordappOnboardingFallbackPinSubtitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "PASSWORDAPP_ONBOARDING_FALLBACK_PIN_SUBTITLE", String(describing: p1), fallback: "_")
    }
        internal static func passwordappOnboardingSubtitle(_ p1: Any) -> String {
      return L10n.tr("Localizable", "PASSWORDAPP_ONBOARDING_SUBTITLE", String(describing: p1), fallback: "_")
    }
        internal static let passwordappOnboardingSubtitlePin = L10n.tr("Localizable", "PASSWORDAPP_ONBOARDING_SUBTITLE_PIN", fallback: "Now you can use your Dashlane PIN to unlock this app.")
        internal static let passwordappOnboardingTitle = L10n.tr("Localizable", "PASSWORDAPP_ONBOARDING_TITLE", fallback: "Your tokens are backed up with Dashlane")
        internal static let pendingAuthRequestAnnouncementDetailButton = L10n.tr("Localizable", "pendingAuthRequestAnnouncementDetailButton", fallback: "View details")
        internal static let pendingAuthRequestAnnouncementIgnoreButton = L10n.tr("Localizable", "pendingAuthRequestAnnouncementIgnoreButton", fallback: "Ignore")
        internal static let pendingAuthRequestAnnouncementTitleDashlane = L10n.tr("Localizable", "pendingAuthRequestAnnouncementTitleDashlane", fallback: "Pending authentication for Dashlane")
        internal static let pinUnlockErrorChangeButtonTitle = L10n.tr("Localizable", "PIN_UNLOCK_ERROR_CHANGE_BUTTON_TITLE", fallback: "Go to login")
        internal static let pinUnlockErrorCta = L10n.tr("Localizable", "PIN_UNLOCK_ERROR_CTA", fallback: "How to update your PIN")
        internal static let pinUnlockErrorMessage = L10n.tr("Localizable", "PIN_UNLOCK_ERROR_MESSAGE", fallback: "To unlock this app, reset your PIN or set up biometric login in your Dashlane Password Manager app. For your security, you’ll be required to verify your identity by logging in with your Master Password.")
        internal static let pinUnlockErrorSupportButtonTitle = L10n.tr("Localizable", "PIN_UNLOCK_ERROR_SUPPORT_BUTTON_TITLE", fallback: "Contact Customer Support")
        internal static let pinUnlockErrorTitle = L10n.tr("Localizable", "PIN_UNLOCK_ERROR_TITLE", fallback: "You entered the wrong PIN too many times")
        internal static func pincodeAttemptsLeftError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "PINCODE_ATTEMPTS_LEFT_ERROR", String(describing: p1), fallback: "_")
    }
        internal static let pincodeError = L10n.tr("Localizable", "PINCODE_ERROR", fallback: "Incorrect PIN")
        internal static let pushErrorButtonTitle = L10n.tr("Localizable", "PUSH_ERROR_BUTTON_TITLE", fallback: "Ok, got it")
        internal static let pushErrorExpiredSubtitle = L10n.tr("Localizable", "PUSH_ERROR_EXPIRED_SUBTITLE", fallback: "Your authentication request expired. Try sending the request again.")
        internal static let pushErrorExpiredTitle = L10n.tr("Localizable", "PUSH_ERROR_EXPIRED_TITLE", fallback: "Request expired")
        internal static let pushErrorSubtitle = L10n.tr("Localizable", "PUSH_ERROR_SUBTITLE", fallback: "We weren’t able to complete your authentication request. Try sending the request again.")
        internal static let pushErrorTitle = L10n.tr("Localizable", "PUSH_ERROR_TITLE", fallback: "Authentication failed")
        internal static let pushAcceptButtonTitle = L10n.tr("Localizable", "pushAcceptButtonTitle", fallback: "Accept")
        internal static let pushFeedbackMessageAccepted = L10n.tr("Localizable", "pushFeedbackMessageAccepted", fallback: "Request accepted")
        internal static let pushFeedbackMessageRejected = L10n.tr("Localizable", "pushFeedbackMessageRejected", fallback: "Request rejected")
        internal static let pushRejectButtonTitle = L10n.tr("Localizable", "pushRejectButtonTitle", fallback: "Reject")
        internal static let qrcodeErrorCancelTitle = L10n.tr("Localizable", "QRCODE_ERROR_CANCEL_TITLE", fallback: "Enter setup code")
        internal static let qrcodeErrorHelpTitle = L10n.tr("Localizable", "QRCODE_ERROR_HELP_TITLE", fallback: "Where can I find the QR code?")
        internal static let qrcodeErrorSubtitle = L10n.tr("Localizable", "QRCODE_ERROR_SUBTITLE", fallback: "QR code is not valid This QR code can’t be used to set up authentication. Make sure you’re scanning the QR code provided in your account security settings.")
        internal static let qrcodeErrorTitle = L10n.tr("Localizable", "QRCODE_ERROR_TITLE", fallback: "QR code is not valid")
        internal static let reScanRecoveryCodesAlertMessage = L10n.tr("Localizable", "Re_scan_recovery_codes_alert_message", fallback: "To complete setup, allow Dashlane Authenticator to access your camera to scan the website recovery codes")
        internal static let rescanQrcodeAlertTitle = L10n.tr("Localizable", "Rescan_qrcode_alert_title", fallback: "Re-scan QR code")
        internal static let scanQrcodeTitle = L10n.tr("Localizable", "Scan_qrcode_title", fallback: "Scan QR code")
        internal static let setupHelpAddTokenCta = L10n.tr("Localizable", "SETUP_HELP_ADD_TOKEN_CTA", fallback: "Select setup method")
        internal static func stepLabel(_ p1: Any) -> String {
      return L10n.tr("Localizable", "STEP_LABEL", String(describing: p1), fallback: "_")
    }
        internal static let tokenAccountHelpCta = L10n.tr("Localizable", "TOKEN_ACCOUNT_HELP_CTA", fallback: "Which accounts need 2FA?")
        internal static let tokenAccountHelpMessage = L10n.tr("Localizable", "TOKEN_ACCOUNT_HELP_MESSAGE", fallback: "We recommend setting up 2FA for accounts that store your important personal data such as financial services, social media, and work-related accounts.")
        internal static let tokenAccountHelpTitle = L10n.tr("Localizable", "TOKEN_ACCOUNT_HELP_TITLE", fallback: "Log in to the account you want to protect with 2FA")
        internal static let tokenCodesHelpCta = L10n.tr("Localizable", "TOKEN_CODES_HELP_CTA", fallback: "Where are the codes?")
        internal static let tokenCodesHelpMessage = L10n.tr("Localizable", "TOKEN_CODES_HELP_MESSAGE", fallback: "Make sure you’ve selected the option to set up 2FA with an authenticator app. If you still can’t find the codes, check your account’s support center for help. ")
        internal static let tokenCodesHelpTitle = L10n.tr("Localizable", "TOKEN_CODES_HELP_TITLE", fallback: "Use this app to scan the QR code or enter the setup code")
        internal static let tokenListEmptyMessage = L10n.tr("Localizable", "TOKEN_LIST_EMPTY_MESSAGE", fallback: "You haven’t added any 2FA tokens yet.")
        internal static let tokenListHelpLabel = L10n.tr("Localizable", "TOKEN_LIST_HELP_LABEL", fallback: "How to set up 2FA")
        internal static let tokenSettingsHelpCta = L10n.tr("Localizable", "TOKEN_SETTINGS_HELP_CTA", fallback: "Where is the 2FA setting?")
        internal static let tokenSettingsHelpMessage = L10n.tr("Localizable", "TOKEN_SETTINGS_HELP_MESSAGE", fallback: "The 2FA setting is usually located in your account security settings. It’s sometimes referred to as 2-step verification (2SV) or multi-factor authentication (MFA).")
        internal static let tokenSettingsHelpTitle = L10n.tr("Localizable", "TOKEN_SETTINGS_HELP_TITLE", fallback: "Turn on 2FA in the security settings of your account")
        internal static let tokensListEditionClose = L10n.tr("Localizable", "TOKENS_LIST_EDITION_CLOSE", fallback: "Close")
        internal static let tokensListNavigationTitle = L10n.tr("Localizable", "TOKENS_LIST_NAVIGATION_TITLE", fallback: "2FA tokens")
        internal static let tokensListStartEdit = L10n.tr("Localizable", "TOKENS_LIST_START_EDIT", fallback: "Edit 2FA tokens")
        internal static let welcomePushMessage = L10n.tr("Localizable", "WELCOME_PUSH_MESSAGE", fallback: "Your authenticator is registered")
    internal enum KWAuthentifiantIOS {
            internal static let login = L10n.tr("Localizable", "KWAuthentifiantIOS.login", fallback: "Username")
            internal static let url = L10n.tr("Localizable", "KWAuthentifiantIOS.url", fallback: "Website")
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
