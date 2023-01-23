import Foundation

extension Definition {

public enum `AutofillOrigin`: String, Encodable {
case `automatic`
case `dropdown`
case `keyboard`
case `notification`
}
}