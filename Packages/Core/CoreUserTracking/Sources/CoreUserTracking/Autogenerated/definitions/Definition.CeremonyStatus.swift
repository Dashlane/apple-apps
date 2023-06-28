import Foundation

extension Definition {

public enum `CeremonyStatus`: String, Encodable {
case `cancelled`
case `failure`
case `success`
}
}