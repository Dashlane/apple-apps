import Foundation

extension NitroSSOAPIClient.Tunnel {
  public struct ClientHello: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/tunnel/ClientHello"

    public let api: NitroSSOAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(clientPublicKey: String, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(clientPublicKey: clientPublicKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var clientHello: ClientHello {
    ClientHello(api: api)
  }
}

extension NitroSSOAPIClient.Tunnel.ClientHello {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case clientPublicKey = "clientPublicKey"
    }

    public let clientPublicKey: String

    public init(clientPublicKey: String) {
      self.clientPublicKey = clientPublicKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(clientPublicKey, forKey: .clientPublicKey)
    }
  }
}

extension NitroSSOAPIClient.Tunnel.ClientHello {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case attestation = "attestation"
      case clientIdentifier = "clientIdentifier"
    }

    public let attestation: String
    public let clientIdentifier: String

    public init(attestation: String, clientIdentifier: String) {
      self.attestation = attestation
      self.clientIdentifier = clientIdentifier
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(attestation, forKey: .attestation)
      try container.encode(clientIdentifier, forKey: .clientIdentifier)
    }
  }
}
