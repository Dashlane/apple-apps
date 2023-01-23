import Foundation

extension Definition {

public enum `AuthenticatorNames`: String, Encodable {
case `authy`
case `duo`
case `google`
case `lastpass`
case `microsoft`
}
}