import Foundation

extension UserDeviceAPIClient.SecretTransfer {
  public struct CompleteTransfer: APIRequest {
    public static let endpoint: Endpoint = "/secretTransfer/CompleteTransfer"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      transfer: Body.Transfer, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(transfer: transfer)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var completeTransfer: CompleteTransfer {
    CompleteTransfer(api: api)
  }
}

extension UserDeviceAPIClient.SecretTransfer.CompleteTransfer {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transfer = "transfer"
    }

    public struct Transfer: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case transferType = "transferType"
        case transferId = "transferId"
        case encryptedData = "encryptedData"
        case nonce = "nonce"
        case publicKey = "publicKey"
      }

      public let transferType: SecretTransfertransfertype
      public let transferId: String
      public let encryptedData: String
      public let nonce: String
      public let publicKey: String?

      public init(
        transferType: SecretTransfertransfertype, transferId: String, encryptedData: String,
        nonce: String, publicKey: String? = nil
      ) {
        self.transferType = transferType
        self.transferId = transferId
        self.encryptedData = encryptedData
        self.nonce = nonce
        self.publicKey = publicKey
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transferType, forKey: .transferType)
        try container.encode(transferId, forKey: .transferId)
        try container.encode(encryptedData, forKey: .encryptedData)
        try container.encode(nonce, forKey: .nonce)
        try container.encodeIfPresent(publicKey, forKey: .publicKey)
      }
    }

    public let transfer: Transfer

    public init(transfer: Transfer) {
      self.transfer = transfer
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transfer, forKey: .transfer)
    }
  }
}

extension UserDeviceAPIClient.SecretTransfer.CompleteTransfer {
  public typealias Response = Empty?
}
