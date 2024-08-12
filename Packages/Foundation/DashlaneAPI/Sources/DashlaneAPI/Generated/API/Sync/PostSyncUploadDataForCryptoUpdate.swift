import Foundation

extension UserDeviceAPIClient.Sync {
  public struct UploadDataForCryptoUpdate: APIRequest {
    public static let endpoint: Endpoint = "/sync/UploadDataForCryptoUpdate"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      timestamp: Int, transactions: [SyncUploadDataTransactions], sharingKeys: SyncSharingKeys,
      remoteKeys: [SyncUploadDataRemoteKeys]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        timestamp: timestamp, transactions: transactions, sharingKeys: sharingKeys,
        remoteKeys: remoteKeys)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var uploadDataForCryptoUpdate: UploadDataForCryptoUpdate {
    UploadDataForCryptoUpdate(api: api)
  }
}

extension UserDeviceAPIClient.Sync.UploadDataForCryptoUpdate {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case timestamp = "timestamp"
      case transactions = "transactions"
      case sharingKeys = "sharingKeys"
      case remoteKeys = "remoteKeys"
    }

    public let timestamp: Int
    public let transactions: [SyncUploadDataTransactions]
    public let sharingKeys: SyncSharingKeys
    public let remoteKeys: [SyncUploadDataRemoteKeys]?

    public init(
      timestamp: Int, transactions: [SyncUploadDataTransactions], sharingKeys: SyncSharingKeys,
      remoteKeys: [SyncUploadDataRemoteKeys]? = nil
    ) {
      self.timestamp = timestamp
      self.transactions = transactions
      self.sharingKeys = sharingKeys
      self.remoteKeys = remoteKeys
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(timestamp, forKey: .timestamp)
      try container.encode(transactions, forKey: .transactions)
      try container.encode(sharingKeys, forKey: .sharingKeys)
      try container.encodeIfPresent(remoteKeys, forKey: .remoteKeys)
    }
  }
}

extension UserDeviceAPIClient.Sync.UploadDataForCryptoUpdate {
  public typealias Response = SyncUploadDataResponse
}
