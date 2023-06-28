import Foundation

extension Definition {

public enum `CreateKeyErrorName`: String, Encodable {
case `unknown`
case `wrongConfirmationKey` = "wrong_confirmation_key"
}
}