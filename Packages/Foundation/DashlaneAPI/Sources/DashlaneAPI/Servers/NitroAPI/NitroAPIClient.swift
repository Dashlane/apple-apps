import Foundation

public typealias NitroConfiguration = RequestConfiguration<NitroAPIClient>

protocol NitroAPIClientProtocol {
  var engine: NitroAPIClientEngine { get }
}

extension NitroAPIClientProtocol {
  public func post<Response: Decodable, Body: Encodable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval?
  ) async throws -> Response {
    return try await engine.post(endpoint, body: body, timeout: timeout)
  }

  public func get<Response: Decodable>(
    _ endpoint: Endpoint,
    timeout: TimeInterval?
  ) async throws -> Response {
    return try await engine.get(endpoint, timeout: timeout)
  }
}

public struct NitroAPIClient: NitroAPIClientProtocol {
  let engine: NitroAPIClientEngine

  public init(configuration: NitroConfiguration) throws {
    self.engine = try NitroAPIClientEngineImp(configuration: configuration)
  }

  public init(engine: NitroAPIClientEngine) {
    self.engine = engine
  }
}

extension NitroAPIClient {
  public func makeNitroSecureAPIClient(secureTunnel: SecureTunnel) -> NitroSecureAPIClient {
    return NitroSecureAPIClient(engine: engine, secureTunnel: secureTunnel)
  }
}
