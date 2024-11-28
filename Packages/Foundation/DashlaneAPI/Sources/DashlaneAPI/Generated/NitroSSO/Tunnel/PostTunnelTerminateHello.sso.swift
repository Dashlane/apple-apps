import Foundation

extension NitroSSOAPIClient.Tunnel {
  public struct TerminateHello: APIRequest {
    public static let endpoint: Endpoint = "/tunnel/TerminateHello"

    public let api: NitroSSOAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      clientHeader: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(clientHeader: clientHeader)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var terminateHello: TerminateHello {
    TerminateHello(api: api)
  }
}

extension NitroSSOAPIClient.Tunnel.TerminateHello {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case clientHeader = "clientHeader"
    }

    public let clientHeader: String

    public init(clientHeader: String) {
      self.clientHeader = clientHeader
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(clientHeader, forKey: .clientHeader)
    }
  }
}

extension NitroSSOAPIClient.Tunnel.TerminateHello {
  public typealias Response = Empty?
}
