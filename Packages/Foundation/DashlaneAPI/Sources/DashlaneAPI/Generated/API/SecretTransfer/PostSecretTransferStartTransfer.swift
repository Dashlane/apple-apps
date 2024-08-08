import Foundation

extension AppAPIClient.SecretTransfer {
  public struct StartTransfer: APIRequest {
    public static let endpoint: Endpoint = "/secretTransfer/StartTransfer"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      transferType: SecretTransfertransfertype, transferId: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(transferType: transferType, transferId: transferId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var startTransfer: StartTransfer {
    StartTransfer(api: api)
  }
}

extension AppAPIClient.SecretTransfer.StartTransfer {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transferType = "transferType"
      case transferId = "transferId"
    }

    public enum TransferType: String, Sendable, Equatable, CaseIterable, Codable {
      case universal = "universal"
      case proximity = "proximity"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let transferType: SecretTransfertransfertype
    public let transferId: String

    public init(transferType: SecretTransfertransfertype, transferId: String) {
      self.transferType = transferType
      self.transferId = transferId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transferType, forKey: .transferType)
      try container.encode(transferId, forKey: .transferId)
    }
  }
}

extension AppAPIClient.SecretTransfer.StartTransfer {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case encryptedData = "encryptedData"
      case nonce = "nonce"
      case senderPublicKey = "senderPublicKey"
    }

    public let encryptedData: String
    public let nonce: String
    public let senderPublicKey: String?

    public init(encryptedData: String, nonce: String, senderPublicKey: String? = nil) {
      self.encryptedData = encryptedData
      self.nonce = nonce
      self.senderPublicKey = senderPublicKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(encryptedData, forKey: .encryptedData)
      try container.encode(nonce, forKey: .nonce)
      try container.encodeIfPresent(senderPublicKey, forKey: .senderPublicKey)
    }
  }
}
