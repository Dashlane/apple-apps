import Foundation

extension Definition {

public enum `Rights`: String, Encodable {
case `limited`
case `revoked`
case `unlimited`
}
}