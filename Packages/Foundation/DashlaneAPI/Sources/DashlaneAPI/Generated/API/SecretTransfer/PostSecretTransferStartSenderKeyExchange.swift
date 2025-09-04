import Foundation

extension UserDeviceAPIClient.SecretTransfer {
  public struct StartSenderKeyExchange: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/secretTransfer/StartSenderKeyExchange"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      senderPublicKey: String, transferId: String? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(senderPublicKey: senderPublicKey, transferId: transferId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var startSenderKeyExchange: StartSenderKeyExchange {
    StartSenderKeyExchange(api: api)
  }
}

extension UserDeviceAPIClient.SecretTransfer.StartSenderKeyExchange {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case senderPublicKey = "senderPublicKey"
      case transferId = "transferId"
    }

    public let senderPublicKey: String
    public let transferId: String?

    public init(senderPublicKey: String, transferId: String? = nil) {
      self.senderPublicKey = senderPublicKey
      self.transferId = transferId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(senderPublicKey, forKey: .senderPublicKey)
      try container.encodeIfPresent(transferId, forKey: .transferId)
    }
  }
}

extension UserDeviceAPIClient.SecretTransfer.StartSenderKeyExchange {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case receiverPublicKey = "receiverPublicKey"
    }

    public let receiverPublicKey: String

    public init(receiverPublicKey: String) {
      self.receiverPublicKey = receiverPublicKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(receiverPublicKey, forKey: .receiverPublicKey)
    }
  }
}
