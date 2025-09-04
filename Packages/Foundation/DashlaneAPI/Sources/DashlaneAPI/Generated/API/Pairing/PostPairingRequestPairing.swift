import Foundation

extension UserDeviceAPIClient.Pairing {
  public struct RequestPairing: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/pairing/RequestPairing"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(pairingId: String? = nil, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(pairingId: pairingId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestPairing: RequestPairing {
    RequestPairing(api: api)
  }
}

extension UserDeviceAPIClient.Pairing.RequestPairing {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case pairingId = "pairingId"
    }

    public let pairingId: String?

    public init(pairingId: String? = nil) {
      self.pairingId = pairingId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(pairingId, forKey: .pairingId)
    }
  }
}

extension UserDeviceAPIClient.Pairing.RequestPairing {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case pairingId = "pairingId"
    }

    public let pairingId: String?

    public init(pairingId: String? = nil) {
      self.pairingId = pairingId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(pairingId, forKey: .pairingId)
    }
  }
}
