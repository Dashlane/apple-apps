import Foundation

extension Definition {

public enum `DismissType`: String, Encodable {
case `cancel`
case `close`
case `closeCross` = "close_cross"
case `closeEscape` = "close_escape"
case `closeSecurity` = "close_security"
case `doNotTrust` = "do_not_trust"
case `never`
case `unfocus`
case `useLocalPasskey` = "use_local_passkey"
}
}