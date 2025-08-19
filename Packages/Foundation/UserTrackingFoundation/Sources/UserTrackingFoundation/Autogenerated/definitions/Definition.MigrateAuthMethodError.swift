import Foundation

extension Definition {

  public enum `MigrateAuthMethodError`: String, Encodable, Sendable {
    case `ssoFeatureBlocked` = "sso_feature_blocked"
    case `ssoLoginCorrupt` = "sso_login_corrupt"
    case `ssoSetupError` = "sso_setup_error"
    case `unknownError` = "unknown_error"
  }
}
