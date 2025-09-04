import Foundation
import LogFoundation

@Loggable
public enum NitroError: Error {
  case invalidSignature
  case pcrDidNotMatch
  case couldNotDecodeCBOR
  case rootCertificateDidNotMatch
  case invalidCertificate
}
