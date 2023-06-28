import Foundation

public enum ControlledFeature: String, CaseIterable {
#if DEBUG
    public static let forcedFeatureFlips: Set<ControlledFeature> = []
#endif
    case sharingGroupForceCategorization             = "sharingGroupForceCategorization"
    case mobileSecureExport                          = "MobileSecureExport"
    case disableSecureNotes
    case swiftUISettings                             = "platform_ios_swiftuiSettings"
    case enforce2FA                                  = "mobile_enforce_2fa"
    case twoFASettings                               = "mobile_two_factor_auth_settings"
    case documentStorageAllItems                     = "attachmentAllItems_ios_dev"
    case documentStorageIds                          = "techweek_ios_attachmentsForIds_v1"
    case prideIcons                                  = "apple_ios_prideIcons"
    case prideColors                                 = "apple_ios_prideColors"
    case disableAutorenewalAnnouncement              = "disable_autorenewal_announcement_ios"
    case chromeImport                                = "platform_ios_chromeImport"
    case dashImport                                  = "platform_ios_import_dash"
    case lastpassImport                              = "platform_ios_import_lastpass"
    case keychainImport                              = "platform_ios_import_keychain"
    case authenticatorTool                           = "apple_ptu_ios_authenticator_phase3"
    case labs                                        = "techWeek_ios_displayLabs"
    case linkedWebsitesOnTachyon                     = "autofill_ios_linkedWebsitesContext"
    case collectionsLabelling                        = "vault_ios_collection_labelling_prod"
    case collectionsContainer                        = "vault_ios_collectionContainer_prod"
    case accountRecoveryKey                          = "mpless_ios_account_recovery_key_dev"
    case autofillBannerEducation                     = "autofill_ios_activationBannerEducation"
    case passkeysVault                               = "apple_platforms_passkeys_dev"
    case sharingCollectionMilestone1                 = "vault_ios_collectionSharing_milestone1_dev"

            case changeMasterPasswordIsAvailable             = "platform_ios_killswitch_change_master_password"
    case masterPasswordResetIsAvailable              = "platform_ios_killswitch_master_password_reset"
    case autofillSafariIsDisabled                    = "autofill_safari_disable" 
    case brazeInAppMessageIsAvailable                = "monetization_apple_killswitch_inAppMessage_3"
    case auditLogsIsAvailable                        = "apple_audit_logs_killswitch"
    case autoRevokeInvalidSharingSignatureEnabled    = "sharing_apple_invalidSignatureAutoRevoke_prod"
    case swiftZXCVBNEnabled                          = "platform_apple_swiftzxcvbn"

    public var updateMode: FeatureFlip.UpdateMode {
        .perLogin
    }
}
