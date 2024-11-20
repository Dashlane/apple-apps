import Foundation

extension AppNitroEncryptionAPIClient.Tunnel {
  public struct TerminateHello: APIRequest {
    public static let endpoint: Endpoint = "/tunnel/TerminateHello"

    public let api: AppNitroEncryptionAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      clientHeader: String, tunnelUuid: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(clientHeader: clientHeader, tunnelUuid: tunnelUuid)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var terminateHello: TerminateHello {
    TerminateHello(api: api)
  }
}

extension AppNitroEncryptionAPIClient.Tunnel.TerminateHello {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case clientHeader = "clientHeader"
      case tunnelUuid = "tunnelUuid"
    }

    public let clientHeader: String
    public let tunnelUuid: String

    public init(clientHeader: String, tunnelUuid: String) {
      self.clientHeader = clientHeader
      self.tunnelUuid = tunnelUuid
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(clientHeader, forKey: .clientHeader)
      try container.encode(tunnelUuid, forKey: .tunnelUuid)
    }
  }
}

extension AppNitroEncryptionAPIClient.Tunnel.TerminateHello {
  public typealias Response = Empty?
}
