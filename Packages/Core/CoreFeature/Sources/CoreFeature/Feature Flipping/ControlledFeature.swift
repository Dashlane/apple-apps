import Foundation

public enum ControlledFeature: String, CaseIterable, Sendable {
  #if DEBUG
    public static let forcedFeatureFlips: Set<ControlledFeature> = []
  #endif
  case sharingGroupForceCategorization = "sharingGroupForceCategorization"
  case mobileSecureExport = "MobileSecureExport"
  case disableSecureNotes
  case swiftUISettings = "platform_ios_swiftuiSettings"
  case twoFASettings = "mobile_two_factor_auth_settings"
  case documentStorageAllItems = "attachmentAllItems_ios_dev"
  case documentStorageIds = "techweek_ios_attachmentsForIds_v1"
  case prideIcons = "apple_ios_prideIcons"
  case prideColors = "apple_ios_prideColors"
  case disableAutorenewalAnnouncement = "disable_autorenewal_announcement_ios"
  case chromeImport = "platform_ios_chromeImport"
  case dashImport = "platform_ios_import_dash"
  case lastpassImport = "platform_ios_import_lastpass"
  case keychainImport = "platform_ios_import_keychain"
  case authenticatorTool = "apple_ptu_ios_authenticator_phase3"
  case labstest = "techweek_ios_labTests"
  case accountRecoveryKey = "authsync_ios_ark_release"
  case sharingCollectionPermissionDisplay = "vault_ios_collectionSharing_permissionDisplay"
  case sharingCollectionPermissionEdition = "vault_ios_collectionSharing_permissionEdition_dev"
  case removeDuplicates = "techweek_apple_remove_duplicates"
  case vaultSecrets = "ace_ios_secrets_vault"
  case documentStorageSecrets = "ace_ios_secrets_attachments"

  case sentryIsEnabled = "platform_apple_killswitch_sentry_enabled"
  case changeMasterPasswordIsAvailable = "platform_ios_killswitch_change_master_password"
  case masterPasswordResetIsAvailable = "platform_ios_killswitch_master_password_reset"
  case brazeInAppMessageIsAvailable = "monetization_apple_killswitch_inAppMessage_3"
  case auditLogsIsAvailable = "apple_audit_logs_killswitch"
  case autoRevokeInvalidSharingSignatureEnabled = "sharing_apple_invalidSignatureAutoRevoke_prod"
  case swiftZXCVBNIdentityDashboardEnabled = "platform_apple_identity_dashboard_swiftzxcvbn2"
  case secureNoteMarkdownEnabled = "apple_platform_secure_notes_markdown"
  case newSecureNoteDetailView = "vault_ios_secureNote_newdetailview"
  case secureNoteCollections = "sharingVault_ios_Secure_Notes_in_Collections"
  case postLaunchReceiptVerificationEnabled = "platform_apple_postlaunch_receipt_enabled"
}
