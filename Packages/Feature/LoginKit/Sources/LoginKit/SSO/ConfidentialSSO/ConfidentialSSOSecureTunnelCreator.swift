import CoreCrypto
import CoreNetworking
import CoreSession
import CryptoKit
import DashTypes
import DashlaneAPI
import Foundation
import SwiftCBOR

public struct ConfidentialSSOSecureTunnelCreator {

  let secureTunnelCreator: NitroSecureTunnelCrypto
  let nitroClient: NitroAPIClient

  public init(nitroClient: NitroAPIClient) throws {
    secureTunnelCreator = try NitroSecureTunnelCrypto()
    self.nitroClient = nitroClient
  }

  public func createTunnel() async throws -> NitroSecureTunnel {
    let coseSign1 = try await startHello()
    let attestationDocument = try parseAttestationDocument(fromCoseSign1: coseSign1)
    try attestationDocument.verifyCertificateChain(
      withRootCertificate: ApplicationSecrets.NitroSSO.rootCertificate)
    try verifySignature(of: coseSign1, withKeyFrom: attestationDocument)
    try attestationDocument.verifyPCR([
      3: ApplicationSecrets.NitroSSO.pcr3, 8: ApplicationSecrets.NitroSSO.pcr8,
    ])
    let secureTunnel = try secureTunnelCreator.createSecureTunnel(
      with: attestationDocument.userData)
    try await nitroClient.tunnel.terminateHello(clientHeader: secureTunnel.header)
    return secureTunnel
  }

  private func startHello() async throws -> CBOR {
    let response = try await nitroClient.tunnel.clientHello(
      clientPublicKey: secureTunnelCreator.publicKey)
    guard let response = try CBORDecoder(input: response.attestation.hexaBytes).decodeItem(),
      case let .tagged(CBOR.Tag(rawValue: 18), responseArray) = response
    else {
      throw NitroError.couldNotDecodeCBOR
    }
    return responseArray
  }

  func parseAttestationDocument(fromCoseSign1 coseSign1: CBOR) throws -> AttestationDocument {
    guard let payloadCbor = coseSign1[2],
      case let CBOR.byteString(payload) = payloadCbor
    else {
      throw NitroError.couldNotDecodeCBOR
    }
    return try CodableCBORDecoder().decode(AttestationDocument.self, from: Data(payload))
  }

  func verifySignature(of coseSign1: CBOR, withKeyFrom attestationDocument: AttestationDocument)
    throws
  {
    guard
      let certificate = SecCertificateCreateWithData(
        nil, attestationDocument.certificate as CFData),
      let pubKey = SecCertificateCopyKey(certificate)
    else {
      throw NitroError.invalidCertificate
    }
    guard let publicKeyData = try? pubKey.data(), let signatureCbor = coseSign1[3],
      case let CBOR.byteString(signature) = signatureCbor
    else {
      throw NitroError.couldNotDecodeCBOR
    }

    let externalData = CBOR.byteString([])
    let signedPayload: [UInt8] = CBOR.encode([
      "Signature1", coseSign1[0]!, externalData, coseSign1[2]!,
    ])

    let publicKey = try P384.Signing.PublicKey(x963RepresentationData: publicKeyData)
    let isValid = try publicKey.isValidSignature(Data(signature), forCOSEPayload: signedPayload)

    guard isValid else {
      throw NitroError.invalidSignature
    }
  }
}
