import Foundation

extension UserDeviceAPIClient.User {
  public struct SendLoginChangeToken: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/user/SendLoginChangeToken"

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
  public var sendLoginChangeToken: SendLoginChangeToken {
    SendLoginChangeToken(api: api)
  }
}

extension UserDeviceAPIClient.User.SendLoginChangeToken {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.User.SendLoginChangeToken {
  public typealias Response = Empty?
}
