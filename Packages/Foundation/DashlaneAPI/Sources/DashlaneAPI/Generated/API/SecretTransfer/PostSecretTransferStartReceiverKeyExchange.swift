import Foundation

extension AppAPIClient.SecretTransfer {
  public struct StartReceiverKeyExchange: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/secretTransfer/StartReceiverKeyExchange"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      transferId: String, receiverHashedPublicKey: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(transferId: transferId, receiverHashedPublicKey: receiverHashedPublicKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var startReceiverKeyExchange: StartReceiverKeyExchange {
    StartReceiverKeyExchange(api: api)
  }
}

extension AppAPIClient.SecretTransfer.StartReceiverKeyExchange {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transferId = "transferId"
      case receiverHashedPublicKey = "receiverHashedPublicKey"
    }

    public let transferId: String
    public let receiverHashedPublicKey: String

    public init(transferId: String, receiverHashedPublicKey: String) {
      self.transferId = transferId
      self.receiverHashedPublicKey = receiverHashedPublicKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transferId, forKey: .transferId)
      try container.encode(receiverHashedPublicKey, forKey: .receiverHashedPublicKey)
    }
  }
}

extension AppAPIClient.SecretTransfer.StartReceiverKeyExchange {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case senderPublicKey = "senderPublicKey"
    }

    public let senderPublicKey: String

    public init(senderPublicKey: String) {
      self.senderPublicKey = senderPublicKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(senderPublicKey, forKey: .senderPublicKey)
    }
  }
}
