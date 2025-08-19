import Foundation

public enum NitroSSOErrorCodes {
}

extension NitroSSOErrorCodes {
  public enum Authentication: String, Sendable, Hashable, Codable, CaseIterable {
    case domainCheckInvalid = "domain_check_invalid"

    case domainConfigurationIntegrityMismatch = "domain_configuration_integrity_mismatch"

    case domainConfigurationNotFound = "domain_configuration_not_found"

    case domainConfigurationS3Empty = "domain_configuration_s3_empty"

    case domainDoesNotBelongToTeam = "domain_does_not_belong_to_team"

    case domainIdpMetadataNotConfigured = "domain_idp_metadata_not_configured"

    case domainNotBound = "domain_not_bound"

    case domainNotFound = "domain_not_found"

    case emailDomainMismatch = "email_domain_mismatch"

    case idpNotFound = "idp_not_found"

    case invalidEmailAddress = "invalid_email_address"

    case notAValidXMLDocument = "not_a_valid_xml_document"

    case notMember = "not_member"

    case notProposedOrAccepted = "not_proposed_or_accepted"

    case samlAssertionAudienceMismatch = "saml_assertion_audience_mismatch"

    case samlResponseInvalid = "saml_response_invalid"

    case samlResponseNoUserProfile = "saml_response_no_user_profile"

    case teamHasNotEnabledSSO = "team_has_not_enabled_sso"

    case teamIsNotUsingNitro = "team_is_not_using_nitro"

    case teamNotFound = "team_not_found"

    case userDoesNotHaveSSOStatus = "user_does_not_have_sso_status"

    case userNotFound = "user_not_found"

  }
}

extension NitroSSOError {
  public func hasAuthenticationCode(_ errorCode: NitroSSOErrorCodes.Authentication) -> Bool {
    self.has(errorCode.rawValue)
  }
}

extension NitroSSOErrorCodes {
  public enum Tunnel: String, Sendable, Hashable, Codable, CaseIterable {
    case clientSessionKeysNotFound = "client_session_keys_not_found"

  }
}

extension NitroSSOError {
  public func hasTunnelCode(_ errorCode: NitroSSOErrorCodes.Tunnel) -> Bool {
    self.has(errorCode.rawValue)
  }
}
