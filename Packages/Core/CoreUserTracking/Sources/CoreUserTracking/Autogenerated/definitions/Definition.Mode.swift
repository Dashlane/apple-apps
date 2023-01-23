import Foundation

extension Definition {

public enum `Mode`: String, Encodable {
case `biometric`
case `masterPassword` = "master_password"
case `pin`
case `sso`
}
}