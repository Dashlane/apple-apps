import Foundation

extension AppAPIClient.SecretTransfer {
  public struct RequestTransfer: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/secretTransfer/RequestTransfer"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(transfer: Body.Transfer, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(transfer: transfer)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestTransfer: RequestTransfer {
    RequestTransfer(api: api)
  }
}

extension AppAPIClient.SecretTransfer.RequestTransfer {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transfer = "transfer"
    }

    public struct Transfer: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case transferType = "transferType"
        case receiverDeviceName = "receiverDeviceName"
        case login = "login"
      }

      public let transferType: SecretTransfertransfertype
      public let receiverDeviceName: String
      public let login: String?

      public init(
        transferType: SecretTransfertransfertype, receiverDeviceName: String, login: String? = nil
      ) {
        self.transferType = transferType
        self.receiverDeviceName = receiverDeviceName
        self.login = login
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transferType, forKey: .transferType)
        try container.encode(receiverDeviceName, forKey: .receiverDeviceName)
        try container.encodeIfPresent(login, forKey: .login)
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

extension AppAPIClient.SecretTransfer.RequestTransfer {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transferId = "transferId"
      case expireDateUnix = "expireDateUnix"
    }

    public let transferId: String
    public let expireDateUnix: Int

    public init(transferId: String, expireDateUnix: Int) {
      self.transferId = transferId
      self.expireDateUnix = expireDateUnix
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transferId, forKey: .transferId)
      try container.encode(expireDateUnix, forKey: .expireDateUnix)
    }
  }
}
