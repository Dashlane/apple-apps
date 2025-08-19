import Foundation

extension AppAPIClient.Account {
  public struct DeleteOrResetAccount: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/account/DeleteOrResetAccount"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      authTicket: String, login: String, isDelete: Bool, detailedReason: String? = nil,
      reason: String? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        authTicket: authTicket, login: login, isDelete: isDelete, detailedReason: detailedReason,
        reason: reason)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deleteOrResetAccount: DeleteOrResetAccount {
    DeleteOrResetAccount(api: api)
  }
}

extension AppAPIClient.Account.DeleteOrResetAccount {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case authTicket = "authTicket"
      case login = "login"
      case isDelete = "isDelete"
      case detailedReason = "detailedReason"
      case reason = "reason"
    }

    public let authTicket: String
    public let login: String
    public let isDelete: Bool
    public let detailedReason: String?
    public let reason: String?

    public init(
      authTicket: String, login: String, isDelete: Bool, detailedReason: String? = nil,
      reason: String? = nil
    ) {
      self.authTicket = authTicket
      self.login = login
      self.isDelete = isDelete
      self.detailedReason = detailedReason
      self.reason = reason
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(authTicket, forKey: .authTicket)
      try container.encode(login, forKey: .login)
      try container.encode(isDelete, forKey: .isDelete)
      try container.encodeIfPresent(detailedReason, forKey: .detailedReason)
      try container.encodeIfPresent(reason, forKey: .reason)
    }
  }
}

extension AppAPIClient.Account.DeleteOrResetAccount {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case renewalPlatform = "renewalPlatform"
      case renewalStatus = "renewalStatus"
    }

    public enum RenewalPlatform: String, Sendable, Hashable, Codable, CaseIterable {
      case ios = "ios"
      case mac = "mac"
      case paypal = "paypal"
      case playstore = "playstore"
      case stripe = "stripe"
      case processout = "processout"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public enum RenewalStatus: String, Sendable, Hashable, Codable, CaseIterable {
      case stopped = "stopped"
      case notStopped = "not_stopped"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let renewalPlatform: RenewalPlatform?
    public let renewalStatus: RenewalStatus?

    public init(renewalPlatform: RenewalPlatform? = nil, renewalStatus: RenewalStatus? = nil) {
      self.renewalPlatform = renewalPlatform
      self.renewalStatus = renewalStatus
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(renewalPlatform, forKey: .renewalPlatform)
      try container.encodeIfPresent(renewalStatus, forKey: .renewalStatus)
    }
  }
}
