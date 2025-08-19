import Foundation

extension UserDeviceAPIClient.Authenticator {
  public struct DisableAuthenticator: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/authenticator/DisableAuthenticator"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var disableAuthenticator: DisableAuthenticator {
    DisableAuthenticator(api: api)
  }
}

extension UserDeviceAPIClient.Authenticator.DisableAuthenticator {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Authenticator.DisableAuthenticator {
  public typealias Response = Empty?
}
