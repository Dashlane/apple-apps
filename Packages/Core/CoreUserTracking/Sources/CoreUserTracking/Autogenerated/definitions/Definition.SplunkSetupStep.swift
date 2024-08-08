import Foundation

extension Definition {

  public enum `SplunkSetupStep`: String, Encodable, Sendable {
    case `activateSplunkIntegration` = "activate_splunk_integration"
    case `clickSetUp` = "click_set_up"
    case `deactivateSplunkIntegration` = "deactivate_splunk_integration"
    case `genericError` = "generic_error"
    case `invalidUrlError` = "invalid_url_error"
    case `mismatchAdminProvisioningKeyError` = "mismatch_admin_provisioning_key_error"
    case `saveTokens` = "save_tokens"
    case `teamNotFoundError` = "team_not_found_error"
  }
}
