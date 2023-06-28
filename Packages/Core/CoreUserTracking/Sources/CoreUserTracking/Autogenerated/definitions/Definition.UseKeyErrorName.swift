import Foundation

extension Definition {

public enum `UseKeyErrorName`: String, Encodable {
case `unknown`
case `wrongKeyEntered` = "wrong_key_entered"
}
}