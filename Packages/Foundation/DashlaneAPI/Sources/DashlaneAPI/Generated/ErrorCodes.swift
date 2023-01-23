import Foundation

public enum APIErrorCodes { }

extension APIErrorCodes {
    public enum Abtesting: String, Decodable, Equatable, RawRepresentable {
                case abtestInvalidDeviceKey = "abtest_invalid_device_key"
                case abtestInvalidParameters = "abtest_invalid_parameters"
                case abtestNotFoundByName = "abtest_not_found_by_name"
                case invalidVariantName = "invalid_variant_name"
    }
}

extension APIError {
    public func hasAbtestingCode(_ errorCode: APIErrorCodes.Abtesting) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Account: String, Decodable, Equatable, RawRepresentable {
                case accountAlreadyExists = "account_already_exists"
                case accountRecoveryAlreadyEnabled = "account_recovery_already_enabled"
                case contactEmailRequired = "contact_email_required"
                case contactPhoneRequired = "contact_phone_required"
                case deviceOutdated = "device_outdated"
                case domainNotValidForTeam = "domain_not_valid_for_team"
                case expiredVersion = "expired_version"
                case invalidContactEmail = "invalid_contact_email"
                case invalidSsoToken = "invalid_sso_token"
                case invalidUser = "invalid_user"
                case missingContactEmail = "missing_contact_email"
                case missingContactPhone = "missing_contact_phone"
                case notAccepted = "not_accepted"
                case ssoBlocked = "sso_blocked"
                case teamHasNotEnabledSso = "team_has_not_enabled_sso"
                case unsupportedVersion = "unsupported_version"
    }
}

extension APIError {
    public func hasAccountCode(_ errorCode: APIErrorCodes.Account) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Analytics: String, Decodable, Equatable, RawRepresentable {
                case prodUserNotRequestable = "prod_user_not_requestable"
                case userNotFound = "user not found"
    }
}

extension APIError {
    public func hasAnalyticsCode(_ errorCode: APIErrorCodes.Analytics) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Authentication: String, Decodable, Equatable, RawRepresentable {
                case accountBlockedContactSupport = "account_blocked_contact_support"
                case adfsCertificateNotProvided = "adfs_certificate_not_provided"
                case assertionRejected = "assertion_rejected"
                case attestationRejected = "attestation_rejected"
                case authenticationTypeNotSupported = "authentication_type_not_supported"
                case authenticatorNotAvailableOnDevice = "authenticator_not_available_on_device"
                case authenticatorNotRegistered = "authenticator_not_registered"
                case b2bSsoUserNotFound = "b2b_sso_user_not_found"
                case cannotSeedForUserWithTotpEnabled = "cannot_seed_for_user_with_totp_enabled"
                case challengeExpired = "challenge_expired"
                case challengeNotFound = "challenge_not_found"
                case challengeVerificationFailed = "challenge_verification_failed"
                case clientVersionDoesNotSupportSsoMigration = "client_version_does_not_support_sso_migration"
                case deactivatedDevice = "deactivated_device"
                case deviceDeactivated = "device_deactivated"
                case deviceNotFound = "device_not_found"
                case existingSecureRemembermeSession = "existing_secure_rememberme_session"
                case expiredSamlAssertion = "expired_saml_assertion"
                case expiredVersion = "expired_version"
                case failedToContactAuthenticatorDevice = "failed_to_contact_authenticator_device"
                case invalidRequest = "invalid request"
                case invalidAuthTicket = "invalid_auth_ticket"
                case invalidAuthentication = "invalid_authentication"
                case invalidOtpAlreadyUsed = "invalid_otp_already_used"
                case invalidOtpBlocked = "invalid_otp_blocked"
                case invalidSignature = "invalid_signature"
                case invalidSsoToken = "invalid_sso_token"
                case invalidToken = "invalid_token"
                case invalidTotpStatus = "invalid_totp_status"
                case loginParameterNotFound = "login_parameter_not_found"
                case noKeyhandleFound = "no_keyhandle_found"
                case noRecoveryPhone = "no_recovery_phone"
                case notATestAccount = "not_a_test_account"
                case otpFailed = "otp_failed"
                case phoneValidationFailed = "phone_validation_failed"
                case ssoBlocked = "sso_blocked"
                case temporaryDeviceForbidden = "temporary_device_forbidden"
                case totpActiveOrNotSeeded = "totp_active_or_not_seeded"
                case totpTypeIsNotSetToEmailToken = "totp_type_is_not_set_to_email_token"
                case twofaEmailTokenNotEnabled = "twofa_email_token_not_enabled"
                case u2fBadRequest = "u2f_bad_request"
                case userHasNoActiveAuthenticator = "user_has_no_active_authenticator"
                case userNotFound = "user_not_found"
                case verificationFailed = "verification_failed"
                case verificationMethodDisabled = "verification_method_disabled"
                case verificationMethodInvalid = "verification_method_invalid"
                case verificationRequiresRequest = "verification_requires_request"
                case verificationTimeout = "verification_timeout"
                case wrongSsoStatusToMigrate = "wrong_sso_status_to_migrate"
    }
}

extension APIError {
    public func hasAuthenticationCode(_ errorCode: APIErrorCodes.Authentication) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum AuthenticationQa: String, Decodable, Equatable, RawRepresentable {
                case noTokenFound = "no_token_found"
                case notATestLogin = "not_a_test_login"
                case userNotFound = "user_not_found"
    }
}

extension APIError {
    public func hasAuthenticationQaCode(_ errorCode: APIErrorCodes.AuthenticationQa) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Authenticator: String, Decodable, Equatable, RawRepresentable {
                case authenticatorAlreadyRegistered = "authenticator_already_registered"
                case authenticatorDoesNotExist = "authenticator_does_not_exist"
                case invalidAuthenticationRequest = "invalid_authentication_request"
    }
}

extension APIError {
    public func hasAuthenticatorCode(_ errorCode: APIErrorCodes.Authenticator) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Breaches: String, Decodable, Equatable, RawRepresentable {
                case invalidBreachDefinitionJson = "invalid_breach_definition_json"
    }
}

extension APIError {
    public func hasBreachesCode(_ errorCode: APIErrorCodes.Breaches) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Darkwebmonitoring: String, Decodable, Equatable, RawRepresentable {
                case anotherUserHasAlreadyAnActiveSubscription = "another_user_has_already_an_active_subscription"
                case emailIsInvalid = "email_is_invalid"
                case tokenHasExpired = "token_has_expired"
                case tokenNotFound = "token_not_found"
                case userIsNotAllowed = "user_is_not_allowed"
    }
}

extension APIError {
    public func hasDarkwebmonitoringCode(_ errorCode: APIErrorCodes.Darkwebmonitoring) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum DarkwebmonitoringQa: String, Decodable, Equatable, RawRepresentable {
                case breachIsNotAccessible = "breach_is_not_accessible"
                case breachNotFound = "breach_not_found"
                case exceededStagingFileSizeLimit = "exceeded_staging_file_size_limit"
    }
}

extension APIError {
    public func hasDarkwebmonitoringQaCode(_ errorCode: APIErrorCodes.DarkwebmonitoringQa) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Devices: String, Decodable, Equatable, RawRepresentable {
                case clientDeviceNotFound = "client_device_not_found"
                case clientDevicesNotFound = "client_devices_not_found"
                case deviceNotFound = "device_not_found"
                case pairingGroupsNotFound = "pairing_groups_not_found"
    }
}

extension APIError {
    public func hasDevicesCode(_ errorCode: APIErrorCodes.Devices) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Features: String, Decodable, Equatable, RawRepresentable {
                case invalidClientAgent = "invalid_client_agent"
    }
}

extension APIError {
    public func hasFeaturesCode(_ errorCode: APIErrorCodes.Features) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Mpless: String, Decodable, Equatable, RawRepresentable {
                case failedToCreateTransfer = "failed_to_create_transfer"
                case transferInvalid = "transfer_invalid"
    }
}

extension APIError {
    public func hasMplessCode(_ errorCode: APIErrorCodes.Mpless) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Pairing: String, Decodable, Equatable, RawRepresentable {
                case invalidPlatform = "invalid_platform"
                case platformIsntSupportedByPairing = "platform_isnt_supported_by_pairing"
    }
}

extension APIError {
    public func hasPairingCode(_ errorCode: APIErrorCodes.Pairing) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Premium: String, Decodable, Equatable, RawRepresentable {
                case customerNotFound = "customer_not_found"
                case noCard = "no_card"
                case noCustomerInfo = "no_customer_info"
                case nonStripeSubscription = "non_stripe_subscription"
                case offerIdentifierNotFound = "offer_identifier_not_found"
                case paymentPendingAlreadyConsumedError = "payment_pending_already_consumed_error"
                case paymentPendingExpired = "payment_pending_expired"
                case paymentPendingInvalidType = "payment_pending_invalid_type"
                case paymentPendingLoginMismatch = "payment_pending_login_mismatch"
                case paymentPendingNotFound = "payment_pending_not_found"
                case paymentPendingUseridMismatch = "payment_pending_userid_mismatch"
                case premiumStatusNotUpdated = "premium_status_not_updated"
                case productIdentifierNotFound = "product_identifier_not_found"
                case userDoesNotBelongToPartner = "user_does_not_belong_to_partner"
                case userDoesNotExist = "user_does_not_exist"
    }
}

extension APIError {
    public func hasPremiumCode(_ errorCode: APIErrorCodes.Premium) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Securefile: String, Decodable, Equatable, RawRepresentable {
                case invalidSecureFile = "invalid_secure_file"
    }
}

extension APIError {
    public func hasSecurefileCode(_ errorCode: APIErrorCodes.Securefile) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum SharingUserdevice: String, Decodable, Equatable, RawRepresentable {
                case aliasDoesNotBelongToAuthor = "alias_does_not_belong_to_author"
                case authorAcceptSignatureIsMissing = "author_accept_signature_is_missing"
                case authorDoesNotHavePermissions = "author_does_not_have_permissions"
                case authorHasInvalidStatus = "author_has_invalid_status"
                case authorIsMissing = "author_is_missing"
                case authorIsNotTeamCaptain = "author_is_not_team_captain"
                case authorMustBeAdmin = "author_must_be_admin"
                case badlyFormattedEmail = "badly_formatted_email"
                case cannotUpdateOwnPermission = "cannot_update_own_permission"
                case existingUserMustSpecifyGroupKey = "existing_user_must_specify_group_key"
                case groupHasInvalidStatus = "group_has_invalid_status"
                case insufficientAccessPrivileges = "insufficient_access_privileges"
                case insufficientPermissionPrivileges = "insufficient_permission_privileges"
                case insufficientPrivileges = "insufficient_privileges"
                case invalidItemGroupRevision = "invalid_item_group_revision"
                case invalidItemTimestamp = "invalid_item_timestamp"
                case invalidNumberOfItems = "invalid_number_of_items"
                case invalidPlatform = "invalid_platform"
                case invalidTeamId = "invalid_team_id"
                case invalidUserGroupRevision = "invalid_user_group_revision"
                case invalidUserGroupTeam = "invalid_user_group_team"
                case itemGroupIdAlreadyExists = "item_group_id_already_exists"
                case itemGroupIsNotFound = "item_group_is_not_found"
                case itemGroupUpdateConflict = "item_group_update_conflict"
                case itemIsAlreadyShared = "item_is_already_shared"
                case itemIsNotFound = "item_is_not_found"
                case missingTeamCaptains = "missing_team_captains"
                case noGroupKeyToAccept = "no_group_key_to_accept"
                case noUserGroupAcceptSignature = "no_user_group_accept_signature"
                case noUserOrUserGroupIsProvided = "no_user_or_user_group_is_provided"
                case nonExistingUserCannotSpecifyGroupKey = "non_existing_user_cannot_specify_group_key"
                case nonExistingUserMustSpecifyProposeSignatureUsingAlias = "non_existing_user_must_specify_propose_signature_using_alias"
                case notAMemberCannotShareWithUserGroup = "not_a_member_cannot_share_with_user_group"
                case notEnoughAdmins = "not_enough_admins"
                case pi20211231Killswitch = "pi_20211231_killswitch"
                case providedUserIdDoesNotExist = "provided_user_id_does_not_exist"
                case providedUserIsNotItemGroupMember = "provided_user_is_not_item_group_member"
                case providedUsergroupIdDoesNotExist = "provided_usergroup_id_does_not_exist"
                case sharingDisabledByTeam = "sharing_disabled_by_team"
                case teamAdminsUserGroupAlreadyExists = "team_admins_user_group_already_exists"
                case teamDoesNotExist = "team_does_not_exist"
                case tooManyLogins = "too_many_logins"
                case userGroupIdAlreadyExists = "user_group_id_already_exists"
                case userGroupIsNotAdmin = "user_group_is_not_admin"
                case userGroupIsNotFound = "user_group_is_not_found"
                case userGroupIsNotInItemGroup = "user_group_is_not_in_item_group"
                case userGroupIsNotInPendingStatus = "user_group_is_not_in_pending_status"
                case userGroupUpdateConflict = "user_group_update_conflict"
                case userGroupsCannotBeRevokedFromItemGroup = "user_groups_cannot_be_revoked_from_item_group"
                case userGroupsItemGroupAlreadyExists = "user_groups_item_group_already_exists"
                case userHasNoPublicKey = "user_has_no_public_key"
                case userIsNotInItemGroup = "user_is_not_in_item_group"
                case userIsNotInPendingStatus = "user_is_not_in_pending_status"
                case userIsNotInUserGroup = "user_is_not_in_user_group"
                case userIsNotMemberOfTeam = "user_is_not_member_of_team"
                case userIsNotTeamCaptain = "user_is_not_team_captain"
                case usersCannotBeRevokedFromItemGroup = "users_cannot_be_revoked_from_item_group"
                case usersCannotBeRevokedFromUserGroup = "users_cannot_be_revoked_from_user_group"
                case usersNotInUserGroup = "users_not_in_user_group"
    }
}

extension APIError {
    public func hasSharingUserdeviceCode(_ errorCode: APIErrorCodes.SharingUserdevice) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Sync: String, Decodable, Equatable, RawRepresentable {
                case _2faServerKeyNotProvided = "2fa_server_key_not_provided"
                case _2faServerKeyProvidedIncorrectly = "2fa_server_key_provided_incorrectly"
                case _2faSettingChangeMayOnlyHappenInPasswordChange = "2fa_setting_change_may_only_happen_in_password_change"
                case _2faSettingSameAsCurrent = "2fa_setting_same_as_current"
                case authTicketMissing = "auth_ticket_missing"
                case changePasswordNeedsContent = "change_password_needs_content"
                case changePasswordNeedsSharingkeys = "change_password_needs_sharingkeys"
                case concurrentUpload = "concurrent_upload"
                case conflictingUpload = "conflicting_upload"
                case current2faSettingCannotBeChangedAtUpload = "current_2fa_setting_cannot_be_changed_at_upload"
                case deviceNotFound = "device_not_found"
                case invalidVerificationTransition = "invalid_verification_transition"
                case missingSettingsTransaction = "missing_settings_transaction"
                case noSharingKeys = "no_sharing_keys"
                case nothingToUpdate = "nothing_to_update"
                case providedSharingPublicKeyDoesNotMatchCurrentOne = "provided_sharing_public_key_does_not_match_current_one"
                case remoteKeyRequired = "remote_key_required"
                case sharingKeysAlreadySet = "sharing_keys_already_set"
                case sharingPrivateKeyUpdateMayOnlyHappenInPasswordChange = "sharing_private_key_update_may_only_happen_in_password_change"
                case ssoBlocked = "sso_blocked"
                case temporaryDisabled = "temporary_disabled"
                case unchangedPrivateKey = "unchanged_private_key"
                case verificationFailed = "verification_failed"
                case verificationSettingSameAsCurrent = "verification_setting_same_as_current"
                case wrongPublicKey = "wrong_public_key"
    }
}

extension APIError {
    public func hasSyncCode(_ errorCode: APIErrorCodes.Sync) -> Bool {
        self.has(errorCode.rawValue)
    }
}
extension APIErrorCodes {
    public enum Vpn: String, Decodable, Equatable, RawRepresentable {
                case userAlreadyHasAnAccount = "user_already_has_an_account"
                case userAlreadyHasAnAccountForProvider = "user_already_has_an_account_for_provider"
                case userAlreadyHaveActiveVpnSubscription = "user_already_have_active_vpn_subscription"
                case userDoesntHaveVpnCapability = "user_doesnt_have_vpn_capability"
    }
}

extension APIError {
    public func hasVpnCode(_ errorCode: APIErrorCodes.Vpn) -> Bool {
        self.has(errorCode.rawValue)
    }
}
