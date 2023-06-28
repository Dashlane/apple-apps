import Foundation

extension Definition {

public enum `AutofillScope`: String, Encodable {
case `field`
case `global`
case `page`
case `site`
}
}