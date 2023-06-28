import Foundation

extension Definition {

public enum `AuthenticatorResidentKey`: String, Encodable {
case `discouraged`
case `preferred`
case `required`
}
}