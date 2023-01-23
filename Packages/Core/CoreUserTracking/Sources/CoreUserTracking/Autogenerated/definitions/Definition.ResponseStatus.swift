import Foundation

extension Definition {

public enum `ResponseStatus`: String, Encodable {
case `accepted`
case `denied`
case `error`
}
}