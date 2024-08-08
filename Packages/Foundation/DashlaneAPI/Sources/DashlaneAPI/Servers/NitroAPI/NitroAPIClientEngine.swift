import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol NitroAPIClientEngine {
  func post<Response: Decodable, Body: Encodable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval?
  ) async throws -> Response
  func get<Response: Decodable>(
    _ endpoint: Endpoint,
    timeout: TimeInterval?
  ) async throws -> Response
}

public struct NitroAPIClientEngineImp: NitroAPIClientEngine {
  let session: URLSession
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()
  let configuration: NitroConfiguration

  public init(configuration: NitroConfiguration) throws {
    self.session = URLSession(configuration: .ephemeral)
    self.configuration = configuration
  }

  public func post<Response: Decodable, Body: Encodable>(
    _ endpoint: Endpoint, body: Body, timeout: TimeInterval?
  ) async throws -> Response {
    var urlRequest = URLRequest(
      endpoint: endpoint, timeoutInterval: timeout, configuration: configuration)
    try urlRequest.updateBody(body, using: encoder)
    return try await session.response(from: urlRequest, using: decoder)
  }

  public func get<Response: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval?) async throws
    -> Response
  {
    let urlRequest = URLRequest(endpoint: endpoint, configuration: configuration)
    return try await session.response(from: urlRequest, using: decoder)
  }
}
