import Foundation

extension Definition {

public enum `AuthenticatorPushStatus`: String, Encodable {
case `accepted`
case `received`
case `rejected`
}
}