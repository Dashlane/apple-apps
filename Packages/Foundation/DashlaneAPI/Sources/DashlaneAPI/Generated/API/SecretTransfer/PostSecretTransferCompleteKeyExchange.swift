import Foundation

extension AppAPIClient.SecretTransfer {
  public struct CompleteKeyExchange: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/secretTransfer/CompleteKeyExchange"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      transferId: String, receiverPublicKey: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(transferId: transferId, receiverPublicKey: receiverPublicKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var completeKeyExchange: CompleteKeyExchange {
    CompleteKeyExchange(api: api)
  }
}

extension AppAPIClient.SecretTransfer.CompleteKeyExchange {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transferId = "transferId"
      case receiverPublicKey = "receiverPublicKey"
    }

    public let transferId: String
    public let receiverPublicKey: String

    public init(transferId: String, receiverPublicKey: String) {
      self.transferId = transferId
      self.receiverPublicKey = receiverPublicKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transferId, forKey: .transferId)
      try container.encode(receiverPublicKey, forKey: .receiverPublicKey)
    }
  }
}

extension AppAPIClient.SecretTransfer.CompleteKeyExchange {
  public typealias Response = Empty?
}
