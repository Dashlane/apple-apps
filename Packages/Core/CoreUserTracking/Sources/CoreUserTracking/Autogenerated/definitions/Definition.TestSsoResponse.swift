import Foundation

extension Definition {

public enum `TestSsoResponse`: String, Encodable {
case `failure`
case `notTested` = "not_tested"
case `success`
case `timeout`
}
}