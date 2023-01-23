import Foundation

extension Definition {

public enum `EncryptionAlgorithm`: String, Encodable {
case `other`
case `sha1`
case `sha256`
case `sha512`
}
}