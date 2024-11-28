import Foundation

extension AppNitroEncryptionAPIClient.Tunnel {
  public struct ClientHello: APIRequest {
    public static let endpoint: Endpoint = "/tunnel/ClientHello"

    public let api: AppNitroEncryptionAPIClient

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

extension AppNitroEncryptionAPIClient.Tunnel.ClientHello {
  public struct Body: Codable, Equatable, Sendable {
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

extension AppNitroEncryptionAPIClient.Tunnel.ClientHello {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case attestation = "attestation"
      case tunnelUuid = "tunnelUuid"
    }

    public let attestation: String
    public let tunnelUuid: String

    public init(attestation: String, tunnelUuid: String) {
      self.attestation = attestation
      self.tunnelUuid = tunnelUuid
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(attestation, forKey: .attestation)
      try container.encode(tunnelUuid, forKey: .tunnelUuid)
    }
  }
}
