import Foundation

public enum NitroError: Error {
  case invalidSignature
  case pcrDidNotMatch
  case couldNotDecodeCBOR
  case rootCertificateDidNotMatch
  case invalidCertificate
}
