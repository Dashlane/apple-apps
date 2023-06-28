import Foundation

extension Definition {

public enum `AuthenticationMediationType`: String, Encodable {
case `conditional`
case `optional`
case `required`
case `silent`
}
}