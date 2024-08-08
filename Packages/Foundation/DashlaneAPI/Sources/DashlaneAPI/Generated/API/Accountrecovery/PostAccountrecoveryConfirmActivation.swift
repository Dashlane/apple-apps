import Foundation

extension UserDeviceAPIClient.Accountrecovery {
  public struct ConfirmActivation: APIRequest {
    public static let endpoint: Endpoint = "/accountrecovery/ConfirmActivation"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(recoveryId: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(recoveryId: recoveryId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var confirmActivation: ConfirmActivation {
    ConfirmActivation(api: api)
  }
}

extension UserDeviceAPIClient.Accountrecovery.ConfirmActivation {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case recoveryId = "recoveryId"
    }

    public let recoveryId: String

    public init(recoveryId: String) {
      self.recoveryId = recoveryId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(recoveryId, forKey: .recoveryId)
    }
  }
}

extension UserDeviceAPIClient.Accountrecovery.ConfirmActivation {
  public typealias Response = Empty?
}
