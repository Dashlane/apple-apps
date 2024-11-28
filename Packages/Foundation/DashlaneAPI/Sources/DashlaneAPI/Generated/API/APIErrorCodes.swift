import Foundation

public enum APIErrorCodes {
}

extension APIErrorCodes {
  public enum Abtesting: String, Sendable, Equatable, CaseIterable, Codable {
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
  public enum Account: String, Sendable, Equatable, CaseIterable, Codable {
    case accountAlreadyExists = "account_already_exists"

    case contactEmailRequired = "contact_email_required"

    case contactPhoneRequired = "contact_phone_required"

    case deviceOutdated = "device_outdated"

    case domainNotValidForTeam = "domain_not_valid_for_team"

    case expiredVersion = "expired_version"

    case invalidAuthTicket = "invalid_auth_ticket"

    case invalidContactEmail = "invalid_contact_email"

    case invalidSSOToken = "invalid_sso_token"

    case invalidUser = "invalid_user"

    case missingContactEmail = "missing_contact_email"

    case missingContactPhone = "missing_contact_phone"

    case notAccepted = "not_accepted"

    case notMember = "not_member"

    case phoneValidationFailed = "phone_validation_failed"

    case ssoBlocked = "sso_blocked"

    case teamHasNotEnabledSSO = "team_has_not_enabled_sso"

    case unsupportedVersion = "unsupported_version"

    case userNotFound = "user_not_found"

  }
}

extension APIError {
  public func hasAccountCode(_ errorCode: APIErrorCodes.Account) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Accountrecovery: String, Sendable, Equatable, CaseIterable, Codable {
    case invalidAuthenticationTicket = "invalid_authentication_ticket"

    case invalidRecoveryId = "invalid_recovery_id"

    case noAccountRecovery = "no_account_recovery"

    case notLatestStartedActivation = "not_latest_started_activation"

    case notPendingForActivation = "not_pending_for_activation"

    case unsupportedEncryption = "unsupported_encryption"

  }
}

extension APIError {
  public func hasAccountrecoveryCode(_ errorCode: APIErrorCodes.Accountrecovery) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Analytics: String, Sendable, Equatable, CaseIterable, Codable {
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
  public enum Authentication: String, Sendable, Equatable, CaseIterable, Codable {
    case accountBlockedContactSupport = "account_blocked_contact_support"

    case b2bSSOUserNotFound = "b2b_sso_user_not_found"

    case cannotSeedForUserWithTOTPEnabled = "cannot_seed_for_user_with_totp_enabled"

    case deactivatedDevice = "deactivated_device"

    case deactivatedUser = "deactivated_user"

    case deviceDeactivated = "device_deactivated"

    case deviceNotFound = "device_not_found"

    case expiredVersion = "expired_version"

    case failedToContactAuthenticatorDevice = "failed_to_contact_authenticator_device"

    case invalidAuthTicket = "invalid_auth_ticket"

    case invalidAuthentication = "invalid_authentication"

    case invalidOTPAlreadyUsed = "invalid_otp_already_used"

    case invalidOTPBlocked = "invalid_otp_blocked"

    case invalidRecoveryPhone = "invalid_recovery_phone"

    case invalidSSOToken = "invalid_sso_token"

    case invalidToken = "invalid_token"

    case invalidTOTPStatus = "invalid_totp_status"

    case otpFailed = "otp_failed"

    case phoneValidationFailed = "phone_validation_failed"

    case smsError = "sms_error"

    case smsOptOut = "sms_opt_out"

    case ssoBlocked = "sso_blocked"

    case teamGenericError = "team_generic_error"

    case totpActiveOrNotSeeded = "totp_active_or_not_seeded"

    case totpTypeIsNotSetToEmailToken = "totp_type_is_not_set_to_email_token"

    case twofaEmailTokenNotEnabled = "twofa_email_token_not_enabled"

    case userHasNoActiveAuthenticator = "user_has_no_active_authenticator"

    case userNotFound = "user_not_found"

    case verificationFailed = "verification_failed"

    case verificationMethodDisabled = "verification_method_disabled"

    case verificationMethodInvalid = "verification_method_invalid"

    case verificationRequiresRequest = "verification_requires_request"

    case verificationTimeout = "verification_timeout"

    case wrongOTPStatus = "wrong_otp_status"

  }
}

extension APIError {
  public func hasAuthenticationCode(_ errorCode: APIErrorCodes.Authentication) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum AuthenticationQA: String, Sendable, Equatable, CaseIterable, Codable {
    case noTokenFound = "no_token_found"

    case notATestLogin = "not_a_test_login"

    case userNotFound = "user_not_found"

  }
}

extension APIError {
  public func hasAuthenticationQACode(_ errorCode: APIErrorCodes.AuthenticationQA) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Authenticator: String, Sendable, Equatable, CaseIterable, Codable {
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
  public enum Breaches: String, Sendable, Equatable, CaseIterable, Codable {
    case invalidBreachDefinitionJson = "invalid_breach_definition_json"

  }
}

extension APIError {
  public func hasBreachesCode(_ errorCode: APIErrorCodes.Breaches) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Country: String, Sendable, Equatable, CaseIterable, Codable {
    case noCountry = "no_country"

  }
}

extension APIError {
  public func hasCountryCode(_ errorCode: APIErrorCodes.Country) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Darkwebmonitoring: String, Sendable, Equatable, CaseIterable, Codable {
    case anotherUserHasAlreadyAnActiveSubscription =
      "another_user_has_already_an_active_subscription"

    case emailIsInvalid = "email_is_invalid"

    case subscriptionNotFound = "subscription_not_found"

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
  public enum DarkwebmonitoringQA: String, Sendable, Equatable, CaseIterable, Codable {
    case breachIsNotAccessible = "breach_is_not_accessible"

    case breachNotFound = "breach_not_found"

    case emailDoesntExistsInBreach = "email_doesnt_exists_in_breach"

    case exceededStagingFileSizeLimit = "exceeded_staging_file_size_limit"

    case invalidJsonBreachLine = "invalid_json_breach_line"

  }
}

extension APIError {
  public func hasDarkwebmonitoringQACode(_ errorCode: APIErrorCodes.DarkwebmonitoringQA) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Devices: String, Sendable, Equatable, CaseIterable, Codable {
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
  public enum Features: String, Sendable, Equatable, CaseIterable, Codable {
    case invalidClientAgent = "invalid_client_agent"

  }
}

extension APIError {
  public func hasFeaturesCode(_ errorCode: APIErrorCodes.Features) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum File: String, Sendable, Equatable, CaseIterable, Codable {
    case encryptionKeyExpected = "encryption_key_expected"

    case invalidRequest = "invalid request"

    case revisionMustBePositiveNumber = "revision_must_be_positive_number"

    case revisionNumberNotHigherThanLatestFile = "revision_number_not_higher_than_latest_file"

    case signatureExpected = "signature_expected"

    case unexpectedEncryptionKey = "unexpected_encryption_key"

  }
}

extension APIError {
  public func hasFileCode(_ errorCode: APIErrorCodes.File) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum InvalidRequest: String, Sendable, Equatable, CaseIterable, Codable {
    case invalidAuthentication = "invalid_authentication"

    case invalidEndpoint = "invalid_endpoint"

    case outOfBoundsTimestamp = "out_of_bounds_timestamp"

    case requestMalformed = "request_malformed"

    case unknownUserdeviceKey = "unknown_userdevice_key"

  }
}

extension APIError {
  public func hasInvalidRequestCode(_ errorCode: APIErrorCodes.InvalidRequest) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Mpless: String, Sendable, Equatable, CaseIterable, Codable {
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
  public enum Pairing: String, Sendable, Equatable, CaseIterable, Codable {
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
  public enum Payments: String, Sendable, Equatable, CaseIterable, Codable {
    case doubleReceiptForTransactionList = "double_receipt_for_transaction_list"

    case invalidReceipt = "invalid_receipt"

    case noReceiptItem = "no_receipt_item"

    case purchaseTokenDoesNotMatchUserId = "purchase_token_does_not_match_user_id"

  }
}

extension APIError {
  public func hasPaymentsCode(_ errorCode: APIErrorCodes.Payments) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Platforms: String, Sendable, Equatable, CaseIterable, Codable {
    case invalidVersionName = "invalid_version_name"

  }
}

extension APIError {
  public func hasPlatformsCode(_ errorCode: APIErrorCodes.Platforms) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Premium: String, Sendable, Equatable, CaseIterable, Codable {
    case noKeyForUser = "no_key_for_user"

    case offerIdentifierNotFound = "offer_identifier_not_found"

    case productIdentifierNotFound = "product_identifier_not_found"

  }
}

extension APIError {
  public func hasPremiumCode(_ errorCode: APIErrorCodes.Premium) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum SecretTransfer: String, Sendable, Equatable, CaseIterable, Codable {
    case failedToCreateTransfer = "failed_to_create_transfer"

    case failedToUpdateTransfer = "failed_to_update_transfer"

    case invalidKeyExchangeStatus = "invalid_key_exchange_status"

    case invalidTransferStatus = "invalid_transfer_status"

    case jsonValidationError = "json_validation_error"

    case missingSenderKey = "missing_sender_key"

    case noTransferPublicKeyHash = "no_transfer_public_key_hash"

    case transferDoesNotExists = "transfer_does_not_exists"

    case transferExpired = "transfer_expired"

    case userNotFound = "user_not_found"

  }
}

extension APIError {
  public func hasSecretTransferCode(_ errorCode: APIErrorCodes.SecretTransfer) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Securefile: String, Sendable, Equatable, CaseIterable, Codable {
    case deletedSecureFile = "deleted_secure_file"

    case hardQuotaExceeded = "hard_quota_exceeded"

    case invalidContentLength = "invalid_content_length"

    case invalidSecureFile = "invalid_secure_file"

    case invalidSecureFileKey = "invalid_secure_file_key"

    case keyNotFound = "key_not_found"

    case maxContentLengthExceeded = "max_content_length_exceeded"

    case softQuotaExceeded = "soft_quota_exceeded"

    case tooManyVersions = "too_many_versions"

  }
}

extension APIError {
  public func hasSecurefileCode(_ errorCode: APIErrorCodes.Securefile) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum SharingUserdevice: String, Sendable, Equatable, CaseIterable, Codable {
    case aliasDoesNotBelongToAuthor = "alias_does_not_belong_to_author"

    case atLeastOneItemGroupAlreadyAcceptedInCollection =
      "at_least_one_item_group_already_accepted_in_collection"

    case authorAcceptSignatureIsMissing = "author_accept_signature_is_missing"

    case authorDoesNotHavePermissions = "author_does_not_have_permissions"

    case authorHasInvalidStatus = "author_has_invalid_status"

    case authorIsMissing = "author_is_missing"

    case authorIsNotTeamCaptain = "author_is_not_team_captain"

    case authorMustBeAdmin = "author_must_be_admin"

    case badlyFormattedEmail = "badly_formatted_email"

    case cannotUpdateOwnPermission = "cannot_update_own_permission"

    case collectionAlreadyExists = "collection_already_exists"

    case collectionHasOtherRemainingMembers = "collection_has_other_remaining_members"

    case collectionNotFound = "collection_not_found"

    case collectionSharingLimitExceeded = "collection_sharing_limit_exceeded"

    case existingUserCannotSpecifyCollectionKey = "existing_user_cannot_specify_collection_key"

    case existingUserCannotSpecifyProposeSignature =
      "existing_user_cannot_specify_propose_signature"

    case existingUserMustSpecifyCollectionKey = "existing_user_must_specify_collection_key"

    case existingUserMustSpecifyGroupKey = "existing_user_must_specify_group_key"

    case groupHasInvalidStatus = "group_has_invalid_status"

    case insufficientAccessPrivileges = "insufficient_access_privileges"

    case insufficientPermissionPrivileges = "insufficient_permission_privileges"

    case insufficientPermissions = "insufficient_permissions"

    case insufficientPrivileges = "insufficient_privileges"

    case invalidCollectionRevision = "invalid_collection_revision"

    case invalidItemGroupRevision = "invalid_item_group_revision"

    case invalidItemTimestamp = "invalid_item_timestamp"

    case invalidNumberOfItems = "invalid_number_of_items"

    case invalidPlatform = "invalid_platform"

    case invalidTeamId = "invalid_team_id"

    case invalidUserGroupRevision = "invalid_user_group_revision"

    case invalidUserGroupTeam = "invalid_user_group_team"

    case itemGroupAlreadyExistsInCollection = "item_group_already_exists_in_collection"

    case itemGroupIdAlreadyExists = "item_group_id_already_exists"

    case itemGroupIsNotFound = "item_group_is_not_found"

    case itemGroupIsPartOfCollection = "item_group_is_part_of_collection"

    case itemGroupNotInCollection = "item_group_not_in_collection"

    case itemGroupUpdateConflict = "item_group_update_conflict"

    case itemIsAlreadyShared = "item_is_already_shared"

    case itemIsNotFound = "item_is_not_found"

    case itemgroupOfTypeUsergroupkeysCannotBePartOfCollection =
      "itemgroup_of_type_usergroupkeys_cannot_be_part_of_collection"

    case missingTeamCaptains = "missing_team_captains"

    case newUserMustSpecifyCollectionKey = "new_user_must_specify_collection_key"

    case newUserMustSpecifyProposeSignature = "new_user_must_specify_propose_signature"

    case noCollectionKeyToAccept = "no_collection_key_to_accept"

    case noGroupKeyToAccept = "no_group_key_to_accept"

    case noTeamForUser = "no_team_for_user"

    case noUserGroupAcceptSignature = "no_user_group_accept_signature"

    case noUserOrUserGroupIsProvided = "no_user_or_user_group_is_provided"

    case nonExistingUserCannotSpecifyGroupKey = "non_existing_user_cannot_specify_group_key"

    case nonExistingUserMustSpecifyProposeSignatureUsingAlias =
      "non_existing_user_must_specify_propose_signature_using_alias"

    case notAMemberCannotShareWithUserGroup = "not_a_member_cannot_share_with_user_group"

    case notEnoughAdmins = "not_enough_admins"

    case notEnoughAdminsInCollection = "not_enough_admins_in_collection"

    case pi20211231Killswitch = "pi_20211231_killswitch"

    case providedCollectionUuidDoesNotExist = "provided_collection_uuid_does_not_exist"

    case providedUserIdDoesNotExist = "provided_user_id_does_not_exist"

    case providedUserIsNotItemGroupMember = "provided_user_is_not_item_group_member"

    case providedUsergroupIdDoesNotExist = "provided_usergroup_id_does_not_exist"

    case sharingDisabledByTeam = "sharing_disabled_by_team"

    case teamAdminsUserGroupAlreadyExists = "team_admins_user_group_already_exists"

    case teamDoesNotExist = "team_does_not_exist"

    case teamNotFound = "team_not_found"

    case tooManyLogins = "too_many_logins"

    case userGroupIdAlreadyExists = "user_group_id_already_exists"

    case userGroupIsNotAdmin = "user_group_is_not_admin"

    case userGroupIsNotFound = "user_group_is_not_found"

    case userGroupIsNotInCollection = "user_group_is_not_in_collection"

    case userGroupIsNotInItemGroup = "user_group_is_not_in_item_group"

    case userGroupIsNotInPendingStatus = "user_group_is_not_in_pending_status"

    case userGroupUpdateConflict = "user_group_update_conflict"

    case userGroupsCannotBeRevokedFromCollection = "user_groups_cannot_be_revoked_from_collection"

    case userGroupsCannotBeRevokedFromItemGroup = "user_groups_cannot_be_revoked_from_item_group"

    case userGroupsItemGroupAlreadyExists = "user_groups_item_group_already_exists"

    case userHasNoPublicKey = "user_has_no_public_key"

    case userIsNotAcceptedInCollection = "user_is_not_accepted_in_collection"

    case userIsNotInCollection = "user_is_not_in_collection"

    case userIsNotInItemGroup = "user_is_not_in_item_group"

    case userIsNotInPendingStatus = "user_is_not_in_pending_status"

    case userIsNotInUserGroup = "user_is_not_in_user_group"

    case userIsNotMemberOfTeam = "user_is_not_member_of_team"

    case userIsNotTeamCaptain = "user_is_not_team_captain"

    case usersCannotBeRevokedFromCollection = "users_cannot_be_revoked_from_collection"

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
  public enum Sync: String, Sendable, Equatable, CaseIterable, Codable {
    case twofaServerKeyNotProvided = "2fa_server_key_not_provided"

    case twofaServerKeyProvidedIncorrectly = "2fa_server_key_provided_incorrectly"

    case twofaSettingChangeMayOnlyHappenInPasswordChange =
      "2fa_setting_change_may_only_happen_in_password_change"

    case twofaSettingSameAsCurrent = "2fa_setting_same_as_current"

    case authTicketMissing = "auth_ticket_missing"

    case changePasswordNeedsContent = "change_password_needs_content"

    case changePasswordNeedsSharingkeys = "change_password_needs_sharingkeys"

    case concurrentUpload = "concurrent_upload"

    case conflictingUpload = "conflicting_upload"

    case current2FASettingCannotBeChangedAtUpload =
      "current_2fa_setting_cannot_be_changed_at_upload"

    case deviceNotFound = "device_not_found"

    case invalidVerificationTransition = "invalid_verification_transition"

    case missingSettingsTransaction = "missing_settings_transaction"

    case noSharingKeys = "no_sharing_keys"

    case nothingToUpdate = "nothing_to_update"

    case providedSharingPublicKeyDoesNotMatchCurrentOne =
      "provided_sharing_public_key_does_not_match_current_one"

    case remoteKeyRequired = "remote_key_required"

    case sharingKeysAlreadySet = "sharing_keys_already_set"

    case sharingPrivateKeyUpdateMayOnlyHappenInPasswordChange =
      "sharing_private_key_update_may_only_happen_in_password_change"

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
  public enum Teams: String, Sendable, Equatable, CaseIterable, Codable {
    case alreadyInTeam = "already_in_team"

    case alreadyMemberOtherTeam = "already_member_other_team"

    case alreadyUsedFreetrial = "already_used_freetrial"

    case cannotAddSeatDuringGracePeriod = "cannot_add_seat_during_grace_period"

    case cannotCreateTeam = "cannot_create_team"

    case cannotExceedTenSeatsForStarterPlans = "cannot_exceed_ten_seats_for_starter_plans"

    case forbiddenTeamMemberEmailDomain = "forbidden_team_member_email_domain"

    case invalidCompanyName = "invalid_company_name"

    case invalidCreatorEmail = "invalid_creator_email"

    case invalidOrigin = "invalid_origin"

    case mailDomainIsAlreadyUsedByAnotherTeam = "mail_domain_is_already_used_by_another_team"

    case noFreeSlot = "no_free_slot"

    case noFreeSlotFreePlan = "no_free_slot_free_plan"

    case notBillingAdmin = "not_billing_admin"

    case paymentFailed = "payment_failed"

    case teamIsDiscontinued = "team_is_discontinued"

    case teamNotFound = "team_not_found"

    case tokenExpired = "token_expired"

    case tokenNotFound = "token_not_found"

    case tokenUsedOrNotfound = "token_used_or_notfound"

    case unsupportedPaymentMean = "unsupported_payment_mean"

    case userDoesntExist = "user_doesnt_exist"

    case userTeamInviteTokenNotFound = "user_team_invite_token_not_found"

  }
}

extension APIError {
  public func hasTeamsCode(_ errorCode: APIErrorCodes.Teams) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension APIErrorCodes {
  public enum Vpn: String, Sendable, Equatable, CaseIterable, Codable {
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
