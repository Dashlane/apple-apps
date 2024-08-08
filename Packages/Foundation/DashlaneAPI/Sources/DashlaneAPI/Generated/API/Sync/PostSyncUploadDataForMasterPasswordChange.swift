import Foundation

extension UserDeviceAPIClient.Sync {
  public struct UploadDataForMasterPasswordChange: APIRequest {
    public static let endpoint: Endpoint = "/sync/UploadDataForMasterPasswordChange"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      timestamp: Int, transactions: [SyncUploadDataTransactions], sharingKeys: SyncSharingKeys,
      authTicket: String? = nil, remoteKeys: [SyncUploadDataRemoteKeys]? = nil,
      updateVerification: Body.UpdateVerification? = nil, uploadReason: Body.UploadReason? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        timestamp: timestamp, transactions: transactions, sharingKeys: sharingKeys,
        authTicket: authTicket, remoteKeys: remoteKeys, updateVerification: updateVerification,
        uploadReason: uploadReason)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var uploadDataForMasterPasswordChange: UploadDataForMasterPasswordChange {
    UploadDataForMasterPasswordChange(api: api)
  }
}

extension UserDeviceAPIClient.Sync.UploadDataForMasterPasswordChange {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case timestamp = "timestamp"
      case transactions = "transactions"
      case sharingKeys = "sharingKeys"
      case authTicket = "authTicket"
      case remoteKeys = "remoteKeys"
      case updateVerification = "updateVerification"
      case uploadReason = "uploadReason"
    }

    public struct UpdateVerification: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case type = "type"
        case serverKey = "serverKey"
        case ssoServerKey = "ssoServerKey"
      }

      public enum `Type`: String, Sendable, Equatable, CaseIterable, Codable {
        case emailToken = "email_token"
        case totpDeviceRegistration = "totp_device_registration"
        case totpLogin = "totp_login"
        case sso = "sso"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let type: `Type`
      public let serverKey: String?
      public let ssoServerKey: String?

      public init(type: `Type`, serverKey: String? = nil, ssoServerKey: String? = nil) {
        self.type = type
        self.serverKey = serverKey
        self.ssoServerKey = ssoServerKey
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(serverKey, forKey: .serverKey)
        try container.encodeIfPresent(ssoServerKey, forKey: .ssoServerKey)
      }
    }

    public enum UploadReason: String, Sendable, Equatable, CaseIterable, Codable {
      case completeAccountRecovery = "complete_account_recovery"
      case masterPasswordMobileReset = "master_password_mobile_reset"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let timestamp: Int
    public let transactions: [SyncUploadDataTransactions]
    public let sharingKeys: SyncSharingKeys
    public let authTicket: String?
    public let remoteKeys: [SyncUploadDataRemoteKeys]?
    public let updateVerification: UpdateVerification?
    public let uploadReason: UploadReason?

    public init(
      timestamp: Int, transactions: [SyncUploadDataTransactions], sharingKeys: SyncSharingKeys,
      authTicket: String? = nil, remoteKeys: [SyncUploadDataRemoteKeys]? = nil,
      updateVerification: UpdateVerification? = nil, uploadReason: UploadReason? = nil
    ) {
      self.timestamp = timestamp
      self.transactions = transactions
      self.sharingKeys = sharingKeys
      self.authTicket = authTicket
      self.remoteKeys = remoteKeys
      self.updateVerification = updateVerification
      self.uploadReason = uploadReason
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(timestamp, forKey: .timestamp)
      try container.encode(transactions, forKey: .transactions)
      try container.encode(sharingKeys, forKey: .sharingKeys)
      try container.encodeIfPresent(authTicket, forKey: .authTicket)
      try container.encodeIfPresent(remoteKeys, forKey: .remoteKeys)
      try container.encodeIfPresent(updateVerification, forKey: .updateVerification)
      try container.encodeIfPresent(uploadReason, forKey: .uploadReason)
    }
  }
}

extension UserDeviceAPIClient.Sync.UploadDataForMasterPasswordChange {
  public typealias Response = SyncUploadDataResponse
}
