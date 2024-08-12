import CryptoKit
import Foundation
import SwiftCBOR

public struct AuthenticatorData: Equatable {
  public let relyingPartyID: String
  public let flags: AuthenticatorFlags
  public let counter: UInt32
  public let attestedData: AttestedCredentialData?
  public let extData: [UInt8]?
}

extension AuthenticatorData {
  init(
    relyingPartyID: String,
    publicKey: Data,
    credentialId: Data,
    applicationIdentifier: AAGUID = .defaultAAGUID,
    counter: UInt32,
    flags: AuthenticatorFlags
  ) {
    let credentialData = AttestedCredentialData(
      aaguid: applicationIdentifier,
      credentialID: [UInt8](credentialId),
      publicKey: [UInt8](publicKey))
    self.relyingPartyID = relyingPartyID
    self.flags = flags
    self.counter = counter
    self.attestedData = credentialData
    self.extData = nil
  }
}

extension AuthenticatorData {

  public struct AttestationInformation {
    public let credentialId: Data
    public let applicationIdentifier: AAGUID
    public let publicKey: PublicKey

    public init(
      credentialId: Data,
      applicationIdentifier: AAGUID = .defaultAAGUID,
      publicKey: PublicKey
    ) {
      self.credentialId = credentialId
      self.applicationIdentifier = applicationIdentifier
      self.publicKey = publicKey
    }

    func makeAttestedCredentialData() -> AttestedCredentialData {
      AttestedCredentialData(
        aaguid: applicationIdentifier,
        credentialID: [UInt8](credentialId),
        publicKey: [UInt8](publicKey.cborByteArrayRepresentation()))
    }
  }

  public init(
    relyingPartyID: String,
    attestationInformation: AttestationInformation?,
    counter: UInt32,
    flags: AuthenticatorFlags
  ) {
    if let attestedData = attestationInformation?.makeAttestedCredentialData() {
      self.attestedData = attestedData
    } else {
      self.attestedData = nil
    }
    self.relyingPartyID = relyingPartyID
    self.flags = flags
    self.counter = counter

    self.extData = nil
  }
}

extension AuthenticatorData {

  public func byteArrayRepresentation() -> [UInt8] {
    var value = [UInt8]()

    value += relyingPartyID.relyingPartyHash()

    value += [flags.byteRepresentation()]

    let counterRepresentation: [UInt8] = withUnsafeBytes(of: counter.bigEndian) {
      Array($0)
    }
    value += counterRepresentation

    if let attestedData {
      value += attestedData.bytesRepresentation()
    }

    if let extData {
      value += extData
    }
    return value
  }
}

extension String {
  func relyingPartyHash() -> [UInt8] {
    let rpIDData = data(using: .utf8)!
    let rpIDHash = SHA256.hash(data: rpIDData)
    return [UInt8](rpIDHash)
  }
}
