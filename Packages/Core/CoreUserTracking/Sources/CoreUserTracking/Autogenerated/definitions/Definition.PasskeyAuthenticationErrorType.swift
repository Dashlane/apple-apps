import Foundation

extension Definition {

public enum `PasskeyAuthenticationErrorType`: String, Encodable {
case `invalidState` = "invalid_state"
case `notAllowed` = "not_allowed"
case `notSupported` = "not_supported"
case `security`
case `unknown`
}
}