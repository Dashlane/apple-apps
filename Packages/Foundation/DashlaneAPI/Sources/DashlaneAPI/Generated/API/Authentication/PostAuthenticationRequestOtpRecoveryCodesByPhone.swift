import Foundation

extension AppAPIClient.Authentication {
  public struct RequestOtpRecoveryCodesByPhone: APIRequest {
    public static let endpoint: Endpoint = "/authentication/RequestOtpRecoveryCodesByPhone"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(login: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(login: login)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestOtpRecoveryCodesByPhone: RequestOtpRecoveryCodesByPhone {
    RequestOtpRecoveryCodesByPhone(api: api)
  }
}

extension AppAPIClient.Authentication.RequestOtpRecoveryCodesByPhone {
  public typealias Body = AuthenticationBody
}

extension AppAPIClient.Authentication.RequestOtpRecoveryCodesByPhone {
  public typealias Response = Empty?
}
