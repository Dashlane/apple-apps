import Foundation

extension Definition {

public enum `Scope`: String, Encodable {
case `global`
case `personal`
case `team`
}
}