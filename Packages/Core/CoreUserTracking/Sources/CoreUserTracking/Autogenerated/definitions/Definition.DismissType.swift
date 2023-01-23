import Foundation

extension Definition {

public enum `DismissType`: String, Encodable {
case `cancel`
case `close`
case `closeCross` = "close_cross"
case `closeEscape` = "close_escape"
case `closeSecurity` = "close_security"
case `never`
case `unfocus`
}
}