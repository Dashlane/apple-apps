import Foundation

extension Definition {

  public enum `ScimSetupStep`: String, Encodable, Sendable {
    case `activateDirectorySync` = "activate_directory_sync"
    case `activateGroupSync` = "activate_group_sync"
    case `clickSetUp` = "click_set_up"
    case `copyApiToken` = "copy_api_token"
    case `copyEndpointLink` = "copy_endpoint_link"
    case `deactivateDirectorySync` = "deactivate_directory_sync"
    case `generateScimToken` = "generate_scim_token"
    case `reGenerateToken` = "re_generate_token"
  }
}
