import Foundation

public enum SSOKeysMigrationType {
    case unlock(_ oldSession: Session, _ validator: SSOLocalLoginValidator)
    case localLogin(ssoKey: Data, remoteKey: Data)
}
