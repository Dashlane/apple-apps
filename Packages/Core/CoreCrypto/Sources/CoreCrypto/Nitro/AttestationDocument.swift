import CryptoKit
import Foundation
import SwiftCBOR

public struct AttestationDocument: Decodable {

  public struct UserData: Decodable {
    public let header: String
    public let publicKey: String
  }

  enum CodingKeys: String, CodingKey {
    case digest
    case cabundle
    case moduleId = "module_id"
    case timestamp
    case certificate
    case userData = "user_data"
    case pcrs
  }

  let digest: String
  public let cabundle: [Data]
  let moduleId: String
  let timestamp: Int
  public let certificate: Data
  public let userData: UserData
  public let pcrs: [Int: Data]

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.digest = try container.decode(String.self, forKey: .digest)
    self.cabundle = try container.decode([Data].self, forKey: .cabundle)
    self.moduleId = try container.decode(String.self, forKey: .moduleId)
    self.timestamp = try container.decode(Int.self, forKey: .timestamp)
    self.certificate = try container.decode(Data.self, forKey: .certificate)
    let jsonData = try container.decode(Data.self, forKey: .userData)
    self.userData = try JSONDecoder().decode(UserData.self, from: jsonData)
    self.pcrs = try container.decode([Int: Data].self, forKey: .pcrs)
  }

  init(coseSign1: CBOR) throws {
    guard let payloadCbor = coseSign1[2],
      case let CBOR.byteString(payload) = payloadCbor
    else {
      throw NitroError.couldNotDecodeCBOR
    }

    self = try CodableCBORDecoder().decode(AttestationDocument.self, from: Data(payload))

    try verifySignatureMatchPublicKey(in: coseSign1)
  }

  init(rawAttestation: String) throws {
    guard let response = try CBORDecoder(input: rawAttestation.hexaBytes).decodeItem(),
      case let .tagged(CBOR.Tag(rawValue: 18), coseSign1) = response
    else {
      throw NitroError.couldNotDecodeCBOR
    }

    try self.init(coseSign1: coseSign1)
  }
}

extension AttestationDocument {
  private func verifySignatureMatchPublicKey(in coseSign1: CBOR) throws {
    guard let certificate = SecCertificateCreateWithData(nil, certificate as CFData),
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

extension AttestationDocument {
  func verify(using certificate: NitroSecureTunnelCertificate) throws {
    try verifyCertificateChain(withRootCertificate: certificate.rootCertificate)
    try verifyPCRMeasurements(withExpectedPCRs: [3: certificate.pcr3, 8: certificate.pcr8])
  }

  func verifyCertificateChain(withRootCertificate rootCertificate: String) throws {
    guard let decodedData = cabundle.first?.base64EncodedString().data(using: .utf8),
      case let rootFromAttestation = String(decoding: decodedData, as: UTF8.self),
      rootCertificate == rootFromAttestation
    else {
      throw NitroError.rootCertificateDidNotMatch
    }

    guard let certificateFromAttestation = SecCertificateCreateWithData(nil, certificate as CFData)
    else {
      throw NitroError.invalidCertificate
    }

    var certificateChain: [SecCertificate] = try cabundle.map { certificate in
      guard let secCertificate = SecCertificateCreateWithData(nil, certificate as CFData) else {
        throw NitroError.invalidCertificate
      }
      return secCertificate
    }
    certificateChain.append(certificateFromAttestation)

    var trust: SecTrust?
    let status = SecTrustCreateWithCertificates(
      certificateChain as AnyObject,
      SecPolicyCreateBasicX509(),
      &trust)
    guard status == errSecSuccess else {
      throw NitroError.invalidCertificate
    }
  }

  func verifyPCRMeasurements(withExpectedPCRs expectedPCRs: [Int: String]) throws {
    try expectedPCRs.forEach { (index, value) in
      guard pcrs[index]?.hexadecimalString == value else {
        throw NitroError.pcrDidNotMatch
      }
    }
  }
}
