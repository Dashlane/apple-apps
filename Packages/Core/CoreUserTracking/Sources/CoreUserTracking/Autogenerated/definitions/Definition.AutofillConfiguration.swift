import Foundation

extension Definition {

public enum `AutofillConfiguration`: String, Encodable {
case `autofillDisabled` = "autofill_disabled"
case `autofillEnabled` = "autofill_enabled"
case `loginAndPasswordsOnly` = "login_and_passwords_only"
}
}