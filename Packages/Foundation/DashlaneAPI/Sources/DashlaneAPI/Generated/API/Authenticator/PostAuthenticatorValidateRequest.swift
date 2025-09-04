import Foundation

extension AppAPIClient.Authenticator {
  public struct ValidateRequest: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/authenticator/ValidateRequest"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      requestId: String, deviceAccessKey: String, approval: Body.Approval,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(requestId: requestId, deviceAccessKey: deviceAccessKey, approval: approval)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var validateRequest: ValidateRequest {
    ValidateRequest(api: api)
  }
}

extension AppAPIClient.Authenticator.ValidateRequest {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case requestId = "requestId"
      case deviceAccessKey = "deviceAccessKey"
      case approval = "approval"
    }

    public struct Approval: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case status = "status"
        case isSuspicious = "isSuspicious"
      }

      public enum Status: String, Sendable, Hashable, Codable, CaseIterable {
        case approved = "approved"
        case rejected = "rejected"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let status: Status
      public let isSuspicious: Bool?

      public init(status: Status, isSuspicious: Bool? = nil) {
        self.status = status
        self.isSuspicious = isSuspicious
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(isSuspicious, forKey: .isSuspicious)
      }
    }

    public let requestId: String
    public let deviceAccessKey: String
    public let approval: Approval

    public init(requestId: String, deviceAccessKey: String, approval: Approval) {
      self.requestId = requestId
      self.deviceAccessKey = deviceAccessKey
      self.approval = approval
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(requestId, forKey: .requestId)
      try container.encode(deviceAccessKey, forKey: .deviceAccessKey)
      try container.encode(approval, forKey: .approval)
    }
  }
}

extension AppAPIClient.Authenticator.ValidateRequest {
  public typealias Response = Empty?
}
