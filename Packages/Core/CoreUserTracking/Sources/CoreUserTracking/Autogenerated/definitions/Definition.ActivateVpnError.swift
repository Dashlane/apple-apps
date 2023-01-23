import Foundation

extension Definition {

public enum `ActivateVpnError`: String, Encodable {
case `emailAlreadyInUse` = "email_already_in_use"
case `serverError` = "server_error"
}
}