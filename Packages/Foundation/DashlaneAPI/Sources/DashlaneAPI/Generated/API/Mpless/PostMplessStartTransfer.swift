import Foundation

extension AppAPIClient.Mpless {
  public struct StartTransfer: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/mpless/StartTransfer"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      transferId: String, cryptography: MplessTransferCryptography, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(transferId: transferId, cryptography: cryptography)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var startTransfer: StartTransfer {
    StartTransfer(api: api)
  }
}

extension AppAPIClient.Mpless.StartTransfer {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transferId = "transferId"
      case cryptography = "cryptography"
    }

    public let transferId: String
    public let cryptography: MplessTransferCryptography

    public init(transferId: String, cryptography: MplessTransferCryptography) {
      self.transferId = transferId
      self.cryptography = cryptography
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transferId, forKey: .transferId)
      try container.encode(cryptography, forKey: .cryptography)
    }
  }
}

extension AppAPIClient.Mpless.StartTransfer {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case encryptedData = "encryptedData"
      case publicKey = "publicKey"
    }

    public let encryptedData: String
    public let publicKey: String

    public init(encryptedData: String, publicKey: String) {
      self.encryptedData = encryptedData
      self.publicKey = publicKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(encryptedData, forKey: .encryptedData)
      try container.encode(publicKey, forKey: .publicKey)
    }
  }
}
