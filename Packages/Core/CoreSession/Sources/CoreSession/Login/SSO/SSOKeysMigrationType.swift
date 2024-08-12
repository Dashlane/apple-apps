import Foundation

public enum SSOKeysMigrationType {
  case unlock(_ oldSession: Session, _ ssoAuthenticationInfo: SSOAuthenticationInfo)
  case localLogin(ssoKey: Data, remoteKey: Data)
}
