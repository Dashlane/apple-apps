import Foundation

extension Definition {

public enum `FlowStep`: String, Encodable {
case `cancel`
case `complete`
case `error`
case `start`
}
}