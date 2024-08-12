import Foundation
import SwiftCBOR

public struct AttestationObject {
  public let authenticatorData: AuthenticatorData
  public let rawAuthenticatorData: Data
  public let format: AttestationFormat
  public let attestationStatement: CBOR

  enum CBORKey: String {
    case format = "fmt"
    case attestationStatement = "attStmt"
    case authenticatorData = "authData"
  }
}

extension AttestationObject {
  public init(
    format: AttestationFormat = .`none`,
    attestationStatement: CBOR = .map([:]),
    authenticatorData: AuthenticatorData
  ) {
    self.format = format
    self.attestationStatement = attestationStatement
    self.authenticatorData = authenticatorData

    let map = CBOR.orderedMap([
      (CBOR.utf8String(CBORKey.format.rawValue), CBOR.utf8String(format.rawValue)),
      (CBOR.utf8String(CBORKey.attestationStatement.rawValue), attestationStatement),
      (
        CBOR.utf8String(CBORKey.authenticatorData.rawValue),
        CBOR.byteString(authenticatorData.byteArrayRepresentation())
      ),
    ])
    self.rawAuthenticatorData = Data(map)
  }
}
