import Foundation

extension Definition {

  public enum `SsoSetupStep`: String, Encodable, Sendable {
    case `addConfigurationToServiceHost` = "add_configuration_to_service_host"
    case `chooseYourSsoSolution` = "choose_your_sso_solution"
    case `clearSsoSettings` = "clear_sso_settings"
    case `completeSsoSetup` = "complete_sso_setup"
    case `createSsoApplication` = "create_sso_application"
    case `emailDomainError` = "email_domain_error"
    case `generateAndSaveConfiguration` = "generate_and_save_configuration"
    case `returnToSsoSelection` = "return_to_sso_selection"
    case `selectEncryptionServicePlatform` = "select_encryption_service_platform"
    case `setUpEncryptionServiceSettings` = "set_up_encryption_service_settings"
    case `submitEmailDomain` = "submit_email_domain"
    case `testSsoConnection` = "test_sso_connection"
    case `turnOnSso` = "turn_on_sso"
    case `updateIdpSettings` = "update_idp_settings"
    case `validateIdpMetadata` = "validate_idp_metadata"
    case `verifyDomain` = "verify_domain"
  }
}
