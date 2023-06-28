import Foundation

extension Definition {

public enum `AuthenticatorUserVerification`: String, Encodable {
case `discouraged`
case `preferred`
case `required`
}
}