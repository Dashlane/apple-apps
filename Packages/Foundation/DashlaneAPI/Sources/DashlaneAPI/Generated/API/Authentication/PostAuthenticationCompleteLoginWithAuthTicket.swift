import Foundation

extension AppAPIClient.Authentication {
  public struct CompleteLoginWithAuthTicket: APIRequest {
    public static let endpoint: Endpoint = "/authentication/CompleteLoginWithAuthTicket"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      login: String, deviceAccessKey: String, authTicket: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(login: login, deviceAccessKey: deviceAccessKey, authTicket: authTicket)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var completeLoginWithAuthTicket: CompleteLoginWithAuthTicket {
    CompleteLoginWithAuthTicket(api: api)
  }
}

extension AppAPIClient.Authentication.CompleteLoginWithAuthTicket {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case deviceAccessKey = "deviceAccessKey"
      case authTicket = "authTicket"
    }

    public let login: String
    public let deviceAccessKey: String
    public let authTicket: String

    public init(login: String, deviceAccessKey: String, authTicket: String) {
      self.login = login
      self.deviceAccessKey = deviceAccessKey
      self.authTicket = authTicket
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(deviceAccessKey, forKey: .deviceAccessKey)
      try container.encode(authTicket, forKey: .authTicket)
    }
  }
}

extension AppAPIClient.Authentication.CompleteLoginWithAuthTicket {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case remoteKeys = "remoteKeys"
      case serverKey = "serverKey"
      case ssoServerKey = "ssoServerKey"
    }

    public let remoteKeys: [AuthenticationCompleteAuthTicketRemoteKeys]?
    public let serverKey: String?
    public let ssoServerKey: String?

    public init(
      remoteKeys: [AuthenticationCompleteAuthTicketRemoteKeys]? = nil, serverKey: String? = nil,
      ssoServerKey: String? = nil
    ) {
      self.remoteKeys = remoteKeys
      self.serverKey = serverKey
      self.ssoServerKey = ssoServerKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(remoteKeys, forKey: .remoteKeys)
      try container.encodeIfPresent(serverKey, forKey: .serverKey)
      try container.encodeIfPresent(ssoServerKey, forKey: .ssoServerKey)
    }
  }
}
