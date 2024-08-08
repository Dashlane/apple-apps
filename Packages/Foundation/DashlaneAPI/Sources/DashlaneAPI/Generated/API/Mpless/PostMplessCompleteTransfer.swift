import Foundation

extension UserDeviceAPIClient.Mpless {
  public struct CompleteTransfer: APIRequest {
    public static let endpoint: Endpoint = "/mpless/CompleteTransfer"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      transferId: String, encryptedData: String, cryptography: MplessTransferCryptography,
      publicKey: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        transferId: transferId, encryptedData: encryptedData, cryptography: cryptography,
        publicKey: publicKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var completeTransfer: CompleteTransfer {
    CompleteTransfer(api: api)
  }
}

extension UserDeviceAPIClient.Mpless.CompleteTransfer {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transferId = "transferId"
      case encryptedData = "encryptedData"
      case cryptography = "cryptography"
      case publicKey = "publicKey"
    }

    public let transferId: String
    public let encryptedData: String
    public let cryptography: MplessTransferCryptography
    public let publicKey: String

    public init(
      transferId: String, encryptedData: String, cryptography: MplessTransferCryptography,
      publicKey: String
    ) {
      self.transferId = transferId
      self.encryptedData = encryptedData
      self.cryptography = cryptography
      self.publicKey = publicKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transferId, forKey: .transferId)
      try container.encode(encryptedData, forKey: .encryptedData)
      try container.encode(cryptography, forKey: .cryptography)
      try container.encode(publicKey, forKey: .publicKey)
    }
  }
}

extension UserDeviceAPIClient.Mpless.CompleteTransfer {
  public typealias Response = Empty?
}
