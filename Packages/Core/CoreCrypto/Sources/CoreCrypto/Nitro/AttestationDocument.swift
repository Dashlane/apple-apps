import Foundation

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
}

extension AttestationDocument {

  public func verifyCertificateChain(withRootCertificate rootCertificate: String) throws {
    guard let decodedData = cabundle.first?.base64EncodedString().data(using: .utf8),
      let rootFromAttestation = String(data: decodedData, encoding: .utf8),
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

  public func verifyPCR(_ localPCRs: [Int: String]) throws {
    try localPCRs.forEach { (index, value) in
      guard pcrs[index]?.hexadecimalString == value else {
        throw NitroError.pcrDidNotMatch
      }
    }
  }
}
